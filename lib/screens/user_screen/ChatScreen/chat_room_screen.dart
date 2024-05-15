import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/resources/storage_methods.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.userMap});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker picker = ImagePicker();
  Map<String, dynamic>? userMap;
  List<Map<String, dynamic>> chats = [];

  XFile? videoFile;
  Uint8List? _file;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchChats().then((chatsData) {
      setState(() {
        chats = chatsData;
      });
    });
    if (chats.length == chats.length + 1) {
      fetchChats().then((chatsData) {
        setState(() {
          chats = chatsData;
        });
      });
    }
  }

  Future getImage() async {
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
      uploadImage();
    });
  }

  void getInfo(String id) async {
    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: id)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  Future<List<Map<String, dynamic>>> fetchChats() async {
    List<Map<String, dynamic>> chatsData = [];

    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .orderBy('time', descending: false)
          .get();

      if (chatSnapshot.docs.isNotEmpty) {
        for (var commentDoc in chatSnapshot.docs) {
          var chatData = commentDoc.data() as Map<String, dynamic>;
          chatsData.add(chatData);
        }
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    return chatsData;
  }

  getMediaFile(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Choose photo'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                    uploadImage();
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Photo from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                    uploadImage();
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose Video from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? file =
                      await picker.pickVideo(source: ImageSource.gallery);
                  setState(() {
                    videoFile = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancel'),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.uid,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    fetchChats().then((chatsData) {
      setState(() {
        chats = chatsData;
      });
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putData(_file!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
      fetchChats().then((chatsData) {
        setState(() {
          chats = chatsData;
        });
      });
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  void onSendMessage() async {
    setState(() {
      isLoading = true;
    });
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.uid,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);

      setState(() {
        isLoading = false;
      });
    } else {
      print("Enter Some Text");
      setState(() {
        isLoading = false;
      });
    }
    fetchChats().then((chatsData) {
      setState(() {
        chats = chatsData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("users")
              .doc(widget.userMap['uid'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.userMap['photoUrl']),
                          radius: 14,
                        ),
                        Text(" " + widget.userMap['username']),
                      ],
                    ),
                    // Text(
                    //   snapshot.data!['status'],
                    //   style: TextStyle(fontSize: 14),
                    // ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body:
          // Container(
          //   margin: EdgeInsets.symmetric(
          //       horizontal: width > webScreenSize ? width * 0.3 : 0,
          //       vertical: width > webScreenSize ? 15 : 0),
          //   child: CustomScrollView(
          //     slivers: [
          //       SliverList(
          //           delegate: SliverChildBuilderDelegate(
          //         (context, index) {
          //           if (chats.length > index) {
          //             final chat = chats[index];
          //             getInfo(chat['sendby']);

          //             return Container(
          //               padding: const EdgeInsets.symmetric(
          //                   vertical: 18, horizontal: 16),
          //               child: InkWell(child: messages(size, chat, context)),
          //             );
          //           }
          //         },
          //         childCount: chats.length,
          //       )),
          //     ],
          //   ),
          // ),
          // bottomNavigationBar: SafeArea(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(
          //         horizontal: width > webScreenSize ? width * 0.3 : 0,
          //         vertical: width > webScreenSize ? 15 : 0),
          //     height: kToolbarHeight,
          //     // margin: EdgeInsets.only(
          //     //   bottom: MediaQuery.of(context).viewInsets.bottom,
          //     // ),
          //     padding: const EdgeInsets.only(left: 16),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: TextField(
          //             controller: _message,
          //             decoration: InputDecoration(
          //               suffixIcon: Container(
          //                 width: 100,
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.end,
          //                   children: [
          //                     IconButton(
          //                       icon: Icon(Icons.emoji_emotions),
          //                       onPressed: () {
          //                         setState(() {
          //                           EmojiSet().showEmojiPicker(context, _message);
          //                         });
          //                       },
          //                     ),
          //                     IconButton(
          //                       onPressed: () => getImage(),
          //                       icon: Icon(Icons.photo),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               hintText: "Send Message",
          //               border: OutlineInputBorder(
          //                 borderRadius: BorderRadius.circular(8),
          //               ),
          //             ),
          //           ),
          //         ),
          //         IconButton(
          //             icon: Icon(Icons.send),
          //             onPressed: () {
          //               onSendMessage();
          //             }),
          //       ],
          //     ),
          //   ),
          // ),
          SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: width > webScreenSize ? width * 0.3 : 0,
              vertical: width > webScreenSize ? 15 : 0),
          child: Column(
            children: [
              Container(
                height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messages(size, map, context);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            suffixIcon: Container(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.emoji_emotions),
                                    onPressed: () {
                                      setState(() {
                                        EmojiSet()
                                            .showEmojiPicker(context, _message);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () => getImage(),
                                    icon: Icon(Icons.photo),
                                  ),
                                ],
                              ),
                            ),
                            hintText: "Send Message",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: onSendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ?
        // isLoading
        //     ?  Center(
        //       child: Container(
        //         height: size.height / 20,
        //         width: size.height / 20,
        //         child: const CircularProgressIndicator(),
        //       ),
        //     ):
        Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: map['sendby'] == _auth.currentUser!.uid
                    ? Colors.blue
                    : Colors.blueGrey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    map['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    map['message'] != ""&& map['time'] != null
                        ? DateFormat.yMMMMd()
                            .add_jm()
                            .format((map['time'] as Timestamp).toDate())
                        : "Loading",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color.fromARGB(255, 190, 187, 187),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ))
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == _auth.currentUser!.uid
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 4,
                width: size.width / 4,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height / 5,
                              width: size.width / 4,
                              child: Image.network(
                                map['message'],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMMd()
                                  .add_jm()
                                  .format(map['time'].toDate()),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: const Text('Image'),
      ),
      body: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Download Image'),
                content: Text("Download Image"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Lấy comment mới từ _editCommentController.text và gọi hàm cập nhật

                      await StorageMethods().downloadImage(imageUrl, context);
                      Navigator.of(context).pop(); // Đóng dialog
                    },
                    child: const Text('Download'),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          height: size.height,
          width: size.width,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}

//
