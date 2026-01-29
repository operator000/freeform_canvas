import 'package:freeform_canvas/models/freeform_canvas_element.dart';

///元素字段中描述元素风格的字段作为一组数据
class ElementStyle {
  /// 描边颜色，默认为黑色
  FreeformCanvasColor strokeColor = FreeformCanvasColor.black();

  /// 填充颜色，默认为transparent
  FreeformCanvasColor backgroundColor = FreeformCanvasColor.transparent();

  /// 填充样式，取值为 solid(实心)、hachure(45°左下、右上平行线)、cross-hatch(45°交叉线)
  String fillStyle = "solid";

  /// 描边宽度，任意实数，典型值为1、2、4
  double strokeWidth = 1;

  /// 边框样式：solid / dashed / dotted
  String strokeStyle = "solid";

  /// 手绘程度，0 表示平滑，值越大越粗糙，典型值为0，1，2
  double roughness = 0;

  /// 不透明度 0–100
  double opacity = 100;

  /// 圆角配置，取值：
  /// FreeformCanvasRoundness(type:3)(固定圆角)，FreeformCanvasRoundness(type:2)(随元素缩放圆角)，null(直角)
  /// 仅对矩形、直线、菱形有效
  FreeformCanvasRoundness? roundness;

  /// 字号
  double fontSize = 16;

  /// 字体枚举
  int fontFamily = 5;

  /// 文本对齐：left / center / right
  String textAlign = 'left';
}

sealed class PatchValue<T>{
  const PatchValue();
}
class Set<T> extends PatchValue<T>{
  final T? value;
  const Set(this.value);
}
class Unset<T> extends PatchValue<T>{
  const Unset();
}

class ElementStylePatch {
  final FreeformCanvasColor? strokeColor;
  final FreeformCanvasColor? backgroundColor;
  final String? fillStyle;
  final double? strokeWidth;
  final String? strokeStyle;
  final double? roughness;
  final double? opacity;
  final PatchValue<FreeformCanvasRoundness> roundness;
  final double? fontSize;
  final int? fontFamily;
  final String? textAlign;

  const ElementStylePatch({
    this.strokeColor,
    this.backgroundColor,
    this.fillStyle,
    this.strokeWidth,
    this.strokeStyle,
    this.roughness,
    this.opacity,
    this.roundness = const Unset<FreeformCanvasRoundness>(),
    this.fontSize,
    this.fontFamily,
    this.textAlign,
  });

  bool get isEmpty =>
      strokeColor == null &&
      backgroundColor == null &&
      fillStyle == null &&
      strokeWidth == null &&
      strokeStyle == null &&
      roughness == null &&
      opacity == null &&
      roundness is Unset &&
      fontSize == null &&
      fontFamily == null &&
      textAlign == null;
}
///补充将Patch应用到ElementStyle以及将ElementStyle应用到元素的方法
extension ElementStyleApply on ElementStyle{
  void applyPatch(ElementStylePatch patch){
    strokeColor = patch.strokeColor ?? strokeColor;
    backgroundColor = patch.backgroundColor ?? backgroundColor;
    fillStyle = patch.fillStyle ?? fillStyle;
    strokeWidth = patch.strokeWidth ?? strokeWidth;
    strokeStyle = patch.strokeStyle ?? strokeStyle;
    roughness = patch.roughness ?? roughness;
    opacity = patch.opacity ?? opacity;
    roundness = patch.roundness is Set<FreeformCanvasRoundness> ? (patch.roundness as Set).value : roundness;
    fontSize = patch.fontSize ?? fontSize;
    fontFamily = patch.fontFamily ?? fontFamily;
    textAlign = patch.textAlign ?? textAlign;
  }
}