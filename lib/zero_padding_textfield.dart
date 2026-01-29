import 'package:flutter/material.dart';

class ZeroPaddingTextfield extends StatefulWidget{
  final void Function() onDone;
  final TextEditingController textEditingController;
  final double? width;
  const ZeroPaddingTextfield({
    super.key,
    required this.textEditingController,
    required this.onDone,
    this.width = 200
  });

  @override
  State<ZeroPaddingTextfield> createState() => _ZeroPaddingTextfieldState();
}

class _ZeroPaddingTextfieldState extends State<ZeroPaddingTextfield> {
  final focusNode = FocusNode()..requestFocus();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: EditableText(
        onEditingComplete: widget.onDone,
        controller: widget.textEditingController,
        focusNode: focusNode,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          height: 1.0,
        ),
        cursorColor: Colors.blue,
        backgroundCursorColor: Colors.grey,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: 1,
        textAlign: TextAlign.left,
        strutStyle: StrutStyle(
          fontSize: 16,
          height: 1.0,
          leading: 0,
        ),
      ),
    );
  }
}