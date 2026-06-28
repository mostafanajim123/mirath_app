// ══════════════════════════════════════════════════════════════════════════════
//  APP FONTS — خطوط محلية مدمجة بالتطبيق (بديل offline لحزمة google_fonts)
//  كل الخطوط هنا مرفقة كملفات .ttf داخل assets/fonts ومسجّلة بـ pubspec.yaml
//  لذلك ماكو أي اتصال إنترنت مطلوب لتحميل أو عرض الخطوط — تشتغل 100% أوفلاين.
// ══════════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  static TextStyle _style({
    required String family,
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final base = textStyle ?? const TextStyle();
    return base.copyWith(
      fontFamily: family,
      color: foreground == null ? (color ?? base.color) : null,
      backgroundColor: background == null ? backgroundColor : null,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
  }

  static TextStyle nunito({
    TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? wordSpacing, TextBaseline? textBaseline, double? height, Locale? locale,
    Paint? foreground, Paint? background, List<Shadow>? shadows,
    List<FontFeature>? fontFeatures, TextDecoration? decoration,
    Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness,
  }) => _style(family: 'Nunito', textStyle: textStyle, color: color,
      backgroundColor: backgroundColor, fontSize: fontSize, fontWeight: fontWeight,
      fontStyle: fontStyle, letterSpacing: letterSpacing, wordSpacing: wordSpacing,
      textBaseline: textBaseline, height: height, locale: locale, foreground: foreground,
      background: background, shadows: shadows, fontFeatures: fontFeatures,
      decoration: decoration, decorationColor: decorationColor,
      decorationStyle: decorationStyle, decorationThickness: decorationThickness);

  static TextStyle lora({
    TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? wordSpacing, TextBaseline? textBaseline, double? height, Locale? locale,
    Paint? foreground, Paint? background, List<Shadow>? shadows,
    List<FontFeature>? fontFeatures, TextDecoration? decoration,
    Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness,
  }) => _style(family: 'Lora', textStyle: textStyle, color: color,
      backgroundColor: backgroundColor, fontSize: fontSize, fontWeight: fontWeight,
      fontStyle: fontStyle, letterSpacing: letterSpacing, wordSpacing: wordSpacing,
      textBaseline: textBaseline, height: height, locale: locale, foreground: foreground,
      background: background, shadows: shadows, fontFeatures: fontFeatures,
      decoration: decoration, decorationColor: decorationColor,
      decorationStyle: decorationStyle, decorationThickness: decorationThickness);

  static TextStyle amiri({
    TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? wordSpacing, TextBaseline? textBaseline, double? height, Locale? locale,
    Paint? foreground, Paint? background, List<Shadow>? shadows,
    List<FontFeature>? fontFeatures, TextDecoration? decoration,
    Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness,
  }) => _style(family: 'Amiri', textStyle: textStyle, color: color,
      backgroundColor: backgroundColor, fontSize: fontSize, fontWeight: fontWeight,
      fontStyle: fontStyle, letterSpacing: letterSpacing, wordSpacing: wordSpacing,
      textBaseline: textBaseline, height: height, locale: locale, foreground: foreground,
      background: background, shadows: shadows, fontFeatures: fontFeatures,
      decoration: decoration, decorationColor: decorationColor,
      decorationStyle: decorationStyle, decorationThickness: decorationThickness);

  static TextStyle amiriQuran({
    TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? wordSpacing, TextBaseline? textBaseline, double? height, Locale? locale,
    Paint? foreground, Paint? background, List<Shadow>? shadows,
    List<FontFeature>? fontFeatures, TextDecoration? decoration,
    Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness,
  }) => _style(family: 'AmiriQuran', textStyle: textStyle, color: color,
      backgroundColor: backgroundColor, fontSize: fontSize, fontWeight: fontWeight,
      fontStyle: fontStyle, letterSpacing: letterSpacing, wordSpacing: wordSpacing,
      textBaseline: textBaseline, height: height, locale: locale, foreground: foreground,
      background: background, shadows: shadows, fontFeatures: fontFeatures,
      decoration: decoration, decorationColor: decorationColor,
      decorationStyle: decorationStyle, decorationThickness: decorationThickness);

  static TextStyle cairo({
    TextStyle? textStyle, Color? color, Color? backgroundColor, double? fontSize,
    FontWeight? fontWeight, FontStyle? fontStyle, double? letterSpacing,
    double? wordSpacing, TextBaseline? textBaseline, double? height, Locale? locale,
    Paint? foreground, Paint? background, List<Shadow>? shadows,
    List<FontFeature>? fontFeatures, TextDecoration? decoration,
    Color? decorationColor, TextDecorationStyle? decorationStyle, double? decorationThickness,
  }) => _style(family: 'Cairo', textStyle: textStyle, color: color,
      backgroundColor: backgroundColor, fontSize: fontSize, fontWeight: fontWeight,
      fontStyle: fontStyle, letterSpacing: letterSpacing, wordSpacing: wordSpacing,
      textBaseline: textBaseline, height: height, locale: locale, foreground: foreground,
      background: background, shadows: shadows, fontFeatures: fontFeatures,
      decoration: decoration, decorationColor: decorationColor,
      decorationStyle: decorationStyle, decorationThickness: decorationThickness);
}
