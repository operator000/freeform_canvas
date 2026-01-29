import 'dart:math';

import 'package:flutter/material.dart';

import '../models/freeform_canvas_element.dart';

class FreeformCanvasPainter extends CustomPainter {
  int dirty;
  final List<FreeformCanvasElement> elements;
  final Color? backgroundColor;
  final String? draftId;
  final double scale;
  final Offset pan;

  FreeformCanvasPainter({
    required this.dirty,
    required this.elements,
    this.scale = 1,
    this.pan = Offset.zero,
    this.backgroundColor,
    this.draftId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor!,
      );
    }

    canvas.save();

    canvas.scale(scale, scale);
    canvas.translate(pan.dx, pan.dy);

    drawGrid(canvas: canvas, size: size, gridSize: 20, gridStep: 5, scale: scale,pan: pan);
    for (final element in elements) {
      if(element.id!=draftId){
        drawElement(canvas, element);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FreeformCanvasPainter oldDelegate) {
    return oldDelegate.dirty!=dirty;
  }
}

/// **ZH** 绘制单个元素
/// 
/// **EN** Draw a single element
void drawElement(Canvas canvas, FreeformCanvasElement element) {
  if(element.isDeleted) return;

  // 如果元素有旋转角度，应用旋转变换
  if (element.angle != 0) {
    canvas.save();

    // 计算旋转中心（边界矩形的中心）
    Offset center;
    if (element.type == FreeformCanvasElementType.freedraw) {
      // freedraw 需要遍历 points 计算实际边界
      final freedraw = element as FreeformCanvasFreedraw;
      if (freedraw.points.isEmpty) {
        center = Offset(element.x + element.width / 2, element.y + element.height / 2);
      } else {
        double minX = double.infinity;
        double minY = double.infinity;
        double maxX = -double.infinity;
        double maxY = -double.infinity;

        for (final point in freedraw.points) {
          final absolutePoint = point.toAbsolute(element.x, element.y);
          if (absolutePoint.dx < minX) minX = absolutePoint.dx;
          if (absolutePoint.dy < minY) minY = absolutePoint.dy;
          if (absolutePoint.dx > maxX) maxX = absolutePoint.dx;
          if (absolutePoint.dy > maxY) maxY = absolutePoint.dy;
        }

        center = Offset((minX + maxX) / 2, (minY + maxY) / 2);
      }
    } else {
      center = Offset(element.x + element.width / 2, element.y + element.height / 2);
    }

    // 平移到旋转中心
    canvas.translate(center.dx, center.dy);
    // 旋转
    canvas.rotate(element.angle);
    // 平移回原位
    canvas.translate(-center.dx, -center.dy);
  }

  switch (element.type) {
    case FreeformCanvasElementType.rectangle:
      _drawRectangle(canvas, element as FreeformCanvasRectangle);
      break;
    case FreeformCanvasElementType.ellipse:
      _drawEllipse(canvas, element as FreeformCanvasEllipse);
      break;
    case FreeformCanvasElementType.text:
      _drawText(canvas, element as FreeformCanvasText);
      break;
    case FreeformCanvasElementType.freedraw:
      _drawFreedraw(canvas, element as FreeformCanvasFreedraw);
      break;
    case FreeformCanvasElementType.line:
      _drawLine(canvas, element as FreeformCanvasLine);
      break;
    case FreeformCanvasElementType.arrow:
      _drawArrow(canvas, element as FreeformCanvasArrow);
      break;
    case FreeformCanvasElementType.diamond:
      _drawDiamond(canvas, element as FreeformCanvasDiamond);
      break;
  }

  // 如果应用了旋转，恢复画布状态
  if (element.angle != 0) {
    canvas.restore();
  }
}

/// **ZH** 绘制矩形
/// 
/// **EN** Draw a rectangle
void _drawRectangle(Canvas canvas, FreeformCanvasRectangle rect) {
  final bounds = rect.bounds;
  final paint = rect.fillPaint;
  final strokePaint = rect.strokePaint;

  // 绘制填充
  if (rect.backgroundColor.isNotTransparent) {
    if (rect.cornerRadius != null) {
      final rrect = RRect.fromRectAndRadius(
        bounds,
        Radius.circular(rect.cornerRadius!),
      );

      // 根据 fillStyle 选择填充方式
      switch (rect.fillStyle) {
        case 'solid':
          canvas.drawRRect(rrect, paint);
          break;
        case 'hachure':
          // 先裁剪到圆角矩形区域
          canvas.save();
          canvas.clipRRect(rrect);
          _drawHachureFill(canvas, bounds, paint);
          canvas.restore();
          break;
        case 'cross-hatch':
          canvas.save();
          canvas.clipRRect(rrect);
          _drawCrossHatchFill(canvas, bounds, paint);
          canvas.restore();
          break;
        default:
          canvas.drawRRect(rrect, paint);
      }

      // 绘制描边
      switch (rect.strokeStyle) {
        case 'solid':
          canvas.drawRRect(rrect, strokePaint);
          break;
        case 'dashed':
        case 'dotted':
          _drawRoundedRectStroke(canvas, rrect, strokePaint, rect.strokeStyle);
          break;
        default:
          canvas.drawRRect(rrect, strokePaint);
      }
    } else {
      // 直角矩形
      switch (rect.fillStyle) {
        case 'solid':
          canvas.drawRect(bounds, paint);
          break;
        case 'hachure':
          _drawHachureFill(canvas, bounds, paint);
          break;
        case 'cross-hatch':
          _drawCrossHatchFill(canvas, bounds, paint);
          break;
        default:
          canvas.drawRect(bounds, paint);
      }

      // 绘制描边
      switch (rect.strokeStyle) {
        case 'solid':
          canvas.drawRect(bounds, strokePaint);
          break;
        case 'dashed':
          _drawRectStrokeDashed(canvas, bounds, strokePaint);
          break;
        case 'dotted':
          _drawRectStrokeDotted(canvas, bounds, strokePaint);
          break;
        default:
          canvas.drawRect(bounds, strokePaint);
      }
    }
  } else {
    // 无填充，只绘制描边
    if (rect.cornerRadius != null) {
      final rrect = RRect.fromRectAndRadius(
        bounds,
        Radius.circular(rect.cornerRadius!),
      );

      switch (rect.strokeStyle) {
        case 'solid':
          canvas.drawRRect(rrect, strokePaint);
          break;
        case 'dashed':
        case 'dotted':
          _drawRoundedRectStroke(canvas, rrect, strokePaint, rect.strokeStyle);
          break;
        default:
          canvas.drawRRect(rrect, strokePaint);
      }
    } else {
      switch (rect.strokeStyle) {
        case 'solid':
          canvas.drawRect(bounds, strokePaint);
          break;
        case 'dashed':
          _drawRectStrokeDashed(canvas, bounds, strokePaint);
          break;
        case 'dotted':
          _drawRectStrokeDotted(canvas, bounds, strokePaint);
          break;
        default:
          canvas.drawRect(bounds, strokePaint);
      }
    }
  }
}

/// **ZH** 绘制椭圆
/// 
/// **EN** Draw an ellipse
void _drawEllipse(Canvas canvas, FreeformCanvasEllipse ellipse) {
  final bounds = ellipse.bounds;
  final paint = ellipse.fillPaint;
  final strokePaint = ellipse.strokePaint;

  // 绘制填充
  if (ellipse.backgroundColor.isNotTransparent) {
    switch (ellipse.fillStyle) {
      case 'solid':
        canvas.drawOval(bounds, paint);
        break;
      case 'hachure':
        canvas.save();
        canvas.clipPath(Path()..addOval(bounds));
        _drawHachureFill(canvas, bounds, paint);
        canvas.restore();
        break;
      case 'cross-hatch':
        canvas.save();
        canvas.clipPath(Path()..addOval(bounds));
        _drawCrossHatchFill(canvas, bounds, paint);
        canvas.restore();
        break;
      default:
        canvas.drawOval(bounds, paint);
    }
  }

  // 绘制描边
  switch (ellipse.strokeStyle) {
    case 'solid':
      canvas.drawOval(bounds, strokePaint);
      break;
    case 'dashed':
    case 'dotted':
      _drawEllipseStroke(canvas, bounds, strokePaint, ellipse.strokeStyle);
      break;
    default:
      canvas.drawOval(bounds, strokePaint);
  }
}

/// **ZH** 绘制文本
/// 
/// **EN** Draw text
void _drawText(Canvas canvas, FreeformCanvasText text) {
  // 如果文本为空，不绘制
  if (text.text.isEmpty) return;

  // 创建文本样式，与 ZeroPaddingTextfield 保持一致
  final textStyle = TextStyle(
    color: text.strokeColor.color.withAlpha(text.colorAlpha),
    fontSize: text.fontSize,
    height: text.lineHeight,
    // TODO: 字体映射，暂时使用默认字体
  );

  // 创建 TextPainter
  final textPainter = TextPainter(
    text: TextSpan(text: text.text, style: textStyle),
    textAlign: _parseTextAlign(text.textAlign),
    textDirection: TextDirection.ltr,
  );

  // 布局文本
  textPainter.layout();

  // 计算绘制位置（左上角对齐）
  double x = text.x;
  double y = text.y;

  // 垂直对齐调整
  if (text.verticalAlign == 'middle') {
    y = text.y + (text.height - textPainter.height) / 2;
  } else if (text.verticalAlign == 'bottom') {
    y = text.y + text.height - textPainter.height;
  }

  textPainter.paint(canvas, Offset(x, y));

  // TODO: 自动调整尺寸（autoResize）需要更新元素的 width/height
  // 当前阶段使用固定尺寸，后续可以更新元素尺寸
}

/// **ZH** 绘制自由绘制路径
/// 
/// **EN** Draw a freeform path
void _drawFreedraw(Canvas canvas, FreeformCanvasFreedraw freedraw) {
  if (freedraw.points.isEmpty) return;

  final strokePaint = freedraw.strokePaint;
  final path = Path();

  // 移动到第一个点（绝对坐标）
  final firstPoint = freedraw.points.first;
  final firstOffset = firstPoint.toAbsolute(freedraw.x, freedraw.y);
  path.moveTo(firstOffset.dx, firstOffset.dy);

  // 连接后续点
  for (int i = 1; i < freedraw.points.length; i++) {
    final point = freedraw.points[i];
    final offset = point.toAbsolute(freedraw.x, freedraw.y);
    path.lineTo(offset.dx, offset.dy);
  }

  canvas.drawPath(path, strokePaint);
}

/// **ZH** 绘制直线
/// 
/// **EN** Draw a line
void _drawLine(Canvas canvas, FreeformCanvasLine line) {
  if (line.points.length < 2) return;

  final strokePaint = line.strokePaint;

  final startOffset = line.points.first.toAbsolute(line.x, line.y);
  Offset lastOffset = startOffset;

  switch(line.strokeStyle){
    case 'dotted':
      for (int i = 1; i < line.points.length; i++) {
        final point = line.points[i];
        final offset = point.toAbsolute(line.x, line.y);
        _drawDottedLine(canvas, lastOffset, offset, strokePaint);
        lastOffset = offset;
      }
    case 'dashed':
      for (int i = 1; i < line.points.length; i++) {
        final point = line.points[i];
        final offset = point.toAbsolute(line.x, line.y);
        _drawDashedLine(canvas, lastOffset, offset, strokePaint);
        lastOffset = offset;
      }
    case 'solid':
    default:
      for (int i = 1; i < line.points.length; i++) {
        final point = line.points[i];
        final offset = point.toAbsolute(line.x, line.y);
        canvas.drawLine(lastOffset,offset,strokePaint);
        lastOffset = offset;
      }
  }


  // 如果是闭合多边形
  if (line.polygon && line.points.length >= 3) {
    switch(line.strokeStyle){
      case 'dotted':
        _drawDottedLine(canvas, startOffset, lastOffset, strokePaint);
      case 'dashed':
        _drawDashedLine(canvas, startOffset, lastOffset, strokePaint);
      case 'solid':
      default:
        canvas.drawLine(startOffset, lastOffset, strokePaint);
    }
  }
}

/// **ZH** 绘制箭头
/// 
/// **EN** Draw an arrow
void _drawArrow(Canvas canvas, FreeformCanvasArrow arrow) {
  // 先绘制直线部分
  _drawLine(canvas, arrow);

  // TODO: 实现箭头头部
  // 当前阶段简单绘制一个三角形箭头
  if (arrow.points.length >= 2 && arrow.endArrowhead == 'arrow') {
    _drawArrowhead(canvas, arrow);
  }
}

/// **ZH** 绘制箭头头部（简单实现）
/// 
/// **EN** Draw an arrowhead(simple implementation)
void _drawArrowhead(Canvas canvas, FreeformCanvasArrow arrow) {
  if (arrow.points.length < 2) return;

  final lastPoint = arrow.points.last;
  final secondLastPoint = arrow.points.length >= 2
      ? arrow.points[arrow.points.length - 2]
      : arrow.points.first;

  final tip = lastPoint.toAbsolute(arrow.x, arrow.y);
  final beforeTip = secondLastPoint.toAbsolute(arrow.x, arrow.y);

  // 计算箭头方向
  final direction = (tip - beforeTip).normalized();

  // 箭头大小
  const arrowSize = 10.0;

  // 计算箭头两侧点
  final perpendicular = Offset(-direction.dy, direction.dx);
  final left = tip - direction * arrowSize + perpendicular * arrowSize / 2;
  final right = tip - direction * arrowSize - perpendicular * arrowSize / 2;

  // 绘制箭头三角形
  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..lineTo(left.dx, left.dy)
    ..lineTo(right.dx, right.dy)
    ..close();

  canvas.drawPath(path, arrow.strokePaint);
  canvas.drawPath(path, arrow.fillPaint);
}

/// **ZH** 绘制虚线矩形边框
/// 
/// **EN** Draw a dashed rectangle
void _drawRectStrokeDashed(Canvas canvas, Rect bounds, Paint paint) {
  // 绘制四条边
  _drawDashedLine(canvas, Offset(bounds.left, bounds.top), Offset(bounds.right, bounds.top), paint); // 上边
  _drawDashedLine(canvas, Offset(bounds.right, bounds.top), Offset(bounds.right, bounds.bottom), paint); // 右边
  _drawDashedLine(canvas, Offset(bounds.right, bounds.bottom), Offset(bounds.left, bounds.bottom), paint); // 下边
  _drawDashedLine(canvas, Offset(bounds.left, bounds.bottom), Offset(bounds.left, bounds.top), paint); // 左边
}

/// 绘制点线矩形边框
void _drawRectStrokeDotted(Canvas canvas, Rect bounds, Paint paint) {
  // 绘制四条边
  _drawDottedLine(canvas, Offset(bounds.left, bounds.top), Offset(bounds.right, bounds.top), paint); // 上边
  _drawDottedLine(canvas, Offset(bounds.right, bounds.top), Offset(bounds.right, bounds.bottom), paint); // 右边
  _drawDottedLine(canvas, Offset(bounds.right, bounds.bottom), Offset(bounds.left, bounds.bottom), paint); // 下边
  _drawDottedLine(canvas, Offset(bounds.left, bounds.bottom), Offset(bounds.left, bounds.top), paint); // 左边
}

/// 绘制虚线/点线圆角矩形边框
void _drawRoundedRectStroke(Canvas canvas, RRect rrect, Paint paint, String style) {
  final path = Path()..addRRect(rrect);
  if (style == 'dashed') {
    _drawDashedPath(canvas, path, paint);
  } else {
    _drawDottedPath(canvas, path, paint);
  }
}

/// 绘制虚线/点线椭圆边框
void _drawEllipseStroke(Canvas canvas, Rect bounds, Paint paint, String style) {
  final path = Path()..addOval(bounds);
  if (style == 'dashed') {
    _drawDashedPath(canvas, path, paint);
  } else {
    _drawDottedPath(canvas, path, paint);
  }
}

/// **ZH** 绘制菱形
/// 
/// **EN** Draw a diamond
void _drawDiamond(Canvas canvas, FreeformCanvasDiamond diamond) {
  final bounds = diamond.bounds;
  final paint = diamond.fillPaint;
  final strokePaint = diamond.strokePaint;

  // 计算菱形的四个顶点（边界矩形的中点）
  final top = Offset(bounds.left + bounds.width / 2, bounds.top);
  final right = Offset(bounds.right, bounds.top + bounds.height / 2);
  final bottom = Offset(bounds.left + bounds.width / 2, bounds.bottom);
  final left = Offset(bounds.left, bounds.top + bounds.height / 2);

  final radii = diamond.diamondCornerRadii;
  if (radii == null) {
    // 无圆角，绘制普通菱形
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    // 绘制填充
    if (diamond.backgroundColor.isNotTransparent) {
      switch (diamond.fillStyle) {
        case 'solid':
          canvas.drawPath(path, paint);
          break;
        case 'hachure':
          canvas.save();
          canvas.clipPath(path);
          _drawHachureFill(canvas, bounds, paint);
          canvas.restore();
          break;
        case 'cross-hatch':
          canvas.save();
          canvas.clipPath(path);
          _drawCrossHatchFill(canvas, bounds, paint);
          canvas.restore();
          break;
        default:
          canvas.drawPath(path, paint);
      }
    }

    // 绘制描边
    switch (diamond.strokeStyle) {
      case 'solid':
        canvas.drawPath(path, strokePaint);
        break;
      case 'dashed':
        _drawDashedLine(canvas, top, right, strokePaint);
        _drawDashedLine(canvas, right, bottom, strokePaint);
        _drawDashedLine(canvas, bottom, left, strokePaint);
        _drawDashedLine(canvas, left, top, strokePaint);
        break;
      case 'dotted':
        _drawDottedLine(canvas, top, right, strokePaint);
        _drawDottedLine(canvas, right, bottom, strokePaint);
        _drawDottedLine(canvas, bottom, left, strokePaint);
        _drawDottedLine(canvas, left, top, strokePaint);
        break;
      default:
        canvas.drawPath(path, strokePaint);
    }
  } else {
    // 绘制圆角菱形
    final (topBottomRadius, leftRightRadius) = radii;

    // 计算四条边的单位方向向量和切点
    // 边的顺序（顺时针）：top -> right -> bottom -> left -> top

    // 右上边：top -> right
    final topToRight = (right - top).normalized();
    final topRightLen = (right - top).distance;
    // 限制圆角半径不超过边长的一半
    final actualTopBottomRadius1 = topBottomRadius < topRightLen / 2 ? topBottomRadius : topRightLen / 2;
    final actualLeftRightRadius1 = leftRightRadius < topRightLen / 2 ? leftRightRadius : topRightLen / 2;
    // 上顶点的右侧切点
    final topRightTangent = top + topToRight * actualTopBottomRadius1;
    // 右顶点的上侧切点
    final rightTopTangent = right - topToRight * actualLeftRightRadius1;

    // 右下边：right -> bottom
    final rightToBottom = (bottom - right).normalized();
    final rightBottomLen = (bottom - right).distance;
    final actualLeftRightRadius2 = leftRightRadius < rightBottomLen / 2 ? leftRightRadius : rightBottomLen / 2;
    final actualTopBottomRadius2 = topBottomRadius < rightBottomLen / 2 ? topBottomRadius : rightBottomLen / 2;
    // 右顶点的下侧切点
    final rightBottomTangent = right + rightToBottom * actualLeftRightRadius2;
    // 下顶点的右侧切点
    final bottomRightTangent = bottom - rightToBottom * actualTopBottomRadius2;

    // 左下边：bottom -> left
    final bottomToLeft = (left - bottom).normalized();
    final bottomLeftLen = (left - bottom).distance;
    final actualTopBottomRadius3 = topBottomRadius < bottomLeftLen / 2 ? topBottomRadius : bottomLeftLen / 2;
    final actualLeftRightRadius3 = leftRightRadius < bottomLeftLen / 2 ? leftRightRadius : bottomLeftLen / 2;
    // 下顶点的左侧切点
    final bottomLeftTangent = bottom + bottomToLeft * actualTopBottomRadius3;
    // 左顶点的下侧切点
    final leftBottomTangent = left - bottomToLeft * actualLeftRightRadius3;

    // 左上边：left -> top
    final leftToTop = (top - left).normalized();
    final leftTopLen = (top - left).distance;
    final actualLeftRightRadius4 = leftRightRadius < leftTopLen / 2 ? leftRightRadius : leftTopLen / 2;
    final actualTopBottomRadius4 = topBottomRadius < leftTopLen / 2 ? topBottomRadius : leftTopLen / 2;
    // 左顶点的上侧切点
    final leftTopTangent = left + leftToTop * actualLeftRightRadius4;
    // 上顶点的左侧切点
    final topLeftTangent = top - leftToTop * actualTopBottomRadius4;

    // 构建圆角菱形路径
    final path = Path();

    // 从上顶点的右侧切点开始（顺时针绘制）
    path.moveTo(topRightTangent.dx, topRightTangent.dy);

    // 右上边的直线部分
    path.lineTo(rightTopTangent.dx, rightTopTangent.dy);

    // 右顶点的圆角（使用二次贝塞尔曲线，控制点为顶点本身）
    path.quadraticBezierTo(
      right.dx, right.dy,
      rightBottomTangent.dx, rightBottomTangent.dy,
    );

    // 右下边的直线部分
    path.lineTo(bottomRightTangent.dx, bottomRightTangent.dy);

    // 下顶点的圆角
    path.quadraticBezierTo(
      bottom.dx, bottom.dy,
      bottomLeftTangent.dx, bottomLeftTangent.dy,
    );

    // 左下边的直线部分
    path.lineTo(leftBottomTangent.dx, leftBottomTangent.dy);

    // 左顶点的圆角
    path.quadraticBezierTo(
      left.dx, left.dy,
      leftTopTangent.dx, leftTopTangent.dy,
    );

    // 左上边的直线部分
    path.lineTo(topLeftTangent.dx, topLeftTangent.dy);

    // 上顶点的圆角
    path.quadraticBezierTo(
      top.dx, top.dy,
      topRightTangent.dx, topRightTangent.dy,
    );

    path.close();

    // 绘制填充
    if (diamond.backgroundColor.isNotTransparent) {
      switch (diamond.fillStyle) {
        case 'solid':
          canvas.drawPath(path, paint);
          break;
        case 'hachure':
          canvas.save();
          canvas.clipPath(path);
          _drawHachureFill(canvas, bounds, paint);
          canvas.restore();
          break;
        case 'cross-hatch':
          canvas.save();
          canvas.clipPath(path);
          _drawCrossHatchFill(canvas, bounds, paint);
          canvas.restore();
          break;
        default:
          canvas.drawPath(path, paint);
      }
    }

    // 绘制描边
    switch (diamond.strokeStyle) {
      case 'solid':
        canvas.drawPath(path, strokePaint);
        break;
      case 'dashed':
        _drawDashedPath(canvas, path, strokePaint);
        break;
      case 'dotted':
        _drawDottedPath(canvas, path, strokePaint);
        break;
      default:
        canvas.drawPath(path, strokePaint);
    }
  }
}

/// 扩展方法:标准化 Offset
extension _OffsetExtension on Offset {
  Offset normalized() {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
}

/// 绘制 hachure 填充（45°左下、右上平行线）
void _drawHachureFill(Canvas canvas, Rect bounds, Paint paint) {
  const double spacing = 8.0; // 线条间距
  final fillPaint = Paint()
    ..color = paint.color
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // 45° 平行线：x + y = c（从左下到右上）
  // 截距 c 的范围
  final cMin = bounds.left + bounds.top;
  final cMax = bounds.right + bounds.bottom;

  // 截距间隔（45° 线的垂直距离转换为截距间隔）
  final cSpacing = spacing * sqrt(2);

  for (double c = cMin; c <= cMax; c += cSpacing) {
    // 对于线 x + y = c，找它与矩形的交点
    final intersections = <Offset>[];

    // 与左边界交点: x = left, y = c - left
    double y = c - bounds.left;
    if (y >= bounds.top && y <= bounds.bottom) {
      intersections.add(Offset(bounds.left, y));
    }

    // 与右边界交点: x = right, y = c - right
    y = c - bounds.right;
    if (y >= bounds.top && y <= bounds.bottom) {
      intersections.add(Offset(bounds.right, y));
    }

    // 与上边界交点: y = top, x = c - top
    double x = c - bounds.top;
    if (x >= bounds.left && x <= bounds.right) {
      intersections.add(Offset(x, bounds.top));
    }

    // 与下边界交点: y = bottom, x = c - bottom
    x = c - bounds.bottom;
    if (x >= bounds.left && x <= bounds.right) {
      intersections.add(Offset(x, bounds.bottom));
    }

    // 一条线与矩形最多有2个交点
    if (intersections.length >= 2) {
      canvas.drawLine(intersections[0], intersections[1], fillPaint);
    }
  }
}

/// 绘制 cross-hatch 填充（45°交叉线）
void _drawCrossHatchFill(Canvas canvas, Rect bounds, Paint paint) {
  // 第一个方向：从左下到右上
  _drawHachureFill(canvas, bounds, paint);

  // 第二个方向：从左上到右下（垂直于第一个方向）
  const double spacing = 8.0;
  final fillPaint = Paint()
    ..color = paint.color
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  // 45° 平行线（另一个方向）：x - y = c（从左上到右下）
  // 截距 c 的范围
  final cMin = bounds.left - bounds.bottom;
  final cMax = bounds.right - bounds.top;

  // 截距间隔
  final cSpacing = spacing * sqrt(2);

  for (double c = cMin; c <= cMax; c += cSpacing) {
    // 对于线 x - y = c，找它与矩形的交点
    final intersections = <Offset>[];

    // 与左边界交点: x = left, y = left - c
    double y = bounds.left - c;
    if (y >= bounds.top && y <= bounds.bottom) {
      intersections.add(Offset(bounds.left, y));
    }

    // 与右边界交点: x = right, y = right - c
    y = bounds.right - c;
    if (y >= bounds.top && y <= bounds.bottom) {
      intersections.add(Offset(bounds.right, y));
    }

    // 与上边界交点: y = top, x = c + top
    double x = c + bounds.top;
    if (x >= bounds.left && x <= bounds.right) {
      intersections.add(Offset(x, bounds.top));
    }

    // 与下边界交点: y = bottom, x = c + bottom
    x = c + bounds.bottom;
    if (x >= bounds.left && x <= bounds.right) {
      intersections.add(Offset(x, bounds.bottom));
    }

    // 一条线与矩形最多有2个交点
    if (intersections.length >= 2) {
      canvas.drawLine(intersections[0], intersections[1], fillPaint);
    }
  }
}

/// 绘制虚线直线段
/// dashLength: 实线长度，gapLength: 间隙长度
void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dashLength = 5.0, double gapLength = 5.0}) {
  final vector = end - start;
  final totalLength = vector.distance;
  if (totalLength == 0) return;

  final direction = vector / totalLength;
  final patternLength = dashLength + gapLength;
  double currentDistance = 0.0;

  while (currentDistance < totalLength) {
    // 计算当前实线段的起点和终点
    final segmentStart = start + direction * currentDistance;
    final remainingLength = totalLength - currentDistance;
    final segmentLength = remainingLength < dashLength ? remainingLength : dashLength;
    final segmentEnd = segmentStart + direction * segmentLength;

    canvas.drawLine(segmentStart, segmentEnd, paint);

    currentDistance += patternLength;
  }
}

/// 绘制点线直线段
/// dotLength: 点的长度，gapLength: 间隙长度
void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint, {double dotLength = 2.0, double gapLength = 5.0}) {
  final vector = end - start;
  final totalLength = vector.distance;
  if (totalLength == 0) return;

  final direction = vector / totalLength;
  final patternLength = dotLength + gapLength;
  double currentDistance = 0.0;

  while (currentDistance < totalLength) {
    // 计算当前点的起点和终点
    final dotStart = start + direction * currentDistance;
    final remainingLength = totalLength - currentDistance;
    final dotActualLength = remainingLength < dotLength ? remainingLength : dotLength;
    final dotEnd = dotStart + direction * dotActualLength;

    canvas.drawLine(dotStart, dotEnd, paint);

    currentDistance += patternLength;
  }
}

/// 绘制虚线路径（用于曲线）
void _drawDashedPath(Canvas canvas, Path path, Paint paint, {double dashLength = 5.0, double gapLength = 5.0}) {
  final metrics = path.computeMetrics().toList();
  final patternLength = dashLength + gapLength;

  for (final metric in metrics) {
    double currentDistance = 0.0;

    while (currentDistance < metric.length) {
      // 计算当前实线段的起点和终点
      final remainingLength = metric.length - currentDistance;
      final segmentLength = remainingLength < dashLength ? remainingLength : dashLength;

      // 提取路径片段
      final segmentPath = metric.extractPath(currentDistance, currentDistance + segmentLength);
      canvas.drawPath(segmentPath, paint);

      currentDistance += patternLength;
    }
  }
}

/// 绘制点线路径（用于曲线）
void _drawDottedPath(Canvas canvas, Path path, Paint paint, {double dotLength = 2.0, double gapLength = 5.0}) {
  final metrics = path.computeMetrics().toList();
  final patternLength = dotLength + gapLength;

  for (final metric in metrics) {
    double currentDistance = 0.0;

    while (currentDistance < metric.length) {
      // 计算当前点的起点和终点
      final remainingLength = metric.length - currentDistance;
      final dotActualLength = remainingLength < dotLength ? remainingLength : dotLength;

      // 提取路径片段
      final dotPath = metric.extractPath(currentDistance, currentDistance + dotActualLength);
      canvas.drawPath(dotPath, paint);

      currentDistance += patternLength;
    }
  }
}

/// 解析文本对齐方式
TextAlign _parseTextAlign(String align) {
  switch (align) {
    case 'center':
      return TextAlign.center;
    case 'right':
      return TextAlign.right;
    case 'justify':
      return TextAlign.justify;
    case 'end':
      return TextAlign.end;
    case 'start':
      return TextAlign.start;
    case 'left':
    default:
      return TextAlign.left;
  }
}

void drawGrid({
  required Canvas canvas,
  required Size size,
  required double gridSize,
  required double gridStep,
  required double scale,
  required Offset pan,
}) {
  assert(gridSize % gridStep == 0);
  gridSize*=5;
  gridStep*=5;

  const double kMinFineGridPixelSpacing = 8.0;
  final bool drawFineGrid = gridStep * scale >= kMinFineGridPixelSpacing;

  final double visualLineWidth = 1.0 / scale;

  final Paint thinPaint = Paint()
    ..color = const Color(0xFFE0E0E0)
    ..strokeWidth = visualLineWidth
    ..style = PaintingStyle.stroke;

  final Paint thickPaint = Paint()
    ..color = const Color(0xFFCCCCCC)
    ..strokeWidth = visualLineWidth * 1.5
    ..style = PaintingStyle.stroke;

  Path dashLine(Offset a, Offset b) {
    const double dash = 4;
    const double gap = 4;

    final path = Path();
    final dir = b - a;
    final length = dir.distance;
    final unit = dir / length;

    double distance = 0;
    while (distance < length) {
      final start = a + unit * distance;
      final end = a + unit * (distance + dash).clamp(0, length);
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
      distance += dash + gap;
    }
    return path;
  }

  final origin = pan;

  final double left   = -origin.dx;
  final double top    = -origin.dy;
  final double right  = left + size.width / scale;
  final double bottom = top + size.height / scale;

  final double startX =
      (left / gridStep).floorToDouble() * gridStep;
  final double startY =
      (top / gridStep).floorToDouble() * gridStep;

  for (double x = startX; x <= right; x += gridStep) {
    final bool isThick = (x % gridSize).abs() < 0.0001;

    if (!isThick && !drawFineGrid) continue;

    final paint = isThick ? thickPaint : thinPaint;
    final a = Offset(x, top);
    final b = Offset(x, bottom);

    if (isThick) {
      canvas.drawLine(a, b, paint);
    } else {
      canvas.drawPath(dashLine(a, b), paint);
    }
  }

  for (double y = startY; y <= bottom; y += gridStep) {
    final bool isThick = (y % gridSize).abs() < 0.0001;

    if (!isThick && !drawFineGrid) continue;

    final paint = isThick ? thickPaint : thinPaint;
    final a = Offset(left, y);
    final b = Offset(right, y);

    if (isThick) {
      canvas.drawLine(a, b, paint);
    } else {
      canvas.drawPath(dashLine(a, b), paint);
    }
  }
}
