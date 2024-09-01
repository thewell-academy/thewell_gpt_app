// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';


class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<http.StreamedResponse> requestImage(String imagePath) async {

    Image myImage = Image.network(imagePath);

    final ImageStream imageStream = myImage.image.resolve(const ImageConfiguration());
    final Completer<ui.Image> completer = Completer<ui.Image>();

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    final ui.Image uiImage = await completer.future;

    final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

    final Uint8List? bytes = byteData?.buffer.asUint8List();

    var request = http.MultipartRequest("POST", Uri.parse("http://127.0.0.1:8000/upload-file"));
    request.files.add(
      http.MultipartFile.fromBytes("file", bytes as List<int>, filename: "image.png"),
    );

    return await request.send();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            http.StreamedResponse response = await requestImage(image.path);
            http.Response httpResponse = await http.Response.fromStream(response);

            dynamic responseData = (response.statusCode == 200)
                ? await jsonDecode(httpResponse.body)
                : "Something's wrong";

            // Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                  answerString: responseData,
                ),
              ),
            );

          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final dynamic answerString;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.answerString
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          kIsWeb ? Image.network(imagePath) : Image.file(File(imagePath)),
          answerString != null
              ? Text(answerString.toString())
              : CircularProgressIndicator(),
        ],
      )


    );
  }
}