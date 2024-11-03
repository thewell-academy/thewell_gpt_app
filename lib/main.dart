import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_editor/image_editor.dart' as editor;
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewell_frontend/history/history_viewer.dart';
import 'package:thewell_frontend/util/util.dart';
import 'dart:io';

import 'auth/login.dart';
import 'camera/answer_viewer.dart';
import 'package:http/http.dart' as http;

const platform = MethodChannel('com.example.thewellFrontend/image_editor');


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedIn = await checkLoginStatus();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera, camera: firstCamera,isLoggedIn: isLoggedIn,));
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return ((prefs.getBool('isLoggedIn')?? false) && (prefs.getString("userId") != null)) ? true : false;
}

class MyApp extends StatefulWidget {
  const MyApp(CameraDescription firstCamera, {
    super.key,
    required this.camera,
    required this.isLoggedIn
  });
  final CameraDescription camera;
  final bool isLoggedIn;

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _appTitle = "더웰 GPT";
  Color _appBarColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    serverHandShake(_updateServerStatus);
  }

  void _updateServerStatus(String title, Color color) {
    setState(() {
      _appTitle = title;
      _appBarColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: _appTitle,
      theme: ThemeData(
        primaryColor: _appBarColor,
        colorScheme: const ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: widget.isLoggedIn
          ? MyHomePage.id
          : LoginPage.id,

      routes: {
        LoginPage.id: (context) => LoginPage(),
        MyHomePage.id: (context) => MyHomePage(
          title: _appTitle,
          appBarColor: _appBarColor,
          camera: widget.camera,
        )
      },
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.appBarColor,
    required this.camera
  });

  final String title;
  final Color appBarColor;
  final CameraDescription camera;

  static String id = '/MyHomePage';

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  int selectedIndex = 0;
  List<bool> selected = [true, false];

  // Function to capture image using the native camera app
  Future<void> _takePictureAndEdit() async {
    setState(() {
      _image = null;
    });
    try {
      // Call native code to open the camera with editing enabled
      final editedImagePath = await platform.invokeMethod<String>('takeAndEditPhoto');

      if (editedImagePath != null) {
        setState(() {
          _image = File(editedImagePath);
        });
      } else {
        print("Edited image path is null.");

      }
    } on PlatformException catch (e) {
      setState(() {
        _image = null;
      });
      print("Error editing picture: $e");
    }
  }


  Future<void> _browsePicture() async {
    try {
      // Pick an image using the gallery from image_picker
      final pickedFile = await _picker.pickImage(source: picker.ImageSource.gallery);

      // If an image is returned, set the image in the state
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await _showConfirmationDialog();
      }
    } catch (e) {
      setState(() {
        _image = null;
      });
      print("Error taking picture: $e");
    }
  }

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('사진 확인'),
          content: _image != null
              ? Image.file(_image!)
              : Text('No image selected.'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                _navigateToNextPage();  // Proceed to the next page
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextPage() {

    File imageCopy = _image!;
    setState(() {
      _image = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(image: imageCopy, selectedIndex: selectedIndex),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("로그아웃"),
          content: Text("정말 로그아웃 할까요?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: Text("아니오"),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
                _logout(context);  // Proceed with logout
              },
              child: Text("네"),
              isDefaultAction: true,
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    // Clear user data (example with shared preferences)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navigate to the login page
    Navigator.pushReplacementNamed(context, '/LoginPage');
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: widget.appBarColor,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _showLogoutConfirmation(context);
              },
            ),
          ],
          ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Spread items vertically
          crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretch items to full width (for center alignment)
          children: [
            Spacer(),  // Push content down to the bottom

            // ToggleButtons centered both horizontally and vertically
            Center(
              child: ToggleButtons(
                isSelected: selected,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text("수학 질문하기"),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Text("과학 질문하기"),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    selectedIndex = index;
                    selected = selected.map((e) => false).toList();
                    selected[selectedIndex] = true;
                  });
                },
              ),
            ),

            // Spacer to push the ToggleButtons up just above the bottom navigation bar
            SizedBox(height: 150),  // Ensure there's spacing from the BottomNavigationBar
          ],
        ),
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            _takePictureAndEdit().then((value) {
              if (_image != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DisplayPictureScreen(
                            image: _image!,
                            selectedIndex: selectedIndex,
                          )
                  ));
              }
            });},
          backgroundColor: Colors.purple.shade400,
          child: const Icon(Icons.camera_alt_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 100,
          color: Colors.deepPurpleAccent.shade100,
          shape: const CircularNotchedRectangle(),
          notchMargin: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.image,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                  _browsePicture();
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryViewer())
                  );
                },
              ),
            ],
          ),
        ),

      );
  }
}
