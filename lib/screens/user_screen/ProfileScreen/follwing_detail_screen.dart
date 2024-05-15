import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/utils/colors.dart';
import 'package:provider/provider.dart';

class FollowingUser extends StatefulWidget {
  final String currentUserId;

  FollowingUser({required this.currentUserId});

  @override
  _FollowingUserState createState() => _FollowingUserState();
}

class _FollowingUserState extends State<FollowingUser> {
  List<Map<String, dynamic>> following = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Bước 1: Lấy dữ liệu người dùng hiện tại từ Firestore
    getUserFollowing();
    setState(() {
      _isLoading = true;
    });
  }

  void getUserFollowing() async {
    // Bước 1: Lấy dữ liệu người dùng hiện tại từ Firestore
    final userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    if (userDocument.exists) {
      final userData = userDocument.data();
      if (userData != null && userData['following'] is List) {
        // Bước 2: Lấy danh sách UID của người đang theo dõi
        final followingUIDs = List<String>.from(userData['following']);

        // Bước 3: Lấy thông tin của người đang theo dõi từ collection "users"
        for (final uid in followingUIDs) {
          final followingDocument = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (followingDocument.exists) {
            final followingData = followingDocument.data();
            if (followingData != null) {
              // Thêm người đang theo dõi vào danh sách following
              following.add(followingData);
            }
          }
        }
        // Bước 4: Cập nhật trạng thái của widget để hiển thị danh sách người đang theo dõi
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: _isLoading
          ? Center(
              child: Container(
                child: CircularProgressIndicator(),
                width: 40,
                height: 40,
              ),
            )
          : ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final followingData = following[index];
                return followingData['uid'] == user.uid
                    ? ListTile(
                        tileColor: Color.fromARGB(255, 66, 96, 111),

                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(followingData['photoUrl']),
                        ),
                        title: Text(followingData['username']),
                        subtitle: Text(followingData['email']),
                        // Hiển thị các thông tin khác của người đang theo dõi
                        // ...
                      )
                    : ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(followingData['photoUrl']),
                        ),
                        title: Text(followingData['username']),
                        subtitle: Text(followingData['email']),
                        // Hiển thị các thông tin khác của người đang theo dõi
                        // ...
                      );
              },
            ),
    );
  }
}
