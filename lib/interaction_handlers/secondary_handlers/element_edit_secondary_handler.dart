import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/hit_testers/extended_hit_tester.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/secondary_handlers/clear_and_move_secondary_handler.dart';
import 'package:freeform_canvas/interaction_handlers/secondary_handlers/handle_resize_secondary_handler.dart';
import 'package:freeform_canvas/interaction_handlers/secondary_handlers/rotate_edit_secondary_handler.dart';
import 'package:freeform_canvas/interaction_handlers/transform_handler.dart';
/// **ZH** `InteractionSecondaryHandler`子类处理`select`工具下，触发不同编辑模式时的交互。
/// 其实例的生命周期为一次按下到该次抬起。
/// 
/// **EN** `InteractionSecondaryHandler` subclasses handle interactions in the `select` tool when a different edit mode is triggered.
/// The instance's lifecycle is from pressing down to lifting this time.
abstract class InteractionSecondaryHandler{
  void onPanStart(Offset canvasPoint,EditorState editorState){}
  void onPanUpdate(Offset canvasPoint,EditorState editorState){}
  void onPanEnd(EditorState editorState){}

  static InteractionSecondaryHandler createHandler(Offset screenPoint,EditorState editorState){
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, screenPoint);
    final hitTest = ExtendedHitTester.hitTest(
      canvasPoint, 
      editorState.file!.elements, 
      editorState.focusState.focusElementId,
      editorState.scale);
    switch(hitTest.hitTestType){
      case HitTestType.none:
        return ClearFocusSecondaryHandler();
      case HitTestType.element:
        return DragEditSecondaryHandler(hitTest.elementId!);
      case HitTestType.resizeHandle:
        return HandleResizeEditSecondaryHandler(hitTest.resizeHandle!);
      case HitTestType.rotateHandle:
        return RotateEditSecondaryHandler();
      case HitTestType.controllPoint:
        // TODO: 全面实现控制点操控
        throw UnimplementedError();
      case HitTestType.secondaryControllPoint:
        // TODO: 全面实现控制点操控
        throw UnimplementedError();
    }
  }
}