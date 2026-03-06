import 'package:flutter/material.dart' hide Opacity;
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/models/element_style.dart';
import 'package:freeform_canvas/inspector/modifier.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';

class _InspectorWrapper extends StatelessWidget{
  final Widget child;

  const _InspectorWrapper({required this.child});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 1,
          ),
        ]
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: child,
      ),
    );
  }
  
}
///**ZH** 元素属性查看和修改面板。这个组件的结构比较复杂，分四层，在inspector文件夹中依次为
///fundamental、selector、modifier、inspector
///
///**EN** The element property viewing and modification panel. This widget has a complex structure with four layers. 
///In the inspector folder, they are: fundamental, selector, modifier, inspector
class Inspector extends StatefulWidget{
  final EditorState editorState;

  const Inspector({super.key,required this.editorState});

  @override
  State<Inspector> createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  @override
  void initState() {
    super.initState();
    widget.editorState.focusState.addListener(_setState);
    widget.editorState.toolState.addListener(_setState);
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.focusState.removeListener(_setState);
    widget.editorState.toolState.removeListener(_setState);
  }
  void _setState(){
    if(mounted) setState(() {});
  }
  
  @override
  Widget build(BuildContext context){
    final textTheme = Theme.of(context).textTheme;
    return DefaultTextStyle(
      style: textTheme.bodyMedium?.copyWith(fontSize: 10) ?? const TextStyle(fontSize: 10), 
      child: _buildCore(context),
    );
  }

  Widget _buildCore(BuildContext context) {
    if(widget.editorState.focusState.hasFocus){
      return _InspectorWrapper(child: _ofElement(context, widget.editorState.focusedElement!));
    }else{
      if(widget.editorState.toolState.isGenerative){
        return _InspectorWrapper(child: _ofDefault(context));
      }else{
        return SizedBox.shrink();
      }
    }
  }

  Widget _ofDefault(BuildContext context){
    final tool = widget.editorState.toolState.currentTool;
    final caps = _capabilitiesOfTool(tool);

    if (caps == null) {
      return Text(AppLocalizations.of(context)!.defaultValueNotSupported);
    }

    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for(var cap in caps)
          _capBuilderOfDefault(cap),
      ],
    );
  }

  /// 根据工具类型获取支持的属性列表
  List<EleCap>? _capabilitiesOfTool(EditorTool tool) {
    switch(tool) {
      case EditorTool.rectangle:
      case EditorTool.embeddable:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness1,
          EleCap.opacity,
        ];
      case EditorTool.diamond:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness2,
          EleCap.opacity,
        ];
      case EditorTool.ellipse:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.opacity,
        ];
      case EditorTool.text:
        return [
          EleCap.strokeColor,
          EleCap.fontFamily,
          EleCap.fontSize,
          EleCap.textAlign,
          EleCap.opacity,
        ];
      case EditorTool.freedraw:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.strokeWidth,
          EleCap.opacity,
        ];
      case EditorTool.line:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness1,
          EleCap.opacity,
        ];
      case EditorTool.arrow:
        return [
          EleCap.strokeColor,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.arrowType,
          EleCap.arrowHeads,
          EleCap.opacity,
        ];
      default:
        return null;
    }
  }

  /// 构建默认值修改器
  Widget _capBuilderOfDefault(EleCap cap) {
    final capBd = CapabilityMap.map[cap]!;
    final defaultStyle = widget.editorState.defaultStyleState.defaultStyle;

    switch(cap) {
      case EleCap.strokeColor:
        return (capBd as Capability<FreeformCanvasColor>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.strokeColor,
          (c) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(strokeColor: c)),
        );
      case EleCap.backgroundColor:
        return (capBd as Capability<FreeformCanvasColor>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.backgroundColor,
          (c) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(backgroundColor: c)),
        );
      case EleCap.roundness1:
        return (capBd as Capability<FreeformCanvasRoundness?>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.roundness,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(roundness: Set(v))),
        );
      case EleCap.roundness2:
        return (capBd as Capability<FreeformCanvasRoundness?>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.roundness,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(roundness: Set(v))),
        );
      case EleCap.strokeStyle:
        return (capBd as Capability<String>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.strokeStyle,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(strokeStyle: v)),
        );
      case EleCap.roughness:
        return (capBd as Capability<int>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.roughness.toInt(),
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(roughness: v.toDouble())),
        );
      case EleCap.strokeWidth:
        return (capBd as Capability<double>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.strokeWidth,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(strokeWidth: v)),
        );
      case EleCap.fillStyle:
        return (capBd as Capability<String>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.fillStyle,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(fillStyle: v)),
        );
      case EleCap.opacity:
        return (capBd as Capability<double>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.opacity,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(opacity: v)),
        );
      case EleCap.fontFamily:
        return (capBd as Capability<FontFamily>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.fontFamily,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(fontFamily: v)),
        );
      case EleCap.fontSize:
        return (capBd as Capability<FontSize>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.fontSize,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(fontSize: v)),
        );
      case EleCap.textAlign:
        return (capBd as Capability<String>).builder(
          widget.editorState.defaultStyleState,
          () => defaultStyle.textAlign,
          (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(textAlign: v)),
        );
      case EleCap.arrowHeads:
        // 箭头头部需要分别处理起点和终点
        return Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            ArrowheadSelector(
              title: AppLocalizations.of(context)!.startArrowhead,
              notifier: widget.editorState.defaultStyleState,
              getter: () => defaultStyle.startArrowhead,
              setter: (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(startArrowhead: Set(v))),
            ),
            ArrowheadSelector(
              title: AppLocalizations.of(context)!.endArrowhead,
              notifier: widget.editorState.defaultStyleState,
              getter: () => defaultStyle.endArrowhead,
              setter: (v) => widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(endArrowhead: Set(v))),
            ),
          ],
        );
      case EleCap.arrowType:
        return (capBd as Capability<ArrowTypeValue>).builder(
          widget.editorState.defaultStyleState,
          () => _getArrowTypeValueFromDefault(),
          (v) => _setArrowTypeValueToDefault(v),
        );
    }
  }

  /// 从默认样式获取箭头类型值
  ArrowTypeValue _getArrowTypeValueFromDefault() {
    final defaultStyle = widget.editorState.defaultStyleState.defaultStyle;
    if (defaultStyle.elbowed) {
      return ArrowTypeValue.elbowed;
    } else if (defaultStyle.roundness != null && defaultStyle.roundness!.type == 2) {
      return ArrowTypeValue.curved;
    } else {
      return ArrowTypeValue.sharp;
    }
  }

  /// 设置箭头类型值到默认样式
  void _setArrowTypeValueToDefault(ArrowTypeValue value) {
    switch (value) {
      case ArrowTypeValue.sharp:
        widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(
          roundness: Set(null),
          elbowed: false,
        ));
        break;
      case ArrowTypeValue.curved:
        widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(
          roundness: Set(FreeformCanvasRoundness(type: 2)),
          elbowed: false,
        ));
        break;
      case ArrowTypeValue.elbowed:
        widget.editorState.defaultStyleState.updateDefault(ElementStylePatch(
          roundness: Set(null),
          elbowed: true,
        ));
        break;
    }
  }

  Widget _ofElement(BuildContext context,FreeformCanvasElement element){
    return Wrap(
      key: ValueKey('${element.id}_ei'),
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for(var cap in capabilitiesOf(element))
          _capBuilderOfElement(cap,element),
        Layer(editorState: widget.editorState, elementId: widget.editorState.focusedElement!.id),
        Operations(editorState: widget.editorState, elementId: widget.editorState.focusedElement!.id),
      ],
    );
  }

  Widget _capBuilderOfElement(EleCap cap,FreeformCanvasElement targetEle){
    final capBd = CapabilityMap.map[cap]!;
    switch(cap){
      case EleCap.strokeColor:
        return (capBd as Capability<FreeformCanvasColor>).builder(
          widget.editorState,
          ()=>targetEle.strokeColor,
          (c)=> setEle(ElementStylePatch(strokeColor: c))
        );
      case EleCap.backgroundColor:
        return (capBd as Capability<FreeformCanvasColor>).builder(
          widget.editorState,
          ()=>targetEle.backgroundColor,
          (c)=> setEle(ElementStylePatch(backgroundColor: c))
        );
      case EleCap.roundness1:
        return (capBd as Capability<FreeformCanvasRoundness?>).builder(
          widget.editorState,
          ()=>targetEle.roundness,
          (v)=> setEle(ElementStylePatch(roundness: Set(v)))
        );
      case EleCap.roundness2:
        return (capBd as Capability<FreeformCanvasRoundness?>).builder(
          widget.editorState,
          ()=>targetEle.roundness,
          (v)=> setEle(ElementStylePatch(roundness: Set(v)))
        );
      case EleCap.strokeStyle:
        return (capBd as Capability<String>).builder(
          widget.editorState,
          ()=>targetEle.strokeStyle,
          (v)=> setEle(ElementStylePatch(strokeStyle: v))
        );
      case EleCap.roughness:
        return (capBd as Capability<int>).builder(
          widget.editorState,
          ()=>targetEle.roughness.toInt(),
          (v)=> setEle(ElementStylePatch(roughness: v.toDouble()))
        );
      case EleCap.strokeWidth:
        return (capBd as Capability<double>).builder(
          widget.editorState,
          ()=>targetEle.strokeWidth,
          (v)=> setEle(ElementStylePatch(strokeWidth: v))
        );
      case EleCap.fillStyle:
        return (capBd as Capability<String>).builder(
          widget.editorState,
          ()=>targetEle.fillStyle,
          (v)=> setEle(ElementStylePatch(fillStyle: v))
        );
      case EleCap.opacity:
        //return OutlinedButton(onPressed: (){}, child: Text('测试'));
        return (capBd as Capability<double>).builder(
          widget.editorState,
          ()=>targetEle.opacity,
          (v)=> setEle(ElementStylePatch(opacity: v))
        );
      case EleCap.fontFamily:
        final textEle = targetEle as FreeformCanvasText;
        return (capBd as Capability<FontFamily>).builder(
          widget.editorState,
          ()=>textEle.fontFamily,
          (v)=> setEle(ElementStylePatch(fontFamily: v))
        );
      case EleCap.fontSize:
        final textEle = targetEle as FreeformCanvasText;
        return (capBd as Capability<FontSize>).builder(
          widget.editorState,
          ()=>textEle.fontSize,
          (v)=> setEle(ElementStylePatch(fontSize: v))
        );
      case EleCap.textAlign:
        final textEle = targetEle as FreeformCanvasText;
        return (capBd as Capability<String>).builder(
          widget.editorState,
          ()=>textEle.textAlign,
          (v)=> setEle(ElementStylePatch(textAlign: v))
        );
      case EleCap.arrowHeads:
        // arrowHeads 需要分别处理起点和终点箭头
        // 这里我们需要返回两个 ArrowheadSelector
        final arrowEle = targetEle as FreeformCanvasArrow;
        return Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            ArrowheadSelector(
              title: AppLocalizations.of(context)!.startArrowhead,
              notifier: widget.editorState,
              getter: () => arrowEle.startArrowhead,
              setter: (v) => setEle(ElementStylePatch(startArrowhead: Set(v))),
            ),
            ArrowheadSelector(
              title: AppLocalizations.of(context)!.endArrowhead,
              notifier: widget.editorState,
              getter: () => arrowEle.endArrowhead,
              setter: (v) => setEle(ElementStylePatch(endArrowhead: Set(v))),
            ),
          ],
        );
      case EleCap.arrowType:
        final arrowEle = targetEle as FreeformCanvasArrow;
        return (capBd as Capability<ArrowTypeValue>).builder(
          widget.editorState,
          () => _getArrowTypeValue(arrowEle),
          (v) => _setArrowTypeValue(v)
        );
    }
  }

  ///Update the attributes of the selected element (ensure that it is selected)
  void setEle(ElementStylePatch patch){
    // 修改元素属性
    widget.editorState.commitIntent(
      StyleUpdateIntent(id: widget.editorState.focusState.focusElementId!, patch: patch)
    );

    // 同步修改默认值
    widget.editorState.defaultStyleState.updateDefault(patch);
  }

  /// 获取箭头类型值（根据 roundness 和 elbowed 判断）
  ArrowTypeValue _getArrowTypeValue(FreeformCanvasArrow arrow) {
    if (arrow.elbowed) {
      return ArrowTypeValue.elbowed;
    } else if (arrow.roundness != null && arrow.roundness!.type == 2) {
      return ArrowTypeValue.curved;
    } else {
      return ArrowTypeValue.sharp;
    }
  }

  /// 设置箭头类型值（同时修改 roundness 和 elbowed）
  void _setArrowTypeValue(ArrowTypeValue value) {
    switch (value) {
      case ArrowTypeValue.sharp:
        setEle(ElementStylePatch(
          roundness: Set(null),
          elbowed: false,
        ));
        break;
      case ArrowTypeValue.curved:
        setEle(ElementStylePatch(
          roundness: Set(FreeformCanvasRoundness(type: 2)),
          elbowed: false,
        ));
        break;
      case ArrowTypeValue.elbowed:
        setEle(ElementStylePatch(
          roundness: Set(null),
          elbowed: true,
        ));
        break;
    }
  }

  List<EleCap> capabilitiesOf(FreeformCanvasElement e){
    switch(e.type){
      case FreeformCanvasElementType.rectangle:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness1,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.diamond:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness2,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.ellipse:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.text:
        return [
          EleCap.strokeColor,
          EleCap.fontFamily,
          EleCap.fontSize,
          EleCap.textAlign,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.freedraw:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.line:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness1,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.arrow:
        return [
          EleCap.strokeColor,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.arrowType,
          EleCap.arrowHeads,
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.embeddable:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
          EleCap.fillStyle,
          EleCap.strokeWidth,
          EleCap.strokeStyle,
          EleCap.roughness,
          EleCap.roundness1,
          EleCap.opacity,
        ];
    }
  }
}