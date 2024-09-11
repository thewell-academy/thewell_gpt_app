// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
//
// class TakePictureUsingNativeApp extends StatefulWidget {
//   @override
//   _TakePictureUsingNativeAppState createState() =>
//       _TakePictureUsingNativeAppState();
// }
//
// class _TakePictureUsingNativeAppState extends State<TakePictureUsingNativeApp> {
//   File? _image;
//   final ImagePicker _picker = ImagePicker();
//
//   // Function to capture image using the native camera app
//   Future<void> _takePicture() async {
//     try {
//       // Pick an image using the camera
//       final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//
//       // If an image is returned, set the image in the state
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       print("Error taking picture: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Native Camera App'),
//       ),
//       body: Center(
//         child: _image == null
//             ? Text('No image taken yet.')
//             : Image.file(_image!),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _takePicture,  // Take picture using the native camera app
//         child: Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }
//
// void main() {
//   runApp(MaterialApp(
//     home: TakePictureUsingNativeApp(),
//   ));
// }