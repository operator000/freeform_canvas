# 国际化使用说明

## 概述

freeform_canvas 项目已支持英文和简体中文双语。项目使用 Flutter 官方的国际化方案（flutter_localizations + intl）。

## 使用方法

### 1. 在应用中配置国际化

在您的应用的 `MaterialApp` 中添加以下配置：

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
  // locale: Locale('en', ''),

  home: YourHomePage(),
);
```

### 2. 使用 FreeformCanvasViewer

正常使用 `FreeformCanvasViewer`，无需额外配置：

```dart
FreeformCanvasViewer(
  file: myFile,
  renderer: CanvasRenderer(),
  interactor: MouseKeyboardInteractor(),
  overlays: [WindowsToolbar()],
)
```

### 3. 语言切换

- **自动检测**：默认根据系统语言自动选择
- **手动指定**：在 MaterialApp 中设置 `locale` 参数

```dart
MaterialApp(
  locale: Locale('zh', ''),  // 强制使用简体中文
  // ...
)
```

## 支持的语言

- **英文 (en)**: 默认语言
- **简体中文 (zh)**: 完整支持

## 翻译文件位置

- 英文翻译：`lib/l10n/app_en.arb`
- 简体中文翻译：`lib/l10n/app_zh.arb`
- 生成的代码：`lib/generated/l10n/`

## 添加新的翻译

1. 在 `lib/l10n/app_en.arb` 中添加新的键值对
2. 在 `lib/l10n/app_zh.arb` 中添加对应的中文翻译
3. 运行 `flutter gen-l10n` 重新生成代码
4. 在代码中使用 `AppLocalizations.of(context)!.yourKey`

## 注意事项

- 确保您的应用已添加 `flutter_localizations` 和 `intl` 依赖
- 所有使用国际化的 Widget 必须在 MaterialApp 内部
- 生成的国际化代码位于 `lib/generated/l10n/` 目录，该目录会被自动生成，无需手动编辑

## 示例

完整示例请参考 `example/lib/main.dart`。
