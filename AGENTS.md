# AGENTS.md

此文件提供项目上下文信息，用于指导 AI Agent 在此项目中工作时做出正确的决策。

## 项目概述

**项目名称**: freeform_canvas  
**项目类型**: Flutter 白板编辑器库  
**当前版本**: 0.2026.3  
**主要技术**: Flutter (SDK ^3.8.1)  
**许可证**: Apache 2.0  

### 项目描述

freeform_canvas 是一个类 Excalidraw 的白板编辑器，使用 Flutter 构建。它提供兼容 Excalidraw 的白板编辑器架构，更关注可扩展性而非 1:1 复刻。

*注意：本项目不是官方 Excalidraw 项目，不使用也不包含任何 Excalidraw 源代码。*

**核心特征**:
- **单一数据源 (SSOT) 架构**: EditorState 作为唯一状态源
- **丰富的元素支持**: 矩形、菱形、椭圆、箭头、直线、自由绘制、文本、嵌入内容 (embeddable)
- **多设备支持**: 电脑桌面、墨水屏平板、平板、手机等多种交互方式
- **插件式架构**: 渲染器、交互器、覆盖层可分别自定义
- **文件格式支持**: 支持 `.excalidraw` 文件格式的多数字段
- **Undo/Redo**: 完整的撤销/重做支持
- **自定义嵌入元素**: 支持创建任意类型的嵌入元素，并提供自定义渲染器
- **国际化支持**: 支持英文和简体中文双语

### 设计目标

> 还原诸多 Excalidraw 的编辑行为、支持 .excalidraw 文件，适配墨水屏、电脑桌面、手机桌面、平板等诸多交互风格，同时保持系统极高的可拓展、可定制。

## 快速开始

### 安装依赖

在 `pubspec.yaml` 中添加：

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

### 基本使用

**Windows 桌面编辑器**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/freeform_canvas_parser.dart';
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';
import 'package:freeform_canvas/windows_freeform_canvas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = EditorState(
      file: FreeformCanvasParser.parseFromString(jsonString),
    );

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      home: Scaffold(
        body: WindowsFreeformCanvas(
          editorState: editorState,
          onSave: (file) {
            print('保存文件: ${file.toJson()}');
          },
        ),
      ),
    );
  }
}
```

**墨水屏编辑器**:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';
import 'package:freeform_canvas/e_ink_freeform_canvas.dart';
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final editorState = EditorState(
      file: FreeformCanvasFileOps.emptyFile(),
    );

    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('zh', ''),
      ],
      home: Scaffold(
        body: EInkFreeformCanvas(
          editorState: editorState,
          onSave: (file) {
            print('保存文件: ${file.toJson()}');
          },
        ),
      ),
    );
  }
}
```

## 项目结构

```
lib/
├── application/              # 应用层 - 编辑器组件
│   ├── freeform_canvas_viewer.dart  # 核心编辑器组件
│   ├── fundamental.dart      # 基础接口定义
│   ├── interactors/          # 交互器
│   │   ├── mouse_keyboard_interactor.dart
│   │   └── stylus_aware_interactor.dart
│   └── renderers/            # 渲染器
│       ├── background_renderer.dart
│       ├── canvas_renderer.dart
│       ├── e_ink_screen_renderer.dart
│       └── text_edit_widget.dart
├── core/                     # 核心层
│   ├── editor_dependencies.dart
│   ├── editor_state.dart     # 编辑器状态管理
│   └── edit_intent_and_session/  # 编辑操作抽象
│       ├── fundamental.dart
│       ├── edit_sessions.dart
│       └── intents.dart
├── fonts/                    # 字体资源
│   └── freeform_canvas_icons.ttf
├── generated/                # 自动生成的代码
│   └── l10n/                 # 国际化代码
│       ├── app_localizations.dart
│       ├── app_localizations_en.dart
│       └── app_localizations_zh.dart
├── hit_testers/              # 命中测试
│   ├── extended_hit_tester.dart
│   └── freeform_canvas_hit_tester.dart
├── inspector/                # 检查器（选择框、控制点等）
│   ├── fundamental.dart
│   ├── inspector.dart
│   ├── modifier.dart
│   └── selector.dart
├── interaction_handlers/     # 交互处理器
│   ├── drawing_handlers.dart
│   ├── eraser_handler.dart
│   ├── interaction_handler.dart
│   ├── select_handler.dart
│   ├── stepping_transform_handler.dart
│   ├── transform_handler.dart
│   └── secondary_handlers/
├── models/                   # 数据模型
│   ├── element_style.dart
│   ├── freeform_canvas_element.dart
│   ├── freeform_canvas_file.dart
│   └── text_editing_data.dart
├── ops/                      # 操作层（元素和文件操作）
│   ├── element_ops.dart
│   └── freeform_canvas_file_ops.dart
├── overlays/                 # 覆盖层（工具栏等）
│   ├── e_ink_toolbar.dart
│   └── windows_toolbar.dart
├── painters/                 # 绘制器
│   ├── active_layer_painter.dart
│   ├── element_geometry.dart
│   └── static_layer_painter.dart
├── widgets/                  # 小部件
│   └── embeddable_link_edit_overlay.dart
├── custom_icons.dart
├── e_ink_freeform_canvas.dart    # 墨水屏编辑器入口
├── freeform_canvas_parser.dart   # 文件解析器
├── pure_renderer.dart            # 纯渲染器
└── windows_freeform_canvas.dart  # Windows 桌面编辑器入口
```

## 构建和运行

### 环境要求
- Flutter SDK ^3.8.1
- Dart SDK (随 Flutter 一起安装)

### 常用命令

```bash
# 运行示例应用（Windows）
flutter run -d windows

# 运行示例应用（需要指定平台）
flutter run

# 代码分析
flutter analyze

# 代码格式化
flutter format .

# 获取依赖
flutter pub get

# 生成国际化代码
flutter gen-l10n
```

### 运行示例应用

项目包含一个完整的示例应用，位于 `example/` 目录：

```bash
cd example
flutter run -d windows
```

示例应用内嵌了一个 `.excalidraw` 文件，可以直接体验编辑器效果。

## 开发约定

### 架构原则

1. **单一数据源 (SSOT)**: EditorState 是编辑器的唯一状态源，所有状态修改都应通过 EditorState 进行
2. **不可变数据结构**: 元素 (Element) 和文件数据 (FreeformCanvasFile) 是不可变的，修改操作通过 ElementOps 和 FreeformCanvasFileOps 创建新实例
3. **插件式设计**: 渲染器、交互器、覆盖层相互独立，可自由组合
4. **关注点分离**: UI 层（InteractionHandler）与业务逻辑层（EditSession/EditIntent/EditAction）分离

### 代码风格

- 使用 `flutter_lints` 进行代码检查
- 遵循 Dart 官方代码风格指南
- 优先使用 `final` 声明不可变变量
- 所有元素字段都是 `final` 类型

### 编辑操作流程

**原子操作**（如修改颜色、元素属性、删除等）:
```
Interactor → InteractionHandler → EditIntent → EditAction → EditorState
```

**长线操作**（如拖动、缩放、旋转、创建新元素）:
```
Interactor → InteractionHandler → EditSession → EditIntent → EditAction → EditorState
```

### 元素操作规范

- **禁止直接创建元素**: 所有元素创建都必须通过 `ElementOps` 类的方法
- **禁止直接修改元素**: 所有元素修改都必须通过 `ElementOps.copyWith()` 或专门的修改方法
- **文件操作**: 文件级操作通过 `FreeformCanvasFileOps` 类进行

### 重要接口

**ElementOps** (`lib/ops/element_ops.dart`):
- `copyWith()`: 复制元素并修改指定字段
- `createDraftElementFromPoints()`: 根据两点创建草稿元素
- `handleScaleElement()`: 基于控制点位移缩放元素
- `pointsScaleElement()`: 对箭头、直线元素进行起点或终点的坐标偏移
- `createFreedraw()`: 从点列表创建自由绘制元素
- `addPointToFreeDrawDraft()`: 向现有的自由绘制草稿元素添加点
- `applyStylePatch()`: 应用样式补丁到元素
- `textElementModify()`: 修改文本元素相关字段

**FreeformCanvasFileOps** (`lib/ops/freeform_canvas_file_ops.dart`):
- `addElement()`: 向文件中添加元素
- `removeElement()`: 从文件中删除元素
- `updateElement()`: 更新文件中的元素
- `moveZOrder()`: 调整元素的 Z 轴顺序
- `findElement()`: 通过 id 定位元素
- `emptyFile()`: 创建空文件

**EditorState** (`lib/core/editor_state.dart`):
- `commitIntent()`: 提交编辑意图
- `undo()`: 撤销操作
- `redo()`: 重做操作
- `newAndEnterPreview()`: 新建元素并进入预览模式
- `ensurePreviewFor()`: 确保某文档元素为预览元素
- `updatePreview()`: 更新预览元素
- `quitPreview()`: 取消预览模式
- `enterTextEdit()`: 进入文本编辑模式
- `quitTextEdit()`: 退出文本编辑模式

### 渲染架构

编辑器使用两层 CustomPaint 进行渲染：

1. **静态层 (StaticLayer)**: 绘制文件中的静态元素，更新频率低
2. **动态层 (ActiveLayer)**: 绘制草稿元素和选择框，更新频率高

### 测试约定

- TODO: 当前项目未包含测试文件
- 建议为编辑操作添加单元测试
- 建议为渲染器添加 Widget 测试

### 贡献指南

- 遵循现有的代码风格和架构模式
- 所有公共 API 应添加文档注释
- 优先实现与 Excalidraw 兼容的功能
- 欢迎新的交互模式、渲染器或平台适配
- 实验性功能也欢迎提交

## 两套编辑器组件

### 1. Windows 桌面编辑器 (`WindowsFreeformCanvas`)

- **适用场景**: Windows 桌面，键鼠交互
- **渲染器**: `CanvasRenderer`
- **交互器**: `MouseKeyboardInteractor`
- **工具栏**: `WindowsToolbar`
- **特点**: 支持大量快捷键，类似 Excalidraw 的操作逻辑

**使用示例（推荐方式）**:
```dart
// 创建 EditorState（推荐）
final editorState = EditorState(
  file: FreeformCanvasParser.parseFromString(jsonString),
  dependencies: EditorDependencies(
    embeddableRenderer: (canvas, width, height, screenPosition, element) {
      // 自定义嵌入元素的渲染逻辑
    },
  ),
);

WindowsFreeformCanvas(
  editorState: editorState,
  onSave: (file) {
    print('save...');
  },
)
```

**使用示例（简化方式）**:
```dart
WindowsFreeformCanvas(
  jsonString: data,
  onSave: (file) {
    print('save...');
  },
)
```

### 2. 墨水屏编辑器 (`EInkFreeformCanvas`)

- **适用场景**: 墨水屏设备，触控笔交互
- **渲染器**: `EInkScreenRenderer`（使用位图缓存、降分辨率、降帧率优化）
- **交互器**: `StylusAwareInteractor`（优先触控笔输入）
- **工具栏**: `EInkToolbar`（高对比度显示）
- **特点**: 针对墨水屏优化，适合书写环境

**使用示例（推荐方式）**:
```dart
// 创建 EditorState（推荐）
final editorState = EditorState(
  file: FreeformCanvasFileOps.emptyFile(),
);

EInkFreeformCanvas(
  editorState: editorState,
  onSave: (file) {
    print('save...');
  },
)
```

**使用示例（简化方式）**:
```dart
EInkFreeformCanvas(
  jsonString: FreeformCanvasFileOps.emptyFile(),
  onSave: (file) {
    print('save...');
  },
)
```

### 纯渲染器

项目还提供一个纯文件渲染函数，不包含交互功能：

```dart
Future<ui.Image> renderFile({
  String? jsonString,  // JSON 字符串格式的文件内容
  File? file,  // 文件对象
  required double Function(ui.Rect rect) scaleCalculator,  // 缩放计算函数
  EmbeddableRenderer? embeddableRenderer,  // 嵌入元素的自定义渲染器
})
```

位置: `lib/pure_renderer.dart`

**使用示例**:
```dart
final image = await renderFile(
  jsonString: fileJsonString,
  scaleCalculator: (rect) {
    // 根据矩形区域计算缩放比例
    return 2.0; // 返回缩放比例
  },
  embeddableRenderer: (canvas, width, height, screenPosition, element) {
    // 自定义嵌入元素的渲染逻辑
    // canvas: Flutter Canvas 对象，用于绘制
    // width: 元素宽度
    // height: 元素高度
    // screenPosition: 元素在屏幕上的位置（左上角坐标）
    // element: 要渲染的嵌入元素
  },
);
```

## 自定义和扩展

### 插入自定义功能

通过 `OverlaysAny` 可以轻松插入自定义按钮或组件：

```dart
FreeformCanvasViewer(
    file: file,
    jsonString: jsonString,
    renderer: renderer,
    interactor: interactor,
    overlays: [
        toolbar,
        OverlaysAny(builder_: (_, editorState) {
            return [YourCustomWidget(editorState: editorState)];
        })
    ],
)
```

### 自定义渲染器

实现 `Renderer` 接口：

```dart
class CustomRenderer extends Renderer {
    @override
    List<Widget> buildcanvas(BuildContext context, EditorState editorState) {
        // 返回渲染画布的组件列表
    }

    @override
    List<Widget> buildInteractiveOverlays(BuildContext context, EditorState editorState) {
        // 返回浮动交互组件列表
    }
}
```

### 自定义交互器

实现 `Interactor` 接口：

```dart
class CustomInteractor extends Interactor {
    @override
    Widget build(BuildContext context, EditorState editorState) {
        // 返回交互组件
    }

    @override
    List<Widget> buildOverlay(BuildContext context, EditorState editorState) {
        // 返回交互层覆盖组件
    }
}
```

### 自定义 Embeddable 渲染器

嵌入元素（embeddable）允许在画布中嵌入任意类型的内容。通过 `EditorState.embeddableRenderer` 可以自定义嵌入元素的渲染逻辑：

```dart
EditorState(
  file: file,
  dependencies: EditorDependencies(
    embeddableRenderer: (canvas, width, height, screenPosition, element) {
      // 自定义渲染逻辑
      // canvas: Flutter Canvas 对象，用于绘制
      // width: 元素宽度
      // height: 元素高度
      // screenPosition: 元素在屏幕上的位置（左上角坐标）
      // element: 要渲染的嵌入元素（FreeformCanvasEmbeddable 类型）
      
      // 示例：绘制一个简单的矩形
      final paint = Paint()..color = Colors.blue;
      canvas.drawRect(
        Rect.fromLTWH(screenPosition.dx, screenPosition.dy, width, height),
        paint,
      );
    },
  ),
)
```

**注意事项**:
- 如果不提供 `embeddableRenderer`，系统将使用默认渲染器
- 渲染器会在每次重绘时被调用，确保渲染逻辑高效
- 可以根据 `element` 的类型或属性来决定不同的渲染方式
- 支持嵌入图片、视频、图表等任意类型的内容
- 可以在 `element` 中存储自定义数据来控制渲染行为

## 文档

详细的技术文档位于 `docs/` 目录：

- `DOCUMENT_EN.md`: 英文技术文档
- `DOCUMENT_ZH.md`: 中文技术文档
- `LOCALIZATION.md`: 国际化使用说明

文档涵盖：
- 元素操作接口详解
- 元素定义和结构
- EditorState 功能说明
- 渲染方案说明
- 元素几何和命中测试
- 编辑操作信息流
- 编辑器组件架构
- ElementStyle 功能说明
- 国际化配置和使用方法

### 技术文档

**DOCUMENT_EN.md** / **DOCUMENT_ZH.md**
- 项目介绍
- ElementOps 和 FreeformCanvasFileOps：元素和文件数据操作的唯一接口
- FreeformCanvasElement：元素定义及结构
- 类型定义和枚举
- EditorState：编辑器操作集合
- 使用 CustomPaint 的绘制方案
- 元素几何和命中测试
- 编辑操作信息流
- 编辑器组件架构
- ElementStyle：元素风格默认风格和风格修改

**LOCALIZATION.md**
- 国际化使用说明
- 配置方法
- 支持的语言列表
- 翻译文件位置说明
- 添加新翻译的步骤

## 国际化 (i18n)

freeform_canvas 支持英文和简体中文双语。

### 配置方法

在应用的 `MaterialApp` 中添加国际化配置：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''),
    Locale('zh', ''),
  ],
  // locale: Locale('en', ''),  // 可选：手动指定语言

  home: YourHomePage(),
);
```

### 支持的语言

- **英文 (en)**: 默认语言
- **简体中文 (zh)**: 完整支持

### 翻译文件位置

- 英文翻译：`lib/l10n/app_en.arb`
- 简体中文翻译：`lib/l10n/app_zh.arb`
- 生成的代码：`lib/generated/l10n/`

### 注意事项

- 确保您的应用已添加 `flutter_localizations` 和 `intl` 依赖
- 所有使用国际化的 Widget 必须在 MaterialApp 内部
- 生成的国际化代码位于 `lib/generated/l10n/` 目录，该目录会被自动生成，无需手动编辑

完整示例请参考 `example/lib/main.dart`。

## 常见任务

### 添加新的元素类型

1. 在 `FreeformCanvasElementType` 枚举中添加新类型
2. 创建新的元素类继承 `FreeformCanvasElement`
3. 在 `ElementOps` 中添加创建和修改方法
4. 在 `StaticLayerPainter` 中添加绘制逻辑
5. 在相应的 `InteractionHandler` 中添加交互逻辑

### 添加新的编辑工具

1. 在 `EditorTool` 枚举中添加新工具
2. 创建对应的 `InteractionHandler` 子类
3. 如需长线操作，创建对应的 `EditSession` 子类
4. 在工具栏中添加按钮
5. 在 `Interactor` 中注册工具切换逻辑

### 添加新的渲染优化

1. 创建新的 `Renderer` 子类
2. 实现自定义的渲染逻辑（如位图缓存、增量绘制等）
3. 在编辑器组件中使用新的渲染器

### 添加新的覆盖层组件

1. 创建 `Overlays` 子类或使用 `OverlaysAny`
2. 实现 `builder()` 方法
3. 在编辑器组件中注册覆盖层

### 创建和使用嵌入元素

嵌入元素允许在画布中嵌入任意类型的内容（如图片、视频、自定义组件等）。

**创建嵌入元素**:
```dart
// 使用 embeddable 工具创建嵌入元素
// 元素类型为 FreeformCanvasElementType.embeddable
```

**自定义嵌入元素渲染**:
```dart
EditorState(
  file: file,
  dependencies: EditorDependencies(
    embeddableRenderer: (canvas, width, height, screenPosition, element) {
      // 根据元素的属性进行不同的渲染
      // 可以嵌入图片、视频、图表等任意内容
    },
  ),
)
```

**编辑嵌入元素**:
- 嵌入元素支持移动、缩放、旋转等基本操作
- 可以通过 `embeddable` 工具选择和编辑嵌入元素
- 双击嵌入元素可以触发自定义编辑行为（需在交互处理器中实现）

## 注意事项

1. **不要直接修改元素**: 始终使用 `ElementOps` 提供的方法
2. **不要直接修改文件**: 始终使用 `FreeformCanvasFileOps` 提供的方法
3. **状态管理**: 所有状态变更都应通过 `EditorState` 进行
4. **文本编辑特殊处理**: 文本编辑是编辑器级别的模式，使用 `enterTextEdit()` 和 `quitTextEdit()` 管理
5. **预览模式**: 创建和修改元素时使用预览模式，避免直接修改文件
6. **Undo/Redo**: 所有可撤销的操作都应实现 `EditIntent` 和 `EditAction`
7. **国际化配置**: 使用编辑器时需要配置 `flutter_localizations`，确保编辑器组件在 `MaterialApp` 内部使用
8. **生成国际化代码**: 修改翻译文件后需要运行 `flutter gen-l10n` 重新生成国际化代码

## 平台支持

- **Windows**: 完整支持，使用 `WindowsFreeformCanvas`
- **墨水屏**: 完整支持，使用 `EInkFreeformCanvas`
- **Android/iOS**: 基础支持，可使用 `FreeformCanvasViewer` 自定义
- **Linux/macOS**: 基础支持，可使用 `FreeformCanvasViewer` 自定义

## 依赖项

主要依赖：
- `flutter`: Flutter SDK
- `cupertino_icons`: ^1.0.8 (iOS 风格图标)
- `url_launcher`: ^6.3.2 (启动外部链接)
- `flutter_localizations`: Flutter SDK (国际化支持)
- `intl`: any (国际化工具)

开发依赖：
- `flutter_test`: Flutter 测试框架
- `flutter_lints`: ^5.0.0 (代码检查规则)

### 字体资源

项目使用自定义字体 `freeform_canvas_icons.ttf`，需要在 `pubspec.yaml` 中配置：

```yaml
flutter:
  uses-material-design: true
  fonts:
    - family: freeform_canvas_icons
      fonts:
        - asset: lib/fonts/freeform_canvas_icons.ttf
```

## 许可证

Apache License 2.0

本项目采用 Apache 2.0 许可证，允许：
- 商业使用
- 修改
- 分发
- 私有使用
- 专利使用

详细许可条款请参见 [LICENSE](LICENSE) 文件。

## 联系方式

- GitHub: https://github.com/operator000/freeform_canvas
- Issues: 通过 GitHub Issues 提交问题和建议
- Pull Requests: 欢迎提交代码贡献

## 项目状态

本项目主要用于满足作者的个人使用场景，可能不会作为一个长期产品进行积极维护。

然而，**freeform_canvas** 的一个核心目标是探索高度可扩展的编辑器架构，特别是针对多样化的交互场景（鼠标、触摸、触控笔、墨水屏等）。

即使核心功能集保持相对稳定，架构也故意设计为开放扩展。我相信通过不同的交互模型、渲染器或平台适配，这个编辑器可以向许多有趣的方向发展。

欢迎贡献、实验和 Fork。如果您实现的功能或扩展可能超出您自己的使用场景，鼓励您考虑通过 Pull Request 将其贡献回来。

各种类型的贡献都非常欢迎——包括错误修复、重构、性能改进、文档和新功能。

如果您计划 Fork 此项目以添加您自己的功能或特定平台支持，强烈建议您考虑通过 Pull Request 将这些改进贡献回来。即使是部分或实验性实现也是受欢迎的，只要它们有助于推动项目前进。

我相信这个项目可以通过共享想法和协作变得更好。如果您感兴趣，欢迎提出 Issue、开始讨论或提交 PR。