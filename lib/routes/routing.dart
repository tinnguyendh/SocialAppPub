import 'package:flutter/material.dart';
import 'package:insta2/responsive/mobile_screen_layout.dart';
import 'package:insta2/responsive/responsive_layout.dart';
import 'package:insta2/responsive/web_screen_layout.dart';
import 'package:insta2/responsive_admin/mobile_admin_screen_layout.dart';
import 'package:insta2/responsive_admin/responsive_admin_layout.dart';
import 'package:insta2/responsive_admin/web_admin_screen_layout.dart';

void navigateToUserFeed(BuildContext context) {
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

void navigateToAdminFeed(BuildContext context) {
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

