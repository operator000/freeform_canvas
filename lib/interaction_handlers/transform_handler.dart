import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';

class TransformHandler extends InteractionHandler {
  double startScale = 1.0;

  @override
  void onScaleStart(_, EditorState editorState) {
    startScale = editorState.scale;
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    // 只有当真正发生缩放时才处理（避免单指拖动误触发）
    if (event.scale != 1.0) {
      final double newScale = (startScale * event.scale).clamp(0.1, 10.0);

      final Offset focalPoint = event.localPoint;
      final double oldScale = editorState.scale;

      final Offset deltaPan = focalPoint * (1 / newScale - 1 / oldScale);

      editorState.pan += deltaPan;
      editorState.scale = newScale;
    }

    // 处理双指拖动带来的平移（focalPointDelta 是屏幕位移）
    if (event.panDelta != Offset.zero) {
      final Offset canvasDelta = event.panDelta / editorState.scale;
      editorState.pan += canvasDelta;
    }

    // 可选：打印调试
    // print("scale: ${editorState.scale}, pan: ${editorState.pan}");
  }
}

///**ZH** 坐标变换函数，其中canvas代表画布上的坐标
///
///**EN** Coordinate transformation function, where canvas represents the coordinates on the canvas
Offset screenToCanvas(double scale,Offset pan,Offset offset){
  return offset/scale-pan;
}
///**ZH** 坐标变换函数，其中canvas代表画布上的坐标
///
///**EN** Coordinate transformation function, where canvas represents the coordinates on the canvas
Offset canvasToScreen(double scale,Offset pan,Offset offset){
  return (offset+pan)*scale;
}