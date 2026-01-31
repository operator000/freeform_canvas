import 'package:flutter/material.dart';
import 'package:freeform_canvas/painters/element_geometry.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';

import '../models/freeform_canvas_element.dart';

/// **ZH** FreeformCanvas 动态元素绘制，使用 CustomPainter
/// 
/// **EN** Drawing of dynamic elements in FreeformCanvas, using CustomPainter
class ActiveLayerPainter extends CustomPainter {
  final int alpha;
  final int repaintCounter;
  final FreeformCanvasElement? draftElement;
  final FreeformCanvasElement? selectionRectElement;
  final double scale;
  final Offset pan;

  ActiveLayerPainter({
    required this.scale,
    required this.pan,
    required this.draftElement,
    required this.selectionRectElement,
    required this.repaintCounter,
    this.alpha = 200,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(scale, scale);
    canvas.translate(pan.dx, pan.dy);

    // Draw the draft element (half-transparent style, transformation applied)
    if (draftElement!= null) {
      drawDraftElement(canvas, draftElement!,alpha);
    }

    // Draw the selection box (transformation applied)
    if (selectionRectElement!=null) {
      _drawSelectionBox(canvas, selectionRectElement!,scale,pan);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ActiveLayerPainter oldDelegate) {
    return oldDelegate.repaintCounter!=repaintCounter;
  }
}

/// **ZH** 绘制选中框
/// 
/// **EN** Draw the selection box
void _drawSelectionBox(Canvas canvas, FreeformCanvasElement? selectionRectElement,double scale,Offset pan) {
  if(selectionRectElement==null) return;
  // Selection box painter
  final selectionPaint = Paint()
    ..color =  const Color.fromRGBO(158, 158, 158, 1) // 灰色
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2/scale
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter;

  final center = ElementGeometry.center(selectionRectElement);
  canvas.translate(center.dx, center.dy);
  canvas.rotate(selectionRectElement.angle);
  canvas.translate(-center.dx, -center.dy);
  // Draw the selection box
  canvas.drawRect(ElementGeometry.selectionRect(selectionRectElement), selectionPaint);

  // Draw the resize handles
  final handleRect = ElementGeometry.resizeHandlePosition(selectionRectElement);
  drawSelectionHandle(canvas, handleRect.topLeft,scale);
  drawSelectionHandle(canvas, handleRect.topRight,scale);
  drawSelectionHandle(canvas, handleRect.bottomLeft,scale);
  drawSelectionHandle(canvas, handleRect.bottomRight,scale);

  canvas.rotate(-selectionRectElement.angle);
}

/// **ZH** 绘制控制点
/// 
/// **EN** Draw the control point
void drawSelectionHandle(Canvas canvas,Offset offset,double scale){
  canvas.drawRRect(
    RRect.fromRectAndRadius(ElementGeometry.resizeHandleRect(offset,scale), Radius.circular(1/scale)), 
    Paint()
    ..color = Colors.grey
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2/scale,
  );
}

/// **ZH** 绘制草稿元素（半透明样式）
/// 
/// **EN** Draw the draft element (half-transparent style)
void drawDraftElement(Canvas canvas, FreeformCanvasElement element,[int alpha = 200]) {
  final alphaPaint = Paint()..colorFilter = ColorFilter.mode(
    Colors.white.withAlpha(alpha),
    BlendMode.modulate,
  );
  canvas.saveLayer(null, alphaPaint);

  drawElement(canvas, element);

  canvas.restore();
}