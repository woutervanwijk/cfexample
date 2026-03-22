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
  FindController? _findController;
  bool lineWrapEnabled = true;

  Future<void> loadAsset(String fileName) async {
    fileContent = await rootBundle.loadString('assets/$fileName');
    codeController?.text = fileContent ?? 'No content';
  }

  void toggleLineWrap() {
    setState(() {
      lineWrapEnabled = !lineWrapEnabled;
    });
  }

  @override
  void initState() {
    super.initState();
    codeController = CodeForgeController();
    _findController = FindController(codeController!);
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
            IconButton(
              icon: Icon(lineWrapEnabled ? Icons.wrap_text : Icons.text_fields),
              tooltip: lineWrapEnabled
                  ? 'Disable Word Wrap'
                  : 'Enable Word Wrap',
              onPressed: toggleLineWrap,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Find',
              onPressed: () {
                setState(() {
                  _findController?.isActive = true;
                });
              },
            ),
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
                  value: 'example2.html',
                  child: Text('Example 2'),
                ),
                const PopupMenuItem<String>(
                  value: 'example3.html',
                  child: Text('Example 3'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: fileContent == null
              ? const Center(child: CircularProgressIndicator())
              : CodeForge(
                  lineWrap: lineWrapEnabled,
                  enableGuideLines: false,
                  enableKeyboardSuggestions: false,
                  enableSuggestions: false,
                  undoController: undoController,
                  findController: _findController,
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
                  finderBuilder: (c, controller) {
                    return FindPanelView(controller: _findController!);
                  },
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
