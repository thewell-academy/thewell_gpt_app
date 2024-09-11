import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thewell_frontend/util/util.dart';
import 'dart:io';

import 'camera/answer_viewer.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera, camera: firstCamera,));
}

class MyApp extends StatefulWidget {
  const MyApp(CameraDescription firstCamera, {
    super.key,
    required this.camera,
  });
  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  ThemeData _themeData = ThemeData(
    primaryColor: Colors.black87,
    colorScheme: const ColorScheme.dark()
  );

  String _appTitle = "더웰 GPT";

  @override
  void initState() {
    super.initState();
    serverHandShake(_updateTitle);
  }

  void _updateTheme(ThemeData newTheme) {
    setState(() {
      _themeData = newTheme;
    });
  }

  void _updateTitle(String title) {
    setState(() {
      _appTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: _appTitle,
      theme: ThemeData(
        primaryColor: Colors.black87,
        colorScheme: const ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: _appTitle,
        camera: widget.camera,
      ),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.camera
  });

  final String title;
  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int selectedIndex = 0;
  List<bool> selected = [true, false];

  // Function to capture image using the native camera app
  Future<void> _takePicture() async {
    try {
      // Pick an image using the camera
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      // If an image is returned, set the image in the state
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<void> _browsePicture() async {
    try {
      // Pick an image using the camera
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      // If an image is returned, set the image in the state
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          ),
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _takePicture().then((value) =>
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DisplayPictureScreen(
                              image: _image!,
                              selectedIndex: selectedIndex,
                            )
                    )
                )
            );
            },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 100,
          color: Colors.cyan.shade400,
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.file_open_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _browsePicture().then((value) =>
                    _image != null
                      ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DisplayPictureScreen(image: _image!, selectedIndex: selectedIndex,)
                        )
                    ): () {}
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
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
        )


      );

    //   Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   bottomNavigationBar: BottomNavigationBar(
    //     items: const <BottomNavigationBarItem>[
    //       BottomNavigationBarItem(
    //         icon: Icon(Icons.home),
    //         label: '홈'
    //       ),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.person),
    //           label: '나의 정보'
    //       )
    //     ],
    //   ),
    //   floatingActionButton: FloatingActionButton(onPressed: () {  },
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         TextButton.icon(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) =>
    //                     // TakePictureScreen(camera: widget.camera),
    //                 TakePictureUsingNativeApp()
    //             ));
    //           },
    //           icon: const Icon(Icons.camera_enhance_rounded),
    //           label: const Text(
    //             '문제 사진 찍기',
    //             style: TextStyle(
    //                 fontSize: 25
    //             ),
    //           ),
    //         ),
    //
    //         const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
    //         TextButton.icon(
    //             onPressed: () {},
    //             icon: const Icon(Icons.history_outlined),
    //             label: const Text(
    //                 '검색 기록 확인하기',
    //                 style: TextStyle(
    //                     fontSize: 25
    //                 )
    //             )
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
