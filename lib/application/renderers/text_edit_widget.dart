import 'dart:math';
import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/transform_handler.dart';
import 'package:freeform_canvas/models/text_editing_data.dart';
import 'package:freeform_canvas/ops/element_ops.dart';

class TextEditWidget extends StatefulWidget{
  final EditorState editorState;

  const TextEditWidget({super.key, required this.editorState});

  @override
  State<TextEditWidget> createState() => _TextEditWidgetState();
}

class _TextEditWidgetState extends State<TextEditWidget> {
  // Default width of the textfield.
  final double defaultWidth = 200;
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.editorState.textEditorState.addListener(_setState);
    widget.editorState.transformState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.textEditorState.removeListener(_setState);
    widget.editorState.transformState.removeListener(_setState);
  }
  void _setState(){
    if(mounted) setState(() {});
    if(widget.editorState.textEditorState.textEditData!=null) focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final textEditData = widget.editorState.textEditorState.textEditData;
    if(textEditData==null){
      return SizedBox.shrink();
    }else{
      Offset? textScreenPosition;
      textScreenPosition = canvasToScreen(
        widget.editorState.scale, 
        widget.editorState.pan, 
        Offset(textEditData.behalfElement.x, textEditData.behalfElement.y)
      );
      // return Positioned(
      //   left: textScreenPosition.dx,
      //   top: textScreenPosition.dy,
      //   child: _buildTextfield(textEditData),
      // );
      return Positioned(
        left: textScreenPosition.dx-4,
        top: textScreenPosition.dy-4,
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(border: BoxBorder.all()),
            child: Padding(
              padding: EdgeInsetsGeometry.all(4),
              child: _buildTextfield(textEditData),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTextfield(TextEditData textEditData){
    final behalfElement = textEditData.behalfElement;
    return SizedBox(
      width:  max(defaultWidth,(behalfElement.width+10))*widget.editorState.scale+100,
      child: EditableText(
        onEditingComplete: () {
          widget.editorState.quitTextEdit();
        },
        onChanged: (value) {
          widget.editorState.textEditorState.textEditData!.behalfElement = ElementOps.textElementModify(
            behalfElement,
            text: value,
          );
          setState(() {});
        },
        controller: textEditData.textController,
        focusNode: focusNode,
        style: TextStyle(
          fontSize: behalfElement.fontSize * widget.editorState.scale,
          height: behalfElement.lineHeight,
          color: behalfElement.strokeColor.color,
        ),
        cursorColor: Colors.blue,
        backgroundCursorColor: Colors.grey,
        selectionColor: Colors.grey,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: 1,
        textAlign: TextAlign.left,
        strutStyle: StrutStyle(
          fontSize: behalfElement.fontSize * widget.editorState.scale,
          height: behalfElement.lineHeight,
          leading: 0,
        ),
      ),
    );
  }
}