import 'package:flutter/material.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

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
    required Color? textColor,
    double fontSize = 36,
    double lineHeight = 1.25,
  }){
    return TextEditData(
      textController: TextEditingController(),
      behalfElement: FreeformCanvasText(
        id: '', 
        index: '', 
        x: textCanvasPosition.dx, 
        y: textCanvasPosition.dy, 
        width: 200, 
        height: lineHeight*fontSize, 
        angle: 0, 
        strokeColor: textColor == null ? FreeformCanvasColor.black() : FreeformCanvasColor.fromColor(textColor), 
        backgroundColor: FreeformCanvasColor.transparent(), 
        fillStyle: '', 
        strokeWidth: 2, 
        strokeStyle: '', 
        roughness: 1, 
        opacity: 100, 
        locked: false, 
        groupIds: [], 
        text: '', 
        fontSize: fontSize, 
        fontFamily: 5, 
        textAlign: 'left', 
        verticalAlign: 'top', 
        lineHeight: lineHeight, 
        autoResize: false
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