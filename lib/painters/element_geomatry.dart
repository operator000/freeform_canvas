import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

///**ZH** 提供元素缩放控制点、边界矩形、控制点等的统一计算。所有坐标均在canvas坐标系下。
///
///**EN** Provides unified calculation of element scaling control points, boundary rectangles, and control points.
/// All coordinates are in the canvas coordinate system.
class ElementGeomatry {
  ElementGeomatry._();
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
    return ElementGeomatry.border(element).inflate(inflate);
  }
  ///**ZH** 元素缩放手柄的相对位置（rect顶点处为缩放手柄中心）
  ///
  ///**EN** The relative position of the resize handle 
  ///(the center of the resize handle is at the top left corner of the rect)
  static Rect resizeHandlePosition(FreeformCanvasElement element){
    return ElementGeomatry.border(element).inflate(10);
  }
  ///**ZH** 元素缩放手柄矩形
  ///
  ///**EN** Resize handle rectangle
  static Rect resizeHandleRect(Offset centerPoint){
    final double d = 8;
    return Rect.fromCenter(center: centerPoint, width: d, height: d);
  }
  ///**ZH** 获取元素边界矩形中心
  ///
  ///**EN** Get the center of the element boundary rectangle
  static Offset center(FreeformCanvasElement element){
    final rect = ElementGeomatry.border(element);
    return rect.center;
  }
  ///**ZH** 以与元素旋转方向相反的方向旋转点（用来判断某点是否在旋转后的矩形内）
  ///
  ///**EN** Rotate the point in the opposite direction of the element rotation
  ///(used to determine whether the point is in the rotated rectangle after rotation)
  static Offset inversedElementRotate(FreeformCanvasElement element,Offset offset){
    final center = ElementGeomatry.center(element);
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
    final center = ElementGeomatry.center(element);
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
}