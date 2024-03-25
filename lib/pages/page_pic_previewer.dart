import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PicPreviewerPage extends StatefulWidget {
  final String imageUrl;

  const PicPreviewerPage({super.key, required this.imageUrl});

  @override
  State<PicPreviewerPage> createState() => _PicPreviewerPageState();
}

class _PicPreviewerPageState extends State<PicPreviewerPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.startsWith("http")) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: PhotoView(
          onTapUp: (ctx, _, __) {
            Navigator.of(context).pop();
          },
          imageProvider: NetworkImage(widget.imageUrl),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: PhotoView(
          onTapUp: (ctx, _, __) {
            Navigator.of(context).pop();
          },
          imageProvider: FileImage(File(widget.imageUrl)),
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
        ),
      );
    }
  }
}
