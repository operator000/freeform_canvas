import 'package:flutter/material.dart';
import 'package:freeform_canvas/inspector/fundamental.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

//多选栏
//MultiSelect bar

class MultiSelectItem<T>{
  final Widget icon;
  final T value;

  MultiSelectItem({
    required this.icon, 
    required this.value
  });
}

class MultiSelect<T> extends StatefulWidget{
  final String title;
  final List<MultiSelectItem<T>> items;
  final void Function(T) onSelect;
  final T initialValue;
  const MultiSelect({
    super.key, 
    required this.items, 
    required this.title, 
    required this.onSelect, 
    required this.initialValue
  });

  @override
  State<MultiSelect<T>> createState() => _MultiSelectState();
}

class _MultiSelectState<T> extends State<MultiSelect<T>> {
  late T selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Text(widget.title),
        Row(
          children: widget.items.map(
            (e)=>Button(
              icon: e.icon, 
              selected: e.value==selected, 
              onSelect: (){
                setState(() {
                  selected = e.value;
                  widget.onSelect(selected);
                });
              }
            )
          ).toList(),
        )
      ],
    );
  }
}

//按钮组
//Button group bar

class MultiButtonItem{
  final Widget icon;
  final void Function() onPressed;

  MultiButtonItem({required this.icon, required this.onPressed});
}

class MultiButton extends StatelessWidget{
  final List<MultiButtonItem> items;
  final String title;

  const MultiButton({
    super.key, 
    required this.items, 
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Text(title),
        Row(
          children: items.map((e)=>Button(
            icon: e.icon, 
            selected: false, 
            onSelect: e.onPressed
          )).toList(),
        )
      ],
    );
  }
  
}

//颜色选择栏
//Color select bar

class ColorSet{
  final List<Color> colors;
  final String name;

  const ColorSet({required this.colors, required this.name});
}

// palette inspired by Mantine color (MIT licensed)
final _paletteRow = const [
  ColorSet(colors: [
    Color(0xff1e1e1e),
  ], name: "黑"),
  ColorSet(colors: [
    Color(0xfffff5f5),
    Color(0xffffc9c9),
    Color(0xffff8787),
    Color(0xfffa5252),
    Color(0xffe03131),
  ], name: "红"),
  ColorSet(colors: [//第三行
    Color(0xffebfbee),
    Color(0xffb2f2bb),
    Color(0xff69db7c),
    Color(0xff40c057),
    Color(0xff2f9e44),
  ], name: "绿"),
  ColorSet(colors: [
    Color(0xffe7f5ff),
    Color(0xffa5d8ff),
    Color(0xff4dabf7),
    Color(0xff228be6),
    Color(0xff1971c2),
  ], name: "蓝"),
  ColorSet(colors: [
    Color(0xfffff9db),
    Color(0xffffec99),
    Color(0xffffd43b),
    Color(0xfffab005),
    Color(0xfff08c00),
  ], name: "黄"),
];


// palette inspired by Mantine color (MIT licensed)
final _paletteMatrix = const [
  ColorSet(colors: [
    Color(0x00ffffff)
  ], name: "透明"),
  ColorSet(colors: [
    Color(0xffffffff)
  ], name: "白"),
  ColorSet(colors: [
    Color(0xfff8f9fa),
    Color(0xffe9ecef),
    Color(0xffced4da),
    Color(0xff868e96),
    Color(0xff343a40),
  ], name: "灰"),
  ColorSet(colors: [
    Color(0xff1e1e1e),
  ], name: "黑"),
  ColorSet(colors: [
    Color(0xfff8f1ee),
    Color(0xffeaddd7),
    Color(0xffd2bab0),
    Color(0xffa18072),
    Color(0xff846358),
  ], name: "古铜"),
  ColorSet(colors: [//第二排
    Color(0xffe3fafc),
    Color(0xff99e9f2),
    Color(0xff3bc9db),
    Color(0xff15aabf),
    Color(0xff0c8599),
  ], name: "青"),
  ColorSet(colors: [
    Color(0xffe7f5ff),
    Color(0xffa5d8ff),
    Color(0xff4dabf7),
    Color(0xff228be6),
    Color(0xff1971c2),
  ], name: "蓝"),
  ColorSet(colors: [
    Color(0xfff3f0ff),
    Color(0xffd0bfff),
    Color(0xff9775fa),
    Color(0xff7950f2),
    Color(0xff6741d9),
  ], name: "蓝紫"),
  ColorSet(colors: [
    Color(0xfff8f0fc),
    Color(0xffeebefa),
    Color(0xffda77f2),
    Color(0xffbe4bdb),
    Color(0xff9c36b5),
  ], name: "紫红"),
  ColorSet(colors: [
    Color(0xfffff0f6),
    Color(0xfffcc2d7),
    Color(0xfff783ac),
    Color(0xffe64980),
    Color(0xffc2255c),
  ], name: "粉红"),
  ColorSet(colors: [//第三行
    Color(0xffebfbee),
    Color(0xffb2f2bb),
    Color(0xff69db7c),
    Color(0xff40c057),
    Color(0xff2f9e44),
  ], name: "绿"),
  ColorSet(colors: [
    Color(0xffe6fcf5),
    Color(0xff96f2d7),
    Color(0xff38d9a9),
    Color(0xff12b886),
    Color(0xff099268),
  ], name: "蓝绿"),
  ColorSet(colors: [
    Color(0xfffff9db),
    Color(0xffffec99),
    Color(0xffffd43b),
    Color(0xfffab005),
    Color(0xfff08c00),
  ], name: "黄"),
  ColorSet(colors: [
    Color(0xfffff4e6),
    Color(0xffffd8a8),
    Color(0xffffa94d),
    Color(0xfffd7e14),
    Color(0xffe8590c),
  ], name: "橙"),
  ColorSet(colors: [
    Color(0xfffff5f5),
    Color(0xffffc9c9),
    Color(0xffff8787),
    Color(0xfffa5252),
    Color(0xffe03131),
  ], name: "红"),
];


///**ZH** 选择颜色的菜单栏
///
///**EN** Color selection menu
class ColorSelect extends StatefulWidget{
  final String title;
  final FreeformCanvasColor initialColor;
  final void Function(FreeformCanvasColor) onSelect;
  ///从0~4亮度递减
  final int brightness;
  const ColorSelect({
    super.key, 
    required this.title,
    required this.initialColor, 
    required this.onSelect,
    required this.brightness,
  });

  @override
  State<ColorSelect> createState() => _ColorSelectState();
}

class _ColorSelectState extends State<ColorSelect> {

  late FreeformCanvasColor selectedColor;

  final layerLink = LayerLink();
  final _controller = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.vertical,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Text(widget.title),
        Row(
          children: _paletteRow.map<Widget>((e){//5种基础颜色
            final Color c = e.colors.length==1?e.colors.first:e.colors[widget.brightness];
            return SmallColorButton(
              color: c, 
              selected: c==selectedColor.color, 
              onSelect: (){
                final fc = FreeformCanvasColor.fromColor(c);
                widget.onSelect(fc);
                setState(() {
                  selectedColor = fc;
                });
              }
            );
          }).toList() + <Widget>[
            Padding(//分割线
              padding: EdgeInsetsGeometry.all(5),
              child: Container(
                width: 1,
                height: 15,
                color: Colors.black,
              ),
            ),
            OverlayPortal(//详细选色
              controller:_controller,
              overlayChildBuilder: (context){
                return CompositedTransformFollower(
                  link: layerLink,
                  targetAnchor: Alignment.topRight,
                  followerAnchor: Alignment.topLeft,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ColorSelectSecondary(
                      selectedColor: selectedColor, 
                      onSelect: (c){
                        widget.onSelect(c);
                        setState(() {
                          selectedColor = c;
                        });
                      },
                      defaultBrightness: widget.brightness,
                    ),
                  ),
                );
              },
              child: CompositedTransformTarget(
                link: layerLink,
                child: LargeColorButton(
                  color: selectedColor.color, 
                  selected: false, 
                  onSelect: (){
                    _controller.toggle();
                  }
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

///**ZH** 选择颜色的二级菜单栏
///
///**EN** Color selection secondary menu
class ColorSelectSecondary extends StatelessWidget{
  final FreeformCanvasColor selectedColor;
  final void Function(FreeformCanvasColor) onSelect;
  ///从0~4亮度递减
  final int defaultBrightness;

  const ColorSelectSecondary({
    super.key, 
    required this.selectedColor, 
    required this.onSelect, 
    required this.defaultBrightness
  });

  @override
  Widget build(BuildContext context) {
    final inSet = contains(selectedColor.color);
    late int matchingBrightness;
    if(inSet==null){
      matchingBrightness = defaultBrightness;
    }else{
      matchingBrightness = inSet.colors.indexOf(selectedColor.color);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BoxBorder.all(width: 1,color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 1,
          ),
        ],
        color: Colors.white
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Text('颜色'),
            _buildColorMatrix(context,matchingBrightness),//矩阵颜色选择组件
            SizedBox(height: 5,),
            Text('色调明暗'),
            Builder(builder: (context){//亮度选择组件
              final colorset = contains(selectedColor.color);
              if(colorset==null||colorset.colors.length==1){
                return Text('此色调没有可用的明暗变化');
              }else{
                return ColorSelectTertiary(
                  colorset: colorset,
                  selected: selectedColor.color,
                  onSelect: (b) {
                    final c = colorset.colors[b];
                    onSelect(FreeformCanvasColor.fromColor(c));
                  },
                );
              }
            }),
            SizedBox(height: 10,),
            Text('十六进制值'),
            ColorPicker(
              color: selectedColor,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorMatrix(BuildContext context,int brightness){
    List<Wrap> rows = [];
    for(int i=0;i<15;i+=5){
      List<LargeColorButton> buttons = [];
      for(int j=0;j<5;j++){
        final colorSet = _paletteMatrix[i+j];
        final Color c = colorSet.colors.length==1?colorSet.colors.first:colorSet.colors[brightness];
        buttons.add(LargeColorButton(
          color: c, 
          selected: c==selectedColor.color, 
          onSelect: (){//从矩阵中选择颜色
            onSelect(FreeformCanvasColor.fromColor(c));
          }
        ));
      }
      rows.add(Wrap(
        direction: Axis.horizontal,
        spacing: 0,
        runSpacing: 0,
        children: buttons,
      ));
    }
    return Wrap(
      direction: Axis.vertical,
      spacing: 0,
      runSpacing: 0,
      children: rows,
    );
  }

  ColorSet? contains(Color color){
    for(var cs in _paletteMatrix){
      for(var c in cs.colors){
        if(c==color){
          return cs;
        }
      }
    }
    return null;
  }
}

///**ZH** 选择颜色的三级菜单栏，即Shades选择栏
///
///**EN** Color selection tertiary menu, i.e. Shades selection bar
class ColorSelectTertiary extends StatelessWidget{
  final ColorSet colorset;
  final Color selected;
  final void Function(int) onSelect;
  const ColorSelectTertiary({
    super.key, 
    required this.colorset, 
    required this.selected, 
    required this.onSelect
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    for(int i=0;i<colorset.colors.length;i++){
      final c = colorset.colors[i];
      buttons.add(LargeColorButton(
        color: c, 
        selected: selected==c, 
        onSelect: ()=>onSelect(i)
      ));
    }
    return Wrap(
      direction: Axis.horizontal,
      children: buttons,
    );
  }
}