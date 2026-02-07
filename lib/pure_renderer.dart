import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:freeform_canvas/freeform_canvas_parser.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import 'package:freeform_canvas/painters/element_geometry.dart';
import 'package:freeform_canvas/painters/static_layer_painter.dart';

Future<ui.Image> renderFile({
  String? jsonString,
  File? file,
  required double Function(ui.Rect rect) scaleCalculator,
})async{
  final double padding = 10;
  final FreeformCanvasFile _file = file==null 
    ? FreeformCanvasParser.parseFromString(jsonString!)
    : await FreeformCanvasParser.parseFromFile(file);

  //在Canvas坐标系下的边界矩形
  final rect = ElementGeometry.calculateBoundary(_file.elements).inflate(padding);
  final scale = scaleCalculator(rect);
  
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  canvas.scale(scale, scale);
  canvas.translate(-rect.left, -rect.top);

  canvas.drawColor(_file.appState.viewBackgroundColor, ui.BlendMode.src);
  for (final element in _file.elements) {
    drawElement(canvas, element);
  }

  final picture = recorder.endRecording();
  return await picture.toImage(
    max(1, (rect.width*scale).round()),
    max(1, (rect.height*scale).round()),
  );
}