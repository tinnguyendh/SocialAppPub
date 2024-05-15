import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:insta2/models/user.dart';

import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';

import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/utils.dart';

class EditPostScreen extends StatefulWidget {
  final snap;
  const EditPostScreen({Key? key, required this.snap}) : super(key: key);

  @override
  State<EditPostScreen> createState() => _EditPostScreen();
}

class _EditPostScreen extends State<EditPostScreen> {
  final TextEditingController _desController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _image;
  bool _isEmojiPickerVisible = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _desController.dispose();
  }

  void selectImage(BuildContext context) async {
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

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return EmojiPicker(
          onEmojiSelected: (category, emoji) {
            if (emoji != null) {
              _desController.text = _desController.text + emoji.emoji;
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     clearImage();
        //     // Navigator.of(context).pushReplacement(
        //     //           MaterialPageRoute(
        //     //             builder: (context) => const ResponsiveLayout(
        //     //               mobileScreenLayout: MobileScreenLayout(),
        //     //               webScreenLayout: WebScreenLayout(),
        //     //             ),
        //     //           ),
        //     //         );
        //   },
        // ),
        title: const Text('Edit Post'),
        actions: [
          TextButton(
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  String res = await FirestoreMethods().updatePost(
                    widget.snap['postId'],
                    _image!,
                    _desController.text,
                    // _image
                  );
                  if (res == "success") {
                    setState(() {
                      _isLoading = false;
                    });
                    showSnackBar('Edited', context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ResponsiveLayout(
                          mobileScreenLayout: MobileScreenLayout(),
                          webScreenLayout: WebScreenLayout(),
                        ),
                      ),
                    );
                  } else {
                    setState(() {
                      _isLoading = false;
                    });
                    showSnackBar(res, context);
                  }
                } catch (e) {
                  showSnackBar(e.toString(), context);
                }
              },
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ))
        ],
      ),
      body: Column(children: [
        _isLoading
            ? const LinearProgressIndicator()
            : const Padding(
                padding: EdgeInsets.only(top: 0),
              ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                user.photoUrl,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: TextField(
                controller: _desController,
                decoration: const InputDecoration(
                  hintText: 'write a cap...',
                  border: InputBorder.none,
                ),
                maxLines: 8,
              ),
            ),
            SizedBox(
              width: 45,
              height: 45,
              child: AspectRatio(
                aspectRatio: 487 / 451,
                child: IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    setState(() {
                      EmojiSet().showEmojiPicker(context, _desController);
                    });
                  },
                ),
              ),
            ),
            const Divider(),
          ],
        ),
        _image != null
            ? SizedBox(
                width: 350,
                height: 350,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: MemoryImage(_image!),
                    // fit: BoxFit.cover,
                    alignment: FractionalOffset.topCenter,
                  )),
                ),
              )
            : SizedBox(
                width: 350,
                height: 350,
                child: Image.network(
                  widget.snap['postUrl'],
                  height: 250,
                  width: 250,
                ),
              ),
        // Stack(
        //   children: [
        //     _image != null
        //         ? Image(
        //             image: MemoryImage(_image!),
        //             height: 200,
        //             width: 200,
        //           )
        //         : Image.network(
        //             widget.snap['postUrl'],
        //             height: 250,
        //             width: 250,
        //           ),
        //   ],
        // ),
        // Center(
        //   child: IconButton(
        //     onPressed: selectImage,
        //     icon: const Icon(Icons.add_a_photo),
        //   ),
        // ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add_a_photo),
        onPressed: () => selectImage(context),
      ),
    );
  }
}
