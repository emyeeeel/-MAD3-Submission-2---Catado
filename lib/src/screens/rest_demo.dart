//updated 6/20/24 at 7:41 PM
import 'package:flutter/cupertino.dart';
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
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Posts")),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              controller.getPosts();
            },
            icon: const Icon(Icons.refresh)),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                            showCupertinoModalPopup(
                                              context: context, 
                                              builder: (BuildContext context) {
                                                return CupertinoActionSheet(
                                                  actions: <CupertinoActionSheetAction>[
                                                    CupertinoActionSheetAction(
                                                      child: const Text('View Post Details'),
                                                      onPressed: () {
                                                        displayDetails(context, post.id, controller);
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: const Text('Edit Post'),
                                                      onPressed: () {
                                                        EditPost.show(context, postID: post.id, controller: controller); 
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: const Text('Delete Post'),
                                                      onPressed: () {
                                                        showCupertinoModalPopup(
                                                          context: context, 
                                                          builder: (BuildContext context) => CupertinoAlertDialog(
                                                          title: const Text('Are you sure you want to delete this post?'),
                                                          content: const Text('This will delete this post permanently. You cannot undo this action.'),
                                                          actions: <CupertinoDialogAction>[
                                                            CupertinoDialogAction(
                                                              isDefaultAction: true,
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Cancel'),
                                                            ),
                                                            CupertinoDialogAction(
                                                              isDestructiveAction: true,
                                                              onPressed: () async {
                                                                controller.deletePost(postId: post.id);
                                                                showDialog(
                                                                  context: context, 
                                                                  builder: (context) {
                                                                    return const Center(child: CircularProgressIndicator());
                                                                  }
                                                                ); 
                                                                await Future.delayed(const Duration(seconds: 2));
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                              },
                                                              child: const Text('Delete'),
                                                            ),
                                                          ],
                                                        ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                );
                                              }
                                            );
                                          },
                                          child: SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Row(
                                                  children: List.generate(3, (index) => const Icon(Icons.circle, size: 8,)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      width: 350,
                                      child: Text(post.body)
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

  //details
  void displayDetails(
      BuildContext context, int postId, PostController controller) {
    var posts = controller.getPostByIdLocally(postId);
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Post Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
              text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'UserId: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.black), 
                    ),
                    TextSpan(
                      text: '${posts.userId}',
                      style: const TextStyle(fontWeight: FontWeight.normal, color:  Colors.black), 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              RichText(
              text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Id: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.black), 
                    ),
                    TextSpan(
                      text: '${posts.id}',
                      style: const TextStyle(fontWeight: FontWeight.normal, color:  Colors.black), 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              RichText(
              text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Title: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.black), 
                    ),
                    TextSpan(
                      text: posts.title,
                      style: const TextStyle(fontWeight: FontWeight.normal, color:  Colors.black), 
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5,),
              RichText(
              text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Body: ',
                      style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.black), 
                    ),
                    TextSpan(
                      text: posts.body,
                      style: const TextStyle(fontWeight: FontWeight.normal, color:  Colors.black), 
                    ),
                  ],
                ),
              ),
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
  late TextEditingController bodyContent, titleContent;

  @override
  void initState() {
    super.initState();
    bodyContent = TextEditingController();
    titleContent = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: const Text("Add new post"),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (titleContent.text.trim().isEmpty || bodyContent.text.trim().isEmpty) {
              return widget.controller.showAlertIfEmpty(context);
            } else {
              await widget.controller.makePost(
                  title: titleContent.text.trim(),
                  body: bodyContent.text.trim(),
                  userId: 1);
              Navigator.pop(context);
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
              controller: titleContent,
            ),
          ),
          const Text("Content"),
          Flexible(
            child: TextFormField(
              controller: bodyContent,
            ),
          ),
        ],
      ),
    );
  }
}

//edit post
class EditPostDialog {
  static Future<void> show(
    BuildContext context, {
    required int postID,
    required PostController controller,
  }) async {
    late TextEditingController bodyContent, titleContent;

    bodyContent = TextEditingController();
    titleContent = TextEditingController();

    await showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: const Text("Edit Post"),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if (titleContent.text.trim().isEmpty || bodyContent.text.trim().isEmpty) {
                return controller.showAlertIfEmpty(context);
              } else {
                await controller.editPost(
                  postId: postID,
                  title: titleContent.text.trim(),
                  body: bodyContent.text.trim(),
                  userId: postID,
                );
              }

              Navigator.pop(context);
            },
            child: const Text("Edit"),
          )
        ],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New Title"),
            Flexible(
              child: TextFormField(
                controller: titleContent,
              ),
            ),
            const SizedBox(height: 30,),
            const Text("New Body Content"),
            Flexible(
              child: TextFormField(
                controller: bodyContent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditPost {
  static Future<void> show(
    BuildContext context, {
    required int postID,
    required PostController controller,
  }) async {
    late TextEditingController bodyContent, titleContent;

    bodyContent = TextEditingController();
    titleContent = TextEditingController();

    await showCupertinoDialog(
      context: context, 
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Post Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const Text('Title: '),
             const SizedBox(height: 5,),
             CupertinoTextField(
              placeholder: controller.getPostByIdLocally(postID).title,
              controller: titleContent,
             ),
             const SizedBox(height: 25,),
             const Text('Body: '),
             const SizedBox(height: 5,),
             CupertinoTextField(
              placeholder: controller.getPostByIdLocally(postID).body,
              maxLines: 10,
              controller: bodyContent,
             ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Confirm changes"),
              onPressed: () async {
                if (titleContent.text.trim().isEmpty && bodyContent.text.trim().isEmpty) {
                  return controller.showAlertIfEmpty(context);
                }else if(titleContent.text.trim().isEmpty){
                  showDialog(
                    context: context, 
                    builder: (context) {
                    return const Center(child: CircularProgressIndicator());
                    }
                  ); 
                  await controller.editPost(
                    postId: postID,
                    title: controller.getPostByIdLocally(postID).title,
                    body: bodyContent.text.trim(),
                    userId: controller.getPostByIdLocally(postID).userId,
                  );
                  Navigator.pop(context);
                }
                else if(bodyContent.text.trim().isEmpty){
                  showDialog(
                    context: context, 
                    builder: (context) {
                    return const Center(child: CircularProgressIndicator());
                    }
                  ); 
                  await controller.editPost(
                    postId: postID,
                    title: titleContent.text.trim(),
                    body: controller.getPostByIdLocally(postID).body,
                    userId: controller.getPostByIdLocally(postID).userId,
                  );
                  Navigator.pop(context);
                }  
                else {
                  showDialog(
                    context: context, 
                    builder: (context) {
                    return const Center(child: CircularProgressIndicator());
                    }
                  ); 
                  await controller.editPost(
                    postId: postID,
                    title: titleContent.text.trim(),
                    body: bodyContent.text.trim(),
                    userId: controller.getPostByIdLocally(postID).userId,
                  );
                  Navigator.pop(context);
                }
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }, 
              child: const Text("Cancel"),
            ),
          ],
      )
    );
  }
}