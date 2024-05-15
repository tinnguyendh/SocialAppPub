import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/Admin/admin_post_card.dart';
import 'package:insta2/widgets/post_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';

class AdminCommentsLoadScreen extends StatefulWidget {
  final postId;
  final snap;
  const AdminCommentsLoadScreen(
      {Key? key, required this.postId, required this.snap})
      : super(key: key);

  @override
  _AdminCommentsLoadScreenState createState() =>
      _AdminCommentsLoadScreenState();
}

class _AdminCommentsLoadScreenState extends State<AdminCommentsLoadScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isEmojiPickerVisible = false;
  List<Map<String, dynamic>> comments = [];
  Map<String, dynamic>? userMap;
  final TextEditingController _editCommentController = TextEditingController();

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
    _isEmojiPickerVisible
        ? showModalBottomSheet(
            context: context,
            builder: (context) {
              return EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  if (emoji != null) {
                    _commentController.text =
                        _commentController.text + emoji.emoji;
                  }
                },
              );
            },
          )
        : SizedBox();
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

    return Scaffold(
      backgroundColor: widget.snap['report'].length > 0
          ? Color.fromARGB(255, 135, 51, 45)
          : mobileBackgroundColor,

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
                  AdminPostCard(snap: widget.snap) // Hiển thị bài viết gốc
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

                        setState(() {
                          _isLoading = true;
                        });
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shrinkWrap: true,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    deleteSingleComment(comment['commentId']);
                                    //   showSnackBar('Delete Comment', context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ResponsiveLayout(
                                          mobileScreenLayout:
                                              MobileScreenLayout(),
                                          webScreenLayout: WebScreenLayout(),
                                        ),
                                      ),
                                    );

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
                      },
                      child: ListTile(
                        tileColor: comment['report'].length > 0? Color.fromARGB(255, 135, 51, 45) : mobileBackgroundColor,
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
                      ),
                    ),
                  );
                }
              },
              childCount: comments.length,
            ))
          ],
        ),
      )

    );
  }
}
