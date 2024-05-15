import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:insta2/screens/user_screen/CommentScreen/comments_load_screen.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
    bool isLoading = false;


 

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(labelText: 'Search for a user...'),
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
              isLoading = true;
            });
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ? width * 0.3 : 0,
            vertical: width > webScreenSize ? 15 : 0),
        child: isShowUsers
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where(
                      'username',
                      isGreaterThanOrEqualTo: searchController.text,
                    )
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } 
                  return ListView.builder(
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      itemBuilder: ((context, index) {
                        return InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: (snapshot.data! as dynamic).docs[index]
                                    ['uid'],
                                membersList: [],
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  (snapshot.data! as dynamic).docs[index]
                                      ['photoUrl']),
                            ),
                            title: Text((snapshot.data! as dynamic).docs[index]
                                ['username']),
                          ),
                        );
                      }));
                },
              )
            : FutureBuilder(
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: const CircularProgressIndicator());
                  }
                  
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: ((context, index) => InkWell(
                          onTap: () {
                            // Chuyển hướng đến trang CommentsLoadScreen khi hình ảnh được nhấp
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CommentsLoadScreen(
                                postId: (snapshot.data! as dynamic).docs[index]
                                    ['postId'],
                                snap: (snapshot.data! as dynamic).docs[index],
                              ),
                            ));
                          },
                          child: Image.network((snapshot.data! as dynamic)
                              .docs[index]['postUrl']),
                        )),
                    staggeredTileBuilder: ((index) =>
                        MediaQuery.of(context).size.width > webScreenSize
                            ? StaggeredTile.count((index % 7 == 0) ? 1 : 1,
                                (index % 7 == 0) ? 1 : 1)
                            : StaggeredTile.count((index % 7 == 0) ? 2 : 1,
                                (index % 7 == 0) ? 2 : 1)),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  );
                }),
                future: FirebaseFirestore.instance.collection('posts').get(),
              ),
      ),
    );
  }
}
