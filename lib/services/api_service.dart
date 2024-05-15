import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/routes/env.dart';
import 'package:insta2/routes/routing.dart';
import 'package:http/http.dart' as http;
import 'package:insta2/utils/utils.dart';

class UserServices {
  final BuildContext context; // Khai báo context ở đây

  UserServices(this.context); // Constructor nhận context
  Future<String> loginService(String email, String password) async {
    final String loginUrl = 'http://localhost:8082/login';

    String res = await AuthMethods().loginUser(
      email: email,
      password: password,
    );
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      print("login url: " + loginUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String customToken = data['customToken'];

        if (res == 'success') {
          // Đăng nhập bằng Custom Token
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
          // Lấy Firebase ID token
          User? user = FirebaseAuth.instance.currentUser;
          String? idToken = await user?.getIdToken();
          String? uid = user?.uid;

          sendUidToPyServer(uid);

          // Lưu token vào local storage hoặc state management của ứng dụng Flutter
          // Điều hướng đến màn hình sau khi đăng nhập thành công
          res = "success";
        }
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String errorMessage = data['error'];

        if (errorMessage.contains("password")) {
          // Nếu lỗi liên quan đến mật khẩu, cập nhật res thành "Invalid password"
          res = "Invalid password";
        } else {
          // Nếu không, sử dụng thông báo lỗi từ máy chủ
          res = errorMessage;
        }
      }
    } catch (error) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      return error.toString();
    }
    return res;
  }

  loginServiceApi(String email, String password) async {
    const String loginUrl =
        'http://localhost:8082/login'; // Construct the complete URL
    // final  = emailController.text.trim();
    // final  = passwordController.text;
    await http.post(
      Uri.parse(loginUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
  }
}

Future<void> sendUidToPyServer(String? uid) async {
  const recommendUrl = 'http://127.0.0.1:8083/receive_uid';
  final recommendResponse = await http.post(
    Uri.parse(recommendUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'uid': uid!,
    }),
  );

  if (recommendResponse.statusCode == 200) {
    // Xử lý phản hồi từ máy chủ Python nếu cần
    print('Send uid succeed: '+uid);
  } else {
    throw Exception('Failed to send UID to server');
  }

  // Tiếp tục xử lý đăng nhập thành công nếu cần
}
