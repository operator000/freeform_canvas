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
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';

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
  //以下为未实现字段：
  fontFamily,
  fontSize,
  textAlign,
  arrowHeads,
  arrowType,
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
    EleCap.fontFamily:FontFamilyCap(),
    EleCap.fontSize:FontSizeCap(),
    EleCap.textAlign:TextAlignCap(),
    EleCap.arrowHeads:ArrowHeadsCap(),
    EleCap.arrowType:ArrowTypeCap(),
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
      Builder(
        builder: (context) => ColorModifier(
          notifier: notifier,
          getter: getter,
          setter: setter,
          title: AppLocalizations.of(context)!.strokeColor,
          brightness: 4
        )
      );
}
class BackgroundColorCap extends Capability<FreeformCanvasColor>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasColor Function() p2, void Function(FreeformCanvasColor p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => ColorModifier(
          notifier: notifier,
          getter: getter,
          setter: setter,
          title: AppLocalizations.of(context)!.backgroundColor,
          brightness: 1
        )
      );
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
      Builder(
        builder: (context) => SingleValue<FreeformCanvasRoundness?>(
          title: AppLocalizations.of(context)!.cornerStyle,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.sharp), value: null),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.round), value: FreeformCanvasRoundness(type: 3)),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}
///**ZH** "可变边角( roundness,type=2 )"修改器
///
///**EN** "Variable edge ( roundness,type=2 )" modifier
class Roundness2Cap extends Capability<FreeformCanvasRoundness?>{
  @override
  Widget Function(ChangeNotifier p1, FreeformCanvasRoundness? Function() p2, void Function(FreeformCanvasRoundness? p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<FreeformCanvasRoundness?>(
          title: AppLocalizations.of(context)!.cornerStyle,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.sharp), value: null),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.round), value: FreeformCanvasRoundness(type: 2)),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}
///**ZH** "边框样式( strokeStyle )"修改器
///
///**EN** "StrokeStyle" modifier
class StrokeStyleCap extends Capability<String>{
  @override
  Widget Function(ChangeNotifier p1, String Function() p2, void Function(String p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<String>(
          title: AppLocalizations.of(context)!.strokeStyle,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.solid), value: 'solid'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.dashed), value: 'dashed'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.dotted), value: 'dotted'),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}
///**ZH** "线条风格( roughness )"修改器
///
///**EN** "Sloppiness ( roughness )" modifier
class RoughnessCap extends Capability<int>{
  @override
  Widget Function(ChangeNotifier p1, int Function() p2, void Function(int p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<int>(
          title: AppLocalizations.of(context)!.sloppiness,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.architect), value: 0),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.artist), value: 1),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.cartoonist), value: 2),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}
///**ZH** "描边宽度（ strokeWidth ）"修改器
///
///**EN** "StrokeWidth" modifier
class StrokeWidthCap extends Capability<double>{
  @override
  Widget Function(ChangeNotifier p1, double Function() p2, void Function(double p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<double>(
          title: AppLocalizations.of(context)!.strokeWidth,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.thin), value: 1),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.bold), value: 2),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.extraBold), value: 4),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}
///**ZH** "填充( fillStyle )"修改器
///
///**EN** "FillStyle" modifier
class FillStyleCap extends Capability<String>{
  @override
  Widget Function(ChangeNotifier p1, String Function() p2, void Function(String p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<String>(
          title: AppLocalizations.of(context)!.fillStyle,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.hachure), value: 'hachure'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.crossHatch), value: 'cross-hatch'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.solidFill), value: 'solid'),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
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
        MultiButtonItem(icon: Text(AppLocalizations.of(context)!.sendToBack), onPressed: ()=>_modifyLayer(ZOrderAction.sendToBack)),
        MultiButtonItem(icon: Text(AppLocalizations.of(context)!.sendBackward), onPressed: ()=>_modifyLayer(ZOrderAction.sendBackward)),
        MultiButtonItem(icon: Text(AppLocalizations.of(context)!.bringForward), onPressed: ()=>_modifyLayer(ZOrderAction.bringForward)),
        MultiButtonItem(icon: Text(AppLocalizations.of(context)!.bringToFront), onPressed: ()=>_modifyLayer(ZOrderAction.bringToFront)),
      ],
      title: AppLocalizations.of(context)!.layer,
    );
  }

  void _modifyLayer(ZOrderAction action){
    editorState.commitIntent(MoveZOrderIntent(id: elementId, zOrderAction: action));
  }
}

///**ZH** "箭头类型"选择器
///
///**EN** "Arrowhead type" selector
class ArrowheadSelector extends StatefulWidget{
  final String title;
  final ChangeNotifier notifier;
  final ArrowHeadType? Function() getter;
  final void Function(ArrowHeadType?) setter;

  const ArrowheadSelector({
    super.key,
    required this.title,
    required this.notifier,
    required this.getter,
    required this.setter,
  });

  @override
  State<ArrowheadSelector> createState() => _ArrowheadSelectorState();
}

class _ArrowheadSelectorState extends State<ArrowheadSelector> {
  final layerLink = LayerLink();
  final _controller = OverlayPortalController();

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

  void _setState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final current = widget.getter();
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Text(widget.title),
        OverlayPortal(
          controller: _controller,
          overlayChildBuilder: (context) {
            return CompositedTransformFollower(
              link: layerLink,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: Offset(0, 5),
              child: Align(
                alignment: Alignment.topLeft,
                child: _ArrowheadPickerMenu(
                  current: current,
                  onSelect: (type) {
                    widget.setter(type);
                    _controller.hide();
                  },
                ),
              ),
            );
          },
          child: CompositedTransformTarget(
            link: layerLink,
            child: GestureDetector(
              onTap: () => _controller.toggle(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_getArrowheadName(current)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getArrowheadName(ArrowHeadType? type) {
    if (type == null) return AppLocalizations.of(context)!.none;
    switch (type) {
      case ArrowHeadType.arrow:
        return AppLocalizations.of(context)!.arrow;
      case ArrowHeadType.triangle:
        return AppLocalizations.of(context)!.filledTriangle;
      case ArrowHeadType.triangleOutline:
        return AppLocalizations.of(context)!.hollowTriangle;
    }
  }
}

///**ZH** 箭头类型选择菜单
///
///**EN** Arrowhead type picker menu
class _ArrowheadPickerMenu extends StatelessWidget {
  final ArrowHeadType? current;
  final void Function(ArrowHeadType?) onSelect;

  const _ArrowheadPickerMenu({
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1, color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 1,
          ),
        ],
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(null, AppLocalizations.of(context)!.none),
            _buildOption(ArrowHeadType.arrow, AppLocalizations.of(context)!.arrow),
            _buildOption(ArrowHeadType.triangle, AppLocalizations.of(context)!.filledTriangle),
            _buildOption(ArrowHeadType.triangleOutline, AppLocalizations.of(context)!.hollowTriangle),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(ArrowHeadType? type, String name) {
    final isSelected = current == type;
    return InkWell(
      onTap: () => onSelect(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check, size: 16, color: Colors.blue),
              ),
            Text(name),
          ],
        ),
      ),
    );
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
        MultiButtonItem(icon: Text(AppLocalizations.of(context)!.delete), onPressed: (){
          editorState.commitIntent(ElementDeleteIntent(id: elementId));
        }),
      ],
      title: AppLocalizations.of(context)!.operations,
    );
  }
}

///**ZH** "字体"修改器
///
///**EN** "Font Family" modifier
class FontFamilyCap extends Capability<FontFamily>{
  @override
  Widget Function(ChangeNotifier p1, FontFamily Function() p2, void Function(FontFamily p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<FontFamily>(
          title: AppLocalizations.of(context)!.fontFamily,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.defaultFont), value: FontFamilyExt.defaultFont),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.handwriting), value: FontFamily.excalifont),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.monospace), value: FontFamily.nunito),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.serif), value: FontFamily.lilitaOne),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}

///**ZH** "字号"修改器
///
///**EN** "Font Size" modifier
class FontSizeCap extends Capability<FontSize>{
  @override
  Widget Function(ChangeNotifier p1, FontSize Function() p2, void Function(FontSize p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<FontSize>(
          title: AppLocalizations.of(context)!.fontSize,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.small), value: FontSize.small()),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.medium), value: FontSize.medium()),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.large), value: FontSize.large()),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.extraLarge), value: FontSize.extraLarge()),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}

///**ZH** "对齐"修改器
///
///**EN** "Text Align" modifier
class TextAlignCap extends Capability<String>{
  @override
  Widget Function(ChangeNotifier p1, String Function() p2, void Function(String p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<String>(
          title: AppLocalizations.of(context)!.textAlign,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.left), value: 'left'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.center), value: 'center'),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.right), value: 'right'),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}

///**ZH** "箭头头部"修改器（用于起点和终点箭头）
///
///**EN** "Arrow Heads" modifier (for start and end arrowheads)
class ArrowHeadsCap extends Capability<ArrowHeadType?>{
  @override
  Widget Function(ChangeNotifier p1, ArrowHeadType? Function() p2, void Function(ArrowHeadType? p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => ArrowheadSelector(
          title: AppLocalizations.of(context)!.arrowhead,
          notifier: notifier,
          getter: getter,
          setter: setter,
        )
      );
}

///**ZH** "箭头类型"修改器（同时处理 roundness 和 elbowed）
///
///**EN** "Arrow Type" modifier (handles both roundness and elbowed)
class ArrowTypeCap extends Capability<ArrowTypeValue>{
  @override
  Widget Function(ChangeNotifier p1, ArrowTypeValue Function() p2, void Function(ArrowTypeValue p1) p3) get builder =>
    (notifier,getter,setter)=>
      Builder(
        builder: (context) => SingleValue<ArrowTypeValue>(
          title: AppLocalizations.of(context)!.arrowType,
          items: [
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.sharp), value: ArrowTypeValue.sharp),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.curved), value: ArrowTypeValue.curved),
            MultiSelectItem(icon: Text(AppLocalizations.of(context)!.elbowed), value: ArrowTypeValue.elbowed),
          ],
          getter: getter, notifier: notifier, setter: setter
        )
      );
}

///**ZH** 箭头类型的值（用于同时表示 roundness 和 elbowed）
///
///**EN** Arrow type value (represents both roundness and elbowed)
enum ArrowTypeValue{
  sharp,   // roundness=null, elbowed=false
  curved,  // roundness=FreeformCanvasRoundness(type:2), elbowed=false
  elbowed, // roundness=null, elbowed=true
}
