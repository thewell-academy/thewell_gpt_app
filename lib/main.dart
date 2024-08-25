import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '더웰 수학',
      theme: ThemeData(
        primaryColor: Colors.black87,
        colorScheme: const ColorScheme.dark(),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: '더웰 수학'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
              onPressed: () {},
              icon: const Icon(Icons.camera_enhance_rounded),
              label: const Text(
                '수학 문제 사진 찍기',
                style: TextStyle(
                    fontSize: 25
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text(
                '문제 사진 업로드하기',
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
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.live_help_rounded),
        backgroundColor: Colors.yellow,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
