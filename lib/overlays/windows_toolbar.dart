///**ZH** 工具栏，用来选择工具：拖动，选择，矩形，椭圆，直线，箭头，自由绘制，文本，橡皮擦
///
///**EN** Toolbar, used to select tools: drag, select, rectangle, ellipse, line, arrow, freedraw, text, eraser
library;

import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/foundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
class WindowsToolbar extends Overlays{
  const WindowsToolbar();
  @override
  List<Widget> builder(BuildContext context, EditorState editorState) {
    return [
      _buildToolButton(editorState: editorState,tool: EditorTool.drag),
      _buildToolButton(editorState: editorState,tool: EditorTool.select),
      _buildToolButton(editorState: editorState,tool: EditorTool.rectangle),
      _buildToolButton(editorState: editorState,tool: EditorTool.diamond),
      _buildToolButton(editorState: editorState,tool: EditorTool.ellipse),
      _buildToolButton(editorState: editorState,tool: EditorTool.line),
      _buildToolButton(editorState: editorState,tool: EditorTool.arrow),
      _buildToolButton(editorState: editorState,tool: EditorTool.freedraw),
      _buildToolButton(editorState: editorState,tool: EditorTool.text),
      _buildToolButton(editorState: editorState,tool: EditorTool.eraser),
      _buildUndoButton(editorState: editorState,),
      _buildRedoButton(editorState: editorState,),
    ];
  }
  static Widget _buildToolButton({required EditorState editorState,required EditorTool tool}) {
    return Listener(
      onPointerDown: (_)=>editorState.switchTool(tool),
      child: ListenableBuilder(
        listenable: editorState.toolState, 
        builder: (_,_){
          return BasicButtonUI(
            iconData: tool.icon, 
            message: tool.name, 
            isSelected: editorState.toolState.currentTool == tool
          );
        }
      ),
    );
  }
  Widget _buildUndoButton({required EditorState editorState}){
    return BasicButton2UI(onPointed: ()=>editorState.undo(), icon: Icons.undo, message: 'undo');
  }
  Widget _buildRedoButton({required EditorState editorState}){
    return BasicButton2UI(onPointed: ()=>editorState.redo(), icon: Icons.redo, message: 'redo');
  }
}

//下面三个类为本Overlay按钮使用的按钮风格组件，用于自定义新的按钮
// The following three classes are button styles used by the buttons in this Overlay,
// and can be used to customize new buttons

///**ZH** WindowsToolbar所使用的按钮外观组件，无selected状态，只有按下和抬起之分
///
///**EN** The button appearance used by WindowsToolbar with pressed and released status
class BasicButton2UI extends StatefulWidget{
  final void Function() onPointed;
  final IconData icon;
  final String message;

  const BasicButton2UI({super.key, required this.onPointed, required this.icon, required this.message});

  @override
  State<BasicButton2UI> createState() => _BasicButton2UIState();
}
class _BasicButton2UIState extends State<BasicButton2UI> {
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        setState(() {
          selected = true;
        });
      },
      onPointerUp: (event) {
        setState(() {
          selected = false;
        });
        widget.onPointed();
      },
      child: BasicButtonUI(iconData: widget.icon, message: widget.message, isSelected: selected),
    );
  }
}
///**ZH** WindowsToolbar所使用的按钮外观组件，有selected状态
///
///**EN** The button appearance used by WindowsToolbar, with selected and !selected status
class BasicButtonUI extends StatelessWidget{
  final IconData iconData;
  final String message;
  final bool isSelected;

  const BasicButtonUI({super.key, required this.iconData, required this.message, required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: ValueKey('${message}tb'),
      message: message,
      child: Padding(
        padding: EdgeInsetsGeometry.all(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: isSelected ? Colors.blue[100]! : Colors.transparent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: EdgeInsetsGeometry.all(7),
            child: Icon(iconData,size: 25,),
          ),
        ),
      ),
    );
  }
}