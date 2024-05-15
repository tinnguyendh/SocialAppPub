import 'package:flutter/material.dart';

class IntroductionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Introduction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Social Media ЯaidRoot!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'ЯaidRoot helps you connect with friends and share special moments in your life.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Main feature:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat and Chat Groups'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      title: 'Chat and Chat Groups',
                      content:
                          'Here you can join individual or group conversations and share opinions, photos, and more.',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Share Photos and Videos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      title: 'Share Photos and Videos',
                      content:
                          'Share your best moments with friends through photos and videos.',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Manage followers'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      title: 'Manage followers',
                      content:
                          'Connect and manage your friends, follow them and be followed by them.',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_a_photo),
              title: Text('Posting instructions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      title: 'Posting instructions',
                      content:
                          '1. Select add article on the menu bar.\n2. On this page, click on the add post button, you will be redirected to the photo selection page, select a photo and enter a description for the post.\n3. Finally, select the post button to complete the posting.',
                    ),
                  ),
                );
              },
            ),
            // Thêm các tính năng khác tùy thuộc vào ứng dụng của bạn
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String title;
  final String content;

  DetailScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
