import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/painters/active_layer_painter.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';
import 'package:freeform_canvas/application/renderers/text_edit_widget.dart';
import 'package:freeform_canvas/widgets/embeddable_link_edit_overlay.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';

class CanvasRenderer extends Renderer{
  @override
  List<Widget> buildcanvas(BuildContext context,EditorState editorState){
    return [
      StaticLayerRendererWidget(editorState: editorState),
      ActiveLayerRendererWidget(editorState: editorState),
    ];
  }

  @override
  List<Widget> buildInteractiveOverlays(BuildContext context, EditorState editorState) {
    return [
      TextEditWidget(editorState: editorState),
      EmbeddableLinkEditOverlayLayer(editorState: editorState),
    ];
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
            backgroundColor: file.appState.viewBackgroundColor.color,
            draftId: widget.editorState.draftState.draftId,
          ),
        ),
      ),
    );
  }
}

/// **ZH** Embeddable 元素的 Link 编辑浮动框层
///
/// **EN** Link edit overlay layer for embeddable elements
class EmbeddableLinkEditOverlayLayer extends StatefulWidget {
  final EditorState editorState;

  const EmbeddableLinkEditOverlayLayer({super.key, required this.editorState});

  @override
  State<EmbeddableLinkEditOverlayLayer> createState() => _EmbeddableLinkEditOverlayLayerState();
}

class _EmbeddableLinkEditOverlayLayerState extends State<EmbeddableLinkEditOverlayLayer> {
  @override
  void initState() {
    super.initState();
    widget.editorState.focusState.addListener(_setState);
    widget.editorState.transformState.addListener(_setState);
    widget.editorState.fileState.addListener(_setState);
    widget.editorState.draftState.addListener(_setState);
  }

  @override
  void dispose() {
    widget.editorState.focusState.removeListener(_setState);
    widget.editorState.transformState.removeListener(_setState);
    widget.editorState.fileState.removeListener(_setState);
    widget.editorState.draftState.removeListener(_setState);
    super.dispose();
  }

  void _setState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 只有当焦点元素是 embeddable 时才显示
    final focusElementId = widget.editorState.focusState.focusElementId;
    if (focusElementId == null) {
      return const SizedBox.shrink();
    }

    final element = FreeformCanvasFileOps.findElement(widget.editorState.file!, focusElementId);
    if (element == null || element is! FreeformCanvasEmbeddable) {
      return const SizedBox.shrink();
    }

    // 计算元素在屏幕上的位置
    final scale = widget.editorState.scale;
    final pan = widget.editorState.pan;
    final screenX = (element.x + pan.dx) * scale;
    final screenY = (element.y + pan.dy) * scale;
    final screenWidth = element.width * scale;

    return EmbeddableLinkEditOverlay(
      element: element,
      editorState: widget.editorState,
      screenPosition: Offset(screenX, screenY),
      screenWidth: screenWidth,
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
            editorState: widget.editorState
          ),
        ),
      ),
    );
  }
}