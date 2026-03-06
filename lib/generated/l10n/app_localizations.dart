import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Label for color picker
  ///
  /// In en, this message translates to:
  /// **'Pick Color'**
  String get pickColor;

  /// Message shown when default value is not supported for a tool
  ///
  /// In en, this message translates to:
  /// **'Default value not supported'**
  String get defaultValueNotSupported;

  /// Label for start arrowhead selector
  ///
  /// In en, this message translates to:
  /// **'Start Arrowhead'**
  String get startArrowhead;

  /// Label for end arrowhead selector
  ///
  /// In en, this message translates to:
  /// **'End Arrowhead'**
  String get endArrowhead;

  /// Label for stroke color
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get strokeColor;

  /// Label for background color
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get backgroundColor;

  /// Label for corner style
  ///
  /// In en, this message translates to:
  /// **'Corner'**
  String get cornerStyle;

  /// Sharp corner style
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get sharp;

  /// Round corner style
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Label for stroke style
  ///
  /// In en, this message translates to:
  /// **'Stroke Style'**
  String get strokeStyle;

  /// Solid line style
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solid;

  /// Dashed line style
  ///
  /// In en, this message translates to:
  /// **'Dashed'**
  String get dashed;

  /// Dotted line style
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get dotted;

  /// Label for line sloppiness/roughness
  ///
  /// In en, this message translates to:
  /// **'Sloppiness'**
  String get sloppiness;

  /// Architect drawing style
  ///
  /// In en, this message translates to:
  /// **'Architect'**
  String get architect;

  /// Artist drawing style
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// Cartoonist drawing style
  ///
  /// In en, this message translates to:
  /// **'Cartoonist'**
  String get cartoonist;

  /// Label for stroke width
  ///
  /// In en, this message translates to:
  /// **'Stroke Width'**
  String get strokeWidth;

  /// Thin stroke width
  ///
  /// In en, this message translates to:
  /// **'Thin'**
  String get thin;

  /// Bold stroke width
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get bold;

  /// Extra bold stroke width
  ///
  /// In en, this message translates to:
  /// **'Extra Bold'**
  String get extraBold;

  /// Label for fill style
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get fillStyle;

  /// Hachure fill style
  ///
  /// In en, this message translates to:
  /// **'Hachure'**
  String get hachure;

  /// Cross-hatch fill style
  ///
  /// In en, this message translates to:
  /// **'Cross-hatch'**
  String get crossHatch;

  /// Solid fill style
  ///
  /// In en, this message translates to:
  /// **'Solid'**
  String get solidFill;

  /// Label for layer operations
  ///
  /// In en, this message translates to:
  /// **'Layer'**
  String get layer;

  /// Send to back layer operation
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get sendToBack;

  /// Send backward layer operation
  ///
  /// In en, this message translates to:
  /// **'Backward'**
  String get sendBackward;

  /// Bring forward layer operation
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get bringForward;

  /// Bring to front layer operation
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get bringToFront;

  /// Label for element operations
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get operations;

  /// Delete operation
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for font family
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontFamily;

  /// Default font family
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultFont;

  /// Handwriting font family
  ///
  /// In en, this message translates to:
  /// **'Handwriting'**
  String get handwriting;

  /// Monospace font family
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get monospace;

  /// Serif font family
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get serif;

  /// Label for font size
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Small font size
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// Medium font size
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Large font size
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// Extra large font size
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get extraLarge;

  /// Label for text alignment
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get textAlign;

  /// Left text alignment
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// Center text alignment
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get center;

  /// Right text alignment
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// Label for arrowhead type
  ///
  /// In en, this message translates to:
  /// **'Arrowhead'**
  String get arrowhead;

  /// No arrowhead
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Arrow arrowhead type
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get arrow;

  /// Filled triangle arrowhead type
  ///
  /// In en, this message translates to:
  /// **'Filled Triangle'**
  String get filledTriangle;

  /// Hollow triangle arrowhead type
  ///
  /// In en, this message translates to:
  /// **'Hollow Triangle'**
  String get hollowTriangle;

  /// Label for arrow type
  ///
  /// In en, this message translates to:
  /// **'Arrow Type'**
  String get arrowType;

  /// Curved arrow type
  ///
  /// In en, this message translates to:
  /// **'Curved'**
  String get curved;

  /// Elbowed arrow type
  ///
  /// In en, this message translates to:
  /// **'Elbowed'**
  String get elbowed;

  /// Placeholder for link input field
  ///
  /// In en, this message translates to:
  /// **'Enter link...'**
  String get enterLink;

  /// Error message when loading file fails
  ///
  /// In en, this message translates to:
  /// **'Load .excalidraw failed'**
  String get loadFailed;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Undo operation
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Redo operation
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Color label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Brightness label
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// Message when a color has no brightness variations
  ///
  /// In en, this message translates to:
  /// **'No brightness variations available for this color'**
  String get noBrightnessVariations;

  /// Hexadecimal color value label
  ///
  /// In en, this message translates to:
  /// **'Hex Value'**
  String get hexValue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
