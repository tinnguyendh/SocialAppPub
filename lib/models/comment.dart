import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String uid;
  final String username;
  final String comId;
    final String postId;

  final datePublished;
  final String profImage;
  final report;

  // construct
  const Comment(
      {required this.text,
      required this.username,
      required this.uid,
      required this.comId,
      required this.datePublished,
      required this.postId,
      required this.profImage,

      required this.report});

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Comment(
      text: snapshot["text"],
      username: snapshot["name"],
      uid: snapshot["uid"],
      comId: snapshot["commentId"],
      datePublished: snapshot["datePublished"],
      postId: snapshot["postId"],
      profImage: snapshot["profilePic"],
      report: snapshot['report'],
    );
  }

  Map<String, dynamic> toJson() => {
        'profilePic': profImage,
        'name': username,
        'uid': uid,
        'text': text,
        'commentId': comId,
        'postId': postId,
        'datePublished': datePublished,
        'report': [],
      };
}
