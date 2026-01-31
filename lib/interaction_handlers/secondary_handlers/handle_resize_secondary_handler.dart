import 'dart:ui';
import 'package:freeform_canvas/hit_testers/extended_hit_tester.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/secondary_handlers/element_edit_secondary_handler.dart';

///按到`ResizeHandle`且允许矩形缩放：处理缩放交互
class HandleResizeEditSecondaryHandler extends InteractionSecondaryHandler{
  HandleResizeEditSecondaryHandler(this.resizeHandle);

  ResizeHandle resizeHandle;
  late HandleResizeSession handleResizeSession;
  @override
  void onPanStart(Offset canvasPoint, EditorState editorState) {
    handleResizeSession = HandleResizeSession(resizeHandle: resizeHandle, editorState: editorState);
    handleResizeSession.onStart(canvasPoint);
  }

  @override
  void onPanUpdate(Offset canvasPoint, EditorState editorState) {
    handleResizeSession.onUpdate(canvasPoint);
  }

  @override
  void onPanEnd(EditorState editorState) {
    handleResizeSession.onEnd();
  }
}