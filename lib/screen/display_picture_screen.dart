import 'dart:io';

import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  
  const DisplayPictureScreen({
    Key? key, 
    required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Preview'),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}
