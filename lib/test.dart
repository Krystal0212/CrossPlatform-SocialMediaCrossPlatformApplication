import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert'; // For URL decoding

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Path Check',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileCheckScreen(),
    );
  }
}

class FileCheckScreen extends StatelessWidget {
  // Replace with your file path
  final String filePath =
      '/data/user/0/com.itproject.socialapp/cache/posts/FxwMrCir7ns2QBVq4ZICE%2Fatsh_celebration_2.webp?alt=media&token=21121248-92b1-404a-9b2c-1c5cb4658882';

  // Check if the file exists
  Future<bool> checkFileExists(String path) async {
    // Decode the URL and remove query parameters
    final decodedPath = Uri.decodeFull(path.split('?')[0]); // Decode and remove query parameters
    final file = File(decodedPath);
    return file.existsSync(); // Check if the file exists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check File Existence'),
      ),
      body: Center(
        child: FutureBuilder<bool>(
          future: checkFileExists(filePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            bool fileExists = snapshot.data ?? false;

            return Text(
              fileExists ? 'File exists!' : 'File does not exist!',
              style: TextStyle(fontSize: 20),
            );
          },
        ),
      ),
    );
  }
}
