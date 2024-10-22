import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

import '../util/util.dart';

class HistoryDetailViewer extends StatefulWidget {
  final String dateTime;
  final Image image;
  final String answer;

  const HistoryDetailViewer({
    super.key,
    required this.dateTime,
    required this.image,
    required this.answer
  });

  @override
  State<StatefulWidget> createState() => _HistoryDetailViewerState();
}

class _HistoryDetailViewerState extends State<HistoryDetailViewer> {

  late TeXViewRenderingEngine renderingEngine;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('풀이 결과')),
      body: SingleChildScrollView(  // Wrap the content in SingleChildScrollView
        child: Column(
          children: [
            widget.image,
            Container(
              padding: EdgeInsets.fromLTRB(
                  width * 0.05, height * 0.05,
                  width * 0.05, height * 0.05),

              // width: width * 0.7,
              child: TeXView(
                // renderingEngine: const TeXViewRenderingEngine.mathjax(),
                child: TeXViewDocument(
                  simplifyLatex(widget.answer),
                  style: const TeXViewStyle(
                    padding: TeXViewPadding.all(10),
                    contentColor: Colors.white,
                  ),
                ),
                loadingWidgetBuilder: (context) {
                  return Row(
                    children: const [
                      Spacer(),
                      CupertinoActivityIndicator(),
                      Spacer()
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}