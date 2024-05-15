import 'package:flutter/material.dart';
import 'package:insta2/providers/user_provider.dart';
import 'package:insta2/utils/Admin/dimensions_admin.dart';
import 'package:provider/provider.dart';



class ResponsiveAdminLayout extends StatefulWidget {
  final Widget mobileScreenLayout;
  final Widget webScreenLayout;
  const ResponsiveAdminLayout({
    Key? key,
    required this.mobileScreenLayout,
    required this.webScreenLayout,
  }) : super(key: key);

  @override
  State<ResponsiveAdminLayout> createState() => _ResponsiveAdminLayoutState();
}

class _ResponsiveAdminLayoutState extends State<ResponsiveAdminLayout> {
  // @override
  // void initState() {
  //   super.initState();
  //   addData();
  // }

  // addData() async {
  //   UserProvider userProvider =
  //       Provider.of<UserProvider>(context, listen: false);
  //   await userProvider.refreshUser();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();

  }

  addData() async{
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        // 600 can be changed to 900 if you want to display tablet screen with mobile screen layout
        return widget.webScreenLayout;
      }
      return widget.mobileScreenLayout;
    });
  }
}
