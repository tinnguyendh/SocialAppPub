import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';

import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/text_field_input.dart';

class EditProfileScreen extends StatefulWidget {
  final snap;
  const EditProfileScreen({Key? key, this.snap}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreen();
}

class _EditProfileScreen extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }



  void navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
          child: Container(
        padding: MediaQuery.of(context).size.width > webScreenSize
            ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3)
            : const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Container(), flex: 2),
              // Stack(
              //   children: [
              //     _image != null
              //         ? CircleAvatar(
              //             radius: 64,
              //             backgroundImage: MemoryImage(_image!),
              //           )
              //         : 
              const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/5087/5087579.png'),
                        ),
              //   ],
              // ),
              // const SizedBox(height: 14),
              // const Text('Edit Profile'),
              const SizedBox(height: 64),
              //email
              TextFieldInput(
                  textEditingController: _usernameController,
                  hintText: 'username',
                  textInputType: TextInputType.text),
              const SizedBox(height: 24),
              //password
              // TextFieldInput(
              //   textEditingController: _bioController,
              //   hintText: 'bio',
              //   textInputType: TextInputType.text,
              // ),
              // SizedBox(
              //   width: MediaQuery.of(context).size.width * 0.4,
              //   child: TextField(
              //     controller: _bioController,
              //     decoration: const InputDecoration(
              //       hintText: 'bio...',
              //       border: InputBorder.none,
              //     ),
              //     maxLines: 8,
              //   ),
              // ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    hintText: 'bio....',
                    border: inputBorder,
                    focusedBorder: inputBorder,
                    enabledBorder: inputBorder,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.emoji_emotions),
                      onPressed: () {
                        setState(() {
                          EmojiSet().showEmojiPicker(context, _bioController);
                        });
                      },
                    ),
                    // filled: true,
                    contentPadding: const EdgeInsets.all(8),
                  ),
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 24),
              //button
              InkWell(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await FirestoreMethods().updateProfile(
                    FirebaseAuth.instance.currentUser!.uid,
                    _usernameController.text,
                    _bioController.text,
                    // _image
                  );
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => ProfileScreen(
                  //         uid: FirebaseAuth.instance.currentUser!.uid,
                  //         membersList: []),
                  //   ),
                  // );
                  showSnackBar('Update Profile Successfully', context);
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Update Profile'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Flexible(child: Container(), flex: 2),
              // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              //   Container(
              //     padding: const EdgeInsets.symmetric(vertical: 8),
              //     child: const Text(
              //       'Edit your profile here ',
              //     ),
              //   ),
              //   GestureDetector(
              //     onTap: navigateToHome,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(vertical: 8),
              //       child: const Text(
              //         'CANCEL',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ])
            ]),
      )),
    );
  }
}
