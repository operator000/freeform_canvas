import 'package:freeform_canvas/ops/element_ops.dart';

import '../models/freeform_canvas_file.dart';
import '../models/freeform_canvas_element.dart';

/// **ZH** 定义图层（Z 轴）操作
/// 
/// **EN** Define layer (Z axis) operations
enum ZOrderAction {
  bringToFront,
  sendToBack,
  bringForward,
  sendBackward,
}

/// **ZH** 该类用于对 FreeformCanvasFile 进行文件级操作。
/// 
/// **EN** This class is used to perform file-level operations on FreeformCanvasFile.
class FreeformCanvasFileOps {
  const FreeformCanvasFileOps._();

  /// **ZH** 向文件中添加一个元素（追加到末尾）
  ///
  /// - 渲染顺序由 elements 列表决定
  /// - index 是 base-62 顺序标识，只在这里生成
  /// 
  /// **EN** Add an element to the file (append to the end)
  /// 
  /// - Rendering order is determined by the elements list
  /// - index is a base-62 order identifier, only generated here
  static FreeformCanvasFile addElement(
    FreeformCanvasFile file,
    FreeformCanvasElement element,
  ) {
    final elements = List<FreeformCanvasElement>.from(file.elements);

    final String newIndex;
    if (elements.isEmpty) {
      newIndex = '0';
    } else {
      newIndex = _nextIndex(elements.last.index);
    }

    final newElement = ElementOps.copyWith(
      element,
      index:newIndex,
      updated: DateTime.now().millisecondsSinceEpoch,
    );
    elements.add(newElement);

    return FreeformCanvasFile(
      type: file.type,
      version: file.version,
      source: file.source,
      elements: elements,
      appState: file.appState,
      files: file.files,
    );
  }

  /// **ZH** 从文件中删除一个元素
  /// 
  /// **EN** Remove an element from the file
  static FreeformCanvasFile removeElement(
    FreeformCanvasFile file,
    String elementId,
  ) {
    final elementExists = file.elements.any((element) => element.id == elementId);
    if (!elementExists) {
      return file;
    }

    final elements = file.elements.where((element) => element.id != elementId).toList();

    return FreeformCanvasFile(
      type: file.type,
      version: file.version,
      source: file.source,
      elements: elements,
      appState: file.appState,
      files: file.files,
    );
  }
  
  ///**ZH** 获取某元素的z轴位置index（即在元素列表中的index）
  ///
  ///**EN** Get the z-axis position index of an element (i.e. the index in the element list)
  static int getZOrderIndex(FreeformCanvasFile file,String elementId){
    return file.elements.indexWhere((element) => element.id == elementId);
  }

  /// **ZH** 更新文件中的某一个元素
  /// 
  /// **EN** Update an element in the file
  static FreeformCanvasFile updateElement(
    FreeformCanvasFile file,
    String elementId,
    FreeformCanvasElement Function(FreeformCanvasElement old) updater,
  ) {
    final elementIndex = file.elements.indexWhere((element) => element.id == elementId);
    if (elementIndex == -1) {
      return file;
    }

    final elements = List<FreeformCanvasElement>.from(file.elements);
    final oldElement = elements[elementIndex];
    final newElement = updater(oldElement);
    elements[elementIndex] = ElementOps.copyWith(
      newElement,
      updated: DateTime.now().millisecondsSinceEpoch,
    );

    return FreeformCanvasFile(
      type: file.type,
      version: file.version,
      source: file.source,
      elements: elements,
      appState: file.appState,
      files: file.files,
    );
  }

  /// **ZH** 调整某一个元素的 Z 轴顺序
  /// 
  /// **EN** Adjust the Z-axis order of a single element
  static FreeformCanvasFile moveZOrder(
    FreeformCanvasFile file,
    String elementId,{
    ZOrderAction? action,
    int? index,
  }) {
    final elements = List<FreeformCanvasElement>.from(file.elements);
    final elementIndex = elements.indexWhere((element) => element.id == elementId);
    if (elementIndex == -1) {
      return file;
    }

    // 根据 action 计算新位置
    int newIndex = elementIndex;
    if(action!=null){
      switch (action) {
        case ZOrderAction.bringToFront:
          newIndex = elements.length - 1;
          break;
        case ZOrderAction.sendToBack:
          newIndex = 0;
          break;
        case ZOrderAction.bringForward:
          if (elementIndex < elements.length - 1) {
            newIndex = elementIndex + 1;
          } else {
            return file; // 已在最上层，不变
          }
          break;
        case ZOrderAction.sendBackward:
          if (elementIndex > 0) {
            newIndex = elementIndex - 1;
          } else {
            return file; // 已在最下层，不变
          }
          break;
      }
    }else{
      newIndex = index!;
    }

    // 调整元素位置（只修改列表顺序，不改变 index）
    final element = elements.removeAt(elementIndex);
    elements.insert(newIndex, element);

    return FreeformCanvasFile(
      type: file.type,
      version: file.version,
      source: file.source,
      elements: elements,
      appState: file.appState,
      files: file.files,
    );
  }

  ///**ZH** 通过 id 定位 element
  ///
  ///**EN** Locate an element by id
  static FreeformCanvasElement? findElement(
    FreeformCanvasFile file,
    String elementId,
  ){
    try{
      return file.elements.firstWhere((e)=>e.id==elementId);
    }on StateError catch(_){
      return null;
    }
  }
}

String _nextIndex(String current) {
  const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final base = chars.length;

  final buffer = current.split('');
  int carry = 1;

  for (int i = buffer.length - 1; i >= 0 && carry > 0; i--) {
    final pos = chars.indexOf(buffer[i]);
    if (pos == -1) {
      throw StateError('Invalid index character: ${buffer[i]}');
    }

    final nextPos = pos + carry;
    if (nextPos < base) {
      buffer[i] = chars[nextPos];
      carry = 0;
    } else {
      buffer[i] = chars[0];
      carry = 1;
    }
  }

  if (carry > 0) {
    buffer.insert(0, chars[1]); // 相当于进位，比如 Z → 10
  }

  return buffer.join();
}

