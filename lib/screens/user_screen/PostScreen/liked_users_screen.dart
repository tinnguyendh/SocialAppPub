import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikedUserScreen extends StatefulWidget {
  final String postId;
  LikedUserScreen({required this.postId});

  @override
  _LikedUserScreenState createState() => _LikedUserScreenState();
}

class _LikedUserScreenState extends State<LikedUserScreen> {
  List<String> likedUserIds = [];
  List<Map<String, dynamic>> likedUsersData = [];

  @override
  void initState() {
    super.initState();
    // Bước 1: Lấy dữ liệu bài đăng cụ thể từ collection 'posts'
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get()
        .then((postSnapshot) {
      if (postSnapshot.exists) {
        // Bước 2: Truy xuất danh sách UID từ trường 'likes'
        likedUserIds = List<String>.from(postSnapshot.data()!['likes']);
        // Bước 3: Truy xuất danh sách người dùng từ collection 'users'
        likedUserIds.forEach((userId) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get()
              .then((userSnapshot) {
            if (userSnapshot.exists) {
              final userData = userSnapshot.data();

              if (userData != null) {
                likedUsersData.add(userData);
                // Sử dụng setState để cập nhật danh sách người dùng
                setState(() {});
              } // Sử dụng setState để cập nhật danh sách người dùng
              setState(() {});
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Users'),
      ),
      body: likedUsersData.isNotEmpty
          ? ListView.builder(
              itemCount: likedUsersData.length,
              itemBuilder: (context, index) {
                final user = likedUsersData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['photoUrl']),
                  ),
                  title: Text(user['username']),
                  subtitle: Text(user['email']),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
