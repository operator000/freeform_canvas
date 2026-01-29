import 'package:flutter/gestures.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/element_edit_controller.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';

class SelectHandler extends InteractionHandler {
  ElementEditController? _editController;
  late Offset lastCanvasPoint;
  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    _editController = ElementEditController.createController(event.localPoint, editorState);
    lastCanvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    _editController!.onPanStart(
      lastCanvasPoint, 
      editorState
    );
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    _editController!.onPanUpdate(
      canvasPoint - lastCanvasPoint, 
      editorState
    );
    lastCanvasPoint = canvasPoint;
  }

  @override
  void onScaleEnd(InputEndEvent event,EditorState editorState){
    _editController?.onPanEnd(editorState);
  }
}