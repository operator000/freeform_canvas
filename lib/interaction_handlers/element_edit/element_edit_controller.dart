import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/extended_hit_tester.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/clear_and_move_controller.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/rect_resize_controller.dart';
import 'package:freeform_canvas/interaction_handlers/element_edit/rotate_edit_controller.dart';
import 'package:freeform_canvas/interaction_handlers/transform_handler.dart';
/// `EditController`处理`select`工具下，触发不同编辑模式时的交互。
/// 
/// 其实例的生命周期为一次按下到该次抬起。
abstract class ElementEditController{
  void onPanStart(Offset canvasPoint,EditorState editorState){}
  void onPanUpdate(Offset canvasPoint,EditorState editorState){}
  void onPanEnd(EditorState editorState){}

  static ElementEditController createController(Offset screenPoint,EditorState editorState){
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, screenPoint);
    final hitTest = ExtendedHitTester.hitTest(canvasPoint, editorState.file!.elements, editorState.focusState.focusElementId);
    switch(hitTest.hitTestType){
      case HitTestType.none:
        return ClearFocusController();
      case HitTestType.element:
        return DragEditController(hitTest.elementId!);
      case HitTestType.resizeHandle:
        return RectResizeEditController(hitTest.resizeHandle!);
      case HitTestType.rotateHandle:
        return RotateEditController();
      case HitTestType.controllPoint:
        // TODO: 全面实现控制点操控
        throw UnimplementedError();
      case HitTestType.secondaryControllPoint:
        // TODO: 全面实现控制点操控
        throw UnimplementedError();
    }
  }
}