import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class WidgetToImage extends StatefulWidget {
  const WidgetToImage(this.builder, {super.key});
  final Function(GlobalKey key) builder;

  @override
  State<WidgetToImage> createState() => _WidgetToImageState();
}

class _WidgetToImageState extends State<WidgetToImage> {
  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: widget.builder(globalKey),
    );
  }
}

Future capture(GlobalKey key) async {
  RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  return pngBytes;
}
