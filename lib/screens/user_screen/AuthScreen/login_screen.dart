import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:insta2/models/user.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/responsive_admin/mobile_admin_screen_layout.dart';
import 'package:insta2/responsive_admin/responsive_admin_layout.dart';
import 'package:insta2/responsive_admin/web_admin_screen_layout.dart';
import 'package:insta2/screens/admin_screen/admin_screen.dart';
import 'package:insta2/screens/user_screen/AuthScreen/signup_screen.dart';
import 'package:insta2/services/api_service.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/password_input.dart';
import 'package:insta2/widgets/text_field_input.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:insta2/routes/env.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _apiEmailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  // final backendUrl = ENVBackEnd.backendUrl;
  bool _isLoading = false;
  bool isEmailAdmin(String email) {
    // Bạn có thể sửa đổi điều kiện kiểm tra email admin theo nhu cầu của mình
    return email.toLowerCase() == 'admin@gmail.com';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<bool> isAdmin(String email) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data();
        var role = userData['role']; // Giả sử trường lưu vai trò là 'role'
        return role == '1'; // Trả về true nếu vai trò là '1', ngược lại false
      }
      return false; // Trường hợp không tìm thấy email trong collection 'users'
    }).catchError((error) {
      print('Error getting user data: $error');
      return false; // Xử lý lỗi
    });
  }

  void checkValidate(String res) {
    if (res ==
        "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.") {
      showSnackBar("The Email or Password is not correct", context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Information'),
              content: Text("The Email or Password is not correct"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
      print(res);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Information'),
              content: const Text('Server NOT responsed'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Đóng dialog
                  },
                  child: const Text('Ok'),
                ),
              ],
            );
          });
    }
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (res == 'success') {
      if (isEmailAdmin(_emailController.text)) {
        navigateToAdminFeed();
      } else {
        navigateToUserFeed();
      }
    } else {
      checkValidate(res);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loginFromService() async {
    try {
      final response = await UserServices(context).loginServiceApi(
          _emailController.text.trim(), _passwordController.text);
      print('response');
      print("RESPONSE: " + response);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String customToken = data['customToken'];

        // Đăng nhập bằng Custom Token
        await FirebaseAuth.instance.signInWithCustomToken(customToken);

        // Lấy Firebase ID token
        User? user = FirebaseAuth.instance.currentUser;
        String? idToken = await user?.getIdToken();

        // Lưu token vào local storage hoặc state management của ứng dụng Flutter
        // Điều hướng đến màn hình sau khi đăng nhập thành công

        navigateToUserFeed(); // Gọi hàm navigateToUserFeed và truyền vào context
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String errorMessage = data['error'];
        print(errorMessage);
        // Hiển thị thông báo lỗi cho người dùng
      }
    } catch (e) {
      print(e);
    }
  }

  // Future<void> _login() async {
  //   final String email = _emailController.text.trim();
  //   final String password = _passwordController.text;
  //   final String loginUrl = '$backendUrl/login'; // Construct the complete URL

  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost:8082/login'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'email': email,
  //         'password': password,
  //       }),
  //     );

  //     print("login url: " + loginUrl);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       final String customToken = data['customToken'];
  //       print(data['customToken']);

  //       // Đăng nhập bằng Custom Token
  //       await FirebaseAuth.instance.signInWithCustomToken(customToken);

  //       // Lấy Firebase ID token
  //       User? user = FirebaseAuth.instance.currentUser;
  //       String? idToken = await user?.getIdToken();

  //       // Lưu token vào local storage hoặc state management của ứng dụng Flutter
  //       // Điều hướng đến màn hình sau khi đăng nhập thành công

  //       navigateToUserFeed();
  //     } else {
  //       final Map<String, dynamic> data = jsonDecode(response.body);
  //       final String errorMessage = data['error'];
  //       // Hiển thị thông báo lỗi cho người dùng
  //     }
  //   } catch (error) {
  //     // Xử lý lỗi kết nối hoặc lỗi khác
  //   }
  // }

  void navigateToSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignupScreen()));
  }

  void navigateToAdminFeed() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ResponsiveAdminLayout(
          mobileScreenLayout: MobileAdminScreenLayout(),
          webScreenLayout: WebAdminScreenLayout(),
        ),
      ),
      (route) => false,
    );
  }

  void navigateToUserFeed() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const ResponsiveLayout(
          mobileScreenLayout: MobileScreenLayout(),
          webScreenLayout: WebScreenLayout(),
        ),
      ),
      (route) => false,
    );
  }

  void _handleLoginTap() async {
    setState(() {
      _isLoading = true;
    });
    String response = await UserServices(context)
        .loginService(_emailController.text.trim(), _passwordController.text);
    if (response == 'success') {
      navigateToUserFeed();
    } else {
      checkValidate(response);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              Image.network(
                'https://firebasestorage.googleapis.com/v0/b/insta-d9db8.appspot.com/o/post%2FCNxmD3wjSLYBx2pFeNMskOka6k43%2F16aa67a0-7284-11ee-b907-85e4ce7f3465?alt=media&token=e6c46a91-cc88-4e03-b317-e241d7e862d4',
                width: 200,
                height: 200,
              ),
              // SvgPicture.asset(
              //   'assets/icon.jpg',
              //   color: primaryColor,
              //   height: 64,
              // ),

              const SizedBox(height: 14),

              const Text(
                'ЯaidRoot',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 64),
              //email
              TextFieldInput(
                  textEditingController: _emailController,
                  hintText: 'Enter your Email',
                  textInputType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              //password
              PassFieldInput(
                textEditingController: _passwordController,
                hintText: 'Enter your Password',
                textInputType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              //button
              InkWell(
                onTap: _handleLoginTap,
                child: Container(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Login'),
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
              // const SizedBox(
              //   height: 15,
              // ),
              // ElevatedButton(
              //   onPressed: () async {
              //     User? user = await AuthMethods().signInWithGoogle();
              //     if (user != null) {
              //       print('Đăng nhập thành công: ${user.displayName}');
              //     } else {
              //       print('Đăng nhập thất bại');
              //     }
              //   },
              //   child: Text('Google Signin'),
              // ),

              const SizedBox(height: 140),
              Flexible(child: Container(), flex: 2),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    'Don`t have an account? ',
                  ),
                ),
                GestureDetector(
                  onTap: navigateToSignUp,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Signup',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
      )),
    );
  }
}
