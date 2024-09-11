import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'dart:convert';

import 'package:thewell_frontend/util/util.dart';


class DisplayPictureScreen extends StatefulWidget {
  final File image;
  final String? answerString;
  final Function(String)? onImageProcessed;
  final int selectedIndex;


  const DisplayPictureScreen({
    super.key,
    required this.image,
    required this.selectedIndex,
    this.answerString,
    this.onImageProcessed,
  });
  // List<bool> selected = [true, false];
  // bool _isLoading = false;


  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  String? _answerString;
  int radVal = 0;
  late TeXViewRenderingEngine renderingEngine;
  String? serverResult;
  bool _isLoading = false;

  @override
  void initState(){
    super.initState();
    _answerString = widget.answerString;
    requestImage(Image.file(widget.image), (result) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> requestImage(Image image, Function(String?) onResult) async {
    setState(() {
      serverResult = null;
    });

    // Image myImage = (kIsWeb)
    //     ? Image.network(imagePath)
    //     : Image.file(File.fromUri(Uri.parse(imagePath)));

    Image myImage = image;

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

    String? deviceId = await PlatformDeviceId.getDeviceId;
    var request = http.MultipartRequest(
        "POST",
        Uri.parse("$serverUrl/ask/${getSubject(widget.selectedIndex)}/${deviceId.toString()}}")
    );

    request.files.add(
      http.MultipartFile.fromBytes("file", bytes as List<int>, filename: "image.png"),
    );
    // request.headers['subject'] = "$selectedIndex";

    final response = await request.send();
    final httpResponse = await http.Response.fromStream(response);

    final responseData = (httpResponse.statusCode == 200)
        ? utf8.decode(httpResponse.bodyBytes)
        : "알 수 없는 오류 발생. \n 다시 시도해 주세요.";
    setState(() {
      serverResult = responseData;
    });

    onResult(responseData);

  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    renderingEngine = radVal == 0
        ? const TeXViewRenderingEngine.katex()
        : const TeXViewRenderingEngine.mathjax();

    String _simplifyLatex(String input) {

      input = input.replaceAll(r'\\(', r'\(').replaceAll(r'\\)', r'\)');
      input = input.replaceAll(r'\\[', r'\[').replaceAll(r'\\]', r'\]');
      input = input.replaceAll(r'\n', '\n');
      input = input.replaceAll(r'###', '<br>');

      final superscriptPattern = RegExp(r'([a-zA-Z])\^([0-9]+)');
      input = input.replaceAllMapped(superscriptPattern, (match) {
        return '${match.group(1)}^{${match.group(2)}}';
      });

      return input;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('풀이 결과')),
      body: SingleChildScrollView(  // Wrap the content in SingleChildScrollView
        child: Column(
          children: [
            Image.file(File(widget.image!.path)),
            serverResult == null
                ? Container(
              padding: EdgeInsets.fromLTRB(0.0, height * 0.05, 0.0, 0.0),
                child: const CupertinoActivityIndicator()
            )
                : Container(
              padding: EdgeInsets.fromLTRB(
                  width * 0.05, height * 0.05,
                  width * 0.05, height * 0.05),
              // width: width * 0.7,
              child: TeXView(
                // renderingEngine: const TeXViewRenderingEngine.mathjax(),
                child: TeXViewDocument(
                  _simplifyLatex(serverResult!),
                  style: const TeXViewStyle(
                    padding: TeXViewPadding.all(10),
                    contentColor: Colors.white,
                  ),
                ),
                // loadingWidgetBuilder: (context) {
                //   return const CupertinoActivityIndicator();
                // },
              ),
            ),
          ],
        ),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        tooltip: '다시 찍기',
        child: const Icon(Icons.backspace_rounded),
      ),
    );
  }
}