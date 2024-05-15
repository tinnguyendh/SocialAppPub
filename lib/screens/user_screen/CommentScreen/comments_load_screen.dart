import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/post_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';

class CommentsLoadScreen extends StatefulWidget {
  final postId;
  final snap;
  const CommentsLoadScreen({Key? key, required this.postId, required this.snap})
      : super(key: key);

  @override
  _CommentsLoadScreenState createState() => _CommentsLoadScreenState();
}

class _CommentsLoadScreenState extends State<CommentsLoadScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isEmojiPickerVisible = false;
  List<Map<String, dynamic>> comments = [];
  Map<String, dynamic>? userMap;
  final TextEditingController _editCommentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchComments().then((commentsData) {
      setState(() {
        comments = commentsData;
      });
    });
  }

  void getInfo(String id) async {
    setState(() {
      _isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: id)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        _isLoading = false;
      });
      print(userMap);
    });
  }

  Future<List<Map<String, dynamic>>> fetchComments() async {
    List<Map<String, dynamic>> commentsData = [];

    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: widget.postId)
          .get();

      if (commentSnapshot.docs.isNotEmpty) {
        for (var commentDoc in commentSnapshot.docs) {
          var commentData = commentDoc.data() as Map<String, dynamic>;
          commentsData.add(commentData);
        }
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }

    return commentsData;
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            if (emoji != null) {
              _commentController.text = _commentController.text + emoji.emoji;
            }
          },
        );
      },
    );
  }

  Future<void> deleteSingleComment(String commentId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi hàm xóa bình luận từ FirestoreMethods cho bình luận cụ thể
      await FirestoreMethods()
          .deleteComment(widget.postId, commentId, widget.snap['comments']);

      // Sau khi xóa bình luận, cập nhật danh sách bình luận
      setState(() {
        // Tải lại danh sách bình luận sau khi xóa
        comments.removeWhere((comment) => comment['commentId'] == commentId);
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future<void> handleUpdateComment(String commentId, String newComment) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Gọi hàm cập nhật comment từ FirestoreMethods cho comment cụ thể
      await FirestoreMethods()
          .updateComment(widget.postId, commentId, newComment);

      // Sau khi cập nhật comment, cập nhật danh sách bình luận
      setState(() {
        // Tải lại danh sách bình luận sau khi cập nhật
        int commentIndex =
            comments.indexWhere((comment) => comment['commentId'] == commentId);
        if (commentIndex != -1) {
          comments[commentIndex]['text'] = newComment;
        }
        _isLoading = false;
      });
      showSnackBar("Edit Comment Success", context);
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
        final size = MediaQuery.of(context).size;

    bool isReported = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        backgroundColor: mobileBackgroundColor,
      ),
      body:
          // comments.isNotEmpty
          //     ?
          Container(
        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ? width * 0.3 : 0,
            vertical: width > webScreenSize ? 15 : 0),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                if (widget.snap != null)
                  PostCard(snap: widget.snap) // Hiển thị bài viết gốc
              ]),
            ),
            SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (comments.length > index) {
                  final comment = comments[index];
                  getInfo(comment['uid']);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    child: InkWell(
                      onLongPress: () async {
                        final currentUserUid =
                            FirebaseAuth.instance.currentUser!.uid;
                        final commentUid = comment['uid'];
                        if (currentUserUid == commentUid ||
                            widget.snap['uid'].toString() == currentUserUid) {
                          setState(() {
                            _isLoading = true;
                          });
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      deleteSingleComment(comment['commentId']);
                                      showSnackBar('Delete Comment', context);

                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: const Text(
                                        'Delete Comment',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shrinkWrap: true,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      FirestoreMethods().reportComment(
                                          comment['commentId'],
                                          comment['uid'],
                                          comment['report']);
                                      showSnackBar('Reported Comment', context);
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Text(
                                         'Report Comment',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      child: ListTile(
                        // Hiển thị thông tin của comment (name, text, uid, profilePic)
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment['profilePic']),
                        ),
                        title: RichText(
                          text: TextSpan(children: [
                            widget.snap['uid'].toString() == comment['uid']
                                ? const TextSpan(
                                    text: "(Author) ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  )
                                : TextSpan(),
                            TextSpan(
                              text: comment['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ]),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(comment['text']),
                            Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(comment['datePublished'].toDate()),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        trailing: FirebaseAuth.instance.currentUser!.uid ==
                                comment['uid']
                            //     ||
                            // widget.snap['uid'].toString() ==
                            //     FirebaseAuth.instance.currentUser!.uid
                            ? IconButton(
                                icon: const Icon(Icons.edit_note),
                                onPressed: () {
                                  _editCommentController.text = comment['text'];
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Edit Comment'),
                                        content: TextField(
                                          controller: _editCommentController,
                                          decoration: InputDecoration(
                                            labelText: 'Edit your comment',
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                Icons.emoji_emotions,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  EmojiSet().showEmojiPicker(
                                                      context,
                                                      _editCommentController);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Đóng dialog
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Lấy comment mới từ _editCommentController.text và gọi hàm cập nhật
                                              String newComment =
                                                  _editCommentController.text;
                                              await handleUpdateComment(
                                                  comment['commentId'],
                                                  newComment);
                                              Navigator.of(context)
                                                  .pop(); // Đóng dialog
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              )
                            : SizedBox(),
                      ),
                    ),
                  );
                }
              },
              childCount: comments.length,
            )),
            // Container(
            //     height: size.height / 1.25,
            //     width: size.width,
            //     child: StreamBuilder<QuerySnapshot>(
            //       stream: _firestore
            //           .collection('comments').where('postId', isEqualTo: widget.postId)
            //           .snapshots(),
            //       builder: (BuildContext context,
            //           AsyncSnapshot<QuerySnapshot> snapshot) {
            //         if (snapshot.data != null) {
            //           return ListView.builder(
            //             itemCount: snapshot.data!.docs.length,
            //             itemBuilder: (context, index) {
            //               Map<String, dynamic> map = snapshot.data!.docs[index]
            //                   .data() as Map<String, dynamic>;
            //               return messages(size, map, context);
            //             },
            //           );
            //         } else {
            //           return Container();
            //         }
            //       },
            //     ),
            //   ),
          ],
        ),
      )
      // : Center(
      //     child: CircularProgressIndicator(),
      //   )
      ,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: width > webScreenSize ? width * 0.3 : 0,
              vertical: width > webScreenSize ? 15 : 0),
          height: kToolbarHeight,
          // margin: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).viewInsets.bottom,
          // ),
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                            hintText: 'Comments as ${user.username}',
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: _isEmojiPickerVisible
                                  ? Icon(Icons.keyboard)
                                  : Icon(Icons.emoji_emotions),
                              onPressed: () {
                                setState(() {
                                  // _showEmojiPicker(context);
                                  EmojiSet().showEmojiPicker(
                                      context, _commentController);
                                });
                              },
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().postComment(
                      widget.snap['postId'],
                      _commentController.text,
                      user.uid,
                      user.username,
                      user.photoUrl,
                      widget.snap['comments']);
                  setState(() {
                    _commentController.text = '';
                  });
                  fetchComments().then((commentsData) {
                    setState(() {
                      comments = commentsData;
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 11),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: blueColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
