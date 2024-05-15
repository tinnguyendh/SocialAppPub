import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta2/screens/admin_screen/admin_feed_screen.dart';
import 'package:insta2/screens/user_screen/PostScreen/add_post_screen.dart';
import 'package:insta2/screens/admin_screen/admin_screen.dart';
import 'package:insta2/screens/user_screen/PostScreen/feed_screen.dart';
import 'package:insta2/screens/user_screen/ChatScreen/home_chat_main_screen.dart';
import 'package:insta2/screens/user_screen/ChatScreen/home_chat_screen.dart';
import 'package:insta2/screens/user_screen/NotificationScreen/notifi_post_screen.dart';
import 'package:insta2/screens/user_screen/NotificationScreen/notification_screen.dart';
import 'package:insta2/screens/user_screen/ProfileScreen/profile_screen.dart';
import 'package:insta2/screens/user_screen/SearchScreen/search_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const AdminFeedScreen(),
  const AdminScreen(),
  NotifiScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid, membersList: [],
  ),
];
