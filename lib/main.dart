import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Entrypoint of the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  late final InAppWebViewController webViewController;
  late final TextEditingController urlController;
  bool _isMenuOpen = false;
  final String imageHTML = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Centered Image</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        img {
            max-width: 100%;
            max-height: 100%;
        }
    </style>
    <script>
        function updateImageSrc(url) {
            document.getElementById('dynamicImage').src = url;
        }
        function toggleFullScreen() {
            if (!document.fullscreenElement) {
                document.documentElement.requestFullscreen();
            } else {
                if (document.exitFullscreen) {
                    document.exitFullscreen();
                }
            }
        }
    </script>
</head>
<body>
    <img id="dynamicImage" src="https://picsum.photos/id/59/100/100?" alt="Centered Image" ondblclick="toggleFullScreen()">
</body>
</html>
''';

  String get url => urlController.text;

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isMenuOpen ? 0.5 : 1.0,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InAppWebView(
                      initialData: InAppWebViewInitialData(data: imageHTML),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                      ),
                      onWebViewCreated: (controller) async {
                        webViewController = controller;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(hintText: 'Image URL'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (urlController.text.isNotEmpty) {
                        webViewController.addJavaScriptHandler(handlerName: "handlerName", callback: (sdsd){});
                        webViewController.evaluateJavascript(source: "updateImageSrc('$url')");
                        // webViewController.callAsyncJavaScript(functionBody: "updateImageSrc('$url')");
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showContextMenu(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) async {
    setState(() {
      _isMenuOpen = true;
    });

    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(
              overlay.size.bottomRight(Offset.zero) - Offset(56, 56)),
          overlay.localToGlobal(overlay.size.bottomRight(Offset.zero)),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: "enter",
          child: Text("Enter fullscreen"),
        ),
        PopupMenuItem(
          value: "exit",
          child: Text("Exit fullscreen"),
        ),
      ],
    ).then((value) {
      setState(() {
        _isMenuOpen = false;
      });
      if (value != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$value selected')),
        );
      }
    });
  }
}
