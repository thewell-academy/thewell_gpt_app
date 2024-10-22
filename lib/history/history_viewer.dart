import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // For base64 encoding/decoding
import 'dart:typed_data';  // For Uint8List (binary data)

import '../util/util.dart';
import 'history_detail_viewer.dart';

class HistoryViewer extends StatefulWidget {
  const HistoryViewer({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryViewerState();
}

class _HistoryViewerState extends State<HistoryViewer> {
  static const List<String> subjects = ['전체 과목', '수학', '과학'];

  String selectedSubject = subjects.first;
  DateTime? startDay = null;
  DateTime? endDay = null;
  bool isLoading = false;
  bool isSearched = false;
  List<dynamic> answer = [];

  String _startDateString = "시작 날짜";
  String _endDateString = "종료 날짜";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("질문 기록")),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.,
        children: [
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? datetime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(3000)
                      );
                      if (datetime != null){
                        startDay = datetime;
                        setState(() {
                          _startDateString = "시작: ${datetime.year}-${datetime.month}-${datetime.day}";
                        });
                      }
                    },
                    child: Text(_startDateString),
                ),
              ),
              Spacer(),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: ElevatedButton(
                    onPressed: () async {
                      final DateTime? datetime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(3000)
                      );
                      if (datetime != null){
                        endDay = datetime;
                        setState(() {
                          _endDateString = "종료: ${datetime.year}-${datetime.month}-${datetime.day}";
                        });
                      }
                    },
                    child: Text(_endDateString)
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: DropdownButton(
                    value: selectedSubject,
                    icon: const Icon(Icons.arrow_downward_rounded),
                    items: subjects.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedSubject = value!;
                      });
                    }
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                    print(startDay);
                    print(endDay);

                    if (startDay == null && endDay == null ) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text('시작 또는 종료 날짜를 선택해주세요.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else if ((startDay != null && endDay != null) && endDay!.isBefore(startDay!)){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('오류'),
                            content: Text('종료 날짜는 시작 날짜 이후로 설정되어야 합니다.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                    else {
                      if (startDay == null && endDay != null) {
                        startDay = DateTime(2024, 1 , 1);
                      } else if (startDay != null && endDay == null) {
                        endDay = DateTime.now();
                      }
                      setState(() {
                        isSearched = false;
                        isLoading = true;
                      });
                    }
                    String? deviceId = await PlatformDeviceId.getDeviceId;
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String userId = prefs.getString('userId')!;
                    final response = await http
                        .get(Uri.parse(
                        '$serverUrl/ask/history/$selectedSubject/$userId?start=$startDay&end=$endDay'
                    ));

                    if (response.statusCode == 200) {
                      setState(() {
                        isSearched = true;
                        isLoading = false;
                      });
                      List<dynamic> jsonList = jsonDecode(response.body);
                      setState(() {
                        answer = jsonList;
                      });
                      print("size: ${answer.length}");
                    } else{
                      setState(() {
                        isSearched = true;
                        isLoading = false;
                      });
                    }
                    },
                label: Text("검색하기"),
                icon: Icon(Icons.search_rounded),
              )
            ],
          ),

          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            child: (isSearched && answer.isNotEmpty)
                ? ListView.builder(
              itemCount: answer.length,
              itemBuilder: (context, index) {
                final String id = answer[index]['id']!;
                final String name = answer[index]['subject']!;
                final DateTime createdAt = DateTime.parse(answer[index]['created_at']);
                final String base64Image = answer[index]['image_preview']!;
                Uint8List imageBytes = base64Decode(base64Image);
                Image image = Image.memory(imageBytes,fit: BoxFit.contain,);
                return ListTile(
                  leading:
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: image
                  ),
                  title: Text(name),  // Display the name
                  subtitle: Text("${createdAt.year}-${createdAt.month}-${createdAt.day} ${createdAt.hour}:${createdAt.minute}:${createdAt.second}"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryDetailViewer(
                              dateTime: '',
                              image: image,
                              answer: answer[index]['answer'],
                            )
                        )
                    );
                  },
                );
              },
            )
            : (isSearched && answer.isEmpty)
                ? const Text("검색 결과 없음")
                : isLoading
                ? const CupertinoActivityIndicator()
                : const Text("검색 시작날짜와 종료날짜 선택 후 검색하기 버튼을 눌러주세요.")
          )
        ],
      ),
    );
  }
}

