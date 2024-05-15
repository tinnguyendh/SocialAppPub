import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/screens/user_screen/AuthScreen/login_screen.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/dimensions.dart';
import 'package:insta2/utils/utils.dart';
import 'package:insta2/widgets/password_input.dart';
import 'package:insta2/widgets/text_field_input.dart';

enum Gender {
  male,
  female,
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  List<String> countries = [
    'Vietnam',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
  ];

  List<int> roles = [0, 1, 2];

  String? selectedCountry;
  Gender? selectedGender;
  String? selectedRole;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    bool genderValue = selectedGender == Gender.male ? true : false;

    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image!,
        gender: genderValue,
        country: selectedCountry ?? '',
        role: "0");

    setState(() {
      _isLoading = false;
    });

    // if (_emailController.text == "") {
    //     showSnackBar("Email is empty", context);

    //   }

    if (res != 'success') {
      showSnackBar(res, context);
      print(res);
      if (res ==
          "[firebase_auth/invalid-email] The email address is badly formatted.") {
        showSnackBar("The email address is emtpy or badly formatted.", context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Invalid Information'),
                content: Text("The email address is emtpy or badly formatted."),
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
      } else {
        if (res ==
            "[firebase_auth/weak-password] Password should be at least 6 characters") {
          showSnackBar("Password should be at least 6 characters", context);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Invalid Information'),
                  content: Text("Password should be at least 6 characters"),
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
        } else {
          if (res ==
              "[firebase_auth/email-already-in-use] The email address is already in use by another account.") {
            showSnackBar(
                "The email address is already in use by another account.",
                context);
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Invalid Information'),
                    content: Text(
                        "The email address is already in use by another account."),
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
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: MediaQuery.of(context).size.width > webScreenSize
            ? EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 3)
            : const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Flexible(child: Container(), flex: 2),
          // SvgPicture.asset(
          //   'assets/ic_instagram.svg',
          //   color: primaryColor,
          //   height: 64,
          // ),
          const SizedBox(height: 64),
          //circular widget to show selected file
          Stack(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 64,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : const CircleAvatar(
                      radius: 64,
                      backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/5087/5087579.png'),
                    ),
              Positioned(
                  bottom: -10,
                  left: 80,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ))
            ],
          ),
          const SizedBox(height: 24),

          //username
          TextFieldInput(
              textEditingController: _usernameController,
              hintText: 'Enter your Username',
              textInputType: TextInputType.text),
          const SizedBox(height: 24),

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
          //bio
          // TextFieldInput(
          //     textEditingController: _bioController,
          //     hintText: 'Enter your bio',
          //     textInputType: TextInputType.text),

          Row(
            children: [
              DropdownButton<String>(
                value: selectedCountry,
                hint: Text('Select a country'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                  });
                },
                items: countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
              ),
              DropdownButton<Gender>(
                value: selectedGender,
                hint: Text('Select gender'),
                onChanged: (Gender? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: Gender.values.map((Gender gender) {
                  return DropdownMenuItem<Gender>(
                    value: gender,
                    child: Text(gender
                        .toString()
                        .split('.')
                        .last), // Hiển thị giá trị của enum
                  );
                }).toList(),
              ),
            ],
          ),

          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: TextField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: 'Enter your bio',
                border: inputBorder,
                focusedBorder: inputBorder,
                enabledBorder: inputBorder,
                // filled: true,
                contentPadding: const EdgeInsets.all(8),
              ),
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 24),
          //button
          InkWell(
            onTap: signUpUser,
            child: Container(
              alignment: Alignment.center,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : const Text('Sign up'),
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
                'You have an account? ',
              ),
            ),
            GestureDetector(
              onTap: navigateToLogin,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Login',
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
