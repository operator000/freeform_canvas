import 'dart:ui';
import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/element_edit_controller.dart';

class RotateEditController extends ElementEditController{
  final session = RotateSession();
  @override
  void onPanStart(Offset canvasPoint, EditorState editorState) {
    session.onStart(canvasPoint, editorState);
  }

  @override
  void onPanUpdate(Offset canvasPoint, EditorState editorState) {
    session.onUpdate(canvasPoint, editorState);
  }

  @override
  void onPanEnd(EditorState editorState) {
    session.onEnd(editorState);
  }
}