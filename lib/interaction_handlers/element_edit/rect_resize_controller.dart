import 'dart:ui';
import 'package:freeform_canvas/extended_hit_tester.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/element_edit_controller.dart';

///按到`ResizeHandle`且允许矩形缩放：处理缩放交互
class RectResizeEditController extends ElementEditController{
  RectResizeEditController(this.resizeHandle);

  ResizeHandle resizeHandle;
  late RectResizeSession rectResizeSession;
  @override
  void onPanStart(Offset canvasPoint, EditorState editorState) {
    rectResizeSession = RectResizeSession(resizeHandle: resizeHandle, editorState: editorState);
    rectResizeSession.onStart(canvasPoint);
  }

  @override
  void onPanUpdate(Offset canvasPoint, EditorState editorState) {
    rectResizeSession.onUpdate(canvasPoint);
  }

  @override
  void onPanEnd(EditorState editorState) {
    rectResizeSession.onEnd();
  }
}