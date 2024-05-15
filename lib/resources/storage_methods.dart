import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;


class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage

    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

    Future<List<String>> uploadMultiImages(String childName, List<XFile> imageFileList, bool isPost) async {
    List<String> imageUrls = [];
    // Reference ref =
    //     _storage.ref().child(childName).child(_auth.currentUser!.uid);

    for (int i = 0; i < imageFileList.length; i++) {
      File imageFile = File(imageFileList[i].path);
      String fileName = path.basename(imageFile.path);

      try {
        TaskSnapshot taskSnapshot = await _storage
            .ref(childName).child(_auth.currentUser!.uid).child(fileName) // Thay đổi đường dẫn lưu trữ tùy ý
            .putFile(imageFile);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      } catch (e) {
        print('Error uploading image: $e');
        // Xử lý lỗi nếu cần thiết
      }
    }

    return imageUrls;
  }

  Future<List<String>> uploadImagesUrlToStorage(
      String childName, List<Uint8List> files, bool isPost) async {
    List<String> downloadUrls = [];

    for (int i = 0; i < files.length; i++) {
      Uint8List file = files[i];

      String downloadUrl = await uploadImageToStorage(childName, file, isPost);

      if (downloadUrl.isNotEmpty) {
        downloadUrls.add(downloadUrl);
      }
    }

    return downloadUrls;
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
      throw e; // Re-throw the error for further handling, if needed.
    }
  }

  Future<void> downloadImage(String imageUrl, BuildContext context) async {
    try {
      Dio dio = Dio();
      final Response<List<int>> response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data!);

      final directory = await getExternalStorageDirectory();
      final folderPath = '${directory!.path}/RR/';

      if (await Directory(folderPath).exists() == false) {
        await Directory(folderPath).create(recursive: true);
      }

      final filePath =
          '$folderPath${DateTime.now().millisecondsSinceEpoch}.jpg';

      await File(filePath).writeAsBytes(bytes);
      print('File saved to: $filePath');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image downloaded successfully')),
      );
    } catch (e) {
      print('Error downloading image: $e');
    }
  }


}
