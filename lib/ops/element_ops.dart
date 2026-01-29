import 'dart:math';
import 'dart:ui';
import 'package:freeform_canvas/models/element_style.dart';

import '../models/freeform_canvas_element.dart';

/// **ZH** 元素操作工具类
///
/// 集中管理 FreeformCanvasElement 的创建和修改逻辑。
/// 原则上这是唯一允许创建新 FreeformCanvasElement 实例的地方。
/// 
/// **EN** Element operation tool class
///
/// Centralize the logic for creating and modifying FreeformCanvasElement instances.
/// Ideally, this is the only place where new FreeformCanvasElement instances can be created.
class ElementOps {
  ElementOps._();

  /// **ZH** 哨兵对象，用于区分“不修改字段”和“将字段设为 null”
  /// 
  /// **EN** Sentinel object, used to distinguish "don't modify field" and "set field to null"
  static const _unset = _Unset();

  /// **ZH** 复制元素并修改指定字段
  ///
  /// - 当参数值为 `null` 时，将该字段显式设为 null（如果字段可为空）
  /// - 如果某字段对该元素类型不存在，则直接忽略该参数
  /// 
  /// **EN** Copy the element and modify the specified field
  /// 
  /// - When the parameter value is `null`, explicitly set the field to null (if the field is nullable)
  /// - If a field does not exist for the element type, ignore the parameter directly
  static FreeformCanvasElement copyWith(
    FreeformCanvasElement element, {
    // Common fields
    Object? id = _unset,
    Object? type = _unset,
    Object? index = _unset,
    Object? x = _unset,
    Object? y = _unset,
    Object? width = _unset,
    Object? height = _unset,
    Object? angle = _unset,
    Object? strokeColor = _unset,
    Object? backgroundColor = _unset,
    Object? fillStyle = _unset,
    Object? strokeWidth = _unset,
    Object? strokeStyle = _unset,
    Object? roughness = _unset,
    Object? opacity = _unset,
    Object? locked = _unset,
    Object? groupIds = _unset,
    Object? frameId = _unset,
    Object? boundElements = _unset,
    Object? link = _unset,
    Object? version = _unset,
    Object? versionNonce = _unset,
    Object? seed = _unset,
    Object? roundness = _unset,
    Object? updated = _unset,
    Object? isDeleted = _unset,

    // Text element-specific fields
    Object? text = _unset,
    Object? originalText = _unset,
    Object? fontSize = _unset,
    Object? fontFamily = _unset,
    Object? textAlign = _unset,
    Object? verticalAlign = _unset,
    Object? lineHeight = _unset,
    Object? autoResize = _unset,
    Object? containerId = _unset,

    // Freedraw element-specific fields
    Object? points = _unset,
    Object? pressures = _unset,
    Object? simulatePressure = _unset,

    // Line and arrow element-specific fields
    Object? polygon = _unset,
    Object? startBinding = _unset,
    Object? endBinding = _unset,
    Object? startArrowhead = _unset,
    Object? endArrowhead = _unset,

    // Arrow element-specific fields
    Object? elbowed = _unset,
  }) {
    switch (element.type) {
      case FreeformCanvasElementType.rectangle:
        return _copyRectangle(element as FreeformCanvasRectangle,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.ellipse:
        return _copyEllipse(element as FreeformCanvasEllipse,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.text:
        return _copyText(element as FreeformCanvasText,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          text: text,
          originalText: originalText,
          fontSize: fontSize,
          fontFamily: fontFamily,
          textAlign: textAlign,
          verticalAlign: verticalAlign,
          lineHeight: lineHeight,
          autoResize: autoResize,
          containerId: containerId,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.freedraw:
        return _copyFreedraw(element as FreeformCanvasFreedraw,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          points: points,
          pressures: pressures,
          simulatePressure: simulatePressure,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.line:
        return _copyLine(element as FreeformCanvasLine,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          points: points,
          polygon: polygon,
          startBinding: startBinding,
          endBinding: endBinding,
          startArrowhead: startArrowhead,
          endArrowhead: endArrowhead,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.arrow:
        return _copyArrow(element as FreeformCanvasArrow,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          points: points,
          polygon: polygon,
          startBinding: startBinding,
          endBinding: endBinding,
          startArrowhead: startArrowhead,
          endArrowhead: endArrowhead,
          elbowed: elbowed,
          isDeleted:isDeleted,
        );
      case FreeformCanvasElementType.diamond:
        return _copyDiamond(element as FreeformCanvasDiamond,
          id: id,
          type: type,
          index: index,
          x: x,
          y: y,
          width: width,
          height: height,
          angle: angle,
          strokeColor: strokeColor,
          backgroundColor: backgroundColor,
          fillStyle: fillStyle,
          strokeWidth: strokeWidth,
          strokeStyle: strokeStyle,
          roughness: roughness,
          opacity: opacity,
          locked: locked,
          groupIds: groupIds,
          frameId: frameId,
          boundElements: boundElements,
          link: link,
          version: version,
          versionNonce: versionNonce,
          seed: seed,
          roundness: roundness,
          updated: updated,
          isDeleted:isDeleted,
        );
    }
  }

  /// **ZH** 根据两点创建草稿元素
  ///
  /// 用于两点拖动型工具（rectangle, ellipse, line, arrow, diamond）
  /// [startPoint] 和 [endPoint] 定义元素的边界
  /// 
  /// **EN** Create a draft element based on two points
  /// 
  /// Used for two-point dragging tools (rectangle, ellipse, line, arrow, diamond)
  /// [startPoint] and [endPoint] define the boundaries of the element
  static FreeformCanvasElement? createDraftElementFromPoints(
    FreeformCanvasElementType type,
    Offset startPoint,
    Offset endPoint,
  ) {
    // 计算边界
    final minX = startPoint.dx < endPoint.dx ? startPoint.dx : endPoint.dx;
    final minY = startPoint.dy < endPoint.dy ? startPoint.dy : endPoint.dy;
    final maxX = startPoint.dx > endPoint.dx ? startPoint.dx : endPoint.dx;
    final maxY = startPoint.dy > endPoint.dy ? startPoint.dy : endPoint.dy;

    final width = maxX - minX;
    final height = maxY - minY;

    // ID在插入元素时具体分配
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    switch (type) {
      case FreeformCanvasElementType.rectangle:
        return FreeformCanvasRectangle(
          id: id,
          index: '00',
          x: minX,
          y: minY,
          width: width,
          height: height,
          angle: 0.0,
          strokeColor: FreeformCanvasColor.black(),
          backgroundColor: FreeformCanvasColor.transparent(),
          fillStyle: 'solid',
          strokeWidth: 2.0,
          strokeStyle: 'solid',
          roughness: 0.0,
          opacity: 100.0,
          locked: false,
          groupIds: [],
          roundness: null,
        );
      case FreeformCanvasElementType.ellipse:
        return FreeformCanvasEllipse(
          id: id,
          index: '00',
          x: minX,
          y: minY,
          width: width,
          height: height,
          angle: 0.0,
          strokeColor: FreeformCanvasColor.black(),
          backgroundColor: FreeformCanvasColor.transparent(),
          fillStyle: 'solid',
          strokeWidth: 2.0,
          strokeStyle: 'solid',
          roughness: 0.0,
          opacity: 100.0,
          locked: false,
          groupIds: [],
        );
      case FreeformCanvasElementType.line:
        // 直线使用points表示
        return FreeformCanvasLine(
          id: id,
          index: '00',
          x: minX,
          y: minY,
          width: width,
          height: height,
          angle: 0.0,
          strokeColor: FreeformCanvasColor.black(),
          backgroundColor: FreeformCanvasColor.transparent(),
          fillStyle: 'solid',
          strokeWidth: 2.0,
          strokeStyle: 'solid',
          roughness: 0.0,
          opacity: 100.0,
          locked: false,
          groupIds: [],
          points: [
            FreeformCanvasPoint(startPoint.dx-minX, startPoint.dy-minY),  // 起点（相对坐标）
            FreeformCanvasPoint(endPoint.dx-minX, endPoint.dy-minY),  // 终点（相对坐标）
          ],
          polygon: false,
          startArrowhead: null,
          endArrowhead: null,
        );
      case FreeformCanvasElementType.arrow:
        // 箭头与直线类似，但包含箭头头
        return FreeformCanvasArrow(
          id: id,
          index: '00',
          x: minX,
          y: minY,
          width: width,
          height: height,
          angle: 0.0,
          strokeColor: FreeformCanvasColor.black(),
          backgroundColor: FreeformCanvasColor.transparent(),
          fillStyle: 'solid',
          strokeWidth: 2.0,
          strokeStyle: 'solid',
          roughness: 0.0,
          opacity: 100.0,
          locked: false,
          groupIds: [],
          points: [
            FreeformCanvasPoint(startPoint.dx-minX, startPoint.dy-minY),  // 起点（相对坐标）
            FreeformCanvasPoint(endPoint.dx-minX, endPoint.dy-minY),  // 终点（相对坐标）
          ],
          polygon: false,
          startArrowhead: null,
          endArrowhead: 'arrow',
        );
      case FreeformCanvasElementType.diamond:
        return FreeformCanvasDiamond(
          id: id,
          index: '00',
          x: minX,
          y: minY,
          width: width,
          height: height,
          angle: 0.0,
          strokeColor: FreeformCanvasColor.black(),
          backgroundColor: FreeformCanvasColor.transparent(),
          fillStyle: 'solid',
          strokeWidth: 2.0,
          strokeStyle: 'solid',
          roughness: 0.0,
          opacity: 100.0,
          locked: false,
          groupIds: [],
          roundness: null,
        );
      default:
        return null;
    }
  }

  // 私有辅助方法：检查值是否为 _unset
  static bool _isUnset(Object? value) => value is _Unset;

  // 私有辅助方法：获取值，如果为 _unset 则返回原值
  static T _getValue<T>(Object? newValue, T oldValue) {
    if (_isUnset(newValue)) return oldValue;
    return newValue as T;
  }

  // 私有辅助方法：获取可为空的值，如果为 _unset 则返回原值
  static T? _getNullableValue<T>(Object? newValue, T? oldValue) {
    if (_isUnset(newValue)) return oldValue;
    return newValue as T?;
  }

  // 复制矩形元素
  static FreeformCanvasRectangle _copyRectangle(
    FreeformCanvasRectangle rectangle, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? isDeleted,
  }) {
    return FreeformCanvasRectangle(
      id: _getValue(id, rectangle.id),
      index: _getValue(index, rectangle.index),
      x: _getValue(x, rectangle.x),
      y: _getValue(y, rectangle.y),
      width: _getValue(width, rectangle.width),
      height: _getValue(height, rectangle.height),
      angle: _getValue(angle, rectangle.angle),
      strokeColor: _getValue(strokeColor, rectangle.strokeColor),
      backgroundColor: _getValue(backgroundColor, rectangle.backgroundColor),
      fillStyle: _getValue(fillStyle, rectangle.fillStyle),
      strokeWidth: _getValue(strokeWidth, rectangle.strokeWidth),
      strokeStyle: _getValue(strokeStyle, rectangle.strokeStyle),
      roughness: _getValue(roughness, rectangle.roughness),
      opacity: _getValue(opacity, rectangle.opacity),
      locked: _getValue(locked, rectangle.locked),
      groupIds: _getValue(groupIds, rectangle.groupIds),
      frameId: _getNullableValue(frameId, rectangle.frameId),
      boundElements: _getNullableValue(boundElements, rectangle.boundElements),
      link: _getNullableValue(link, rectangle.link),
      version: _getNullableValue(version, rectangle.version),
      versionNonce: _getNullableValue(versionNonce, rectangle.versionNonce),
      seed: _getNullableValue(seed, rectangle.seed),
      updated: _getNullableValue(updated, rectangle.updated),
      roundness: _getNullableValue(roundness, rectangle.roundness),
      isDeleted: _getValue(isDeleted, rectangle.isDeleted),
    );
  }

  // 复制椭圆元素
  static FreeformCanvasEllipse _copyEllipse(
    FreeformCanvasEllipse ellipse, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? isDeleted,
  }) {
    return FreeformCanvasEllipse(
      id: _getValue(id, ellipse.id),
      index: _getValue(index, ellipse.index),
      x: _getValue(x, ellipse.x),
      y: _getValue(y, ellipse.y),
      width: _getValue(width, ellipse.width),
      height: _getValue(height, ellipse.height),
      angle: _getValue(angle, ellipse.angle),
      strokeColor: _getValue(strokeColor, ellipse.strokeColor),
      backgroundColor: _getValue(backgroundColor, ellipse.backgroundColor),
      fillStyle: _getValue(fillStyle, ellipse.fillStyle),
      strokeWidth: _getValue(strokeWidth, ellipse.strokeWidth),
      strokeStyle: _getValue(strokeStyle, ellipse.strokeStyle),
      roughness: _getValue(roughness, ellipse.roughness),
      opacity: _getValue(opacity, ellipse.opacity),
      locked: _getValue(locked, ellipse.locked),
      groupIds: _getValue(groupIds, ellipse.groupIds),
      frameId: _getNullableValue(frameId, ellipse.frameId),
      boundElements: _getNullableValue(boundElements, ellipse.boundElements),
      link: _getNullableValue(link, ellipse.link),
      version: _getNullableValue(version, ellipse.version),
      versionNonce: _getNullableValue(versionNonce, ellipse.versionNonce),
      seed: _getNullableValue(seed, ellipse.seed),
      updated: _getNullableValue(updated, ellipse.updated),
      roundness: _getNullableValue(roundness, ellipse.roundness),
      isDeleted: _getValue(isDeleted, ellipse.isDeleted),
    );
  }

  // 复制文本元素
  static FreeformCanvasText _copyText(
    FreeformCanvasText textElement, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? text,
    required Object? originalText,
    required Object? fontSize,
    required Object? fontFamily,
    required Object? textAlign,
    required Object? verticalAlign,
    required Object? lineHeight,
    required Object? autoResize,
    required Object? containerId,
    required Object? isDeleted,
  }) {
    return FreeformCanvasText(
      id: _getValue(id, textElement.id),
      index: _getValue(index, textElement.index),
      x: _getValue(x, textElement.x),
      y: _getValue(y, textElement.y),
      width: _getValue(width, textElement.width),
      height: _getValue(height, textElement.height),
      angle: _getValue(angle, textElement.angle),
      strokeColor: _getValue(strokeColor, textElement.strokeColor),
      backgroundColor: _getValue(backgroundColor, textElement.backgroundColor),
      fillStyle: _getValue(fillStyle, textElement.fillStyle),
      strokeWidth: _getValue(strokeWidth, textElement.strokeWidth),
      strokeStyle: _getValue(strokeStyle, textElement.strokeStyle),
      roughness: _getValue(roughness, textElement.roughness),
      opacity: _getValue(opacity, textElement.opacity),
      locked: _getValue(locked, textElement.locked),
      groupIds: _getValue(groupIds, textElement.groupIds),
      frameId: _getNullableValue(frameId, textElement.frameId),
      boundElements: _getNullableValue(boundElements, textElement.boundElements),
      link: _getNullableValue(link, textElement.link),
      version: _getNullableValue(version, textElement.version),
      versionNonce: _getNullableValue(versionNonce, textElement.versionNonce),
      seed: _getNullableValue(seed, textElement.seed),
      updated: _getNullableValue(updated, textElement.updated),
      roundness: _getNullableValue(roundness, textElement.roundness),
      text: _getValue(text, textElement.text),
      originalText: _getNullableValue(originalText, textElement.originalText),
      fontSize: _getValue(fontSize, textElement.fontSize),
      fontFamily: _getValue(fontFamily, textElement.fontFamily),
      textAlign: _getValue(textAlign, textElement.textAlign),
      verticalAlign: _getValue(verticalAlign, textElement.verticalAlign),
      lineHeight: _getValue(lineHeight, textElement.lineHeight),
      autoResize: _getValue(autoResize, textElement.autoResize),
      containerId: _getNullableValue(containerId, textElement.containerId),
      isDeleted: _getValue(isDeleted, textElement.isDeleted),
    );
  }

  // 复制自由绘制元素
  static FreeformCanvasFreedraw _copyFreedraw(
    FreeformCanvasFreedraw freedraw, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? points,
    required Object? pressures,
    required Object? simulatePressure,
    required Object? isDeleted,
  }) {
    return FreeformCanvasFreedraw(
      id: _getValue(id, freedraw.id),
      index: _getValue(index, freedraw.index),
      x: _getValue(x, freedraw.x),
      y: _getValue(y, freedraw.y),
      width: _getValue(width, freedraw.width),
      height: _getValue(height, freedraw.height),
      angle: _getValue(angle, freedraw.angle),
      strokeColor: _getValue(strokeColor, freedraw.strokeColor),
      backgroundColor: _getValue(backgroundColor, freedraw.backgroundColor),
      fillStyle: _getValue(fillStyle, freedraw.fillStyle),
      strokeWidth: _getValue(strokeWidth, freedraw.strokeWidth),
      strokeStyle: _getValue(strokeStyle, freedraw.strokeStyle),
      roughness: _getValue(roughness, freedraw.roughness),
      opacity: _getValue(opacity, freedraw.opacity),
      locked: _getValue(locked, freedraw.locked),
      groupIds: _getValue(groupIds, freedraw.groupIds),
      frameId: _getNullableValue(frameId, freedraw.frameId),
      boundElements: _getNullableValue(boundElements, freedraw.boundElements),
      link: _getNullableValue(link, freedraw.link),
      version: _getNullableValue(version, freedraw.version),
      versionNonce: _getNullableValue(versionNonce, freedraw.versionNonce),
      seed: _getNullableValue(seed, freedraw.seed),
      updated: _getNullableValue(updated, freedraw.updated),
      roundness: _getNullableValue(roundness, freedraw.roundness),
      points: _getValue(points, freedraw.points),
      pressures: _getNullableValue(pressures, freedraw.pressures),
      simulatePressure: _getValue(simulatePressure, freedraw.simulatePressure),
      isDeleted: _getValue(isDeleted, freedraw.isDeleted),
    );
  }

  // 复制直线元素
  static FreeformCanvasLine _copyLine(
    FreeformCanvasLine line, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? points,
    required Object? polygon,
    required Object? startBinding,
    required Object? endBinding,
    required Object? startArrowhead,
    required Object? endArrowhead,
    required Object? isDeleted,
  }) {
    return FreeformCanvasLine(
      id: _getValue(id, line.id),
      index: _getValue(index, line.index),
      x: _getValue(x, line.x),
      y: _getValue(y, line.y),
      width: _getValue(width, line.width),
      height: _getValue(height, line.height),
      angle: _getValue(angle, line.angle),
      strokeColor: _getValue(strokeColor, line.strokeColor),
      backgroundColor: _getValue(backgroundColor, line.backgroundColor),
      fillStyle: _getValue(fillStyle, line.fillStyle),
      strokeWidth: _getValue(strokeWidth, line.strokeWidth),
      strokeStyle: _getValue(strokeStyle, line.strokeStyle),
      roughness: _getValue(roughness, line.roughness),
      opacity: _getValue(opacity, line.opacity),
      locked: _getValue(locked, line.locked),
      groupIds: _getValue(groupIds, line.groupIds),
      frameId: _getNullableValue(frameId, line.frameId),
      boundElements: _getNullableValue(boundElements, line.boundElements),
      link: _getNullableValue(link, line.link),
      version: _getNullableValue(version, line.version),
      versionNonce: _getNullableValue(versionNonce, line.versionNonce),
      seed: _getNullableValue(seed, line.seed),
      updated: _getNullableValue(updated, line.updated),
      roundness: _getNullableValue(roundness, line.roundness),
      points: _getValue(points, line.points),
      polygon: _getValue(polygon, line.polygon),
      startBinding: _getNullableValue(startBinding, line.startBinding),
      endBinding: _getNullableValue(endBinding, line.endBinding),
      startArrowhead: _getNullableValue(startArrowhead, line.startArrowhead),
      endArrowhead: _getNullableValue(endArrowhead, line.endArrowhead),
      isDeleted: _getValue(isDeleted, line.isDeleted),
    );
  }

  // 复制箭头元素
  static FreeformCanvasArrow _copyArrow(
    FreeformCanvasArrow arrow, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? points,
    required Object? polygon,
    required Object? startBinding,
    required Object? endBinding,
    required Object? startArrowhead,
    required Object? endArrowhead,
    required Object? elbowed,
    required Object? isDeleted,
  }) {
    return FreeformCanvasArrow(
      id: _getValue(id, arrow.id),
      index: _getValue(index, arrow.index),
      x: _getValue(x, arrow.x),
      y: _getValue(y, arrow.y),
      width: _getValue(width, arrow.width),
      height: _getValue(height, arrow.height),
      angle: _getValue(angle, arrow.angle),
      strokeColor: _getValue(strokeColor, arrow.strokeColor),
      backgroundColor: _getValue(backgroundColor, arrow.backgroundColor),
      fillStyle: _getValue(fillStyle, arrow.fillStyle),
      strokeWidth: _getValue(strokeWidth, arrow.strokeWidth),
      strokeStyle: _getValue(strokeStyle, arrow.strokeStyle),
      roughness: _getValue(roughness, arrow.roughness),
      opacity: _getValue(opacity, arrow.opacity),
      locked: _getValue(locked, arrow.locked),
      groupIds: _getValue(groupIds, arrow.groupIds),
      frameId: _getNullableValue(frameId, arrow.frameId),
      boundElements: _getNullableValue(boundElements, arrow.boundElements),
      link: _getNullableValue(link, arrow.link),
      version: _getNullableValue(version, arrow.version),
      versionNonce: _getNullableValue(versionNonce, arrow.versionNonce),
      seed: _getNullableValue(seed, arrow.seed),
      updated: _getNullableValue(updated, arrow.updated),
      roundness: _getNullableValue(roundness, arrow.roundness),
      points: _getValue(points, arrow.points),
      polygon: _getValue(polygon, arrow.polygon),
      startBinding: _getNullableValue(startBinding, arrow.startBinding),
      endBinding: _getNullableValue(endBinding, arrow.endBinding),
      startArrowhead: _getNullableValue(startArrowhead, arrow.startArrowhead),
      endArrowhead: _getNullableValue(endArrowhead, arrow.endArrowhead),
      elbowed: _getValue(elbowed, arrow.elbowed),
      isDeleted: _getValue(isDeleted, arrow.isDeleted),
    );
  }

  // 复制菱形元素
  static FreeformCanvasDiamond _copyDiamond(
    FreeformCanvasDiamond diamond, {
    required Object? id,
    required Object? type,
    required Object? index,
    required Object? x,
    required Object? y,
    required Object? width,
    required Object? height,
    required Object? angle,
    required Object? strokeColor,
    required Object? backgroundColor,
    required Object? fillStyle,
    required Object? strokeWidth,
    required Object? strokeStyle,
    required Object? roughness,
    required Object? opacity,
    required Object? locked,
    required Object? groupIds,
    required Object? frameId,
    required Object? boundElements,
    required Object? link,
    required Object? version,
    required Object? versionNonce,
    required Object? seed,
    required Object? roundness,
    required Object? updated,
    required Object? isDeleted,
  }) {
    return FreeformCanvasDiamond(
      id: _getValue(id, diamond.id),
      index: _getValue(index, diamond.index),
      x: _getValue(x, diamond.x),
      y: _getValue(y, diamond.y),
      width: _getValue(width, diamond.width),
      height: _getValue(height, diamond.height),
      angle: _getValue(angle, diamond.angle),
      strokeColor: _getValue(strokeColor, diamond.strokeColor),
      backgroundColor: _getValue(backgroundColor, diamond.backgroundColor),
      fillStyle: _getValue(fillStyle, diamond.fillStyle),
      strokeWidth: _getValue(strokeWidth, diamond.strokeWidth),
      strokeStyle: _getValue(strokeStyle, diamond.strokeStyle),
      roughness: _getValue(roughness, diamond.roughness),
      opacity: _getValue(opacity, diamond.opacity),
      locked: _getValue(locked, diamond.locked),
      groupIds: _getValue(groupIds, diamond.groupIds),
      frameId: _getNullableValue(frameId, diamond.frameId),
      boundElements: _getNullableValue(boundElements, diamond.boundElements),
      link: _getNullableValue(link, diamond.link),
      version: _getNullableValue(version, diamond.version),
      versionNonce: _getNullableValue(versionNonce, diamond.versionNonce),
      seed: _getNullableValue(seed, diamond.seed),
      updated: _getNullableValue(updated, diamond.updated),
      roundness: _getNullableValue(roundness, diamond.roundness),
      isDeleted: _getValue(isDeleted, diamond.isDeleted),
    );
  }

  /// **ZH** 对矩形、椭圆、自由绘制、文本元素进行几何缩放
  ///
  /// 输入两个矩形 [fromRect] 和 [toRect]，其中toRect为fromRect经过某线性变换后的结果。
  /// 函数对输入的元素进行完全一致的线性变换，返回新的元素实例。例外：文本元素等比缩放
  /// 
  /// **EN** Scale rectangle, ellipse, free drawing and text elements by a linear transformation.
  /// 
  /// Given two rectangles [fromRect] and [toRect], where [toRect] is the result of a linear transformation of [fromRect].
  /// The function applies a linear transformation to the input element completely, and returns a new element instance. 
  /// Exception: Text elements are scaled proportionally
  static FreeformCanvasElement rectScaleElement(
    FreeformCanvasElement element,
    Rect fromRect,
    Rect toRect,
  ) {
    // 计算线性变换的比例
    final scaleX = toRect.width / fromRect.width;
    final scaleY = toRect.height / fromRect.height;

    switch (element.type) {
      case FreeformCanvasElementType.rectangle:
      case FreeformCanvasElementType.ellipse:
      case FreeformCanvasElementType.diamond:
        // 矩形、椭圆、菱形：直接应用线性变换
        double newX = toRect.left + (element.x - fromRect.left) * scaleX;
        double newY = toRect.top + (element.y - fromRect.top) * scaleY;
        double newWidth = element.width * scaleX;
        double newHeight = element.height * scaleY;
        if(scaleX<0){
          newWidth*=-1;
          newX -= newWidth;
        }
        if(scaleY<0){
          newHeight*=-1;
          newY -= newHeight;
        }

        return copyWith(
          element,
          x: newX,
          y: newY,
          width: newWidth,
          height: newHeight,
        );

      case FreeformCanvasElementType.text:
        // 文本元素：需要等比缩放
        // 计算 x 方向和 y 方向的线性缩放量
        final scaleX = toRect.width / fromRect.width;
        final scaleY = toRect.height / fromRect.height;

        // 取放大较多的缩放值（取绝对值较大的缩放值）
        final uniformScale = scaleX.abs() > scaleY.abs() ? scaleX : scaleY;

        // 计算线性变换的固定点（变换前后位置不变的点）
        // 线性变换公式：x' = scaleX * x + tx, y' = scaleY * y + ty
        // 从 fromRect 到 toRect 的变换参数：
        final tx = toRect.left - scaleX * fromRect.left;
        final ty = toRect.top - scaleY * fromRect.top;

        // 固定点满足：x = scaleX * x + tx, y = scaleY * y + ty
        // 即 x = tx / (1 - scaleX), y = ty / (1 - scaleY)
        // 需要处理 scaleX == 1 或 scaleY == 1 的情况
        Offset fixedPoint;
        if ((scaleX - 1.0).abs() < 1e-10) {
          // scaleX ≈ 1，x方向无缩放，固定点在x方向可以是任意值
          // 取 fromRect 和 toRect 的x中心点作为参考
          if ((scaleY - 1.0).abs() < 1e-10) {
            // scaleY ≈ 1，两个方向都无缩放，只有平移，固定点不存在（无穷远）
            // 使用 fromRect 的中心点作为缩放中心
            fixedPoint = fromRect.center;
          } else {
            // 只有y方向有缩放，固定点x坐标任意，取 fromRect 的x中心
            final fixedY = ty / (1 - scaleY);
            fixedPoint = Offset(fromRect.center.dx, fixedY);
          }
        } else if ((scaleY - 1.0).abs() < 1e-10) {
          // 只有x方向有缩放，固定点y坐标任意，取 fromRect 的y中心
          final fixedX = tx / (1 - scaleX);
          fixedPoint = Offset(fixedX, fromRect.center.dy);
        } else {
          // 两个方向都有缩放，计算唯一固定点
          final fixedX = tx / (1 - scaleX);
          final fixedY = ty / (1 - scaleY);
          fixedPoint = Offset(fixedX, fixedY);
        }

        // 以固定点为缩放中心进行等比缩放
        // 等比缩放变换：newPos = fixedPoint + (oldPos - fixedPoint) * uniformScale
        double newX = fixedPoint.dx + (element.x - fixedPoint.dx) * uniformScale;
        double newY = fixedPoint.dy + (element.y - fixedPoint.dy) * uniformScale;
        double newWidth = element.width * uniformScale;
        double newHeight = element.height * uniformScale;
        if(uniformScale<0){
          newWidth*=-1;
          newX -= newWidth;
        }
        if(uniformScale<0){
          newHeight*=-1;
          newY -= newHeight;
        }

        // 字体大小等比缩放
        final textElement = element as FreeformCanvasText;
        final newFontSize = textElement.fontSize * uniformScale.abs();

        return copyWith(
          element,
          x: newX,
          y: newY,
          width: newWidth,
          height: newHeight,
          fontSize: newFontSize,
        );

      case FreeformCanvasElementType.freedraw:
        // 自由绘制元素：缩放位置、尺寸和所有路径点
        final newX = toRect.left + (element.x - fromRect.left) * scaleX;
        final newY = toRect.top + (element.y - fromRect.top) * scaleY;
        final newWidth = element.width * scaleX;
        final newHeight = element.height * scaleY;

        // 缩放路径点（相对坐标）
        final freedraw = element as FreeformCanvasFreedraw;
        final scaledPoints = freedraw.points.map((point) {
          return FreeformCanvasPoint(
            point.x * scaleX,
            point.y * scaleY,
          );
        }).toList();

        return copyWith(
          element,
          x: newX,
          y: newY,
          width: newWidth.abs(),
          height: newHeight.abs(),
          points: scaledPoints,
        );

      default:
        throw ArgumentError('rectScaleElement 不支持元素类型: ${element.type}');
    }
  }

  /// **ZH** 对箭头、直线元素进行起点或终点的坐标偏移
  ///
  /// - pointIndex 为整型值，0代表变换起点
  /// 
  /// **EN** Offset the start or end point of a line or arrow element
  /// 
  /// - pointIndex is an integer value, 0 representing the start point
  static FreeformCanvasElement pointsScaleElement(
    FreeformCanvasElement element,
    int pointIndex,
    Offset offset,
  ) {
    if (element.type != FreeformCanvasElementType.line &&
        element.type != FreeformCanvasElementType.arrow) {
      throw ArgumentError('pointsScaleElement only supports line and arrow elements.');
    }

    final line = element as FreeformCanvasLine;
    if (line.points.length < 2) {
      throw ArgumentError("Element points'length must be at least 2");
    }

    // 计算所有点的绝对坐标
    final absolutePoints = line.points.map((p) {
      return Offset(element.x + p.x, element.y + p.y);
    }).toList();

    // 对指定点应用偏移
    absolutePoints[pointIndex] = absolutePoints[pointIndex] + offset;

    // 计算新的边界
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final point in absolutePoints) {
      if (point.dx < minX) minX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy > maxY) maxY = point.dy;
    }

    final newX = minX;
    final newY = minY;
    final newWidth = maxX - minX;
    final newHeight = maxY - minY;

    // 计算新的相对坐标（相对于新的原点）
    final newPoints = absolutePoints.map((p) {
      return FreeformCanvasPoint(p.dx - newX, p.dy - newY);
    }).toList();

    return copyWith(
      element,
      x: newX,
      y: newY,
      width: newWidth,
      height: newHeight,
      points: newPoints,
    );
  }
  ///**ZH** 从点列表创建freedraw元素
  ///
  ///**EN** Create a freedraw element from a list of points
  static FreeformCanvasFreedraw createFreedraw(Iterable<Offset> points) {
    assert(points.isNotEmpty);
    // 计算新点的相对坐标（相对于元素起点）
    final x = points.first.dx;
    final y = points.first.dy;

    // 创建点列表
    List<FreeformCanvasPoint> newPoints = [];
    for(var point in points){
      newPoints.add(FreeformCanvasPoint(point.dx-x, point.dy-y));
    }

    // 计算新的边界（基于所有点）
    double minX = 0.0;  // 第一个点始终是 [0, 0]
    double maxX = 0.0;
    double minY = 0.0;
    double maxY = 0.0;

    for (final point in newPoints) {
      minX = min(minX, point.x);
      maxX = max(maxX, point.x);
      minY = min(minY, point.y);
      maxY = max(maxY, point.y);
    }

    final width = maxX - minX;
    final height = maxY - minY;

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    return FreeformCanvasFreedraw(
      id: id,
      index: '00',
      x: x,
      y: y,
      width: width,
      height: height,
      angle: 0.0,
      strokeColor: FreeformCanvasColor.black(),
      backgroundColor: FreeformCanvasColor.transparent(),
      fillStyle: 'solid',
      strokeWidth: 2.0,
      strokeStyle: 'solid',
      roughness: 0.0,
      opacity: 100.0,
      locked: false,
      groupIds: [],
      frameId: null,
      boundElements: null,
      link: null,
      version: null,
      versionNonce: null,
      seed: null,
      updated: null,
      points: newPoints,
      pressures: null,
      simulatePressure: true,
    );
  }

  /// **ZH** 向现有的自由绘制草稿元素添加点
  /// 
  /// **EN** Add a point to the existing free drawing draft element
  static FreeformCanvasFreedraw addPointToFreeDrawDraft(
    FreeformCanvasFreedraw element,
    Offset newCanvasPoint,
  ) {
    // 计算新点的相对坐标（相对于元素起点）
    final relativeX = newCanvasPoint.dx - element.x;
    final relativeY = newCanvasPoint.dy - element.y;

    // 创建新的点列表（包含所有现有点和新点）
    final newPoints = List<FreeformCanvasPoint>.from(element.points)
      ..add(FreeformCanvasPoint(relativeX, relativeY));

    // 计算新的边界（基于所有点）
    double minX = 0.0;  // 第一个点始终是 [0, 0]
    double maxX = 0.0;
    double minY = 0.0;
    double maxY = 0.0;

    for (final point in newPoints) {
      minX = min(minX, point.x);
      maxX = max(maxX, point.x);
      minY = min(minY, point.y);
      maxY = max(maxY, point.y);
    }

    final newWidth = maxX - minX;
    final newHeight = maxY - minY;

    return ElementOps.copyWith(
      element,
      width: newWidth,
      height: newHeight,
      points: newPoints
    ) as FreeformCanvasFreedraw;
  }

  static FreeformCanvasElement applyStylePatch(ElementStylePatch patch, FreeformCanvasElement element) {
    return ElementOps.copyWith(
      element,
      strokeColor: patch.strokeColor ?? _Unset(),
      backgroundColor: patch.backgroundColor ?? _Unset(),
      fillStyle: patch.fillStyle ?? _Unset(),
      strokeWidth: patch.strokeWidth ?? _Unset(),
      strokeStyle: patch.strokeStyle ?? _Unset(),
      roughness: patch.roughness ?? _Unset(),
      opacity: patch.opacity ?? _Unset(),
      roundness: patch.roundness is Set ? (patch.roundness as Set).value : _Unset(),
      fontSize: patch.fontSize ?? _Unset(),
      fontFamily: patch.fontFamily ?? _Unset(),
      textAlign: patch.textAlign ?? _Unset(),
    );
  }
}

/// **ZH** 哨兵类，用于区分“不修改字段”和“将字段设为 null”
/// 
/// **EN** Sentinel class used to distinguish between "don't modify the field" and "set the field to null"
class _Unset {
  const _Unset();

  @override
  String toString() => '_Unset()';
}