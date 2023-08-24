import 'dart:io';

import 'package:camera/camera.dart';
import 'package:demo_camera_app/screen/video_page.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;
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
    _cameraController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center (
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      try {
                        final image = await _cameraController.takePicture();

                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Image.file(File(image.path))
                              );
                            }
                        );
                        // await Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder:
                        //       (context) => DisplayPictureScreen(
                        //           imagePath: image.path
                        //       )
                        //   )
                        // );
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                  const SizedBox(width: 40,),
                  FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    backgroundColor: Colors.white,
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.circle,
                      color: _isRecording ? Colors.black : Colors.red,
                    ),
                    onPressed: () => _recordVideo(),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: FloatingActionButton(
                onPressed: () => _toggleCameraLens(),
                child: const Icon(Icons.flip_camera_android_outlined),
              ),
            ),
          ],
        ),
      );
    }
  }

  // get available cameras
  Future<void> _getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _availableCameras = await availableCameras();
    _initCamera(_availableCameras.first);
  }
  
  // init camera
  Future<void> _initCamera(CameraDescription description) async {
    _cameraController = CameraController(description, ResolutionPreset.max, enableAudio: true);

    try {
      await _cameraController.initialize();
      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  _recordVideo() async {
    if(_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });

      // route to recorded video
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path,),
      );
      Navigator.push(context, route);
    }
    // if camera not yet recording, CameraController prepare for recording
    else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  // re-initialize the camera controller when change lens direction
  void _toggleCameraLens() {
    //get current lens direction (font / rear)
    final lensDirection = _cameraController.description.lensDirection;
    CameraDescription newDescription;
    if(lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.back
      );
    } else {
      newDescription = _availableCameras.firstWhere(
        (description) => description.lensDirection == CameraLensDirection.front
      );
    }

    if(newDescription != null) {
      _initCamera(newDescription);
    } else {
      print('Asked camera not available');
    }
  }
}
