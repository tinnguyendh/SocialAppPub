import 'package:flutter/material.dart';
import 'package:insta2/resources/auth_methods.dart';
import 'package:insta2/utils/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        shadowColor: mobileBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Current Password'),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            SizedBox(height: 16),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  )
                : Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.green),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _changePassword();
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    setState(() {
      isLoading = true;
    });
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Kiểm tra xem mật khẩu mới và xác nhận mật khẩu có khớp nhau không
    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New password and confirm password do not match.';
      });
      return;
    }

    // Gọi hàm cập nhật mật khẩu từ AuthMethods
    String result = await _authMethods.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (result == 'success') {
      // Thành công, có thể thực hiện các xử lý khác nếu cần
      setState(() {
        _errorMessage = 'Password updated successfully.';
      });
    } else {
      // Thất bại, hiển thị thông báo lỗi
      setState(() {
        _errorMessage = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
