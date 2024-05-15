import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/screens/group_chats/group_chat_screen.dart';
import 'package:insta2/screens/user_screen/ChatScreen/chat_room_screen.dart';

import 'package:insta2/screens/user_screen/ChatScreen/home_chat_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';

class HomeChatMainScreen extends StatefulWidget {
  const HomeChatMainScreen({Key? key}) : super(key: key);
  @override
  State<HomeChatMainScreen> createState() => _HomeChatMainScreenState();
}

class _HomeChatMainScreenState extends State<HomeChatMainScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  Map<String, dynamic>? allUserMap;

  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userStream = FirebaseFirestore.instance
      .collection('users')
      .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // setStatus("Online");
  }

  String chatRoomId(String user1, String user2) {
    // Nếu mã Unicode của ký tự đầu tiên của user1 lớn hơn user2,
    // thì sắp xếp theo thứ tự user1-user2
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
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
            appBar: AppBar(
              title: const Text("Chat Screen"),
              backgroundColor: mobileBackgroundColor,
              actions: [
                IconButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search))
              ],
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
                                await _firestore
                                    .collection('users')
                                    .where("uid",
                                        isEqualTo: (snapshot.data! as dynamic)
                                            .docs[index]['uid'])
                                    .get()
                                    .then((value) {
                                  setState(() {
                                    userMap = value.docs[0].data();
                                    isLoading = false;
                                  });
                                  print(userMap);
                                });
                                String roomId = chatRoomId(
                                    _auth.currentUser!.uid, userMap!['uid']);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      userMap: userMap!,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    (snapshot.data! as dynamic).docs[index]
                                        ['photoUrl']),
                              ),
                              title: Text((snapshot.data! as dynamic)
                                  .docs[index]['username']),
                              subtitle: Text((snapshot.data! as dynamic)
                                  .docs[index]['email']),
                              trailing: const Icon(Icons.chat_outlined),
                            ),
                          ));
                })),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.group),
              backgroundColor: primaryColor,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GroupChatHomeScreen(),
                ),
              ),
            ),
          );
  }
}
