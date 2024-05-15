import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final bool gender;
  final String country;
  final List likedPost;
  final String role;

  // final List<Map<String, dynamic>> followingList;
  // final List<Map<String, dynamic>> followersList;

  // final String status;

  // construct
  const User({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.gender,
    required this.country,
    required this.likedPost,
    required this. role
    // required this.followersList,
    // required this.followingList

    // this.status = "Unavailable",
  });

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      followers: snapshot["followers"],
      following: snapshot["following"],
      gender: snapshot["gender"]?? false,
      country: snapshot["country"],
      likedPost: snapshot["likedPost"],
      role: snapshot['role']

      // followersList: snapshot["followersList"],
      // followingList: snapshot["followingList"],
      // status: snapshot["status"],
    );
  }

  // Phương thức tĩnh để chuyển đổi JSON thành đối tượng User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      gender: json['gender'],
      country: json['country'] ?? '',
      likedPost: List<String>.from(json['likedPost'] ?? []),
      role: json['role']
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
        "gender": gender,
        "country": country,
        "likedPost": likedPost,
        "role": role,
        // "status": status,
      };
}
