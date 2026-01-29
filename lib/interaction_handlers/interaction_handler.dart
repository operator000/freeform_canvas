import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
export 'package:freeform_canvas/interaction_handlers/drawing_handlers.dart';
export 'package:freeform_canvas/interaction_handlers/select_handler.dart';
export 'package:freeform_canvas/interaction_handlers/transform_handler.dart';
export 'package:freeform_canvas/interaction_handlers/stepping_transform_handler.dart';
export 'package:freeform_canvas/interaction_handlers/eraser_handler.dart';

///**ZH** 所有Interactor接收到的一次交互过程交由该类处理，该类应该直接与EditorState.commitIntent和EditSessions交互。
///
///**EN** All Interactor-received interaction processes are handled by this class.
/// This class should directly interact with EditorState.commitIntent and EditSessions.
class InteractionHandler {
  void onScaleStart(InputStartEvent event,EditorState editorState){}
  void onScaleUpdate(InputUpdateEvent event,EditorState editorState){}
  void onScaleEnd(InputEndEvent event,EditorState editorState){}
}

class InputStartEvent{
  final Offset localPoint;

  InputStartEvent({required this.localPoint});
}

class InputUpdateEvent{
  final Offset localPoint;
  final Offset panDelta;
  final double scale;

  InputUpdateEvent({required this.localPoint, required this.panDelta, required this.scale});
}

class InputEndEvent{
  InputEndEvent();
}