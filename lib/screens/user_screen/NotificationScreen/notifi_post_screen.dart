import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:insta2/screens/group_chats/group_chat_screen.dart';
import 'package:insta2/screens/user_screen/ChatScreen/chat_room_screen.dart';
import 'package:insta2/screens/user_screen/CommentScreen/comments_load_screen.dart';

import 'package:insta2/screens/user_screen/ChatScreen/home_chat_screen.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';

class NotifiScreen extends StatefulWidget {
  const NotifiScreen({Key? key}) : super(key: key);
  @override
  State<NotifiScreen> createState() => _NotifiScreenState();
}

class _NotifiScreenState extends State<NotifiScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  Map<String, dynamic>? postMap;

  bool isLoading = false;
  bool isSeen = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? token = '';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  final _userStream = FirebaseFirestore.instance
      .collection('notification')
      .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
    requestPermisson();
    getToken();
    configureFirebaseMessaging();
    WidgetsBinding.instance.addObserver(this);

    // setStatus("Online");
  }

  //   void getInfo() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   await FirebaseFirestore.instance
  //       .collection('posts')
  //       .where('postId', isEqualTo: widget.snap['notifiId'])
  //       .get()
  //       .then((value) {
  //     setState(() {
  //       userMap = value.docs[0].data();
  //       isLoading = false;
  //     });
  //     print(userMap);
  //   });
  // }

  void requestPermisson() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permisson');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user granted provisional permisson');
    } else {
      print('declined or not apccepted permission');
    }
  }

  void getToken() async {
    // token = await firebaseMessaging.getToken();
    firebaseMessaging.getToken().then((tokenvalue) {
      setState(() {
        token = tokenvalue;
        print('my token: $token');
      });
    });
  }

  void configureFirebaseMessaging() {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: ${message.data}");
      //_showItemDialog(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: ${message.data}");
      //_navigateToItemDetail(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_myBackgroundMessageHandler);
  }

  Future<void> _myBackgroundMessageHandler(RemoteMessage message) async {
    print("onLaunch: ${message.data}");
    //_navigateToItemDetail(message.data);
  }

  Future<void> sendDevices() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notification')
        .doc('id')
        .get();

    final name = snapshot.get('name');
    final subject = snapshot.get('subject');
    final token = snapshot.get('token');

    final payload = <String, dynamic>{
      'notification': {
        'title': 'from $name',
        'body': 'subject $subject',
        'sound': 'default',
      },
    };

    try {
      final response =
          await functions.httpsCallable('senddevices').call(payload);
      print('Notification sent successfully');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;

    return isLoading
        ? Center(
            child: Container(
              height: size.height / 20,
              width: size.height / 20,
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    backgroundColor: width > webScreenSize
                        ? webBackgroundColor
                        : mobileBackgroundColor,
                    title: const Text("Notification"),
                    
                  ),
            body: StreamBuilder(
                // future: FirebaseFirestore.instance
                //     .collection('users')
                //     .where('uid',
                //         isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                //     .get(),

                stream: _userStream,
                builder: ((context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Connection Error');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: (context, index) => Container(
                            margin: EdgeInsets.symmetric(
                                horizontal:
                                    width > webScreenSize ? width * 0.3 : 0,
                                vertical: width > webScreenSize ? 15 : 0),
                            child: ListTile(
                              onTap: () async {
                                setState(() {
                                  isSeen = true;
                                });
                                await _firestore
                                    .collection('posts')
                                    .where("postId",
                                        isEqualTo: (snapshot.data! as dynamic)
                                            .docs[index]['notifiId'])
                                    .get()
                                    .then((QuerySnapshot querySnapshot) {
                                  if (querySnapshot.docs.isNotEmpty) {
                                    final postMap = querySnapshot.docs[0].data()
                                        as Map<String, dynamic>;
                                    print(postMap);

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CommentsLoadScreen(
                                          postId: postMap['postId'],
                                          snap: postMap,
                                        ),
                                      ),
                                    );
                                  } else {
                                    print('Post not found');
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Post is not available'),
                                            content: Text(
                                                "The post has been deleted or is unavailable at this time"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Đóng dialog
                                                },
                                                child: const Text('Ok'),
                                              ),
                                            ],
                                          );
                                        });
                                  }
                                });
                              },
                              leading: Icon(Icons.notification_add_outlined),
                              title: Text((snapshot.data! as dynamic)
                                  .docs[index]['username']),
                              subtitle: Text((snapshot.data! as dynamic)
                                  .docs[index]['title']),
                            ),
                          ));
                })),
          );
  }
}
