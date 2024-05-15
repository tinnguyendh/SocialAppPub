// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:insta2/utils/colors.dart';
// import 'package:insta2/responsive/mobile_screen_layout.dart';
// import 'package:insta2/responsive/responsive_layout.dart';
// import 'package:insta2/responsive/web_screen_layout.dart';


// class LoginAPIScreen extends StatefulWidget {
//     const LoginAPIScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginAPIScreen> createState() => _LoginAPIScreenState();
// }

// class _LoginAPIScreenState extends State<LoginAPIScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _login() async {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text;

//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:8082/login'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, String>{
//           'email': email,
//           'password': password,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final String customToken = data['customToken'];

//         // Đăng nhập bằng Custom Token
//         await FirebaseAuth.instance.signInWithCustomToken(customToken);

//         // Lấy Firebase ID token
//         User? user = FirebaseAuth.instance.currentUser;
//         String? idToken = await user?.getIdToken();

//         // Lưu token vào local storage hoặc state management của ứng dụng Flutter
//         // Điều hướng đến màn hình sau khi đăng nhập thành công

//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ResponsiveLayout(
//               mobileScreenLayout: MobileScreenLayout(),
//               webScreenLayout: WebScreenLayout(),
//             ),
//           ),
//           (route) => false,
//         );
//       } else {
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         final String errorMessage = data['error'];
//         // Hiển thị thông báo lỗi cho người dùng
//       }
//     } catch (error) {
//       // Xử lý lỗi kết nối hoặc lỗi khác
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             InkWell(
//                 onTap: _login,
//                 child: Container(
//                   alignment: Alignment.center,
//                   child: _isLoading
//                       ? const Center(
//                           child: CircularProgressIndicator(
//                             color: primaryColor,
//                           ),
//                         )
//                       : const Text('Login'),
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: const ShapeDecoration(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(4)),
//                     ),
//                     color: blueColor,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
