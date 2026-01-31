import 'dart:async';
import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/models/text_editing_data.dart';

class EInkToolbar extends Overlays{
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
      _buildUndoButton(editorState: editorState),
      _buildRedoButton(editorState: editorState),
      _buildTextEditButton(editorState: editorState)
    ];
  }

  static Widget _buildToolButton({
    required EditorState editorState,
    required EditorTool tool,
  }) {
    return Tooltip(
      key: ValueKey('${tool.index}tb'),
      message: tool.name,
      child: Padding(
        padding: EdgeInsetsGeometry.all(2),
        child: ListenableBuilder(
          listenable: editorState.toolState, 
          builder: (_, _) {
            final isSelected = editorState.toolState.currentTool == tool;
            return Listener(
              onPointerDown: (_)=>editorState.switchTool(tool),
              child: BasicButtonUI(
                message: tool.name,
                iconData: tool.icon, 
                isSelected: isSelected,
              ),
            );
          },
        ),
      ),
    );
  }
}
Widget _buildUndoButton({required EditorState editorState}){
  return LongpressButtonUI(onPressed: ()=>editorState.undo(), icon: Icons.undo, message: 'undo');
}
Widget _buildRedoButton({required EditorState editorState}){
  return LongpressButtonUI(onPressed: ()=>editorState.redo(), icon: Icons.redo, message: 'redo');
}
Widget _buildTextEditButton({required EditorState editorState}){
  return ListenableBuilder(listenable: editorState.focusState, builder: (_,_){
    final element = editorState.focusedElement;
    if(element is FreeformCanvasText){
      return LongpressButtonUI(
        onPressed: ()=>editorState.enterTextEdit(TextEditData.fromElement(element: element)), 
        icon: Icons.text_format, 
        message: 'edit text'
      );
    }else{
      return SizedBox.shrink();
    }
  });
}
//下面三个类为本Overlay按钮使用的按钮风格组件，用于自定义新的按钮
// The following three classes are button styles used by the buttons in this Overlay,
// and can be used to customize new buttons

///**ZH** EInkToolbar undo/redo 功能所使用的长按按钮外观组件，长按会被多次触发
///
///**EN** The appearance of the long-press button used in the undo/redo function of EInkToolbar, 
///which will be triggered multiple times when long-pressing
class LongpressButtonUI extends StatefulWidget{
  final void Function() onPressed;
  final IconData icon;
  final String message;

  const LongpressButtonUI({super.key, required this.onPressed, required this.icon, required this.message});

  @override
  State<LongpressButtonUI> createState() => _LongpressButtonUIState();
}

class _LongpressButtonUIState extends State<LongpressButtonUI> {
  Timer? timer;
  bool pressing = false;
  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: (_){
        pressing = false;
      },
      child: BasicButtonUI(
        message: widget.message,
        iconData: widget.icon, 
        isSelected: false,
      ),
    );
  }

  Future<void> _handlePointerDown(_)async{
    pressing = true;
    timer?.cancel();
    timer = null;
    widget.onPressed();
    await Future.delayed(Duration(seconds: 1));
    if(mounted&&pressing){
      timer = Timer(Duration(milliseconds: 500), ()async{
        if(!pressing||!mounted){
          timer?.cancel();
          timer = null;
          return;
        }
        widget.onPressed();
      });
    }
  }
}

///EInkToolbar所使用的按钮外观组件，无selected状态，只有按下和抬起之分
///
///**EN** The button appearance used by EInkToolbar with pressed and released status
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
///EInkToolbar所使用的按钮外观组件，有selected和!selected之分
///
///**EN** The button appearance used by EInkToolbar, with selected and !selected status
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
            border: BoxBorder.all(color: isSelected?Colors.black:Colors.transparent),
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