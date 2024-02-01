import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mimicon/canvas.dart';
import 'package:mimicon/widgettoimage.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen(this.xFile, {super.key});
  final XFile xFile;

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late InputImage inputImage;
  final options = FaceDetectorOptions(enableLandmarks: true);
  late FaceDetector faceDetector;
  bool isSingleFace = true;
  List<Face> faces = [];
  Point<int>? leftEyePoint;
  Point<int>? rightEyePoint;
  Point<int>? mouthPoint;
  GlobalKey? imageKey;
  Uint8List? bytes;
  bool isLoading = false;

  isSaveButtonEnabled() =>
      leftEyePoint != null && rightEyePoint != null && mouthPoint != null;

  @override
  void initState() {
    inputImage = InputImage.fromFilePath(widget.xFile.path);
    faceDetector = FaceDetector(options: options);
    findFaces();
    super.initState();
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 7,
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    child: Center(
                      child:
                          WidgetToImage((GlobalKey<State<StatefulWidget>> key) {
                        imageKey = key;
                        return Stack(
                          children: [
                            Image.file(File(widget.xFile.path)),
                            leftEyePoint != null
                                ? Positioned(
                                    left: leftEyePoint!.x - 11,
                                    top: leftEyePoint!.y - 4,
                                    child: CustomPaint(
                                      painter: OvalPainter(),
                                      size: const Size(20.0,
                                          10.0), // Adjust the size as needed
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            rightEyePoint != null
                                ? Positioned(
                                    left: rightEyePoint!.x - 11,
                                    top: rightEyePoint!.y - 4,
                                    child: CustomPaint(
                                      painter: OvalPainter(),
                                      size: const Size(20.0,
                                          10.0), // Adjust the size as needed
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            mouthPoint != null
                                ? Positioned(
                                    left: mouthPoint!.x - 11,
                                    top: mouthPoint!.y - 6,
                                    child: CustomPaint(
                                      painter: OvalPainter(),
                                      size: const Size(40.0,
                                          15.0), // Adjust the size as needed
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        );
                      }),
                    ),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/go_back.png',
                                        width: 20,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text(
                                        '다시찍기',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                isSingleFace
                                    ? Row(
                                        children: [
                                          customButton('눈', () {
                                            setState(() {
                                              leftEyePoint = faces
                                                  .first
                                                  .landmarks[
                                                      FaceLandmarkType.leftEye]
                                                  ?.position;

                                              rightEyePoint = faces
                                                  .first
                                                  .landmarks[
                                                      FaceLandmarkType.rightEye]
                                                  ?.position;
                                            });

                                            print(leftEyePoint);
                                          }),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          customButton('입', () {
                                            setState(() {
                                              mouthPoint = faces
                                                  .first
                                                  .landmarks[FaceLandmarkType
                                                      .leftMouth]
                                                  ?.position;
                                            });
                                          }),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ]),
                        ),
                        isSingleFace
                            ? isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xff7B8FF7),
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (isSaveButtonEnabled()) {
                                        saveImageToGallery();
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                          color: Color(isSaveButtonEnabled()
                                              ? 0xff7B8FF7
                                              : 0xffd3d3d3),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Center(
                                        child: Text(
                                          '저장하기',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                            : const SizedBox.shrink()
                      ],
                    ),
                  )),
            ],
          ),
        ));
  }

  findFaces() async {
    faces = await faceDetector.processImage(inputImage);

    if (faces.length > 1) {
      Fluttertoast.showToast(
        msg: "2개 이상의 얼굴이 감지되었어요!",
        gravity: ToastGravity.TOP,
      );
      setState(() {
        isSingleFace = false;
      });
      return;
    }

    if (faces.isEmpty) {
      Fluttertoast.showToast(
        msg: "No face detected",
        gravity: ToastGravity.TOP,
      );
      setState(() {
        isSingleFace = false;
      });
      return;
    }
  }

  Widget customButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(text)),
      ),
    );
  }

  saveImageToGallery() async {
    setState(() => isLoading = true);
    bytes = await capture(imageKey!);
    await ImageGallerySaver.saveImage(bytes!.buffer.asUint8List());
    Fluttertoast.showToast(
      msg: "Image saved",
      gravity: ToastGravity.TOP,
    );
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    super.dispose();
    faceDetector.close();
  }
}
