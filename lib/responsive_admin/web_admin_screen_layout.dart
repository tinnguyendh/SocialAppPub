import 'package:flutter/material.dart';
import 'package:insta2/utils/colors.dart';
import 'package:insta2/utils/Admin/dimensions_admin.dart';

class WebAdminScreenLayout extends StatefulWidget {
  const WebAdminScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebAdminScreenLayout> createState() => _WebAdminScreenLayoutState();
}

class _WebAdminScreenLayoutState extends State<WebAdminScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
    setState(() {
      _page = page;
    });
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: webBackgroundColor,
        centerTitle: false,
        title: const Text('RaidRoot'),
        actions: [
          IconButton(
              onPressed: () => navigationTapped(0),
              icon: Icon(
                Icons.home,
                color: _page == 0 ? primaryColor : secondaryColor,
              )),
          IconButton(
              onPressed: () => navigationTapped(1),
              icon: Icon(
                Icons.manage_accounts,
                color: _page == 1 ? primaryColor : secondaryColor,
              )),
          IconButton(
              onPressed: () => navigationTapped(2),
              icon: Icon(
                Icons.favorite,
                color: _page == 3 ? primaryColor : secondaryColor,
              )),
          IconButton(
              onPressed: () => navigationTapped(3),
              icon: Icon(
                Icons.person,
                color: _page == 4 ? primaryColor : secondaryColor,
              )),

        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        children: homeScreenItems,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
