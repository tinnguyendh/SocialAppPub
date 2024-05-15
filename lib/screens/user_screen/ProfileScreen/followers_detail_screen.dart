import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/utils/colors.dart';
import 'package:provider/provider.dart';

class FollowerUser extends StatefulWidget {
  final String currentUserId;

  FollowerUser({required this.currentUserId});

  @override
  _FollowerUserState createState() => _FollowerUserState();
}

class _FollowerUserState extends State<FollowerUser> {
  List<Map<String, dynamic>> followers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Bước 1: Lấy dữ liệu người dùng hiện tại từ Firestore
    getUserFollowers();
    setState(() {
      _isLoading = true;
    });
  }

  void getUserFollowers() async {
    //  Lấy dữ liệu người dùng hiện tại từ Firestore
    final userDocument = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    if (userDocument.exists) {
      final userData = userDocument.data();
      if (userData != null && userData['followers'] is List) {
        // Lấy danh sách UID của người theo dõi
        final followerUIDs = List<String>.from(userData['followers']);

        //  Lấy thông tin của người theo dõi từ collection "users"
        for (final uid in followerUIDs) {
          final followerDocument = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (followerDocument.exists) {
            final followerData = followerDocument.data();
            if (followerData != null) {
              // Thêm người theo dõi vào danh sách followers
              followers.add(followerData);
            }
          }
        }
        //  Cập nhật trạng thái của widget để hiển thị danh sách người theo dõi
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
        backgroundColor: mobileBackgroundColor,
        title: const Text('Followers'),
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
              itemCount: followers.length,
              itemBuilder: (context, index) {
                final followerData = followers[index];
                return followerData['uid'] == user.uid?
                 ListTile(
                  tileColor: Color.fromARGB(255, 66, 96, 111),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(followerData['photoUrl']),
                  ),
                  title: Text(followerData['username']),
                  subtitle: Text(followerData['email']),
                  // Hiển thị các thông tin khác của người theo dõi
                  // ...
                ) :
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(followerData['photoUrl']),
                  ),
                  title: Text(followerData['username']),
                  subtitle: Text(followerData['email']),
                  // Hiển thị các thông tin khác của người theo dõi
                  // ...
                );
              },
            ),
    );
  }
}
