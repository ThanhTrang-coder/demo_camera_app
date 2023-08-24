import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  bool _isLoading = true;
  late CameraController _controller;
  late List<CameraDescription> _availableCameras;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAvailableCameras();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      body: FutureBuilder<void>(
        builder: (context, snapshot) {
          if(_isLoading) {
            return const Center(child: CircularProgressIndicator(),);
          } else {
            return CameraPreview(_controller);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final image = await _controller.takePicture();
            if(!mounted) return;

            // if the picture was taken, display it on a new screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context)  => DisplayPictureScreen(
                  imagePath: image.path,
                )
              )
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  // get available cameras
  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = await availableCameras();
    _initCamera(_availableCameras.first);
  }

  //init camera
  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.max);

    try {
      await _controller.initialize();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }
}

// a widget that displays the picture taken by the user
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  
  const DisplayPictureScreen({
    Key? key, 
    required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}

