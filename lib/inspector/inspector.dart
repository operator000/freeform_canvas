import 'package:flutter/material.dart' hide Opacity;
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/models/element_style.dart';
import 'package:freeform_canvas/inspector/modifier.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

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
  }
  @override
  void dispose() {
    super.dispose();
    widget.editorState.focusState.removeListener(_setState);
  }
  void _setState(){
    if(mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
    return Text('Default value not supported');
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
    }
  }

  ///Update the attributes of the selected element (ensure that it is selected)
  void setEle(ElementStylePatch patch){
    widget.editorState.commitIntent(
      StyleUpdateIntent(id: widget.editorState.focusState.focusElementId!, patch: patch)
    );
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
          //TODO:字体
          //TODO:字体大小
          //TODO:文本对齐
          EleCap.opacity,
        ];
      case FreeformCanvasElementType.freedraw:
        return [
          EleCap.strokeColor,
          EleCap.backgroundColor,
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
          //TODO:箭头类型
          //TODO:端点
          EleCap.opacity,
        ];
    }
  }
}