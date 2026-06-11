import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            SizedBox(height: 60),
            Text(
              'Ari Deane',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Mobile Developer',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('phone number: 054-5570197'),
            SizedBox(height: 8),
            Text('email: ari.deane@gmail.com'),
            SizedBox(height: 60),
            Text(
              'Simon Navon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Backend Developer',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('phone number: 054-9877094'),
            SizedBox(height: 8),
            Text('email: navonsimon1@gmail.com'),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
