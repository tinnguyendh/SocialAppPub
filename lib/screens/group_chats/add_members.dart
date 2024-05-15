import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';

class AddMembersINGroup extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;
  const AddMembersINGroup(
      {required this.name,
      required this.membersList,
      required this.groupChatId,
      Key? key})
      : super(key: key);

  @override
  _AddMembersINGroupState createState() => _AddMembersINGroupState();
}

class _AddMembersINGroupState extends State<AddMembersINGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  List membersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList = widget.membersList;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("username", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  void onAddMembers() async {
    bool isAlreadyExist = false;
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }
    if (!isAlreadyExist) {
      membersList.add({
        'username': userMap!['username'],
        'uid': userMap!['uid'],
        'email': userMap!['email'],
        'photoUrl': userMap!['photoUrl'],
        'isAdmin': false,
      });

      await _firestore.collection('groups').doc(widget.groupChatId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(userMap!['uid'])
          .collection('groups')
          .doc(widget.groupChatId)
          .set({"name": widget.name, "id": widget.groupChatId});
    } else {
      showSnackBar('This User is Already in Group', context);
    }
    setState(() {
      userMap = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text("Add Members"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: width > webScreenSize ? width * 0.3 : 0,
            vertical: width > webScreenSize ? 15 : 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: size.height / 20,
              ),
              Container(
                height: size.height / 14,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 14,
                  width: size.width / 1.15,
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 50,
              ),
              isLoading
                  ? Container(
                      height: size.height / 12,
                      width: size.height / 12,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: onSearch,
                      child: Text("Search"),
                    ),
              userMap != null
                  ? ListTile(
                      onTap: onAddMembers,
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(userMap!['photoUrl']),
                        radius: 13,
                      ),
                      title: Text(userMap!['username']),
                      subtitle: Text(userMap!['email']),
                      trailing: Icon(Icons.add),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
