import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/models/post.dart';
import 'package:insta2/resources/storage_methods.dart';
import 'package:insta2/screens/user_screen/PostScreen/add_post_screen.dart';
import 'package:insta2/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('post', file, true);

      String postId = const Uuid().v1();

      Post post = Post(
          description: description,
          username: username,
          uid: uid,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profImage: profImage,
          likes: [],
          comments: [],
          imageList: [],
          report: []);

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );

      _firestore.collection('notification').doc(postId).set({
        'uid': uid,
        'notifiId': postId,
        'username': username,
        'title': username + " add a new post",
      });

      addNotificationForFollowers(uid, postId, username + " add a new post", profImage);
      

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadPostMulti(
    String description,
    List<XFile> files, // Sử dụng danh sách Uint8List cho nhiều ảnh
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    try {
      List<String> postUrls =
          await StorageMethods().uploadMultiImages('post', files, true);

      String postId = const Uuid().v1();

      Post post = Post(
          description: description,
          username: username,
          uid: uid,
          postId: postId,
          datePublished: DateTime.now(),
          postUrl:
              postUrls.isNotEmpty ? postUrls[0] : '', // Lấy URL ảnh đầu tiên
          profImage: profImage,
          likes: [],
          comments: [],
          report: [],
          imageList: postUrls); // Sử dụng danh sách URL ảnh

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );

      _firestore.collection('notification').doc(postId).set({
        'uid': uid,
        'notifiId': postId,
        'username': username,
        'title': username + " add a new post",
      });

      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Future<String> uploadImess(
  //   Uint8List file,
  //   String uid,
  //   String username,
  //   String profImage,
  // ) async {
  //   String res = "Some error occurred";
  //   try {
  //     String photoUrl =
  //         await StorageMethods().uploadImageToStorage('images', file, true);

  //     String chatRoomId = const Uuid().v1();
  //     String chatId = const Uuid().v1();

  //     _firestore
  //         .collection('chatroom')
  //         .doc(chatRoomId)
  //         .collection('chats')
  //         .doc(chatId)
  //         .set({
  //       "sendby": _auth.currentUser!.uid,
  //       "message": photoUrl,
  //       "type": "img",
  //       "time": FieldValue.serverTimestamp(),
  //     });
  //     res = "success";
  //   } catch (e) {
  //     res = e.toString();
  //   }
  //   return res;
  // }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> reportPost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'report': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'report': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> reportComment(String comId, String uid, List likes) async {
    try {
      DocumentReference commentRef =
          _firestore.collection('comments').doc(comId);

      // Lấy dữ liệu hiện tại của comment
      DocumentSnapshot commentSnapshot = await commentRef.get();
      Map<String, dynamic>? commentData =
          commentSnapshot.data() as Map<String, dynamic>?;

      // Kiểm tra xem uid đã có trong mảng 'report' hay chưa
      bool isReported = commentData?['report']?.contains(uid) ?? false;

      // Nếu uid đã được báo cáo, loại bỏ nó khỏi mảng
      if (isReported) {
        await commentRef.update({
          'report': FieldValue.arrayRemove([uid]),
        });
      } else {
        // Nếu uid chưa được báo cáo, thêm nó vào mảng
        await commentRef.update({
          'report': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic, List comments) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        // _firestore
        //     .collection('posts')
        //     .doc(postId)
        //     .collection('comments')
        //     .doc(commentId)
        //     .set({
        //   'profilePic': profilePic,
        //   'name': name,
        //   'uid': uid,
        //   'text': text,
        //   'commentId': commentId,
        //   'datePublished': DateTime.now(),
        //   'report': [],
        // });

        _firestore.collection('comments').doc(commentId).set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'postId': postId,
          'datePublished': DateTime.now(),
          'report': [],
        });

        if (!comments.contains(commentId)) {
          await _firestore.collection('posts').doc(postId).update({
            'comments': FieldValue.arrayUnion([commentId]),
          });
        }
      } else {
        print('text is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId, String photoUrl) async {
    try {
      await StorageMethods().deleteImageFromStorage(photoUrl);

      await _firestore.collection('posts').doc(postId).delete();
      await _firestore.collection('notification').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteComment(String postId, String comId, List comments) async {
    try {
      if (comments.contains(comId)) {
        await _firestore.collection('posts').doc(postId).update({
          'comments': FieldValue.arrayRemove([comId]),
        });
      }

      await _firestore.collection('comments').doc(comId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> updatePost(String postId, Uint8List file, String des) async {
    String res = "Some error occurred";
    DocumentSnapshot postSnapshot =
        await _firestore.collection('posts').doc(postId).get();
    Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;
    String oldPhotoUrl = postData['postUrl'];
    String photoUrl =
        await StorageMethods().uploadImageToStorage('post', file, true);

    try {
      if (file.isNotEmpty && des.isEmpty) {
        if (oldPhotoUrl.isNotEmpty) {
          await StorageMethods().deleteImageFromStorage(oldPhotoUrl);
          await _firestore.collection('posts').doc(postId).update({
            // 'description': des,
            'postUrl': photoUrl,
          });
        }
        res = "success";
      } else if (file.isNotEmpty && des.isNotEmpty) {
        if (oldPhotoUrl.isNotEmpty) {
          await StorageMethods().deleteImageFromStorage(oldPhotoUrl);
          await _firestore.collection('posts').doc(postId).update({
            'description': des,
            'postUrl': photoUrl,
          });
        }

        res = "success";
      } else if (file.isEmpty && des.isEmpty) {
        print('No image and No description');
        res = "No image and No description";
      } else if (file.isEmpty && des.isNotEmpty) {
        await _firestore.collection('posts').doc(postId).update({
          'description': des,
          // 'postUrl': photoUrl,
        });
        res = "success";
      }
    } catch (e) {
      res = e.toString();
      print(res);
    }
    return res;
  }

  Future<String> updateComment(
      String postId, String comId, String comment) async {
    String res = "Some error occurred";

    try {
      if (comment.isNotEmpty) {
        var commentRef = _firestore.collection('comments').doc(comId);

        await commentRef.update({
          // 'description': des,
          'text': comment,
        });
        res = "success";
      }
    } catch (e) {
      res = e.toString();
      print(res);
    }
    return res;
  }

  Future<void> updateProfile(
    String uid,
    String username,
    String bio,
    // String photoUrl
  ) async {
    User currentUser = _auth.currentUser!;
    // var userSnap = await FirebaseFirestore.instance
    //     .collection('posts')
    //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //     .get();
    try {
      if (username.isNotEmpty && bio.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(
          {
            'username': username, 'bio': bio,
            // 'photoUrl': photoUrl
          },
        );
        await currentUser.updateDisplayName(username);
      } else if (username.isEmpty && bio.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(
          {
            'bio': bio,
            // 'photoUrl': photoUrl
          },
        );
      } else if (username.isNotEmpty && bio.isEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(
          {
            'username': username,
            // 'photoUrl': photoUrl
          },
        );
        await currentUser.updateDisplayName(username);
      } else {
        print('name or bio is empty');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateAvatar(
    String uid,
    Uint8List file,
    // String photoUrl
  ) async {
    User currentUser = _auth.currentUser!;
    // var userSnap = await FirebaseFirestore.instance
    //     .collection('posts')
    //     .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //     .get();
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', file, true);

      if (file.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser.uid).update(
          {
            'photoUrl': photoUrl,
          },
        );
        // await _firestore
        //     .collection('posts')
        //     .where("uid", isEqualTo: currentUser.uid)
        //     .get()
        //     .then((value) {
        //   _firestore.collection('posts').doc('uid').update({
        //     'profImage': photoUrl,
        //   });
        // });

        await currentUser.updatePhotoURL(photoUrl);
      } else {
        print('No image');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> addNotification(
      String uid, String postId, String content, String profImage) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(uid)
        .collection('userNotifications')
        .add({
      'postId': postId,
      'content': content,
      'image': profImage,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false, // Đánh dấu đã đọc hay chưa
    });
  }
    Future<void> addNotificationForFollowers(String currentUserId, String postId, String content, String profImage) async {
  // Lấy danh sách người theo dõi từ trường 'followers' của user hiện tại
  var followersSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
  var followers = followersSnapshot.data()?['followers'] as List<String>?;

  if (followers != null) {
    // Thêm thông báo cho mỗi người theo dõi
    for (var followerUid in followers) {
      await FirestoreMethods().addNotification(followerUid, postId, content, profImage);
    }
  }
}

  Future<void> followUserMap(String uid, String followId) async {
    List<Map<String, dynamic>> membersList = [];

    try {
      //   await _firestore
      //     .collection('users')
      //     .doc(_auth.currentUser!.uid)
      //     .get()
      //     .then((map) {
      //   setState(() {
      //     membersList.add({
      //       "username": map['username'],
      //       "email": map['email'],
      //       "uid": map['uid'],
      //       "isAdmin": true,
      //       "photoUrl": map['photoUrl'],
      //     });
      //   });
      // });
    } catch (e) {
      print(e.toString());
    }
  }
}
