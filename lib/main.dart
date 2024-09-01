import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera/camera_controller.dart';
import 'camera/photo_taker.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera, camera: firstCamera,));
}

class MyApp extends StatelessWidget {
  const MyApp(CameraDescription firstCamera, {
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '더웰 GPT',
      theme: ThemeData(
        primaryColor: Colors.black87,
        colorScheme: const ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        title: '더웰 GPT',
        camera: camera,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePictureScreen(camera: widget.camera),
                ));
              },
              icon: const Icon(Icons.camera_enhance_rounded),
              label: const Text(
                '문제 사진 찍기',
                style: TextStyle(
                    fontSize: 25
                ),
              ),
            ),

            const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
            TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.history_outlined),
                label: const Text(
                    '검색 기록 확인하기',
                    style: TextStyle(
                        fontSize: 25
                    )
                )
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   backgroundColor: Colors.yellow,
      //   child: const Icon(Icons.live_help_rounded),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
