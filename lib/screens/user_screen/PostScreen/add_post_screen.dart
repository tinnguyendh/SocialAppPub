import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/models/user.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/resources/emoji_set.dart';
import 'package:insta2/resources/firestore_methods.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:multiple_images_picker/multiple_images_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  List<Uint8List> _selectedImages = [];
  List<XFile>? imageFileList = [];
  List<int>? _videofile;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  late VideoPlayerController _controller;
  bool _isEmojiPickerVisible = false;

  void initState() {
    super.initState();
  }

  // void postVideo(){
  //   try{
  //     if (_videofile != null){
  //       Uri videoUri = Uri.file(_file.path);
  //       _controller = VideoPlayerController.networkUrl(
  //     Uri.parse(
  //         videoUri), // Thay đổi URL mạng của video ở đây
  //   )..initialize().then((_) {
  //       // Đảm bảo video đã được tải xong trước khi chơi
  //       setState(() {});
  //     });
  //     }
  //   } catch(e){

  //   }
  // }

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await FirestoreMethods().uploadPost(
          _descriptionController.text, _file!, uid, username, profImage);

      if (res == "success") {
        setState(() {
          _isLoading = false;
        });
        // addNotificationForFollowers(uid, postId, "New post Added", profImage);
        showSnackBar('Posted', context);
        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  // void postImageMulti(
  //   String uid,
  //   String username,
  //   String profImage,
  // ) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     String res = await FirestoreMethods().uploadPostMulti(
  //       _descriptionController.text,
  //       _selectedImages, // Truyền _selectedImages vào hàm
  //       uid,
  //       username,
  //       profImage,
  //     );

  //     if (res == "success") {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       showSnackBar('Posted', context);
  //       clearImage();
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       showSnackBar(res, context);
  //     }
  //   } catch (e) {
  //     showSnackBar(e.toString(), context);
  //   }
  // }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // List<Asset> images =  selectMultiImages();
                  // // Chuyển đổi danh sách Asset sang Uint8List và lưu vào _selectedImages
                  // for (var image in images) {
                  //   final data = await image.getByteData();
                  //   if (data != null) {
                  //     final uint8List = data.buffer.asUint8List();
                  //     _selectedImages.add(uint8List);
                  //   }
                  // }
                  selectMultiImages();
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose video from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickVideo(ImageSource.gallery);
                  setState(() {
                    _file = file;
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

  Future<List<Asset>> pickMultipleImages() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultipleImagesPicker.pickImages(
        maxImages: 5, // Số lượng ảnh tối đa có thể chọn
        enableCamera: true,
      );
    } on Exception catch (e) {
      // Xử lý lỗi
      print(e);
    }

    return resultList;
  }

  void selectMultiImages() async {
    final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:" + imageFileList!.length.toString());
    setState(() {});
  }

  void _showEmojiPicker(BuildContext context) {
    _isEmojiPickerVisible
        ? showModalBottomSheet(
            context: context,
            builder: (context) {
              return EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  if (emoji != null) {
                    _descriptionController.text =
                        _descriptionController.text + emoji.emoji;
                  }
                },
              );
            },
          )
        : SizedBox();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
    _controller.dispose();
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  Future<void> addNotificationForFollowers(String currentUserId, String postId, String content, String profImage) async {
  // Lấy danh sách người theo dõi từ trường 'followers' của user hiện tại
  var followersSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
  var followers = followersSnapshot.data()?['followers'] as List<String>?;

  if (followers != null) {
    // Thêm thông báo cho mỗi người theo dõi
    for (var followerUid in followers) {
      await FirestoreMethods().addNotification(followerUid, postId, content, profImage);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return _file == null
        ? Scaffold(
            appBar: width > webScreenSize
                ? null
                : AppBar(
                    title: const Text('Create Posts'),
                    centerTitle: false,
                    backgroundColor: mobileBackgroundColor,
                  ),
            body: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0),
              color: mobileBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                          .copyWith(right: 0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/5087/5087579.png'),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () {},
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: double.infinity,
                        child: Image.network(
                          'https://media.sproutsocial.com/uploads/2022/05/How-to-post-on-instagram-from-pc.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {},
                        icon: const Icon(
                          Icons.favorite_border,
                        )),
                    IconButton(
                        onPressed: () {},
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
                                IconButton(
                                    icon: const Icon(Icons.edit_note),
                                    onPressed: () {})))
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(fontWeight: FontWeight.w800),
                          child: Text(
                            '? likes',
                            style: Theme.of(context).textTheme.bodyText2,
                          )),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 8),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: primaryColor),
                            children: [
                              TextSpan(
                                  text: 'username',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: ' description',
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Text(
                            'view all comments',
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          DateFormat.yMMMMd().add_jm().format(DateTime.now()),
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
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: primaryColor,
              child: Icon(Icons.add_a_photo),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text('Post to'),
              centerTitle: false,
              actions: [
                TextButton(
                    onPressed: () =>
                        postImage(user.uid, user.username, user.photoUrl),
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
            body: SingleChildScrollView(
              child: Column(
                children: [
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
                          controller: _descriptionController,
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
                                EmojiSet().showEmojiPicker(context, _descriptionController);
                              });
                            },
                          ),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                  SizedBox(
                    width: 350,
                    height: 350,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: MemoryImage(_file!),
                        // fit: BoxFit.cover,
                        alignment: FractionalOffset.topCenter,
                      )),
                    ),
                  ),
                  // ),
                ],
              ),
            ),
          );
  }
}
