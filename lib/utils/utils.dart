import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async{
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);
  if(_file!= null){
    return await _file.readAsBytes();
  }
  print('no image selected');
}

pickVideo(ImageSource source) async{
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickVideo(source: source);
  if(_file!= null){
    return await _file.readAsBytes();
  }
  print('no video selected');
}

Future<List<int>?> pickVideoWeb() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp4', 'avi', 'mov'], // Thêm các phần mở rộng video bạn muốn cho phép
  );

  if (result != null) {
    PlatformFile file = result.files.first;
    Uint8List? videoBytes = await file.bytes;

    if (videoBytes != null) {
      return videoBytes;
    } else {
      print('Không thể đọc video');
      return null;
    }
  } else {
    print('Không có video được tải lên');
    return null;
  }
}

showSnackBar(String content, BuildContext context){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content))
  );
}