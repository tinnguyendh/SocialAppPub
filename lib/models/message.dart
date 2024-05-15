import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String uid;
  final String type;

  final datePublished;

  // construct
  const Message({
    required this.text,
    required this.type,
    required this.uid,
    required this.datePublished,
  });

  static Message fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Message(
      text: snapshot["text"],
      uid: snapshot["sendby"],
      datePublished: snapshot["time"],
      type: snapshot["type"],
    );
  }

  Map<String, dynamic> toJson() => {
        "sendby": uid,
        "message": text,
        "type": type,
        "time": datePublished,
      };
}
