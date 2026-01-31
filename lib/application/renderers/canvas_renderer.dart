import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/painters/active_layer_painter.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';
import 'package:freeform_canvas/application/renderers/text_edit_widget.dart';

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
    return TextEditWidget(editorState: editorState);
  }

  const CanvasRenderer();
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
    widget.editorState.textEditorState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.fileState.removeListener(_setState);
    widget.editorState.transformState.removeListener(_setState);
    widget.editorState.focusState.removeListener(_setState);
    widget.editorState.textEditorState.removeListener(_setState);
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
            dirty: widget.editorState.fileState.count 
              + widget.editorState.transformState.count 
              + widget.editorState.focusState.count
              + widget.editorState.textEditorState.count,
            elements: file.elements,
            appState: file.appState,
            editorState: widget.editorState,
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