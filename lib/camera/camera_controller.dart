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
  int selectedIndex = 0;
  List<bool> selected = [true, false];

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

  Future<void> requestImage(String imagePath, Function(String) onResult) async {

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

    final response = await request.send();
    final httpResponse = await http.Response.fromStream(response);

    final responseData = (httpResponse.statusCode == 200)
        ? jsonDecode(httpResponse.body)
        : "알 수 없는 오류 발생";

    onResult(responseData);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문제 사진 찍기')),
      body: Column(
        children: <Widget>[
          FutureBuilder<void>(
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
          Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: ToggleButtons(
              isSelected: selected,
              children: const [Text("수학"), Text("과학")],
              onPressed: (int index) {
                setState(() {
                  selectedIndex = index;
                  selected = selected.map((e) => false).toList();
                  selected[selectedIndex] = true;
                });
              },
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FloatingActionButton(
                    onPressed: () {},
                    tooltip: '사진 업로드하기',
                    // backgroundColor: Colors.yellow,
                    child: const Icon(Icons.upload_rounded),
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () async {
                      try {
                        await _initializeControllerFuture;

                        final image = await _controller.takePicture();

                        Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DisplayPictureScreen(
                                  imagePath: image.path,
                                  onImageProcessed: (result) {
                                    print('Result: $result');
                                  }
                              ),
                            )
                        );

                        requestImage(image.path, (result) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => DisplayPictureScreen(
                                    imagePath: image.path,
                                    answerString: result,
                                  )
                              )
                          );
                        });
                      }
                      catch (e) {
                        print(e);
                      }
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                )
              ],
            ),
          )
        ],
      ),


    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final String? answerString;
  final Function(String)? onImageProcessed;

  const DisplayPictureScreen({
    super.key,
    required this.imagePath,
    this.answerString,
    this.onImageProcessed,
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? _answerString;

  @override
  void initState(){
    super.initState();
    _answerString = widget.answerString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('풀이 결과')),
      body: Column(
        children: [
          kIsWeb ? Image.network(widget.imagePath) : Image.file(File(widget.imagePath)),
          _answerString != null
              ? Text(_answerString!)
              : const CircularProgressIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        tooltip: '다시 찍기',
        // backgroundColor: Colors.yellow,
        child: const Icon(Icons.refresh_rounded),
      ),


    );
  }
}