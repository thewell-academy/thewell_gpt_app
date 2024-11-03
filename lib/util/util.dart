import 'package:platform_device_id/platform_device_id.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:thewell_frontend/util/server_config.dart';  // Import for Timer

Timer? _retryTimer;

String serverUrl = gptServerUrl;

Future<void> serverHandShake(Function(String, Color) updateStatus) async {

  try {
    String? deviceId = await PlatformDeviceId.getDeviceId;

    // Add a timeout of 10 seconds to the HTTP request
    final response = await http
        .get(Uri.parse('$serverUrl/auth/$deviceId'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      // If the response is not 200, change the theme and retry after 5 seconds
      updateStatus("서버 오류", Colors.red);

      // Retry after 5 seconds
      _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateStatus));
    } else {
      updateStatus("더웰 GPT", Colors.black87);
      _retryTimer?.cancel();  // Stop retrying if the response is 200
    }
  } on TimeoutException catch (_) {
    // Handle timeout by updating theme and retrying after 5 seconds
    updateStatus("서버 연결 실패", Colors.orange);

    // Retry after 5 seconds
    _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateStatus));
  } catch (e) {
    // Handle other errors by updating theme and retrying after 5 seconds
    print("Error occurred: $e");
    updateStatus("알 수 없는 오류", Colors.red);

    // Retry after 5 seconds
    _retryTimer = Timer(const Duration(seconds: 5), () => serverHandShake(updateStatus));
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

String simplifyLatex(String input) {

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