import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/foundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/painters/active_layer_painter.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';
import 'package:freeform_canvas/interaction_handlers/transform_handler.dart';
import 'package:freeform_canvas/zero_padding_textfield.dart';

class CanvasRenderer extends Renderer{
  @override
  List<Widget> buildcanvas(BuildContext context,EditorState editorState){
    return [
      StaticLayerRendererWidget(editorState: editorState),
      ActiveLayerRendererWidget(editorState: editorState),
    ];
  }
  
  @override
  Widget buildTextfield(BuildContext context, EditorState editorState) {
    return TextfieldWidget(editorState: editorState);
  }

  const CanvasRenderer();
}

class TextfieldWidget extends StatefulWidget{
  final EditorState editorState;

  const TextfieldWidget({super.key, required this.editorState});

  @override
  State<TextfieldWidget> createState() => _TextfieldWidgetState();
}

class _TextfieldWidgetState extends State<TextfieldWidget> {
  @override
  void initState() {
    super.initState();
    widget.editorState.textEditorState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.textEditorState.removeListener(_setState);
  }
  void _setState(){
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textEditorState = widget.editorState.textEditorState;
    if(textEditorState.textController==null){
      return SizedBox.shrink();
    }else{
      Offset? textScreenPosition;
      textScreenPosition = canvasToScreen(
        widget.editorState.scale, 
        widget.editorState.pan, 
        textEditorState.textCanvasPosition!
      );
      return Positioned(
        left: textScreenPosition.dx-4,
        top: textScreenPosition.dy-4,
        child: SizedBox(
          child: DecoratedBox(
            decoration: BoxDecoration(border: BoxBorder.all()),
            child: Padding(
              padding: EdgeInsetsGeometry.all(4),
              child: ZeroPaddingTextfield(
                key: UniqueKey(),
                textEditingController: textEditorState.textController!,
                onDone: () {
                  widget.editorState.quitTextEdit();
                },
              ),
            ),
          ),
        ),
      );
    }
  }
}

class StaticLayerRendererWidget extends StatefulWidget{
  final EditorState editorState;
  const StaticLayerRendererWidget({super.key, required this.editorState});

  @override
  State<StaticLayerRendererWidget> createState() => _StaticLayerRendererWidgetState();
}

class _StaticLayerRendererWidgetState extends State<StaticLayerRendererWidget> {
  @override
  void initState() {
    super.initState();
    widget.editorState.fileState.addListener(_setState);
    widget.editorState.transformState.addListener(_setState);
    widget.editorState.focusState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.fileState.removeListener(_setState);
    widget.editorState.transformState.removeListener(_setState);
    widget.editorState.focusState.removeListener(_setState);
  }
  void _setState(){
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final file = widget.editorState.file!;

    return SizedBox.expand(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: FreeformCanvasPainter(
            dirty: widget.editorState.fileState.count + widget.editorState.transformState.count + widget.editorState.focusState.count,
            elements: file.elements,
            scale: widget.editorState.scale,
            pan: widget.editorState.pan,
            backgroundColor: file.appState.viewBackgroundColor,
            draftId: widget.editorState.draftState.draftId,
          ),
        ),
      ),
    );
  }
}

class ActiveLayerRendererWidget extends StatefulWidget{
  final EditorState editorState;
  const ActiveLayerRendererWidget({super.key, required this.editorState});

  @override
  State<ActiveLayerRendererWidget> createState() => _ActiveLayerRendererWidgetState();
}

class _ActiveLayerRendererWidgetState extends State<ActiveLayerRendererWidget> {
  @override
  void initState() {
    super.initState();
    widget.editorState.draftState.addListener(_setState);
    widget.editorState.focusState.addListener(_setState);
    widget.editorState.transformState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.draftState.removeListener(_setState);
    widget.editorState.focusState.removeListener(_setState);
    widget.editorState.transformState.removeListener(_setState);
  }
  void _setState(){
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {

    return SizedBox.expand(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: ActiveLayerPainter(
            draftElement: widget.editorState.draftState.draftElement, 
            selectionRectElement: widget.editorState.focusedElement, 
            repaintCounter: widget.editorState.focusState.count
              + widget.editorState.draftState.count
              + widget.editorState.transformState.count,
            scale: widget.editorState.scale,
            pan: widget.editorState.pan, 
          ),
        ),
      ),
    );
  }
}