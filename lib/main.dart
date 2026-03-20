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

  Future<void> loadAsset() async {
    fileContent = await rootBundle.loadString('assets/mozilla.org.html');
  }

  @override
  void initState() {
    super.initState();
    loadAsset();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            codeController?.setGitDiffDecorations(
              addedRanges: [(1, 5), (10, 25)],
              removedRanges: [
                (
                  afterLine: 29,
                  content:
                      'final x = 10;\nfinal y = 20;\nprint("removed line");',
                ),
              ],
            );
            codeController?.scrollToLine(30);
          },
        ),
        body: SafeArea(
          child: FutureBuilder<void>(
            future: loadAsset(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (fileContent == null) {
                return const Center(child: Text("Failed to load asset"));
              }
              return CodeForge(
                undoController: undoController,
                language: langXml,
                editorTheme: atomOneDarkReasonableTheme,
                controller: codeController,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
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
              );
            },
          ),
        ),
      ),
    );
  }
}
