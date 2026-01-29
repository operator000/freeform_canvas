import 'dart:ui';

import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/element_edit_controller.dart';

///按到元素本身：处理平移交互
class DragEditController extends ElementEditController{
  final String elementId;
  late ElementDragSession elementDragSession;
  DragEditController(this.elementId);
  @override
  void onPanStart(Offset canvasPoint, EditorState editorState) {
    elementDragSession = ElementDragSession(editorState: editorState, elementId: elementId);
    elementDragSession.onStart(canvasPoint);
    return;
  }

  @override
  void onPanUpdate(Offset canvasPoint, EditorState editorState) {
    elementDragSession.onUpdate(canvasPoint);
  }

  @override
  void onPanEnd(EditorState editorState) {
    elementDragSession.onEnd();
  }
}

///按到空白：清空focus
class ClearFocusController extends ElementEditController{
  @override
  void onPanStart(_,EditorState editorState) {
    editorState.focusState.cancelFocus();
    editorState.quitTextEdit();
  }

  @override
  void onPanUpdate(_,_) {}

  @override
  void onPanEnd(_) {}
}