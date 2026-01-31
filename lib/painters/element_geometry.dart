import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

///**ZH** 提供元素缩放控制点、边界矩形、控制点等的统一计算。所有坐标均在canvas坐标系下。
///
///**EN** Provides unified calculation of element scaling control points, boundary rectangles, and control points.
/// All coordinates are in the canvas coordinate system.
class ElementGeometry {
  ElementGeometry._();
  ///**ZH** 元素实际边界
  ///
  ///**EN** Actual element boundary
  static Rect border(FreeformCanvasElement element){
    if(element.type==FreeformCanvasElementType.freedraw
      || element.type==FreeformCanvasElementType.line
    ){
      double l=0;
      double t=0;
      for(var point in (element as ElementWithPoints).points){
        if(point.x<l) l = point.x;
        if(point.y<t) t = point.y;
      }
      final lt = Offset(element.x + l, element.y + t);
      final rb = Offset(element.width, element.height) + lt;
      return Rect.fromPoints(lt, rb);
    }else{
      final lt = Offset(element.x, element.y);
      final rb = Offset(element.width, element.height) + lt;
      return Rect.fromPoints(lt, rb);
    }
  }
  ///**ZH** 元素选择框矩形
  ///
  ///**EN** Selection box rectangle
  static Rect selectionRect(FreeformCanvasElement element){
    final double inflate = 5;
    return ElementGeometry.border(element).inflate(inflate);
  }
  ///**ZH** 元素缩放手柄的相对位置（rect顶点处为缩放手柄中心）
  ///
  ///**EN** The relative position of the resize handle 
  ///(the center of the resize handle is at the top left corner of the rect)
  static Rect resizeHandlePosition(FreeformCanvasElement element){
    return ElementGeometry.border(element).inflate(10);
  }
  static double get resizeHandleDiameter => 8;
  ///**ZH** 元素缩放手柄矩形，画布坐标系。手柄大小随scale变化。
  ///
  ///**EN** Resize handle rectangle in the canvas coordinate system. The handle size changes with scale.
  static Rect resizeHandleRect(Offset centerPoint,double scale){
    return Rect.fromCenter(center: centerPoint, width: resizeHandleDiameter/scale, height: resizeHandleDiameter/scale);
  }
  ///**ZH** 获取元素边界矩形中心
  ///
  ///**EN** Get the center of the element boundary rectangle
  static Offset center(FreeformCanvasElement element){
    final rect = ElementGeometry.border(element);
    return rect.center;
  }
  ///**ZH** 以与元素旋转方向相反的方向旋转点（用来判断某点是否在旋转后的矩形内）
  ///
  ///**EN** Rotate the point in the opposite direction of the element rotation
  ///(used to determine whether the point is in the rotated rectangle after rotation)
  static Offset inversedElementRotate(FreeformCanvasElement element,Offset offset){
    final center = ElementGeometry.center(element);
    final dx = offset.dx-center.dx;
    final dy = offset.dy-center.dy;
    final l = sqrt(pow(dx, 2)+pow(dy, 2));
    final angle = atan2(dy, dx) - element.angle;
    return Offset(l*cos(angle), l*sin(angle));
  }
  ///**ZH** 以与元素旋转方向相同的方向旋转点
  ///
  ///**EN** Rotate the point in the same direction as the element rotation
  static Offset correspondedElementRotate(FreeformCanvasElement element,Offset offset){
    final center = ElementGeometry.center(element);
    final dx = offset.dx-center.dx;
    final dy = offset.dy-center.dy;
    final l = sqrt(pow(dx, 2)+pow(dy, 2));
    final angle = atan2(dy, dx) + element.angle;
    return Offset(l*cos(angle), l*sin(angle));
  }
  ///**ZH** 获取元素旋转手柄在canvas坐标系下的坐标
  ///
  ///**EN** Get the position of the element rotation handle in the canvas coordinate system
  static Offset rotateHandlePosition(FreeformCanvasElement element){
    late double t;
    if(element.type==FreeformCanvasElementType.freedraw
      || element.type==FreeformCanvasElementType.line
    ){
      t=0;
      for(var point in (element as ElementWithPoints).points){
        if(point.y<t) t = point.y;
      }
      t += element.y;
    }else{
      t = element.y;
    }
    return correspondedElementRotate(element, Offset(element.x, t));
  }
  ///**ZH** 获取元素旋转手柄的半径
  ///
  ///**EN** Get the radius of the element rotation handle
  static double get rotateHandleRadius => 4;
  ///**ZH** 根据相关字段计算文本宽高，返回（宽，高）
  ///
  ///**EN** Calculate the width and height of text based on related fields, return (width, height)
  static (double, double) layoutText({
    required String text,
    required double fontSize,
    required int fontFamily,
    required String textAlign,
    required String verticalAlign,
    required double lineHeight,
  }){
    final textStyle = TextStyle(
      color: const Color(0xff000000),
      fontSize: fontSize,
      height: lineHeight,
    );
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return (textPainter.width, textPainter.height);
  }
}