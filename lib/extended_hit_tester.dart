import 'dart:ui';
import 'package:freeform_canvas/freeform_canvas_hit_tester.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/painters/element_geomatry.dart';

///**ZH** 命中内容的类型
///
///**EN** Type of hit content
enum HitTestType{
  none,
  element,
  resizeHandle,
  rotateHandle,
  controllPoint,
  secondaryControllPoint,
}
///**ZH** 缩放手柄类型
///
///**EN** Type of resize handle
enum ResizeHandle{
  tl,
  tr,
  bl,
  br
}

///**ZH** 对所有可命中元素的统一命中测试结果
///
///**EN** Result of unified hit test
class ExtendedHitTestResult{
  final HitTestType hitTestType;
  ///当且仅当`type!=element`时，`elementId`为`focusedElementId`
  final String? elementId;
  final ResizeHandle? resizeHandle;

  ExtendedHitTestResult({
    required this.hitTestType,
    this.elementId,
    this.resizeHandle,
  });
}
///**ZH** 对所有可命中元素的统一命中测试,包含控制点等
///
///**EN** Unified hit test for all elements, including control points, etc
class ExtendedHitTester {
  /// **ZH** focusedElementId： 当前聚焦元素（该元素拥有控制点等）
  ///
  /// 返回第一个命中的内容
  /// 
  /// **EN** focusedElementId: Current focus element (this element has control points, etc.)
  /// 
  /// Returns the first hit content
  static ExtendedHitTestResult hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
    String? focusedElementId,
  ){
    //仅对选中元素的控制手柄做测试
    if(focusedElementId!=null){
      for(var element in elements){
        if(element.id==focusedElementId){
          final handleHitResult = _singleEleResizeHandleHitTest(worldPoint, element);
          if(handleHitResult!=null){
            //命中缩放手柄
            return ExtendedHitTestResult(
              hitTestType: HitTestType.resizeHandle,
              elementId: element.id,
              resizeHandle: handleHitResult
            );
          }
          final rotateHitResult = _singleEleRotateHandleHitTest(worldPoint,element);
          if(rotateHitResult){
            //命中旋转手柄
            return ExtendedHitTestResult(
              hitTestType: HitTestType.rotateHandle,
              elementId: element.id,
              resizeHandle: null,
            );
          }
          //命中元素控制点
          break;
        }
      }
    }
    //对元素本身做命中测试
    final elementHitTest = FreeformCanvasHitTester.hitTest(worldPoint, elements);
    if(elementHitTest==null){
      return ExtendedHitTestResult(hitTestType: HitTestType.none);
    }else{
      return ExtendedHitTestResult(
        hitTestType: HitTestType.element,
        elementId: elementHitTest.elementId,
        resizeHandle: null,
      );
    }
  }

  ///计算是否命中缩放手柄
  static ResizeHandle? _singleEleResizeHandleHitTest(Offset canvasPoint,FreeformCanvasElement element){
    final rect = ElementGeomatry.resizeHandlePosition(element);
    if(_singleResizeHandleHitTest(canvasPoint, rect.topLeft)){
      return ResizeHandle.tl;
    }else 
    if(_singleResizeHandleHitTest(canvasPoint, rect.topRight)){
      return ResizeHandle.tr;
    }else 
    if(_singleResizeHandleHitTest(canvasPoint, rect.bottomLeft)){
      return ResizeHandle.bl;
    }else 
    if(_singleResizeHandleHitTest(canvasPoint, rect.bottomRight)){
      return ResizeHandle.br;
    }else{
      return null;
    }
  }
  static bool _singleResizeHandleHitTest(Offset canvasPoint,Offset center){
    return ElementGeomatry.resizeHandleRect(center).contains(canvasPoint);
  }
  ///计算是否命中旋转手柄
  static bool _singleEleRotateHandleHitTest(Offset worldPoint,FreeformCanvasElement element){
    final center = ElementGeomatry.rotateHandlePosition(element);
    return (worldPoint - center).distanceSquared <= ElementGeomatry.rotateHandleRadius;
  }
}

