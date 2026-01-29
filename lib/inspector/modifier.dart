///**ZH** 遵循.excalidraw文件的若干单字段修改组件
///
///**EN** Some single-field modification components that follow the .excalidraw file.
library;

import 'package:flutter/material.dart';
import 'package:freeform_canvas/inspector/selector.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

///ElementCapability,representing a single field
enum EleCap{
  strokeColor,
  backgroundColor,
  roundness1,
  roundness2,
  strokeStyle,
  roughness,
  strokeWidth,
  fillStyle,
  opacity,
}

abstract class Capability<T>{
  Widget Function(ChangeNotifier,T Function(),void Function(T)) get builder;
}

///**ZH** 将元素字段映射到字段修改器
///
///**EN** Map element fields to field modifiers
class CapabilityMap{
  CapabilityMap._();
  
  static Map<EleCap,Capability<dynamic>> get map => {
    EleCap.strokeColor:StrokeColorCap(),
    EleCap.backgroundColor:BackgroundColorCap(),
    EleCap.roundness1:Roundness1Cap(),
    EleCap.roundness2:Roundness2Cap(),
    EleCap.strokeStyle:StrokeStyleCap(),
    EleCap.roughness:RoughnessCap(),
    EleCap.strokeWidth:StrokeWidthCap(),
    EleCap.fillStyle:FillStyleCap(),
    EleCap.opacity:OpacityCap(),
  };
}


//Color modifier
class ColorModifier extends StatefulWidget{
  final ChangeNotifier notifier;
  final FreeformCanvasColor Function() getter;
  final void Function(FreeformCanvasColor) setter;
  final String title;
  final int brightness;

  const ColorModifier({
    super.key, 
    required this.notifier, 
    required this.getter, 
    required this.setter, 
    required this.title, 
    required this.brightness,
  });

  @override
  State<ColorModifier> createState() => _ColorModifierState();
}

class _ColorModifierState extends State<ColorModifier> {
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
  void _setState()=> setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = widget.getter();
    return ColorSelect(
      title: widget.title, 
      initialColor: c,
      onSelect: widget.setter, 
      brightness: widget.brightness
    );
  }
}

class StrokeColorCap extends Capability<FreeformCanvasColor>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasColor Function() p2, void Function(FreeformCanvasColor p1) p3) get builder => 
    (notifier,getter,setter)=>
      ColorModifier(notifier: notifier, getter: getter, setter: setter, title: '描边', brightness: 4);
}
class BackgroundColorCap extends Capability<FreeformCanvasColor>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasColor Function() p2, void Function(FreeformCanvasColor p1) p3) get builder => 
    (notifier,getter,setter)=>
      ColorModifier(notifier: notifier, getter: getter, setter: setter, title: '背景', brightness: 1);
}

// - Enumerable field modifiers:

///**ZH** 通用的单字段修改器
///
///**EN** Generic single-field modifier
class SingleValue<T> extends StatefulWidget{
  final String title;
  final List<MultiSelectItem<T>> items;
  final ChangeNotifier notifier;
  final T Function() getter;
  final void Function(T) setter;

  const SingleValue({
    super.key, 
    required this.title, 
    required this.items,
    required this.getter, 
    required this.notifier, 
    required this.setter, 
  });

  @override
  State<SingleValue<T>> createState() => _SingleValueState<T>();
}

class _SingleValueState<T> extends State<SingleValue<T>> {
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
  void _setState()=> setState(() {});

  @override
  Widget build(BuildContext context) {
    return MultiSelect<T>(
      items: widget.items, 
      title: widget.title, 
      onSelect: (value){
        widget.setter(value);
      }, 
      initialValue: widget.getter()
    );
  }
}
///**ZH** "固定边角( roundness,type=3 )"修改器
///
///**EN** "Fixed edge ( roundness,type=3 )" modifier
class Roundness1Cap extends Capability<FreeformCanvasRoundness?>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasRoundness? Function() p2, void Function(FreeformCanvasRoundness? p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<FreeformCanvasRoundness?>(
        title: '边角', 
        items: [
          MultiSelectItem(icon: Text('尖锐'), value: null),
          MultiSelectItem(icon: Text('圆润'), value: FreeformCanvasRoundness(type: 3)),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}
///**ZH** "可变边角( roundness,type=2 )"修改器
///
///**EN** "Variable edge ( roundness,type=2 )" modifier
class Roundness2Cap extends Capability<FreeformCanvasRoundness?>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasRoundness? Function() p2, void Function(FreeformCanvasRoundness? p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<FreeformCanvasRoundness?>(
        title: '边角', 
        items: [
          MultiSelectItem(icon: Text('尖锐'), value: null),
          MultiSelectItem(icon: Text('圆润'), value: FreeformCanvasRoundness(type: 2)),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}
///**ZH** "边框样式( strokeStyle )"修改器
///
///**EN** "StrokeStyle" modifier
class StrokeStyleCap extends Capability<String>{
  @override
  Widget Function(ChangeNotifier p1, String Function() p2, void Function(String p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<String>(
        title: '边框样式', 
        items: [
          MultiSelectItem(icon: Text('实线'), value: 'solid'),
          MultiSelectItem(icon: Text('虚线'), value: 'dashed'),
          MultiSelectItem(icon: Text('点虚线'), value: 'dotted'),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}
///**ZH** "线条风格( roughness )"修改器
///
///**EN** "Sloppiness ( roughness )" modifier
class RoughnessCap extends Capability<int>{
  @override
  Widget Function(ChangeNotifier p1, int Function() p2, void Function(int p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<int>(
        title: '线条风格', 
        items: [
          MultiSelectItem(icon: Text('朴素'), value: 0),
          MultiSelectItem(icon: Text('艺术'), value: 1),
          MultiSelectItem(icon: Text('漫画家'), value: 2),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}
///**ZH** "描边宽度（ strokeWidth ）"修改器
///
///**EN** "StrokeWidth" modifier
class StrokeWidthCap extends Capability<double>{
  @override
  Widget Function(ChangeNotifier p1, double Function() p2, void Function(double p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<double>(
        title: '描边宽度', 
        items: [
          MultiSelectItem(icon: Text('细'), value: 1),
          MultiSelectItem(icon: Text('粗'), value: 2),
          MultiSelectItem(icon: Text('特粗'), value: 4),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}
///**ZH** "填充( fillStyle )"修改器
///
///**EN** "FillStyle" modifier
class FillStyleCap extends Capability<String>{
  @override
  Widget Function(ChangeNotifier p1, String Function() p2, void Function(String p1) p3) get builder => 
    (notifier,getter,setter)=>
      SingleValue<String>(
        title: '填充', 
        items: [
          MultiSelectItem(icon: Text('线条'), value: 'hachure'),
          MultiSelectItem(icon: Text('交叉线条'), value: 'cross-hatch'),
          MultiSelectItem(icon: Text('实心'), value: 'solid'),
        ], 
        getter: getter, notifier: notifier, setter: setter
      );
}

// - Continuous-value field modifiers:

///**ZH** "透明度"修改器
///
///**EN** "Opacity" modifier
class Opacity extends StatefulWidget{
  final ChangeNotifier notifier;
  final double Function() getter;
  final void Function(double) setter;

  const Opacity({super.key, required this.notifier, required this.getter, required this.setter,});

  @override
  State<Opacity> createState() => _OpacityState();
}

class _OpacityState extends State<Opacity> {
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
  void _setState()=> setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 30,
      child: Slider(
        max: 100,
        value: widget.getter(), 
        onChanged: widget.setter,
        padding: EdgeInsets.all(5),
      ),
    );
  }
}

class OpacityCap extends Capability<double>{
  @override
  Widget Function(ChangeNotifier p1, double Function() p2, void Function(double p1) p3) get builder
   => (notifier,getter,setter)
    => Opacity(notifier: notifier, getter: getter, setter: setter);
}

// - Operation modifiers:

///**ZH** "图层"修改器
///
///**EN** "Layers" modifier
class Layer extends StatelessWidget{
  final EditorState editorState;
  final String elementId;

  const Layer({super.key, required this.editorState, required this.elementId,});
  @override
  Widget build(BuildContext context) {
    return MultiButton(
      items: [
        MultiButtonItem(icon: Text('底'), onPressed: ()=>_modifyLayer(ZOrderAction.sendToBack)),
        MultiButtonItem(icon: Text('下'), onPressed: ()=>_modifyLayer(ZOrderAction.sendBackward)),
        MultiButtonItem(icon: Text('上'), onPressed: ()=>_modifyLayer(ZOrderAction.bringForward)),
        MultiButtonItem(icon: Text('顶'), onPressed: ()=>_modifyLayer(ZOrderAction.bringToFront)),
      ], 
      title: '图层',
    );
  }

  void _modifyLayer(ZOrderAction action){
    editorState.commitIntent(MoveZOrderIntent(id: elementId, zOrderAction: action));
  }
}

///**ZH** "操作"修改器
///
///**EN** "Actions" modifier
class Operations extends StatelessWidget{
  final EditorState editorState;
  final String elementId;

  const Operations({super.key, required this.editorState, required this.elementId,});
  @override
  Widget build(BuildContext context) {
    return MultiButton(
      items: [
        MultiButtonItem(icon: Text('删除'), onPressed: (){
          editorState.commitIntent(ElementDeleteIntent(id: elementId));
        }),
      ], 
      title: '操作',
    );
  }
}
