import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeform_canvas/application/foundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';


class MouseKeyboardInteractor extends Interactor{
  @override
  Widget build(BuildContext context, EditorState editorState) {
    return MouseKeyboardInteractorWidget(editorState: editorState);
  }

  const MouseKeyboardInteractor();
  
  @override
  List<Widget> buildOverlay(BuildContext context, EditorState editorState) {
    return [];
  }
}

class MouseKeyboardInteractorWidget extends StatefulWidget{
  final EditorState editorState;
  const MouseKeyboardInteractorWidget({
    super.key, 
    required this.editorState
  });

  @override
  State<MouseKeyboardInteractorWidget> createState() => _MouseKeyboardInteractorWidgetState();
}

class _MouseKeyboardInteractorWidgetState extends State<MouseKeyboardInteractorWidget> {
  InteractionHandler? currentController;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_keyboardHandler);
  }
  @override
  void dispose() {
    super.dispose();
    HardwareKeyboard.instance.removeHandler(_keyboardHandler);
  }

  bool _keyboardHandler(KeyEvent event){
    if((event is KeyDownEvent || event is KeyRepeatEvent)
      && HardwareKeyboard.instance.isControlPressed 
      && event.logicalKey == LogicalKeyboardKey.keyZ
    ){
      widget.editorState.undo();
      return true;
    }else if((event is KeyDownEvent || event is KeyRepeatEvent)
      && HardwareKeyboard.instance.isControlPressed 
      && event.logicalKey == LogicalKeyboardKey.keyY
    ){
      widget.editorState.redo();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        late EditorTool tool;
        switch(event.character){
          case '1':
          case 'v':
            tool = EditorTool.select;
          case '2':
          case 'r':
            tool = EditorTool.rectangle;
          case '3':
          case 'd':
            tool = EditorTool.diamond;
          case '4':
          case 'o':
            tool = EditorTool.ellipse;
          case '5':
          case 'a':
            tool = EditorTool.arrow;
          case '6':
          case 'l':
            tool = EditorTool.line;
          case '7':
          case 'p':
            tool = EditorTool.freedraw;
          case '8':
          case 't':
            tool = EditorTool.text;
          case '9':
            tool = EditorTool.eraser;//TODO:Support image
          case '0':
          case 'e':
            tool = EditorTool.eraser;
          default:
            //Didn't trigger any shortcut
            return KeyEventResult.ignored;
        }
        widget.editorState.switchTool(tool);
        return KeyEventResult.handled;
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerPanZoomStart: _handlePanZoomStart,
        onPointerPanZoomUpdate: _handlePanZoomUpdate,
        onPointerPanZoomEnd: _handlePanZoomEnd,
        onPointerSignal: _handlePointerSignal,
      ),
    );
  }
  ///Deal with scroll wheel scroll and press
  void _handlePointerSignal(PointerSignalEvent event){
    if(event is PointerScrollEvent){
      if(HardwareKeyboard.instance.isControlPressed){
        //Scaling
        final delta = event.scrollDelta.dy/300;
        late double scaleDelta;
        if(delta>0){
          scaleDelta = 1 + delta;
        }else if(delta<0){
          scaleDelta = 1/(1-delta);
        }else{
          return;
        }
        final double newScale = (widget.editorState.scale / scaleDelta).clamp(0.1, 10.0);

        // 以手指焦点为中心缩放的平移补偿（适用于 pan 是画布坐标偏移的情况）
        // The compensation of the translation when scaling around the focal point
        final Offset focalPoint = event.localPosition;
        final double oldScale = widget.editorState.scale;

        final Offset deltaPan = focalPoint * (1 / newScale - 1 / oldScale);

        widget.editorState.pan += deltaPan;
        widget.editorState.scale = newScale;
      }else if(HardwareKeyboard.instance.isShiftPressed){
        //Left&right pan
        widget.editorState.pan -= Offset(event.scrollDelta.dy/widget.editorState.scale, 0);
      }else{
        //Up&down pan
        widget.editorState.pan -= Offset(0, event.scrollDelta.dy/widget.editorState.scale);
      }
    }
  }

  void _handlePanZoomStart(PointerPanZoomStartEvent event){
    currentController = TransformHandler();
    final iEvent = InputStartEvent(localPoint: event.localPosition);
    currentController?.onScaleStart(iEvent, widget.editorState);
  }

  void _handlePanZoomUpdate(PointerPanZoomUpdateEvent event){
    final iEvent = InputUpdateEvent(
      localPoint: event.localPosition, 
      panDelta: event.panDelta, 
      scale: event.scale
    );
    currentController?.onScaleUpdate(iEvent, widget.editorState);
  }

  void _handlePanZoomEnd(PointerPanZoomEndEvent event){
    currentController?.onScaleEnd(InputEndEvent(), widget.editorState);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if(HardwareKeyboard.instance.isLogicalKeyPressed(LogicalKeyboardKey.space)
      || (event.buttons&kMiddleMouseButton)!=0
    ){
      //Middle mouse button or space + left mouse button: Drag the canvas
      currentController = TransformHandler();
    }else{
      switch(widget.editorState.toolState.currentTool){
        case EditorTool.drag:
          currentController = TransformHandler();
        case EditorTool.select:
          currentController = SelectHandler();
        case EditorTool.rectangle:
          currentController = TwoPointCreationHandler(type: FreeformCanvasElementType.rectangle);
        case EditorTool.diamond:
          currentController = TwoPointCreationHandler(type: FreeformCanvasElementType.diamond);
        case EditorTool.ellipse:
          currentController = TwoPointCreationHandler(type: FreeformCanvasElementType.ellipse);
        case EditorTool.line:
          currentController = TwoPointCreationHandler(type: FreeformCanvasElementType.line);
        case EditorTool.arrow:
          currentController = TwoPointCreationHandler(type: FreeformCanvasElementType.arrow);
        case EditorTool.freedraw:
          currentController = FreeDrawHandler();
        case EditorTool.text:
          currentController = TextCreateHandler();
        case EditorTool.eraser:
          currentController = EraserHandler();
      }
    }
    final iEvent = InputStartEvent(localPoint: event.localPosition);
    currentController?.onScaleStart(iEvent, widget.editorState);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final iEvent = InputUpdateEvent(
      localPoint: event.localPosition, 
      panDelta: event.delta, 
      scale: 1
    );
    currentController?.onScaleUpdate(iEvent, widget.editorState);
  }

  void _handlePointerUp(PointerUpEvent event) {
    currentController?.onScaleEnd(InputEndEvent(), widget.editorState);
    currentController = null;
  }
}