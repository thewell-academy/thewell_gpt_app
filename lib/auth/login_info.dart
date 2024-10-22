import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveLoginInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save a boolean flag for auto-login
  await prefs.setBool('isLoggedIn', true);

  // Optionally, save user token or other info
  // await prefs.setString('userToken', 'your_token');
}