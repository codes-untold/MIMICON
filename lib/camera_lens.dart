import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mimicon/face_detection.dart';

class CameraLens extends StatefulWidget {
  const CameraLens(this.camera, {super.key});
  final CameraDescription camera;

  @override
  State<CameraLens> createState() => _CameraLensState();
}

class _CameraLensState extends State<CameraLens> with WidgetsBindingObserver {
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;
  late CameraDescription cameraDescription;

  @override
  void initState() {
    cameraDescription = widget.camera;
    cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      cameraDescription,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = cameraController.initialize();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeControllerFuture = cameraController.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const Icon(
          Icons.clear,
          color: Colors.white,
        ),
        actions: const [
          Icon(
            Icons.more_vert,
            color: Colors.white,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 8,
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(cameraController);
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final image = await cameraController.takePicture();
                        // ignore: use_build_context_synchronously
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FaceDetectionScreen(image)));
                      },
                      child: Image.asset(
                        'assets/camera_button.png',
                        width: 60,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          print('ghghghgh');
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);

                          print(image);
                          if (image == null) {
                            return;
                          }
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FaceDetectionScreen(image!)));
                        },
                        child: Image.asset(
                          'assets/gallery_icon.png',
                          width: 30,
                        ),
                      ),
                      InkWell(
                          onTap: () => toggleCamera(),
                          child: Image.asset('assets/swap_lens.png', width: 30))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void toggleCamera() async {
    // Get the list of available cameras
    List<CameraDescription> cameras = await availableCameras();

    if (cameraDescription.lensDirection == CameraLensDirection.front) {
      cameraDescription = cameras
          .where((element) => element.lensDirection == CameraLensDirection.back)
          .first;
    } else {
      cameraDescription = cameras
          .where(
              (element) => element.lensDirection == CameraLensDirection.front)
          .first;
    }

    // Dispose of the current controller and initialize a new one with the next camera
    await cameraController.dispose();
    cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = cameraController.initialize();

    // Update the UI
    setState(() {});
  }
}
