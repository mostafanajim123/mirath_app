import 'package:flutter/material.dart';
import 'app_fonts.dart';

class IHTheme {
  // ── LIGHT COLORS ──────────────────────────────────────────
  static const Color primary       = Color(0xFFB5602F); // warm copper/terracotta
  static const Color primaryDark   = Color(0xFF7F3E1F); // deep burnt sienna
  static const Color primaryLight  = Color(0xFFE0A876); // soft amber
  static const Color secondary     = Color(0xFFC79A3C); // antique gold (Mesopotamian feel)
  static const Color tertiary      = Color(0xFF2E6E6B); // deep lapis-teal accent
  static const Color bgPrimary     = Color(0xFFFDF8F0);
  static const Color bgCard        = Color(0xFFFFFFFF);
  static const Color surface       = Color(0xFFF3E7D4);
  static const Color alternate     = Color(0xFFE8D6BB);
  static const Color textPrimary   = Color(0xFF3A2A1C);
  static const Color textSecondary = Color(0xFF5E4530);
  static const Color textMuted     = Color(0xFF947A60);
  static const Color textLight     = Color(0xFFC2AC92);
  static const Color border        = Color(0xFFE3CBA8);
  static const Color borderLight   = Color(0xFFEFDFC4);

  // ── DARK COLORS ───────────────────────────────────────────
  static const Color darkPrimary       = Color(0xFFE0A876);
  static const Color darkPrimaryDark   = Color(0xFFB5602F);
  static const Color darkPrimaryLight  = Color(0xFF7F3E1F);
  static const Color darkBgPrimary     = Color(0xFF14100B);
  static const Color darkBgCard        = Color(0xFF201810);
  static const Color darkSurface       = Color(0xFF2A1F14);
  static const Color darkAlternate     = Color(0xFF382A1B);
  static const Color darkTextPrimary   = Color(0xFFF6EADA);
  static const Color darkTextSecondary = Color(0xFFD6AE7F);
  static const Color darkTextMuted     = Color(0xFF9C8167);
  static const Color darkTextLight     = Color(0xFF6B5640);
  static const Color darkBorder        = Color(0xFF4A3623);
  static const Color darkBorderLight   = Color(0xFF3A2A1A);

  // ── GRADIENTS ────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7F3E1F), Color(0xFFB5602F), Color(0xFFC79A3C)],
    stops: [0, .55, 1],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF4A2614), Color(0xFF7F3E1F), Color(0xFFB5602F)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFFDF8F0), Color(0xFFF6ECDA)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );
  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF14100B), Color(0xFF201810)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  // ── SHADOWS ──────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: const Color(0xFFB5602F).withValues(alpha: .12),
      blurRadius: 14, offset: const Offset(0, 4)),
    BoxShadow(color: Colors.black.withValues(alpha: .05),
      blurRadius: 6, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: .3),
      blurRadius: 14, offset: const Offset(0, 4)),
    BoxShadow(color: const Color(0xFFB5602F).withValues(alpha: .1),
      blurRadius: 6, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(color: const Color(0xFFB5602F).withValues(alpha: .35),
      blurRadius: 16, offset: const Offset(0, 5)),
  ];
  static List<BoxShadow> get deepShadow => [
    BoxShadow(color: Colors.black.withValues(alpha: .14),
      blurRadius: 24, offset: const Offset(0, 8)),
  ];

  // ── TEXT HELPERS ─────────────────────────────────────────
  static TextStyle lora({double size = 16,
    FontWeight w = FontWeight.w600,
    Color color = textPrimary, double? height}) =>
    AppFonts.lora(fontSize: size, fontWeight: w,
      color: color, height: height);

  static TextStyle nunito({double size = 14,
    FontWeight w = FontWeight.w400,
    Color color = textSecondary, double? height}) =>
    AppFonts.nunito(fontSize: size, fontWeight: w,
      color: color, height: height);

  // ── LIGHT THEME ──────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bgPrimary,
    colorScheme: ColorScheme.light(
      primary: primary, secondary: secondary,
      surface: bgCard, onPrimary: Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: primary, elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: AppFonts.lora(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: Colors.white)),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    textTheme: TextTheme(
      displaySmall:   AppFonts.lora(fontSize: 36, fontWeight: FontWeight.w700, color: textPrimary, height: 1.2),
      headlineMedium: AppFonts.lora(fontSize: 26, fontWeight: FontWeight.w600, color: textPrimary, height: 1.25),
      headlineSmall:  AppFonts.lora(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, height: 1.3),
      titleMedium:    AppFonts.nunito(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
      titleSmall:     AppFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      bodyMedium:     AppFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.6),
      bodySmall:      AppFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: textMuted),
    ),
  );

  // ── DARK THEME ───────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBgPrimary,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary, secondary: secondary,
      surface: darkBgCard, onPrimary: darkBgPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBgCard, elevation: 2,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkPrimary),
      titleTextStyle: AppFonts.lora(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: darkTextPrimary)),
    cardTheme: CardThemeData(
      color: darkBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    textTheme: TextTheme(
      displaySmall:   AppFonts.lora(fontSize: 36, fontWeight: FontWeight.w700, color: darkTextPrimary, height: 1.2),
      headlineMedium: AppFonts.lora(fontSize: 26, fontWeight: FontWeight.w600, color: darkTextPrimary, height: 1.25),
      headlineSmall:  AppFonts.lora(fontSize: 22, fontWeight: FontWeight.w600, color: darkTextPrimary, height: 1.3),
      titleMedium:    AppFonts.nunito(fontSize: 17, fontWeight: FontWeight.w600, color: darkTextPrimary),
      titleSmall:     AppFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextPrimary),
      bodyMedium:     AppFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: darkTextSecondary, height: 1.6),
      bodySmall:      AppFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: darkTextMuted),
    ),
  );

  // ── CONTEXT-AWARE HELPERS ────────────────────────────────
  static Color bg(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkBgPrimary : bgPrimary;
  static Color card(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkBgCard : bgCard;
  static Color surf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;
  static Color alt(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkAlternate : alternate;
  static Color txtPrimary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;
  static Color txtSecondary(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;
  static Color txtMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkTextMuted : textMuted;
  static Color bdr(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkBorder : border;
  static Color bdrLight(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkBorderLight : borderLight;
  static Color prim(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkPrimary : primary;
  static Color primLight(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? darkPrimaryLight : primaryLight;
  static bool isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
  static List<BoxShadow> shadow(BuildContext context) =>
    isDark(context) ? darkCardShadow : cardShadow;
}
