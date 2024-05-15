import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/screens/admin_screen/admin_comments_load_screen.dart';
import 'package:insta2/screens/user_screen/ChatScreen/chat_room_screen.dart';
import 'package:insta2/screens/user_screen/PostScreen/edit_post.dart';
import 'package:insta2/screens/user_screen/PostScreen/liked_users_screen.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminPostCard extends StatefulWidget {
  final snap;
  const AdminPostCard({Key? key, required this.snap}) : super(key: key);

  @override
  State<AdminPostCard> createState() => _AdminPostCardState();
}

class _AdminPostCardState extends State<AdminPostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  bool isLoading = false;

  Map<String, dynamic>? userMap;
  final List<String> likes = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void getLikes() async {
    QuerySnapshot<Map<String, dynamic>> usersnapshot =
        await firestore.collection('users').get();

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('posts')
        .where('likes', arrayContains: usersnapshot)
        .get();

    for (final DocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final List<dynamic> postLikes = doc['likes'];
      likes.addAll(postLikes.map((like) => like['uid'].toString()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
    getInfo();
    getLikes();
  }

  void getInfo() async {
    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: widget.snap['uid'])
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: widget.snap['postId'])
          .get();

      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {});
  }

  void getReports() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: widget.snap['postId'])
          .get();

      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    final size = MediaQuery.of(context).size;
    return Container(
      
      // decoration: BoxDecoration(
      //     border: Border.all(
      //         color: width > webScreenSize
      //             ? webBackgroundColor
      //             : mobileBackgroundColor)),
      color: widget.snap['report'].length>0 ? Color.fromARGB(255, 135, 51, 45) : mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        // isLoading
        //     ? Center(
        //         child: Container(
        //           height: size.height / 20,
        //           width: size.height / 20,
        //           child: const CircularProgressIndicator(),
        //         ),
        //       )
        //     :
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
              .copyWith(right: 0),
          child: Row(
            children: [
              isLoading
                  ? Center(
                      child: Container(
                        height: size.height / 20,
                        width: size.height / 20,
                        child: const CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                uid: widget.snap['uid'],
                                membersList: [],
                              ))),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(userMap!['photoUrl']),
                      ),
                    ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? Container(
                            // height: size.height / 20,
                            width: size.height / 15,
                            child: const LinearProgressIndicator(
                              color: primaryColor,
                            ),
                          )
                        : InkWell(
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                          uid: widget.snap['uid'],
                                          membersList: [],
                                        ))),
                            child: Text(
                              userMap!['username'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                  ],
                ),
              )),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shrinkWrap: true,
                        children: [
                          InkWell(
                            onTap: () async {
                              FirestoreMethods().deletePost(
                                  widget.snap['postId'],
                                  widget.snap['postUrl']);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              child: const Text(
                                'Delete Post',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_vert),
              )
            ],
          ),
        ),
        GestureDetector(
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShowImage(
                  imageUrl: widget.snap['postUrl'],
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                isLoading
                    ? Center(
                        child: Container(
                          // height: size.height / 20,
                          width: size.height / 2,
                          child: const LinearProgressIndicator(
                            color: primaryColor,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: double.infinity,
                        child: Image.network(
                          widget.snap['postUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            // const Icon(
            //     Icons.favorite_border,
            //   ),

            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminCommentsLoadScreen(
                          postId: widget.snap['postId'],
                          snap: widget.snap,
                        ))),
                icon: const Icon(
                  Icons.comment_outlined,
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                )),
            Expanded(
                child: Align(
              alignment: Alignment.bottomRight,
              child:

                  // IconButton(
                  //   icon: const Icon(Icons.bookmark_border),
                  //   onPressed: () {},
                  // ),
                  widget.snap['uid'].toString() == user.uid
                      ? IconButton(
                          icon: const Icon(Icons.edit_note),
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditPostScreen(
                                        snap: widget.snap,
                                      ))),
                        )
                      : Container(),
            ))
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: InkWell(
                      child: Text(
                        '${widget.snap['likes'].length} likes',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LikedUserScreen(
                            postId: widget.snap['postId'],
                          ),
                        ),
                      ),
                    ),
                  ),
                  DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: InkWell(
                      child: Text(
                        '  ${widget.snap['report'].length} reports',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LikedUserScreen(
                            postId: widget.snap['postId'],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: primaryColor),
                    children: [
                      TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: ' ${widget.snap['description']}',
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AdminCommentsLoadScreen(
                          postId: widget.snap['postId'],
                          snap: widget.snap,
                        ))),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'view all ${commentLen} comments',
                    style: const TextStyle(
                      fontSize: 16,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  DateFormat.yMMMMd()
                      .add_jm()
                      .format(widget.snap['datePublished'].toDate()),
                  style: const TextStyle(
                    fontSize: 13,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
