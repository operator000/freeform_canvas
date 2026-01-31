# freeform_canvas

![Flutter](https://img.shields.io/badge/flutter-3.32-blue)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)
![GitHub stars](https://img.shields.io/github/stars/operator000/freeform_canvas?style=social)
![GitHub forks](https://img.shields.io/github/forks/operator000/freeform_canvas?style=social)

**Read this in other languages:** [English](README_en.md) | [中文](README.md)

## 项目介绍
本项目
freeform_canvas 是一个 **类 Excalidraw 白板编辑器**，旨在提供一个兼容 Excalidraw 的 flutter 白板编辑器架构，更关注可扩展性而非1：1复刻。

*注意：本项目并非 Excalidraw 官方项目，不使用、也不包含 Excalidraw 的任何源码*

freeform_canvas 的核心特征包括：

* Single Source of Truth（SSOT）架构（EditorState 作为唯一状态源）
* 支持丰富元素的创建、编辑，支持undo/redo
* 支持电脑桌面、墨水屏平板、平板、手机等多种交互方式，并可重写交互类
* 编辑器具有插件式结构，渲染器、交互器、覆盖层可分别自定义
* 支持`.excalidraw`文件格式的多数字段

设计目标之一是：

> **还原诸多 Excalidraw 的编辑行为、支持.excalidraw文件，适配墨水屏、电脑桌面、手机桌面、平板等诸多交互风格，同时保持系统极高的可拓展、可定制。**

## 快速开始

在pubspec.yaml添加内容如下
```yaml
dependencies:
  freeform_canvas:
    git:
      url: https://github.com/operator000/freeform_canvas.git
flutter:
  uses-material-design: true
  fonts:
    - family: freeform_canvas_icons
      fonts:
        - asset: packages/freeform_canvas/fonts/freeform_canvas_icons.ttf
```

本项目提供“两个”编辑器：
- 一个专为电脑桌面、键鼠交互设计
- 一个专为墨水屏、触控笔交互设计

```dart
WindowsFreeformCanvas(
    jsonString: data,
    onSave: (file) {
    print('save...');
    },
)
```
```dart
EInkFreeformCanvas(
    jsonString: FreeformCanvasFileOps.emptyFile(),
    onSave: (file) {
    print('save...');
    },
)
```
之所以称之为“两个”，是因为编辑器架构是插件式的，上述两个编辑器核心相同，但交互逻辑和渲染逻辑完全不同。

在`example\lib\main.dart`还有一个完整的flutter app，内嵌一个示例.excalidraw文件，可以直接在Windows上运行并体验编辑器效果。

![example app](image.png)

对于适配墨水屏的编辑器，其运行效果如下：

<img src="image2.png" style="max-width:  90vmin;max-height: 90vmin;"></img>

## 详细文档
编辑器源码的详细介绍，如编辑器组件架构、编辑操作信息流，参阅[中文文档](docs/DOCUMENT_ZH.md)或[英文文档](docs/DOCUMENT_EN.md)。

该文档在开发中也可以作为编码agent的参考文档。

## 状态说明
这是一个个人项目，更新节奏随缘，不保证稳定 API