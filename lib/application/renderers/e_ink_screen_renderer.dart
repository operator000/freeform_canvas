import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/application/renderers/text_edit_widget.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/fundamental.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/ops/element_ops.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';
import 'package:freeform_canvas/painters/active_layer_painter.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';
import 'dart:ui' as ui;
///**ZH** 针对墨水屏适配的渲染模式，static层使用做bitmap缓存、降分辨率，
///active层降帧率处理，分析EditIntent尽量做增量绘制，一切为了提升流畅度
///
///**EN** The renderer specified for the e-ink screen, static layer uses bitmap caching and down-sampling,
/// active layer reduces frame rate and analyzes EditIntent to do as much incremental drawing as possible
class EInkScreenRenderer extends Renderer{
  @override
  List<Widget> buildcanvas(BuildContext context,EditorState editorState){
    return [
      CachedStaticLayerRendererWidget(editorState: editorState),
      ActiveLayerRendererWidget(editorState: editorState),
    ];
  }
  
  @override
  Widget buildTextfield(BuildContext context, EditorState editorState) {
    return TextEditWidget(editorState: editorState);
  }
}

class CachedStaticLayerRendererWidget extends StatelessWidget{
  final EditorState editorState;

  const CachedStaticLayerRendererWidget({super.key, required this.editorState});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraints){
      assert(constraints.hasBoundedHeight&&constraints.hasBoundedWidth);
      return _CachedStaticLayerRendererWidget(
        editorState: editorState,
        size: Size(constraints.maxWidth, constraints.maxHeight),
      );
    });
  }
  
}

class _CachedStaticLayerRendererWidget extends StatefulWidget{
  final EditorState editorState;
  final Size size;
  const _CachedStaticLayerRendererWidget({required this.editorState,required this.size});

  @override
  State<_CachedStaticLayerRendererWidget> createState() => _CachedStaticLayerRendererWidgetState();
}

class _CachedStaticLayerRendererWidgetState extends State<_CachedStaticLayerRendererWidget> {
  ui.Image? _mainBitmap;
  String? lastDraftId;
  FreeformCanvasFreedraw? lastFreedrawElement;
  @override
  void initState() {
    super.initState();
    //Register callback
    widget.editorState.transformState.addListener(transformUpdater);
    widget.editorState.draftState.addListener(draftUpdater);
    widget.editorState.actionState.addListener(actionUpdater);
    widget.editorState.textEditorState.addListener(textEditUpdater);
    //First update
    if(widget.editorState.file!=null){
      WidgetsBinding.instance.addPostFrameCallback((_){
        rebuildBitmap();
        setState(() {});
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.transformState.removeListener(transformUpdater);
    widget.editorState.draftState.removeListener(draftUpdater);
    widget.editorState.actionState.removeListener(actionUpdater);
    widget.editorState.textEditorState.removeListener(textEditUpdater);
  }

  //Callbacks:
  
  void transformUpdater(){
    rebuildBitmap();
    setState(() {});
  }
  void actionUpdater(EditAction? action){
    if(action is ElementCreateAction){
      //For element creation, add it directly to the bitmap
      addElementToBitmap(action.element);
      setState(() {});
    }else{
      rebuildBitmap();
      setState(() {});
    }
  }
  void draftUpdater(){
    //Conduct incremental drawing/full drawing/no drawing according to the draft
    //Notice: draftId is the id of the element that does not need to be drawn in the static layer
    final newDraftId = widget.editorState.draftState.draftId;
    if(newDraftId==lastDraftId){
      //No change
      return;
    }
    if(newDraftId==null){
      //Need to add a draft element
      final element = FreeformCanvasFileOps.findElement(widget.editorState.file!, lastDraftId!);
      if(element!=null){
        addElementToBitmap(element);
        setState(() {});
      }
    }else{
      //Rebuild full bitmap
      rebuildBitmap();
      setState(() {});
    }
    lastDraftId = newDraftId;
  }

  void textEditUpdater(){
    rebuildBitmap();
    setState(() {});
  }

  //Bitmap operations:

  void rebuildBitmap(){
    // There has no need to render full-size bitmap on E-ink screen.
    //final dpr = MediaQuery.of(context).devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    //canvas.scale(dpr, dpr);

    final scale = widget.editorState.scale;
    final pan = widget.editorState.pan;
    canvas.scale(scale, scale);
    canvas.translate(pan.dx, pan.dy);
    canvas.drawColor(widget.editorState.file!.appState.viewBackgroundColor.color, BlendMode.src);
    drawGrid(canvas: canvas, size: widget.size, appState:widget.editorState.file!.appState, scale: scale,pan: pan);
    for (final element in widget.editorState.file!.elements) {
      if(element.id!=widget.editorState.draftState.draftId 
        && element.id!=widget.editorState.textEditorState.textEditData?.behalfElement.id){
        drawElement(canvas, element);
      }
    }

    final picture = recorder.endRecording();
    _mainBitmap = picture.toImageSync(
      (widget.size.width).round(),
      (widget.size.height).round(),
    );
  }

  void addElementToBitmap(FreeformCanvasElement element){
    //final dpr = MediaQuery.of(context).devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawImage(_mainBitmap!, Offset.zero, Paint());
    //canvas.scale(dpr, dpr);

    final scale = widget.editorState.scale;
    final pan = widget.editorState.pan;
    canvas.scale(scale, scale);
    canvas.translate(pan.dx, pan.dy);
    
    drawElement(canvas, element);

    final picture = recorder.endRecording();
    _mainBitmap = picture.toImageSync(
      (widget.size.width).round(),
      (widget.size.height).round(),
    );
    print('bitmap add');
  }
  ///弃用，效率太低
  ///Deprecated, low efficiency in current version
  void updateFreedrawToBitmap(FreeformCanvasFreedraw lastfd,FreeformCanvasFreedraw newfd){
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    canvas.drawImage(_mainBitmap!, Offset.zero, Paint());
    canvas.scale(dpr, dpr);

    final scale = widget.editorState.scale;
    final pan = widget.editorState.pan;
    canvas.scale(scale, scale);
    canvas.translate(pan.dx, pan.dy);
    
    assert(lastfd.points.isNotEmpty);
    int startIdx = lastfd.points.length-1;
    final pointDiff = newfd.points.sublist(startIdx,newfd.points.length);
    final diff = ElementOps.createFreedraw(pointDiff.map((e)=>Offset(e.x, e.y)));
    drawElement(canvas, diff);

    final picture = recorder.endRecording();
    _mainBitmap = picture.toImageSync(
      (widget.size.width * dpr).round(),
      (widget.size.height * dpr).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: OrientationBuilder(builder: (_,_){
        rebuildBitmap();
        return RepaintBoundary(
          child: RawImage(
            image: _mainBitmap,
            scale: 1,
          ),
        );
      }),
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
  final frameInterval = Duration(milliseconds: 80); // 12.5 fps
  DateTime _lastPaint = DateTime.fromMillisecondsSinceEpoch(0);
  @override
  void initState() {
    super.initState();
    widget.editorState.draftState.addListener(updateCanvas);
    widget.editorState.focusState.addListener(updateCanvas);
    widget.editorState.transformState.addListener(updateCanvas);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.draftState.removeListener(updateCanvas);
    widget.editorState.focusState.removeListener(updateCanvas);
    widget.editorState.transformState.removeListener(updateCanvas);
  }
  void updateCanvas(){
    final time = DateTime.now();
    if(time.difference(_lastPaint)>frameInterval){
      _lastPaint = time;
      setState(() {});
    }
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
            alpha: 255,
          ),
        ),
      ),
    );
  }
}

