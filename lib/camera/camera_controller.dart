// A screen that allows users to take a picture using a given camera.
import 'dart:async';
import 'dart:io';
import 'dart:math';
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
import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';

import 'answer_viewer.dart';
import 'file_selector.dart';
//
//
// class TakePictureScreen extends StatefulWidget {
//   const TakePictureScreen({
//     super.key,
//     required this.camera,
//   });
//
//   final CameraDescription camera;
//
//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }
//
// class TakePictureScreenState extends State<TakePictureScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   int selectedIndex = 0;
//   List<bool> selected = [true, false];
//   bool _isLoading = false;
//   String? _serverResult;
//   File? _imageFile;
//   double _currentZoomLevel = 1.0;
//   double _minZoomLevel = 1.0;
//   double _maxZoomLevel = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.medium,
//       imageFormatGroup: ImageFormatGroup.bgra8888
//     );
//
//     _initializeControllerFuture = _controller.initialize().then((_) async {
//       setState(() {
//         _controller.getMinZoomLevel().then((value) {_minZoomLevel = value;});
//         _controller.getMaxZoomLevel().then((value) {_maxZoomLevel = value;});
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _focusCamera(TapDownDetails details, BoxConstraints constraints) async {
//     final offsetX = details.localPosition.dx / constraints.maxWidth;
//     final offsetY = details.localPosition.dy / constraints.maxHeight;
//
//     try {
//       await _controller.setFocusPoint(Offset(offsetX, offsetY));
//     } catch (e) {
//       print("Error focusing camera: $e");
//     }
//   }
//
//   Future<void> requestImage(String imagePath, Function(String?) onResult) async {
//     setState(() {
//       _serverResult = null;
//     });
//
//     Image myImage = (kIsWeb)
//         ? Image.network(imagePath)
//         : Image.file(File.fromUri(Uri.parse(imagePath)));
//
//     final ImageStream imageStream = myImage.image.resolve(const ImageConfiguration());
//     final Completer<ui.Image> completer = Completer<ui.Image>();
//
//     imageStream.addListener(
//       ImageStreamListener((ImageInfo info, bool _) {
//         completer.complete(info.image);
//       }),
//     );
//
//     final ui.Image uiImage = await completer.future;
//     final ByteData? byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
//     final Uint8List? bytes = byteData?.buffer.asUint8List();
//
//     var request = http.MultipartRequest("POST", Uri.parse("http://172.30.1.96:8000/upload-file"));
//
//     request.files.add(
//       http.MultipartFile.fromBytes("file", bytes as List<int>, filename: "image.png"),
//     );
//     request.headers['subject'] = "$selectedIndex";
//
//     final response = await request.send();
//     final httpResponse = await http.Response.fromStream(response);
//
//     final responseData = (httpResponse.statusCode == 200)
//         ? utf8.decode(httpResponse.bodyBytes)
//         : "알 수 없는 오류 발생. \n 다시 시도해 주세요.";
//     setState(() {
//       _serverResult = responseData;
//     });
//
//     onResult(responseData);
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('문제 사진 찍기')),
//       body: Column(
//         children: <Widget>[
//           FutureBuilder<void>(
//             future: _initializeControllerFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 return SizedBox(
//                   width: min(
//                     _controller.value.previewSize!.width,
//                     MediaQuery.of(context).size.width,
//                   ),
//                   height: min(
//                     _controller.value.previewSize!.height,
//                     MediaQuery.of(context).size.height * 0.7,
//                   ),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return GestureDetector(
//                         onTapDown: (details) => _focusCamera(details, constraints),
//                         onScaleUpdate: (details) {
//                           if (details.scale != 1.0) {
//                             setState(() {
//                               _currentZoomLevel = (_currentZoomLevel * details.scale)
//                                   .clamp(_minZoomLevel, _maxZoomLevel);
//                               _controller.setZoomLevel(_currentZoomLevel);
//                             });
//                           }
//                         },
//                         child: CameraPreview(_controller),
//                       );
//                     },
//                   ),
//                 );
//               } else {
//                 return const Center(child: CircularProgressIndicator());
//               }
//             },
//           ),
//           Container(
//             padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
//             child: _isLoading? const CircularProgressIndicator() :
//             ToggleButtons(
//               isSelected: selected,
//               children: const [Text("수학"), Text("과학")],
//               onPressed: (int index) {
//                 setState(() {
//                   selectedIndex = index;
//                   selected = selected.map((e) => false).toList();
//                   selected[selectedIndex] = true;
//                 });
//               },
//             ),
//           ),
//           const Spacer(),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.9,
//             padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//             child: Row(
//               children: [
//                 // Align(
//                 //   alignment: Alignment.bottomLeft,
//                 //   child: FloatingActionButton(
//                 //     heroTag: "upload",
//                 //     onPressed: () {
//                 //       Navigator.of(context).push(_createImageUploadRoute());
//                 //     },
//                 //     tooltip: '사진 업로드하기',
//                 //     // backgroundColor: Colors.yellow,
//                 //     child: const Icon(Icons.photo_album_rounded),
//                 //   ),
//                 // ),
//                 const Spacer(),
//                 Align(
//                   alignment: Alignment.center,
//                   child: FloatingActionButton(
//                     heroTag: "photo",
//                     onPressed: () async {
//                       try {
//
//                         setState(() {
//                           _isLoading = true;
//                         });
//
//                         await _initializeControllerFuture;
//
//                         final image = await _controller.takePicture();
//
//                         requestImage(image.path, (result) {
//                           // Navigator.of(context).push(
//                           //     MaterialPageRoute(
//                           //         builder: (context) => DisplayPictureScreen(
//                           //           imagePath: image.path,
//                           //           answerString: _serverResult,
//                           //         )
//                           //     )
//                           // );
//                           setState(() {
//                             _isLoading = false;
//                           });
//                         });
//                       }
//                       catch (e) {
//                         print(e);
//                       }
//                     },
//                     child: const Icon(Icons.camera_alt),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//
//
//     );
//   }
// }
