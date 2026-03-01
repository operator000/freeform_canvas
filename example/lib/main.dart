import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/freeform_canvas_parser.dart';
import 'embedded_file.dart';
import 'package:freeform_canvas/windows_freeform_canvas.dart';

void main() async {
  runApp(const FreeformCanvasExampleApp());
}

class FreeformCanvasExampleApp extends StatefulWidget {
  const FreeformCanvasExampleApp({super.key});

  @override
  State<FreeformCanvasExampleApp> createState() => _FreeformCanvasExampleAppState();
}

class _FreeformCanvasExampleAppState extends State<FreeformCanvasExampleApp> {
  EditorState? editorState = EditorState(file: FreeformCanvasParser.parseFromString(EMBEDDED))
    ..embeddableRenderer = (editor, width, height, screenPosition, element) {
      print('embeddable renderer:$width $height $screenPosition');
    };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeformCanvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
      ),
      home: Scaffold(
        body: SafeArea(
          child: WindowsFreeformCanvas(
            editorState: editorState,
            onSave: (file) {
              print('save...');
            },
          )
        )
      ),
    );
  }
}