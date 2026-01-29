import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';
///**ZH** 步进执行平移操作的handler，适用于规整书写时
///
///**EN** Handler for executing step-by-step translation operations, suitable for regular writing.
class SteppingTransformHandler extends InteractionHandler {
  final double minimunStep = 100;
  //final double minimunScale = 0.1;
  double startScale = 1.0;
  double latestScale = 1.0;
  Offset panDelta = Offset.zero;
  late Offset startPan;

  @override
  void onScaleStart(_, EditorState editorState) {
    startScale = editorState.scale;
    latestScale = startScale;
    startPan = editorState.pan;
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    if (event.scale != 1.0) {
      final double newScale = (startScale * event.scale).clamp(0.1, 10.0);

      // 以手指焦点为中心缩放的平移补偿（适用于 pan 是画布坐标偏移的情况）
      final Offset focalPoint = event.localPoint;

      panDelta += focalPoint * (1 / newScale - 1 / latestScale);

      editorState.scale = newScale;
      latestScale = newScale;
    }

    // 处理双指拖动带来的平移（focalPointDelta 是屏幕位移）
    if (event.panDelta != Offset.zero) {
      final Offset canvasDelta = event.panDelta / editorState.scale;
      panDelta += canvasDelta;
    }

    final continiousPan = startPan + panDelta;
    editorState.pan = continiousPan - continiousPan % minimunStep;
  }
}