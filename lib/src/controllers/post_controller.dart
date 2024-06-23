import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/post.model.dart';
import '../services/http.dart';

class PostController with ChangeNotifier {
  Map<String, dynamic> posts = {};
  bool working = true;
  Object? error;

  List<Post> get postList => posts.values.whereType<Post>().toList();

  clear() {
    error = null;
    posts = {};
    notifyListeners();
  }

  Post getPostByIdLocally(int postId) {
    return posts[postId.toString()];
  }

  Future<void> showAlertIfEmpty(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validation Error'),
          content: const Text('Please input all fields'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  //to generate random ID
  int generateUniqueId() {
    Random random = Random();
    int id = random.nextInt(1000000);
    return id;
  }

  Future<Post> makePost(
      {required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      print(title);
      print(body);
      print(userId);
      http.Response res = await HttpService.post(
          url: "https://jsonplaceholder.typicode.com/posts",
          body: {"title": title, "body": body, "userId": userId});
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      int randomId = generateUniqueId();

      while (posts.containsKey(randomId.toString())) {
        randomId = generateUniqueId();
      }
      Post madePost =
          Post(id: randomId, body: body, userId: randomId, title: title);

      posts[randomId.toString()] = madePost;
      working = false;
      notifyListeners();
      return madePost;
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
      return Post.empty;
    }
  }

  Future<Post> getPostById(int postId) async {
    http.Response res = await http
        .get(Uri.parse("https://jsonplaceholder.typicode.com/posts/$postId"));
    if (res.statusCode != 200 && res.statusCode != 201) {
      if (posts.containsKey(postId.toString())) {
        return posts[postId.toString()];
      }
      throw Exception("${res.statusCode} | ${res.body}");
    }
    var result = jsonDecode(res.body);
    return Post.fromJson(result);
  }

  Future<void> getPosts() async {
    try {
      working = true;
      clear();
      List result = [];
      http.Response res = await HttpService.get(
          url: "https://jsonplaceholder.typicode.com/posts");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      result = jsonDecode(res.body);

      List<Post> tmpPost = result.map((e) => Post.fromJson(e)).toList();
      posts = {for (Post p in tmpPost) "${p.id}": p};
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  Future<void> getPostsIndi(int postId) async {
    try {
      working = true;
      clear();
      http.Response res = await HttpService.get(
          url:
              "https://jsonplaceholder.typicode.com/posts/$postId"); 
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }
      var result = jsonDecode(res.body);

      List<Post> tmpPost = [Post.fromJson(result)];
      posts = {for (Post p in tmpPost) "${p.id}": p};

      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  //delete post
  Future<void> deletePost({required int postId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.delete(
          url: "https://jsonplaceholder.typicode.com/posts/$postId");
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception("${res.statusCode} | ${res.body}");
      }

      if (posts.containsKey(postId.toString())) {
        posts.remove(postId.toString());
      }
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }

  //edit post
  Future<void> editPost(
      {required int postId,
      required String title,
      required String body,
      required int userId}) async {
    try {
      working = true;
      if (error != null) error = null;
      http.Response res = await HttpService.put(
          url: "https://jsonplaceholder.typicode.com/posts/$postId",
          body: {"title": title, "body": body, "userId": userId});

      if (res.statusCode != 200 && res.statusCode != 201) {
        if (!posts.containsKey(postId.toString())) {
          throw Exception("${res.statusCode} | ${res.body}");
        }
      }

      Post newEditedPost =
          Post(id: postId, body: body, userId: userId, title: title);
      posts[postId.toString()] = newEditedPost;
      working = false;
      notifyListeners();
    } catch (e, st) {
      print(e);
      print(st);
      error = e;
      working = false;
      notifyListeners();
    }
  }
}


