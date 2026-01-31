import 'dart:math';
import 'package:flutter/material.dart';
import '../models/freeform_canvas_element.dart';

/// **ZH** 命中测试结果
/// 
/// **EN** Hit test result
class HitTestResult {
  /// **ZH** 被命中的元素ID
  /// 
  /// **EN** ID of the element hit
  final String elementId;

  HitTestResult(this.elementId);
}
/// **ZH** 命中测试器：提供对 FreeformCanvas 元素的几何命中测试功能
/// 仅基于几何形状和 bounds 判断
/// 
/// **EN** Hit tester: provides geometric hit testing for FreeformCanvas elements
/// Only based on shape and bounds
class FreeformCanvasHitTester {
  /// 命中容差（像素）
  static const double hitTolerance = 4.0;

  /// 文本元素的额外容差（像素）
  static const double textHitTolerance = 4.0;

  /// 将点从世界坐标转换到元素局部坐标（反向旋转）
  ///
  /// [worldPoint] 世界坐标系中的点
  /// [element] 元素
  /// 返回元素局部坐标系中的点
  static Offset _worldToLocal(Offset worldPoint, FreeformCanvasElement element) {
    if (element.angle == 0) {
      return worldPoint;
    }

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

    // 反向旋转：将点绕中心旋转 -angle
    final dx = worldPoint.dx - center.dx;
    final dy = worldPoint.dy - center.dy;
    final cosAngle = cos(-element.angle);
    final sinAngle = sin(-element.angle);

    final rotatedX = dx * cosAngle - dy * sinAngle;
    final rotatedY = dx * sinAngle + dy * cosAngle;

    return Offset(center.dx + rotatedX, center.dy + rotatedY);
  }

  /// **ZH** 对元素列表进行命中测试，返回第一个命中的元素（按渲染顺序反向遍历，保证点中最上层元素）
  /// 如果无命中，返回 null
  /// 
  /// **EN** Hit test elements in the list and return the first hit element 
  /// (reverse traversal to ensure the point is in the topmost element)
  /// 
  /// Returns null if no hit
  static HitTestResult? hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
  ) {
    // 按 index 排序（z-order），然后反向遍历
    final sortedElements = List<FreeformCanvasElement>.from(elements);
    sortedElements.sort((a, b) => a.index.compareTo(b.index));

    for (int i = sortedElements.length - 1; i >= 0; i--) {
      final element = sortedElements[i];
      if (_isPointInElement(worldPoint, element)) {
        return HitTestResult(element.id);
      }
    }

    return null;
  }

  /// 判断点是否在元素内（考虑旋转）
  static bool _isPointInElement(Offset point, FreeformCanvasElement element) {
    // 将点从世界坐标转换到元素局部坐标
    final localPoint = _worldToLocal(point, element);

    switch (element.type) {
      case FreeformCanvasElementType.rectangle:
        return _isPointInRectangle(localPoint, element as FreeformCanvasRectangle);
      case FreeformCanvasElementType.ellipse:
        return _isPointInEllipse(localPoint, element as FreeformCanvasEllipse);
      case FreeformCanvasElementType.text:
        return _isPointInText(localPoint, element as FreeformCanvasText);
      case FreeformCanvasElementType.freedraw:
        return _isPointInFreedraw(localPoint, element as FreeformCanvasFreedraw);
      case FreeformCanvasElementType.line:
        return _isPointInLine(localPoint, element as FreeformCanvasLine);
      case FreeformCanvasElementType.arrow:
        return _isPointInArrow(localPoint, element as FreeformCanvasArrow);
      case FreeformCanvasElementType.diamond:
        return _isPointInDiamond(localPoint, element as FreeformCanvasDiamond);
    }
  }

  /// 判断点是否在矩形内（支持填充和圆角）
  static bool _isPointInRectangle(Offset point, FreeformCanvasRectangle rect) {
    final bounds = rect.bounds;
    final hasFill = rect.backgroundColor != 'transparent';
    final cornerRadius = rect.cornerRadius;

    if (hasFill) {
      // 有填充：命中内部即可
      if (cornerRadius != null) {
        // 圆角矩形：使用 RRect 的 contains 判断
        final rrect = RRect.fromRectAndRadius(
          bounds,
          Radius.circular(cornerRadius),
        );
        return rrect.contains(point);
      } else {
        // 直角矩形：使用简单的矩形判断
        return isPointInRect(point, bounds);
      }
    } else {
      // 无填充：只判断边框
      if (cornerRadius != null) {
        // 圆角矩形边框
        return _distanceToRoundedRectangleBorder(point, bounds, cornerRadius) <= hitTolerance;
      } else {
        // 直角矩形边框
        return _distanceToRectangleBorder(point, bounds) <= hitTolerance;
      }
    }
  }

  /// 判断点是否在椭圆内（支持填充）
  static bool _isPointInEllipse(Offset point, FreeformCanvasEllipse ellipse) {
    // 椭圆半径
    final rx = ellipse.width / 2;
    final ry = ellipse.height / 2;

    // 如果宽度或高度为0，无法形成椭圆
    if (rx <= 0 || ry <= 0) {
      return false;
    }

    final hasFill = ellipse.backgroundColor != 'transparent';

    if (hasFill) {
      // 有填充：判断点是否在椭圆内部
      // 椭圆方程：((x - cx) / rx)^2 + ((y - cy) / ry)^2 <= 1
      final cx = ellipse.x + rx;
      final cy = ellipse.y + ry;
      final normalizedX = (point.dx - cx) / rx;
      final normalizedY = (point.dy - cy) / ry;
      return normalizedX * normalizedX + normalizedY * normalizedY <= 1.0;
    } else {
      // 无填充：判断点到边框的距离
      final distance = _distanceToEllipseBorder(point, ellipse);
      return distance <= hitTolerance;
    }
  }

  /// 判断点是否在文本元素内
  static bool _isPointInText(Offset point, FreeformCanvasText text) {
    // 使用 axis-aligned bounding box，可以稍微 inflate 以提升点击容错
    final bounds = text.bounds.inflate(textHitTolerance);
    return isPointInRect(point, bounds);
  }

  /// 判断点是否在自由绘制路径内
  static bool _isPointInFreedraw(Offset point, FreeformCanvasFreedraw freedraw) {
    if (freedraw.points.isEmpty) {
      return false;
    }

    // 判断点击点到每一段线段的最短距离 <= hitTolerance
    for (int i = 0; i < freedraw.points.length - 1; i++) {
      final p1 = freedraw.points[i].toAbsolute(freedraw.x, freedraw.y);
      final p2 = freedraw.points[i + 1].toAbsolute(freedraw.x, freedraw.y);

      if (pointToSegmentDistance(point, p1, p2) <= hitTolerance) {
        return true;
      }
    }

    return false;
  }

  /// 判断点是否在直线内
  static bool _isPointInLine(Offset point, FreeformCanvasLine line) {
    if (line.points.length < 2) {
      return false;
    }

    // 遍历所有线段
    for (int i = 0; i < line.points.length - 1; i++) {
      final p1 = line.points[i].toAbsolute(line.x, line.y);
      final p2 = line.points[i + 1].toAbsolute(line.x, line.y);

      if (pointToSegmentDistance(point, p1, p2) <= hitTolerance) {
        return true;
      }
    }

    // 如果是闭合多边形，还需要检查最后一段到第一段的连接
    if (line.polygon && line.points.length >= 3) {
      final p1 = line.points.last.toAbsolute(line.x, line.y);
      final p2 = line.points.first.toAbsolute(line.x, line.y);

      if (pointToSegmentDistance(point, p1, p2) <= hitTolerance) {
        return true;
      }
    }

    return false;
  }

  /// 判断点是否在箭头内
  static bool _isPointInArrow(Offset point, FreeformCanvasArrow arrow) {
    // 箭头本质上是直线，使用相同的命中测试逻辑
    return _isPointInLine(point, arrow);
  }

  /// 判断点是否在菱形内（支持填充和圆角）
  static bool _isPointInDiamond(Offset point, FreeformCanvasDiamond diamond) {
    final bounds = diamond.bounds;
    final hasFill = diamond.backgroundColor != 'transparent';

    // 计算菱形的四个顶点（边界矩形的中点）
    final top = Offset(bounds.left + bounds.width / 2, bounds.top);
    final right = Offset(bounds.right, bounds.top + bounds.height / 2);
    final bottom = Offset(bounds.left + bounds.width / 2, bounds.bottom);
    final left = Offset(bounds.left, bounds.top + bounds.height / 2);

    if (hasFill) {
      // 有填充：判断点是否在菱形内部
      // 菱形内部判断：点在所有四条边的内侧
      // 使用叉积判断点在边的哪一侧
      if (!_isPointOnLeftOfEdge(point, top, right)) return false;
      if (!_isPointOnLeftOfEdge(point, right, bottom)) return false;
      if (!_isPointOnLeftOfEdge(point, bottom, left)) return false;
      if (!_isPointOnLeftOfEdge(point, left, top)) return false;
      return true;
    } else {
      // 无填充：判断点到边框的距离
      final radii = diamond.diamondCornerRadii;
      if (radii != null) {
        // 圆角菱形边框
        // TODO: 实现圆角菱形边框的精确测试
        // 目前简化为直边测试
        final distanceToTopRight = pointToSegmentDistance(point, top, right);
        final distanceToRightBottom = pointToSegmentDistance(point, right, bottom);
        final distanceToBottomLeft = pointToSegmentDistance(point, bottom, left);
        final distanceToLeftTop = pointToSegmentDistance(point, left, top);

        final minDistance = min(
          min(distanceToTopRight, distanceToRightBottom),
          min(distanceToBottomLeft, distanceToLeftTop),
        );

        return minDistance <= hitTolerance;
      } else {
        // 直边菱形边框
        final distanceToTopRight = pointToSegmentDistance(point, top, right);
        final distanceToRightBottom = pointToSegmentDistance(point, right, bottom);
        final distanceToBottomLeft = pointToSegmentDistance(point, bottom, left);
        final distanceToLeftTop = pointToSegmentDistance(point, left, top);

        final minDistance = min(
          min(distanceToTopRight, distanceToRightBottom),
          min(distanceToBottomLeft, distanceToLeftTop),
        );

        return minDistance <= hitTolerance;
      }
    }
  }

  /// 判断点是否在边的左侧（使用叉积）
  static bool _isPointOnLeftOfEdge(Offset point, Offset edgeStart, Offset edgeEnd) {
    // 叉积：(edgeEnd - edgeStart) × (point - edgeStart)
    // 如果叉积 >= 0，点在边的左侧（或边上）
    final dx = edgeEnd.dx - edgeStart.dx;
    final dy = edgeEnd.dy - edgeStart.dy;
    final px = point.dx - edgeStart.dx;
    final py = point.dy - edgeStart.dy;
    final crossProduct = dx * py - dy * px;
    return crossProduct >= 0;
  }

  /// 辅助函数：判断点是否在矩形内
  static bool isPointInRect(Offset point, Rect rect) {
    return point.dx >= rect.left &&
        point.dx <= rect.right &&
        point.dy >= rect.top &&
        point.dy <= rect.bottom;
  }

  /// 辅助函数：计算点到线段的最短距离
  ///
  /// 使用向量投影方法，参考：https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
  static double pointToSegmentDistance(
    Offset point,
    Offset segmentStart,
    Offset segmentEnd,
  ) {
    final lineVector = segmentEnd - segmentStart;
    final pointVector = point - segmentStart;

    final lineLengthSquared = lineVector.dx * lineVector.dx + lineVector.dy * lineVector.dy;

    // 如果线段长度为0，直接返回点到起点的距离
    if (lineLengthSquared == 0) {
      return pointVector.distance;
    }

    // 计算投影比例 t = (pointVector · lineVector) / ||lineVector||^2
    final t = (pointVector.dx * lineVector.dx + pointVector.dy * lineVector.dy) /
        lineLengthSquared;

    if (t < 0) {
      // 投影点在线段起点之前，返回点到起点的距离
      return pointVector.distance;
    } else if (t > 1) {
      // 投影点在线段终点之后，返回点到终点的距离
      return (point - segmentEnd).distance;
    } else {
      // 投影点在线段上，计算垂足
      final projection = segmentStart + lineVector * t;
      return (point - projection).distance;
    }
  }

  /// 计算点到矩形边框的最短距离
  static double _distanceToRectangleBorder(Offset point, Rect rect) {
    final left = rect.left;
    final top = rect.top;
    final right = rect.right;
    final bottom = rect.bottom;

    // 计算点到四条边的距离
    final distanceToTop = pointToSegmentDistance(
      point,
      Offset(left, top),
      Offset(right, top),
    );
    final distanceToBottom = pointToSegmentDistance(
      point,
      Offset(left, bottom),
      Offset(right, bottom),
    );
    final distanceToLeft = pointToSegmentDistance(
      point,
      Offset(left, top),
      Offset(left, bottom),
    );
    final distanceToRight = pointToSegmentDistance(
      point,
      Offset(right, top),
      Offset(right, bottom),
    );

    // 返回最短距离
    return min(
      min(distanceToTop, distanceToBottom),
      min(distanceToLeft, distanceToRight),
    );
  }

  /// 计算点到圆角矩形边框的最短距离
  static double _distanceToRoundedRectangleBorder(Offset point, Rect rect, double radius) {
    // 简化实现：近似为四条边和四个圆角的组合
    // 创建 RRect
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // 如果点在圆角矩形内部，计算到边界的距离
    if (rrect.contains(point)) {
      // 点在内部，计算到最近边界的距离
      // 简化：计算到四条边的距离（忽略圆角的精确计算）
      final distanceToTop = (point.dy - rect.top).abs();
      final distanceToBottom = (rect.bottom - point.dy).abs();
      final distanceToLeft = (point.dx - rect.left).abs();
      final distanceToRight = (rect.right - point.dx).abs();

      return min(
        min(distanceToTop, distanceToBottom),
        min(distanceToLeft, distanceToRight),
      );
    } else {
      // 点在外部，计算到最近边界的距离
      // 简化：使用直角矩形的距离
      return _distanceToRectangleBorder(point, rect);
    }
  }

  /// 计算点到椭圆边框的最短距离
  static double _distanceToEllipseBorder(Offset point, FreeformCanvasEllipse ellipse) {
    // 将点转换到椭圆局部坐标系（以椭圆中心为原点）
    final localPoint = point - Offset(ellipse.x, ellipse.y);
    final cx = ellipse.width / 2;
    final cy = ellipse.height / 2;

    // 以椭圆中心为原点的坐标
    final px = localPoint.dx - cx;
    final py = localPoint.dy - cy;

    // 椭圆半轴
    final a = ellipse.width / 2;
    final b = ellipse.height / 2;

    if (a <= 0 || b <= 0) {
      // 退化椭圆，返回到中心的距离
      return Offset(px, py).distance;
    }

    // 计算椭圆上最近点
    final closest = _closestPointOnEllipse(a, b, Offset(px, py));

    // 计算距离
    final dx = px - closest.dx;
    final dy = py - closest.dy;
    return sqrt(dx * dx + dy * dy);
  }

  /// 计算椭圆上距离给定点最近的点（椭圆中心在原点，主轴与坐标轴对齐）
  ///
  /// 算法参考：http://wet-robots.ghost.io/simple-method-for-distance-to-ellipse/
  /// [a] - 椭圆x轴半长
  /// [b] - 椭圆y轴半长
  /// [p] - 查询点（以椭圆中心为原点）
  /// 返回椭圆上最近点的坐标
  static Offset _closestPointOnEllipse(double a, double b, Offset p) {
    // 取点的绝对值
    double px = p.dx.abs();
    double py = p.dy.abs();

    // 初始参数（0.707 ≈ sqrt(0.5)）
    double tx = 0.707;
    double ty = 0.707;

    // 迭代3次（如原文所述）
    for (int i = 0; i < 3; i++) {
      double x = a * tx;
      double y = b * ty;

      double ex = (a * a - b * b) * tx * tx * tx / a;
      double ey = (b * b - a * a) * ty * ty * ty / b;

      double rx = x - ex;
      double ry = y - ey;

      double qx = px - ex;
      double qy = py - ey;

      double r = sqrt(ry * ry + rx * rx);
      double q = sqrt(qy * qy + qx * qx);

      // 避免除零（当点在椭圆中心时）
      if (q < 1e-12) {
        // 点在椭圆中心，返回较近的半轴端点
        if (a <= b) {
          return Offset(a * (p.dx < 0 ? -1 : 1), 0);
        } else {
          return Offset(0, b * (p.dy < 0 ? -1 : 1));
        }
      }

      tx = (qx * r / q + ex) / a;
      ty = (qy * r / q + ey) / b;

      // 限制在[0, 1]范围内
      tx = max(0.0, min(1.0, tx));
      ty = max(0.0, min(1.0, ty));

      double t = sqrt(ty * ty + tx * tx);
      tx /= t;
      ty /= t;
    }

    // 恢复符号
    return Offset(
      a * tx * (p.dx < 0 ? -1 : 1),
      b * ty * (p.dy < 0 ? -1 : 1),
    );
  }
}