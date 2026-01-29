import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';

///**ZH** 橡皮擦工具
/// 
///**EN** Eraser tool
class EraserHandler extends InteractionHandler{
  final session = EraserSession();
  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    session.onUpdate(canvasPoint, editorState);
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    session.onUpdate(canvasPoint, editorState);
  }
}