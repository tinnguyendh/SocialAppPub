import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';
import 'package:insta2/widgets/follow_button.dart';

class RecommendedUsers extends StatefulWidget {
  const RecommendedUsers({super.key});

  @override
  State<RecommendedUsers> createState() => _RecommendedUsersState();
}

class _RecommendedUsersState extends State<RecommendedUsers> {
  List<String> recommendedUserIds = [];
  bool isFollowing = false;
  String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchRecommendedUsers(uid);
  }

  Future<void> fetchRecommendedUsers(String? uid) async {
    final uri = Uri.parse('http://127.0.0.1:8083/get_recommend_user_uid');

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"uid": uid!}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> suggestedUsers = responseData['suggested_users'];
      setState(() {
        recommendedUserIds = List<String>.from(suggestedUsers);
      });
    } else {
      throw Exception('Failed to load recommended users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended Users'),
      ),
      body: recommendedUserIds.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recommendedUserIds.length,
              itemBuilder: (context, index) {
                final userId = recommendedUserIds[index];
                // return ListTile(
                //   leading: CircleAvatar(
                //     backgroundImage: NetworkImage(

                //     ),
                //   ),
                //   title: Text(
                //       '$userId'), // Replace with actual user information
                //   // Add onTap to navigate to user profile page or perform other actions
                // );
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('User not found');
                    } else {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final String username = userData['username'] ?? 'Unknown';
                      final String photoUrl = userData['photoUrl'] ??
                          ''; // Provide a default photoUrl if not available
                      final String email = userData['email'];
                      final currentUid = FirebaseAuth.instance.currentUser!.uid;
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    uid: userData['uid'], membersList: []))),
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(photoUrl),
                            ),
                            title: Text(username),
                            subtitle: Text(email),
                            trailing:
                                // InkWell(
                                //   onTap: () =>  FirestoreMethods().followUser(currentUid, userData['uid']),
                                //   child: Icon(Icons.person_add)),
                                !isFollowing
                                    ? FollowButon(
                                        backgroundColor: Colors.blue,
                                        borderColor: Colors.blue,
                                        text: 'Follow',
                                        textColor: Colors.black,
                                        function: () async {
                                          await FirestoreMethods().followUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['uid']);
                                          // removeMembers;
                                          setState(() {
                                            isFollowing = true;
                                          });
                                        },
                                      )
                                    : FollowButon(
                                        backgroundColor: Colors.white,
                                        borderColor: Colors.grey,
                                        text: 'UnFollow',
                                        textColor: Colors.white,
                                        function: () async {
                                          await FirestoreMethods().followUser(
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['uid']);
                                          // onAddMembers;
                                        },
                                      )
                            // Add onTap to navigate to user profile page or perform other actions
                            ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RecommendedUsers(),
  ));
}
