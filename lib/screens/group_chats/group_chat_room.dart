import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/screens/group_chats/group_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:insta2/screens/user_screen/ChatScreen/chat_room_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName;

  GroupChatRoom({required this.groupName, required this.groupChatId, Key? key})
      : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Uint8List? _file;
  bool isLoading = false;
  bool _isEmojiPickerVisible = false;

  Future getImage() async {
    Uint8List file = await pickImage(ImageSource.gallery);
    setState(() {
      _file = file;
      uploadImage();
    });
  }

  void _showEmojiPicker(BuildContext context) {
    _isEmojiPickerVisible
        ? showModalBottomSheet(
            context: context,
            builder: (context) {
              return EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  if (emoji != null) {
                    _message.text = _message.text + emoji.emoji;
                  }
                },
              );
            },
          )
        : SizedBox();
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.uid,
      "message": "",
      "displayname": _auth.currentUser!.displayName,
      "photoUrl": _auth.currentUser!.photoURL,
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('imgMessGroup')
        .child("$fileName.jpg");

    var uploadTask = await ref.putData(_file!).catchError((error) async {
      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  void onSendMessage() async {
    setState(() {
      isLoading = true;
    });
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": _auth.currentUser!.uid,
        "displayname": _auth.currentUser!.displayName,
        "photoUrl": _auth.currentUser!.photoURL,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: RichText(
            text: TextSpan(children: [
          TextSpan(
            text: widget.groupName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          const TextSpan(
              text: " (Group)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 17,
              )),
        ])),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupInfo(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                      ),
                    ),
                  ),
              icon: Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
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
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;

                          return messageTile(size, chatMap);
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

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: const CircularProgressIndicator(),
                ),
              )
            : Container(
                width: size.width,
                alignment: chatMap['sendBy'] == _auth.currentUser!.uid
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: chatMap['sendBy'] == _auth.currentUser!.uid
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundImage: NetworkImage(chatMap['photoUrl']),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: chatMap['sendBy'] == _auth.currentUser!.uid
                              ? Colors.blue
                              : Colors.blueGrey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatMap['displayname'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 86, 83, 83),
                              ),
                            ),
                            SizedBox(
                              height: size.height / 200,
                            ),
                            Text(
                              chatMap['message'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMMd()
                                  .add_jm()
                                  .format(chatMap['time'].toDate()),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 198, 197, 197),
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        )),
                  ],
                ),
                // CircleAvatar(
                //   radius: 13,
                //   backgroundImage: NetworkImage(chatMap['photoUrl']),
                // ),
              );
      } else if (chatMap['type'] == "img") {
        // isLoading
        return isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: const CircularProgressIndicator(),
                ),
              )
            : Container(
                width: size.width,
                alignment: chatMap['sendBy'] == _auth.currentUser!.uid
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowImage(
                        imageUrl: chatMap['message'],
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    height: size.height / 2.5,
                    child: Container(
                      height: size.height / 4,
                      width: size.width / 4,
                      child: chatMap['message'] != ""
                          ? Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    chatMap['displayname'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height / 5,
                                    width: size.width / 4,
                                    child: Image.network(
                                      chatMap['message'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.yMMMMd()
                                        .add_jm()
                                        .format(chatMap['time'].toDate()),
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
                ),
              );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    });
  }
}
