import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? token = '';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;

  @override
  void initState() {
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   if (notification != null) {
    //     print('Message also contained a notification: $notification');
    //   }
    //   print("onMessage: $message");
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print("onLaunch/onResume: $message");
    // });

    super.initState();
    requestPermisson();
    getToken();
    configureFirebaseMessaging();
  }

  void getToken() async {
    // token = await firebaseMessaging.getToken();
    firebaseMessaging.getToken().then((tokenvalue) {
      setState(() {
        token = tokenvalue;
        print('my token: $token');
      });
      savetoken(tokenvalue!);
    });
  }

  void savetoken(String token) async {
    await FirebaseFirestore.instance.collection('Tokens').doc('user123').set({
      'token': token,
    });
  }

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
    return Scaffold(
      body: Center(child: Text("Token : " + token!)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getToken();
          print(token);
        },
        child: Icon(Icons.print),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationScreen extends StatefulWidget {
//   @override
//   _NotificationScreenState createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   List<Map<String, dynamic>> userData = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchNotifications();
//   }

//   Future<void> fetchNotifications() async {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
    
//     final String currentUserId = currentUser.uid;

//     final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
//         .collection('posts')
//         .where('uid', isEqualTo: currentUserId)
//         .get();

//     final List<Future<Map<String, dynamic>?>> userPromises = [];

//     querySnapshot.docs.forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//       final postData = doc.data();
//       final likesMap = postData['likes'] as Map<String, dynamic>? ?? {};
//       final userIds = likesMap.values.toList();

//       userIds.forEach((userId) {
//         final userPromise = FirebaseFirestore.instance
//             .collection('users')
//             .doc(userId)
//             .get()
//             .then((DocumentSnapshot<Map<String, dynamic>> userDoc) {
//           if (userDoc.exists) {
//             final userData = userDoc.data();
//             return {
//               'postId': doc.id,
//               'username': userData!['username'],
//               'email': userData['email'],
//               'uid': userData['uid'],
//               'datePublished': postData['datePublished'], // Assuming you have a 'time' field in the 'MoreNews' collection
//             };
//           }
//           return null;
//         });
//         userPromises.add(userPromise);
//       });
//     });

//     final results = await Future.wait(userPromises);
//     final filteredUserData = results.where((user) => user != null).toList();
//     // filteredUserData.sort((a, b) => b!['datePublished'].compareTo(a!['time']));
//     setState(() {
//       userData = filteredUserData.cast<Map<String, dynamic>>();
//     });
//     print("print user data 1344 3523 525 3 523324$userData");
//   }

//   // void handleCommentPress(String postID) {
//   //   Navigator.pushNamed(context, '/comment', arguments: postID);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//       ),
//       body: ListView.builder(
//         itemCount: userData.length,
//         itemBuilder: (context, index) {
//           final item = userData[index];
//           return Card(
//             child: ListTile(
//               title: Text('${item['username']} đã yêu thích bài viết của bạn'),
//               subtitle: Text('Email: ${item['email']}'),
//               onTap: () {},
//             ),
//           );
//         },
//       ),
//     );
//   }
// }