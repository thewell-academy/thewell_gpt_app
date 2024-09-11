import 'package:platform_device_id/platform_device_id.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';  // Import for Timer

Timer? _retryTimer;

String serverUrl = "http://172.30.1.26:8000";

Future<void> serverHandShake(Function(String) updateString) async {
  print("handshake ${DateTime.now()}");

  try {
    String? deviceId = await PlatformDeviceId.getDeviceId;

    // Add a timeout of 10 seconds to the HTTP request
    final response = await http
        .get(Uri.parse('$serverUrl/${deviceId.toString()}'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      // If the response is not 200, change the theme and retry after 5 seconds
      updateString("서버 오류");

      // Retry after 5 seconds
      _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateString));
    } else {
      // If the response is 200, change the theme to green and cancel the timer
      // updateString("더웰 GPT");
      _retryTimer?.cancel();  // Stop retrying if the response is 200
    }
  } on TimeoutException catch (_) {
    // Handle timeout by updating theme and retrying after 5 seconds
    print("Request to server timed out");
    updateString("서버 오류");

    // Retry after 5 seconds
    _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateString));
  } catch (e) {
    // Handle other errors by updating theme and retrying after 5 seconds
    print("Error occurred: $e");
    updateString("서버 오류");

    // Retry after 5 seconds
    _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateString));
  }
}

String getSubject(int index) {
  if (index == 0) {
    return "math";
  } else if (index == 1) {
    return "science";
  } else {
    return "unknown";
  }
}