import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rich_editor/src/services/local_server.dart';
import 'package:rich_editor/src/utils/javascript_executor_base.dart';
import 'package:rich_editor/src/widgets/editor_tool_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RichEditor extends StatefulWidget {
  final String? value;
  final Function(File image)? getImageUrl;
  final Function(File video)? getVideoUrl;

  RichEditor({Key? key, this.value, this.getImageUrl, this.getVideoUrl})
      : super(key: key);

  @override
  RichEditorState createState() => RichEditorState();
}

class RichEditorState extends State<RichEditor> {
  WebViewController? _controller;
  String text = "";
  final Key _mapKey = UniqueKey();
  String assetPath = 'packages/rich_editor/assets/editor/editor.html';

  int port = 5321;
  String html = '';
  LocalServer? localServer;
  JavascriptExecutorBase javascriptExecutorBase = JavascriptExecutorBase();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    if (!Platform.isAndroid) {
      initServer();
    }
  }

  initServer() async {
    localServer = LocalServer(port);
    await localServer!.start(handleRequest);
  }

  void handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == "getRawTeXHTML") {
      } else {}
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller = null;
    }
    if (!Platform.isAndroid) {
      localServer!.close();
    }
    super.dispose();
  }

  _loadHtmlFromAssets() async {
    final filePath = assetPath;
    _controller!.loadUrl("http://localhost:$port/$filePath");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditorToolBar(
          controller: _controller,
          getImageUrl: widget.getImageUrl,
          javascriptExecutorBase: javascriptExecutorBase,
        ),
        Expanded(
          child: WebView(
            key: _mapKey,
            onWebViewCreated: (WebViewController controller) async {
              _controller = controller;
              print('WebView created');
              setState(() {});
              if (!Platform.isAndroid) {
                print('Loading');
                await _loadHtmlFromAssets();
              } else {
                await _controller!
                    .loadUrl('file:///android_asset/flutter_assets/$assetPath');
              }
              javascriptExecutorBase.init(_controller!);
              if (widget.value != null) {
                // wait  1 second before setting the html
                Timer(Duration(seconds: 1), () async {
                  await javascriptExecutorBase.setHtml(widget.value!);
                });
              }
            },
            javascriptMode: JavascriptMode.unrestricted,
            gestureNavigationEnabled: true,
            gestureRecognizers: [
              Factory(() => VerticalDragGestureRecognizer()..onUpdate = (_) {}),
            ].toSet(),
            onWebResourceError: (e) {
              print("error ${e.description}");
            },
          ),
        )
      ],
    );
  }

  Future<String?> getHtml() async {
    try {
      html = await javascriptExecutorBase.getCurrentHtml();
    } catch (e) {}
    return html;
  }

  setHtml(String html) async {
    return await javascriptExecutorBase.setHtml(html);
  }

  // Hide the keyboard using JavaScript since it's being opened in a WebView
  // https://stackoverflow.com/a/8263376/10835183
  unFocus() {
    _controller!.evaluateJavascript('document.activeElement.blur();');
  }

  // Clear editor content using Javascript
  clear() {
    _controller!.evaluateJavascript('document.getElementById(\'editor\').innerHTML = "";');
  }

  // Focus and Show the keyboard using JavaScript
  // https://stackoverflow.com/a/6809236/10835183
  focus() {
    _controller!.evaluateJavascript('document.getElementById(\'editor\').focus();');
  }
}
