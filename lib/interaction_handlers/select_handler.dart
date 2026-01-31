import 'package:flutter/gestures.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/secondary_handlers/element_edit_secondary_handler.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';

class SelectHandler extends InteractionHandler {
  InteractionSecondaryHandler? _secondaryHandler;
  late Offset lastCanvasPoint;
  SelectHandler();
  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    _secondaryHandler = InteractionSecondaryHandler.createHandler(event.localPoint, editorState);
    lastCanvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    _secondaryHandler!.onPanStart(
      lastCanvasPoint, 
      editorState
    );
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    _secondaryHandler!.onPanUpdate(
      canvasPoint - lastCanvasPoint, 
      editorState
    );
    lastCanvasPoint = canvasPoint;
  }

  @override
  void onScaleEnd(InputEndEvent event,EditorState editorState){
    _secondaryHandler?.onPanEnd(editorState);
  }
}