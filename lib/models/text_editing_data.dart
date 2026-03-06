import 'package:flutter/material.dart';
import 'package:freeform_canvas/models/element_style.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/ops/element_ops.dart';

///**ZH** 文本编辑数据
///
///**EN** Text editing data
class TextEditData{
  final TextEditingController textController;// 文本编辑控制器
  FreeformCanvasText behalfElement;
  ///isVirtual==true: The element is not in the file
  final bool isVirtual;

  TextEditData({
    required this.textController,
    required this.behalfElement,
    required this.isVirtual,
  });

  void dispose(){
    textController.dispose();
  }

  factory TextEditData.newText({
    required Offset textCanvasPosition,
    required ElementStyle defaultStyle,
  }){
    return TextEditData(
      textController: TextEditingController(),
      behalfElement: ElementOps.createText(
        textCanvasPosition: textCanvasPosition,
        defaultStyle: defaultStyle,
      ),
      isVirtual: true,
    );
  }
  
  factory TextEditData.fromElement({required FreeformCanvasText element}){
    return TextEditData(
      textController: TextEditingController(text: element.text),
      behalfElement: element,
      isVirtual: false,
    );
  }
}