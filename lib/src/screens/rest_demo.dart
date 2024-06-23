//updated 6/20/24 at 7:41 PM
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:state_change_demo/src/models/post.model.dart';

import '../controllers/post_controller.dart';

class RestDemoScreen extends StatefulWidget {
  const RestDemoScreen({super.key});

  @override
  State<RestDemoScreen> createState() => _RestDemoScreenState();
}

class _RestDemoScreenState extends State<RestDemoScreen> {
  PostController controller = PostController();

  @override
  void initState() {
    super.initState();
    controller.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posts"),
        leading: IconButton(
            onPressed: () {
              controller.getPosts();
            },
            icon: const Icon(Icons.refresh)),
        actions: [
          IconButton(
              onPressed: () {
                showNewPostFunction(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.error != null) {
                return Center(
                  child: Text(controller.error.toString()),
                );
              }

              if (!controller.working) {
                return Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (Post post in controller.postList)
                            Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.only(bottom: 8),
                                width: 450,
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundImage: NetworkImage('https://th.bing.com/th/id/OIP.1ysuWzMkrR4WxUAL3jfWEwAAAA?rs=1&pid=ImgDetMain'),
                                        ),
                                        const SizedBox(width: 10,),
                                        Text("@user${post.userId}"),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            showConfirmationDialog(context, post.id, controller);
                                          },
                                          child: Row(
                                                children: List.generate(3, (index) => const Icon(Icons.circle, size: 8,)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Center(child: Text(post.body, textAlign: TextAlign.justify,)),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 190),
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                EditPostDialog.show(context,
                                                    postID: post.id,
                                                    controller: controller);
                                              },
                                              icon: const Icon(Icons.edit)),
                                          IconButton(
                                              onPressed: () {
                                                controller.deletePost(
                                                    postId: post.id);
                                              },
                                              icon: const Icon(Icons.delete)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ))
                        ],
                      )),
                );
              }
              return const Center(
                child: SpinKitChasingDots(
                  size: 54,
                  color: Colors.black87,
                ),
              );
            }),
      ),
    );
  }

  showNewPostFunction(BuildContext context) {
    AddPostDialog.show(context, controller: controller);
  }
  
  //details cards
  void showConfirmationDialog(
      BuildContext context, int postId, PostController controller) {
    var posts = controller.getPostByIdLocally(postId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Post Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("UserId: ${posts.userId}\n"),
              Text("Id: ${posts.id}\n"),
              Text("Title: ${posts.title}\n"),
              Text("Body: ${posts.body}\n"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddPostDialog extends StatefulWidget {
  static show(BuildContext context, {required PostController controller}) =>
      showDialog(
          context: context, builder: (dContext) => AddPostDialog(controller));
  const AddPostDialog(this.controller, {super.key});

  final PostController controller;

  @override
  State<AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<AddPostDialog> {
  late TextEditingController bodyC, titleC;

  @override
  void initState() {
    super.initState();
    bodyC = TextEditingController();
    titleC = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text("Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty) {
              return widget.controller.showAlertIfEmpty(context);
            } else {
              await widget.controller.makePost(
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: 1);
              Navigator.of(context).pop();
            }
          },
          child: const Text("Add"),
        )
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Title"),
          Flexible(
            child: TextFormField(
              controller: titleC,
            ),
          ),
          const Text("Content"),
          Flexible(
            child: TextFormField(
              controller: bodyC,
            ),
          ),
        ],
      ),
    );
  }
}

//dialog for the edit post
class EditPostDialog {
  static Future<void> show(
    BuildContext context, {
    required int postID,
    required PostController controller,
  }) async {
    late TextEditingController bodyC, titleC;

    bodyC = TextEditingController();
    titleC = TextEditingController();

    await showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: const Text("Edit Post"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (titleC.text.trim().isEmpty || bodyC.text.trim().isEmpty) {
                return controller.showAlertIfEmpty(context);
              } else {
                await controller.editPost(
                  postId: postID,
                  title: titleC.text.trim(),
                  body: bodyC.text.trim(),
                  userId: postID,
                );
              }

              Navigator.of(context).pop();
            },
            child: const Text("Edit"),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title"),
            Flexible(
              child: TextFormField(
                controller: titleC,
              ),
            ),
            const Text("Content"),
            Flexible(
              child: TextFormField(
                controller: bodyC,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

