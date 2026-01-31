import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/overlays/e_ink_toolbar.dart';
///**ZH** 交互器。适配有硬件支持触控笔的屏幕，以触控笔为高优先级，适合书写
///
///**EN** Interactor. Adapted to screens with hardware support for touchpads, with touchpads as the highest priority.
///Suitable for writing situations.
class StylusAwareInteractor extends Interactor{
  final notifier = TouchDeviceSwitchNotifier();
  @override
  Widget build(BuildContext context, EditorState editorState) {
    return StylusAwareInteractorWidget(editorState: editorState,notifier: notifier);
  }
  @override
  List<Widget> buildOverlay(BuildContext context, EditorState editorState){
    return [
      TouchDeviceSwitch(notifier: notifier),
    ];
  }
}
///**ZH** 切换是否允许手交互
///
///**EN** Switch whether to allow hand interaction
class TouchDeviceSwitch extends StatefulWidget{
  final TouchDeviceSwitchNotifier notifier;

  const TouchDeviceSwitch({super.key, required this.notifier});
  @override
  State<TouchDeviceSwitch> createState() => _TouchDeviceSwitchState();
}

class _TouchDeviceSwitchState extends State<TouchDeviceSwitch> {
  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.notifier.removeListener(_setState);
  }
  void _setState(){
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_){
        widget.notifier.pointerDeviceExclusive = !widget.notifier.pointerDeviceExclusive;
        widget.notifier.notify();
      },
      child: BasicButtonUI(
        iconData: Icons.waving_hand_outlined, 
        message: 'interact mode', 
        isSelected: !widget.notifier.pointerDeviceExclusive
      )
    );
  }
}

class TouchDeviceSwitchNotifier extends ChangeNotifier{
  ///False means that hand dragging is allowed
  bool pointerDeviceExclusive = true;
  void notify(){
    notifyListeners();
  }
}

//Main widget

class StylusAwareInteractorWidget extends StatefulWidget{
  final EditorState editorState;
  final TouchDeviceSwitchNotifier notifier;
  const StylusAwareInteractorWidget({
    super.key, 
    required this.editorState,
    required this.notifier
  });

  @override
  State<StylusAwareInteractorWidget> createState() => _StylusAwareInteractorWidgetState();
}

class _StylusAwareInteractorWidgetState extends State<StylusAwareInteractorWidget> {
  InteractionHandler? currentController;
  ///**ZH** 标记GestureDetector正在处理当前事件
  ///
  ///**EN** Mark that the GestureDetector is currently processing the current event
  bool onGestureHandle = false;
  final mainDeviceKind = PointerDeviceKind.stylus;

  ///**ZH** 判断是否是Listener处理的事件。Listener处理除缩放外的所有操作，包括freedraw
  ///
  ///**EN** Determine whether the Listener should handle the event.
  ///Listener handles all operations except scaling, including freedraw
  bool _isValidListenerEvent(PointerDeviceKind kind){
    return widget.editorState.toolState.currentTool!=EditorTool.freedraw
      || !widget.notifier.pointerDeviceExclusive
      || kind == mainDeviceKind;
  }
  ///**ZH** 判断是否是GestureDetector处理的事件。GestureDetector处理所有缩放操作和freedraw下的平移操作
  ///
  ///**EN** Determine whether the GestureDetector should handle the event.
  ///GestureDetector handles all scaling operations and the translation operation of freedraw
  bool _isValidGesture(PointerDeviceKind? kind,int pointerCount){
    return (widget.editorState.toolState.currentTool!=EditorTool.freedraw && pointerCount>1)
      || (!widget.notifier.pointerDeviceExclusive
      && kind != mainDeviceKind);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
      ),
    );
  }

  // Listener Callbacks

  void _handlePointerDown(PointerDownEvent event) {
    if(!widget.notifier.pointerDeviceExclusive&&event.kind==mainDeviceKind){
      //When using the stylus, automatically revoke the hand's permission
      widget.notifier.pointerDeviceExclusive = true;
      widget.notifier.notify();
    }
    if(_isValidListenerEvent(event.kind)){
      if(widget.editorState.toolState.currentTool==EditorTool.freedraw
        && !widget.notifier.pointerDeviceExclusive
      ){
        ///Temporary drag in freedraw mode
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
            currentController = TextEditHandler();
          case EditorTool.eraser:
            currentController = EraserHandler();
        }
      }
      if(currentController!=null){
        onGestureHandle = true;
        currentController?.onScaleStart(InputStartEvent(localPoint: event.localPosition), widget.editorState);
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if(_isValidListenerEvent(event.kind)){
      final iEvent = InputUpdateEvent(
        localPoint: event.localPosition, 
        panDelta: event.delta, 
        scale: 1
      );
      currentController?.onScaleUpdate(iEvent, widget.editorState);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if(_isValidListenerEvent(event.kind)){
      currentController?.onScaleEnd(InputEndEvent(), widget.editorState);
      currentController = null;
      onGestureHandle = false;
    }
  }

  // GestureDetector Callbacks

  void _handleScaleStart(ScaleStartDetails details) {
    if(_isValidGesture(details.kind,details.pointerCount)){
      currentController = TransformHandler();
      final iEvent = InputStartEvent(localPoint: details.localFocalPoint);
      currentController?.onScaleStart(iEvent, widget.editorState);
      onGestureHandle = true;
    }else{
      onGestureHandle = false;
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if(onGestureHandle){
      final iEvent = InputUpdateEvent(
        localPoint: details.localFocalPoint, 
        panDelta: details.focalPointDelta, 
        scale: details.scale
      );
      currentController?.onScaleUpdate(iEvent, widget.editorState);
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if(onGestureHandle){
      currentController?.onScaleEnd(InputEndEvent(), widget.editorState);
      currentController = null;
      onGestureHandle = false;
    }
  }
}