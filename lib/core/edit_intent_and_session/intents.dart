import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/foundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/element_style.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import 'package:freeform_canvas/ops/element_ops.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';
///元素整体平移
///Element translation
class DragEditIntent extends EditIntent{
  final String elementId;
  final Offset offset;
  DragEditIntent({required this.elementId, required this.offset});
  
  @override
  EditAction generateAction(EditorState editorState) {
    final start = FreeformCanvasFileOps.findElement(editorState.file!,elementId)!;
    return DragEditAction(
      elementId: elementId,
      offset: offset,
      oldElement: start
    );
  }
  
}
class DragEditAction extends EditAction{
  final String elementId;
  final Offset offset;
  final FreeformCanvasElement oldElement;

  DragEditAction({
    required this.elementId,
    required this.offset,
    required this.oldElement, 
  });

  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (e)=>ElementOps.copyWith(
        e,
        x: e.x + offset.dx,
        y: e.y + offset.dy,
      )
    ));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (_)=>oldElement
    ));
  }
}

///元素矩形缩放
///Element rectangle scaling
class RectScaleElementIntent extends EditIntent{
  final String elementId;
  final Rect startRect;
  final Rect endRect;

  RectScaleElementIntent({required this.elementId, required this.startRect, required this.endRect});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return RectScaleElementAction(
      elementId: elementId, 
      startRect: startRect, 
      endRect: endRect, 
      oldElement: FreeformCanvasFileOps.findElement(editorState.file!, elementId)!
    );
  }
}
class RectScaleElementAction extends EditAction{
  final String elementId;
  final Rect startRect;
  final Rect endRect;
  final FreeformCanvasElement oldElement;

  RectScaleElementAction({
    required this.elementId, 
    required this.startRect, 
    required this.endRect,
    required this.oldElement
  });
  
  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (e)=>ElementOps.rectScaleElement(
        e, 
        startRect, 
        endRect,
      )
    ));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (_)=>oldElement
    ));
  }
}

///元素旋转
///Element rotation
class RotateElementIntent extends EditIntent{
  final String elementId;
  final double angleDelta;

  RotateElementIntent({required this.elementId, required this.angleDelta});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return RotateElementAction(
      elementId: elementId, 
      angleDelta: angleDelta, 
      originalangle: FreeformCanvasFileOps.findElement(editorState.file!, elementId)!.angle
    );
  }
}
class RotateElementAction extends EditAction{
  final String elementId;
  final double angleDelta;
  final double originalangle;

  RotateElementAction({required this.elementId, required this.angleDelta,required this.originalangle});
  
  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (e)=>ElementOps.copyWith(
        e, 
        angle: e.angle + angleDelta
      )
    ));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      elementId, 
      (e)=>ElementOps.copyWith(
        e, 
        angle: originalangle
      )
    ));
  }
}
///新建元素
///New element
class ElementCreateIntent extends EditIntent{
  final FreeformCanvasElement element;
  ElementCreateIntent({required this.element});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return ElementCreateAction(element: element);
  }
}
class ElementCreateAction extends EditAction{
  final FreeformCanvasElement element;
  ElementCreateAction({required this.element});

  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(
      FreeformCanvasFileOps.addElement(editorState.file!, element)
    );
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(
      FreeformCanvasFileOps.removeElement(editorState.file!, element.id)
    );
  }
}
///删除元素
///Delete element
class ElementDeleteIntent extends EditIntent{
  final String id;
  ElementDeleteIntent({required this.id});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return ElementDeleteAction(id: id, oldFile: editorState.file!);
  }
}
class ElementDeleteAction extends EditAction{
  final String id;
  //没有做指定index插入，因此直接备份文件
  final FreeformCanvasFile oldFile;
  ElementDeleteAction({required this.id,required this.oldFile});
  
  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.removeElement(editorState.file!, id));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(oldFile);
  }
}
///更新元素style相关字段
///Update element style
class StyleUpdateIntent extends EditIntent{
  final String id;
  final ElementStylePatch patch;
  StyleUpdateIntent({required this.id,required this.patch});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return StyleUpdateAction(
      oldElement: FreeformCanvasFileOps.findElement(editorState.file!, id)!,
      patch: patch,
    );
  }
}
class StyleUpdateAction extends EditAction{
  final FreeformCanvasElement oldElement;
  final ElementStylePatch patch;

  StyleUpdateAction({required this.oldElement, required this.patch});
  
  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(
      editorState.file!, 
      oldElement.id,
      (e) => ElementOps.applyStylePatch(patch, e)
    ));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.updateElement(editorState.file!, oldElement.id, (_)=>oldElement));
  }
}
///更改元素顺序
///Change element order
class MoveZOrderIntent extends EditIntent{
  final String id;
  final ZOrderAction zOrderAction;
  MoveZOrderIntent({required this.id,required this.zOrderAction});
  
  @override
  EditAction generateAction(EditorState editorState) {
    return MoveZOrderAction(
      id: id,
      zOrderAction: zOrderAction,
      originalZOrder: FreeformCanvasFileOps.getZOrderIndex(editorState.file!, id)
    );
  }
}
class MoveZOrderAction extends EditAction{
  final String id;
  final int originalZOrder;
  final ZOrderAction zOrderAction;

  MoveZOrderAction({required this.id,required this.zOrderAction,required this.originalZOrder});
  
  @override
  void commit(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.moveZOrder(editorState.file!,id,action:zOrderAction));
  }
  @override
  void inverse(EditorState editorState,var modifyFile) {
    modifyFile(FreeformCanvasFileOps.moveZOrder(editorState.file!, id, index: originalZOrder));
  }
}