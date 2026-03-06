import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';

class BackgroundRenderer extends StatelessWidget{
  final EditorState editorState;

  const BackgroundRenderer({super.key, required this.editorState});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: editorState.file!.appState.viewBackgroundColor.color,
    );
  }
}