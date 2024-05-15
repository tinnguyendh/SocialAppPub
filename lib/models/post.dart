import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profImage;
  final likes;
  final comments;
  final imageList;
  final report;

  // construct
  const Post(
      {required this.description,
      required this.username,
      required this.uid,
      required this.postId,
      required this.datePublished,
      required this.postUrl,
      required this.profImage,
      required this.likes,
      required this.comments,
      required this.imageList,
      required this.report});

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        description: snapshot["description"],
        username: snapshot["username"],
        uid: snapshot["uid"],
        postId: snapshot["postId"],
        datePublished: snapshot["datePublished"],
        postUrl: snapshot["postUrl"],
        profImage: snapshot["profImage"],
        likes: snapshot["likes"],
        comments: snapshot["comments"],
        imageList: snapshot["imageList"],
        report: snapshot['report'],
        );
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "username": username,
        "uid": uid,
        "postId": postId,
        "datePublished": datePublished,
        "postUrl": postUrl,
        "profImage": profImage,
        "likes": likes,
        "comments": comments,
        "imageList": imageList,
        "report": report
      };
}
