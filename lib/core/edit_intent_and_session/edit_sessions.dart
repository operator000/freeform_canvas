import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/hit_testers/extended_hit_tester.dart';
import 'package:freeform_canvas/hit_testers/freeform_canvas_hit_tester.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/fundamental.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/models/text_editing_data.dart';
import 'package:freeform_canvas/ops/element_ops.dart';
import 'package:freeform_canvas/painters/element_geometry.dart';
///拖动元素
///Drag element
class ElementDragSession extends EditSession{
  late Offset startCanvasPoint;
  late Offset lastCanvasPoint;

  final EditorState editorState;
  final String elementId;
  ElementDragSession({
    required this.editorState,
    required this.elementId,
  });

  void onStart(Offset canvasPoint){
    editorState.focusState.focusOnElement(elementId);
    startCanvasPoint = canvasPoint;
    lastCanvasPoint = canvasPoint;
  }

  void onUpdate(Offset canvasDelta){
    // 进入预览状态
    editorState.ensurePreviewFor(elementId);
    // 计算拖拽增量(canvas坐标系)
    editorState.updatePreview(
      (e)=>ElementOps.copyWith(
        e,
        x: e.x + canvasDelta.dx,
        y: e.y + canvasDelta.dy,
      )
    );
    lastCanvasPoint += canvasDelta;
  }

  void onEnd(){
    editorState.quitPreview();
    if(startCanvasPoint==lastCanvasPoint){
      return;
    }
    editorState.commitIntent(
      DragEditIntent(elementId: elementId, offset: lastCanvasPoint-startCanvasPoint)
    );
  }
}
///缩放元素
///Scale element
class HandleResizeSession extends EditSession{
  final EditorState editorState;
  final ResizeHandle resizeHandle;
  HandleResizeSession({required this.resizeHandle,required this.editorState});

  late Rect resizeStartRect;
  late String elementId;
  FreeformCanvasElement? resizeStartElement;
  Offset resizeDelta = Offset.zero;
  late Offset startPoint;
  ///canvasPoint:按下处的canvas坐标
  void onStart(Offset canvasPoint) {
    elementId = editorState.focusState.focusElementId!;
    editorState.ensurePreviewFor(elementId);
    resizeStartRect = ElementGeometry.resizeHandlePosition(editorState.focusedElement!);
    resizeStartElement = editorState.focusedElement;
    startPoint = canvasPoint;
  }

  void onUpdate(Offset canvasDelta) {
    //计算缩放量
    resizeDelta += canvasDelta;

    editorState.updatePreview(
      (_)=>ElementOps.handleScaleElement(
        resizeStartElement!,
        resizeHandle,
        resizeDelta
      )
    );
  }

  void onEnd() {
    editorState.commitIntent(HandleScaleElementIntent(
      elementId: elementId, 
      startHandle: resizeHandle,
      offset: resizeDelta
    ));
    editorState.quitPreview();
  }
}
///旋转元素
///Rotate element
class RotateSession extends EditSession{
  late Offset elementCenter;
  late double startAngle;
  late double latestAngle;
  void onStart(Offset canvasPoint, EditorState editorState) {
    if(!editorState.focusState.isFocusOnElement) return;
    elementCenter = ElementGeometry.center(editorState.focusedElement!);
    final offset = canvasPoint - elementCenter;
    startAngle = atan2(offset.dy, offset.dx);
    latestAngle = startAngle;
  }

  void onUpdate(Offset canvasPoint, EditorState editorState) {
    if(!editorState.focusState.isFocusOnElement) return;
    editorState.ensurePreviewFor(editorState.focusState.focusElementId!);
    final offset = canvasPoint - elementCenter;
    final nowAngle = atan2(offset.dy, offset.dx);
    editorState.updatePreview(
      (e)=>ElementOps.copyWith(e,angle: e.angle + nowAngle - latestAngle)
    );
    latestAngle = nowAngle;
  }

  void onEnd(EditorState editorState) {
    if(!editorState.focusState.isFocusOnElement) return;
    if(startAngle!=latestAngle){
      editorState.commitIntent(RotateElementIntent(
        elementId: editorState.focusState.focusElementId!, 
        angleDelta: latestAngle-startAngle
      ));
      editorState.quitPreview();
    }
  }
}
///两点式创建新元素
///Two-point creation
class TwoPointCreateSession extends EditSession{
  final FreeformCanvasElementType type;
  Offset? creationStartPoint;
  late Offset lastUpdatePoint;

  TwoPointCreateSession({required this.type});

  void onStart(Offset canvasPoint, EditorState editorState) {
    // 创建元素
    final newElement = ElementOps.createDraftElementFromPoints(
      type,
      canvasPoint,
      canvasPoint,  // 初始时终点与起点相同
    );

    if(newElement==null) return;
    editorState.newAndEnterPreview(newElement);
    creationStartPoint = canvasPoint;
    lastUpdatePoint = canvasPoint;
  }

  void onUpdate(Offset canvasDelta, EditorState editorState) {
    if (creationStartPoint==null) {
      return;
    }

    lastUpdatePoint += canvasDelta;

    // 创建更新后的元素
    final updatedElement = ElementOps.createDraftElementFromPoints(
      type,
      creationStartPoint!,
      lastUpdatePoint,
    );

    if(updatedElement==null) return;
    editorState.updatePreview((_)=>updatedElement);
  }

  void onEnd(EditorState editorState) {
    if (creationStartPoint==null) {
      return;
    }
    // 检查是否有效距离（避免微小点击创建元素）
    if ((creationStartPoint! - lastUpdatePoint).distanceSquared < 4.0) {
      // 距离太小，不创建元素
      editorState.quitPreview();
      return;
    }

    // 提交草稿
    editorState.quitPreview();
    final element = ElementOps.createDraftElementFromPoints(
      type,
      creationStartPoint!,
      lastUpdatePoint,
    );
    editorState.commitIntent(ElementCreateIntent(element: element!));
    editorState.switchToolToDefault();
    editorState.focusState.focusOnElement(element.id);
  }
}
///创建freedraw元素
///Create freedraw element
class CreateFreedrawSession extends EditSession{
  Offset? creationStartPoint;
  void onStart(Offset canvasPoint, EditorState editorState) {
    // 创建初始的freedraw元素
    final element = ElementOps.createFreedraw([canvasPoint]);

    editorState.newAndEnterPreview(element);
    creationStartPoint = canvasPoint;
  }

  void onUpdate(Offset canvasPoint, EditorState editorState) {
    if (editorState.draftState.isEmpty()) {
      return;
    }

    // 向当前freedraw元素添加点
    editorState.updatePreview(
      (e)=>ElementOps.addPointToFreeDrawDraft(e as FreeformCanvasFreedraw, canvasPoint)
    );
  }
  
  void onEnd(EditorState editorState) {
    // 检查是否有有效笔划（points数量大于1）
    final preview = editorState.draftState.draftElement;
    if (preview is FreeformCanvasFreedraw && preview.points.length > 1) {
      // 将元素加入正式元素列表
      editorState.commitIntent(ElementCreateIntent(element: preview));
      editorState.quitPreview();
    } else {
      // 无效笔划（只有一个点），清理状态
      editorState.quitPreview();
    }
  }
}
///橡皮擦
///Eraser
class EraserSession extends EditSession{
  void onUpdate(Offset canvasPoint, EditorState editorState){
    final elementHitTest = FreeformCanvasHitTester.hitTest(canvasPoint, editorState.file!.elements);
    if(elementHitTest!=null){
      editorState.commitIntent(ElementDeleteIntent(id: elementHitTest.elementId));
    }
  }
}
///文本编辑。文本编辑操作为长线操作，尽管本Session仅处理触发。
///Text editing. Text editing operations are long-line operations, even though this Session only handles triggering.
class TextEditSession extends EditSession{
  void onTrigger(Offset canvasPoint, EditorState editorState) {
    final focusedElement = editorState.focusedElement;
    if(focusedElement==null){
      editorState.enterTextEdit(TextEditData.newText(textCanvasPosition: canvasPoint, textColor: null));
    }else if(focusedElement is FreeformCanvasText){
      editorState.enterTextEdit(TextEditData.fromElement(element: focusedElement));
    }
  }
}