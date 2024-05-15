import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';

import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/text_field_input.dart';

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({Key? key}) : super(key: key);

  @override
  State<ChangeAvatar> createState() => _ChangeAvatar();
}

class _ChangeAvatar extends State<ChangeAvatar> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
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
    return Scaffold(
      appBar: AppBar(title: const Text('Change Avatar')),
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Flexible(child: Container(), flex: 2),
          Stack(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 94,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : const CircleAvatar(
                      radius: 94,
                      backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/5087/5087579.png'),
                    ),
              Positioned(
                  bottom: -10,
                  left: 120,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ))
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Change Avatar',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 64),
          //email

          //button
          InkWell(
            onTap: () async {
              setState(() {
                _isLoading = true;
              });
              if (_image != null) {
                await FirestoreMethods().updateAvatar(
                  FirebaseAuth.instance.currentUser!.uid,
                  _image!,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ResponsiveLayout(
                      mobileScreenLayout: MobileScreenLayout(),
                      webScreenLayout: WebScreenLayout(),
                    ),
                  ),
                );
              }

              showSnackBar("No image selected", context);

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
                  : const Text('Update Avatar'),
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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                'Edit your profile here ',
              ),
            ),
            GestureDetector(
              onTap: navigateToHome,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ])
        ]),
      )),
    );
  }
}
