import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewell_frontend/main.dart';

import '../util/util.dart';

// ignore: must_be_immutable
class LoginPage extends StatefulWidget {
  static String id = '/LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String userId = "";
  late String password = "";

  bool _emptyIdField = false;
  bool _emptyPasswordField = false;

  bool _showSpinner = false;

  String emailText = '아이디를 입력해주세요.';
  String passwordText = '비밀번호를 입력해주세요.';

  String welcomeText = '\n로그인을 해주세요.';

  Future<void> _saveLoginInfo(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString("userId", userId);
    // await prefs.setString('userToken', 'your_token'); // Save user token if needed
  }

  void _showLoginFailedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text('아이디 또는 비밀번호를 다시 확인해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _switchToMainPage() {
    Navigator.pushReplacementNamed(context, MyHomePage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enable resizing when keyboard appears
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          color: Colors.blueAccent,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 60.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '더웰 GPT',
                    style: TextStyle(fontSize: 50.0),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcomeText,
                        style: TextStyle(fontSize: 30.0),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          userId = value;
                        },
                        decoration: InputDecoration(
                          hintText: '학원에서 전달받은 아이디를 입력하세요.',
                          labelText: '아이디',
                          errorText: _emptyIdField ? '아이디를 입력해주세요.': null ,
                          labelStyle: _emptyIdField ? TextStyle(color: Colors.red) : null
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) {
                          password = value;
                        },
                        decoration: InputDecoration(
                            hintText: '학원에서 전달받은 비밀번호를 입력하세요.',
                            labelText: '비밀번호',
                            errorText: _emptyPasswordField ? '비밀번호를 입력해주세요.':  null,
                            labelStyle: _emptyPasswordField ? TextStyle(color: Colors.red): null,
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {


                      if (userId.isEmpty) {
                        setState((){_emptyIdField = true;});
                        print("user id empty. _emptyIdField: $_emptyIdField");
                      }
                      else { setState((){_emptyIdField = false;});  }

                      if (password.isEmpty) {
                        setState((){_emptyPasswordField = true;});
                        print("password empty. _emptyPasswordField: $_emptyPasswordField");
                      }
                      else { setState(() {_emptyPasswordField = false;});}


                      if (userId.isNotEmpty && password.isNotEmpty) {

                        setState(() {_showSpinner = true;});

                        final url = "$serverUrl/auth/login";

                        final response = await http.post(
                          Uri.parse(url),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, String>{
                            'id': userId,
                            'password': password,
                          }),
                        );

                        if (response.statusCode == 200) {
                          _saveLoginInfo(userId);
                          _switchToMainPage();
                        } else {
                          _showLoginFailedDialog();
                          setState((){userId = "";});
                          setState((){password = "";});
                        }
                        setState(() {_showSpinner = false;});
                      }
                    },
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 25.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}