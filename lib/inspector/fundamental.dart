import 'package:flutter/material.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

///通用工具选项按钮
class Button extends StatefulWidget{
  final Widget icon;
  final bool selected;
  final void Function() onSelect;

  Button({
    super.key, 
    required this.icon, 
    required this.selected, 
    required this.onSelect
  });
  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool hover = false;
  bool pointerDown = false;
  @override
  Widget build(BuildContext context) {
    late Color color;
    if(pointerDown || widget.selected){
      color = Color.fromRGBO(224,223,255,1);
    }else{
      if(hover){
        color = Color(0xfff1f0ff);
      }else{
        color = Color.fromRGBO(246,246,249,1);
      }
    }
    return SizedBox(
      width: 40,
      height: 40,
      child: Padding(
        padding: EdgeInsetsGeometry.all(4),
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          onEnter: (_)=>setState(() {
            hover = true;
          }),
          onExit: (_)=>setState(() {
            hover = false;
          }),
          child: Listener(
            onPointerDown: (_){
              widget.onSelect();
              setState(() {
                pointerDown = true;
              });
            },
            onPointerUp: (_){
              if(mounted){
                setState(() {
                  pointerDown = false;
                });
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: widget.icon,),
            ),
          ),
        ),
      ),
    );
  }
}

class SmallColorButton extends StatelessWidget{
  final Color color;
  final bool selected;
  final void Function() onSelect;

  const SmallColorButton({
    super.key, 
    required this.color, 
    required this.selected, 
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: selected?Color(0xff4A47B1):Colors.transparent),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(2),
          child: Listener(
            onPointerDown: (_)=>onSelect(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
              child: SizedBox(
                width: 22,
                height: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LargeColorButton extends StatelessWidget{
  final Color color;
  final bool selected;
  final void Function() onSelect;

  const LargeColorButton({
    super.key, 
    required this.color, 
    required this.selected, 
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(1),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.all(color: selected?Color(0xff4A47B1):Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsetsGeometry.all(2),
          child: Listener(
            onPointerDown: (_)=>onSelect(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color,
              ),
              child: SizedBox(
                width: 29,
                height: 29,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/// 十六进制字符串取色/吸管取色
class ColorPicker extends StatefulWidget{
  final FreeformCanvasColor color;
  final void Function(FreeformCanvasColor) onSelect;
  const ColorPicker({
    super.key, 
    required this.color, 
    required this.onSelect,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textEditingController.text = widget.color.colorStr.replaceFirst('#', '');
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BoxBorder.all(),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('#'),
          SizedBox(width: 10,),
          SizedBox(
            width: 100,
            child: TextField(
              onChanged: (text) {
                try{
                  final color = FreeformCanvasColor.fromString(text);
                  widget.onSelect(color);
                }on FormatException catch(_){}
              },
              controller: textEditingController,
              enabled: true,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: Colors.grey,
          ),
          IconButton(onPressed: (){}, icon: Text('取色'))
        ],
      ),
    );
  }
}