import 'package:example/finder.dart';
import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/styles/atom-one-dark-reasonable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final undoController = UndoRedoController();
  String? fileContent;
  CodeForgeController? codeController;

  Future<void> loadAsset(String fileName) async {
    fileContent = await rootBundle.loadString('assets/$fileName');
    codeController?.text = fileContent ?? 'No content';
  }

  @override
  void initState() {
    super.initState();
    codeController = CodeForgeController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadAsset('example.html');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Code Example'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                await loadAsset(value);
                setState(() {});
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'example.html',
                  child: Text('Example'),
                ),
                const PopupMenuItem<String>(
                  value: 'mozilla.org.html',
                  child: Text('Mozilla'),
                ),
                const PopupMenuItem<String>(
                  value: 'nytimes.com.html',
                  child: Text('NYTimes'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: fileContent == null
              ? const Center(child: CircularProgressIndicator())
              : CodeForge(
                  undoController: undoController,
                  language: langXml,
                  editorTheme: atomOneDarkReasonableTheme,
                  controller: codeController,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'mono',
                    fontFamilyFallback: [
                      'Courier',
                      'Courier New',
                      'SF Mono',
                      'monospace',
                    ],
                  ),
                  initialText: fileContent,
                  matchHighlightStyle: const MatchHighlightStyle(
                    currentMatchStyle: TextStyle(
                      backgroundColor: Color(0xFFFFA726),
                    ),
                    otherMatchStyle: TextStyle(
                      backgroundColor: Color(0x55FFFF00),
                    ),
                  ),
                  finderBuilder: (c, controller) =>
                      FindPanelView(controller: controller),
                  customCodeSnippets: [
                    CustomCodeSnippet(
                      label: 'if',
                      value: 'if (condition) {\n  \n}',
                      cursorLocations: {4},
                    ),
                    CustomCodeSnippet(
                      label: 'if-else',
                      value: 'if (condition) {\n  \n} else {\n  \n}',
                      cursorLocations: {18, 31},
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
