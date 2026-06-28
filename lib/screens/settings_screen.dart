import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/user_type_card.dart';
import '../data/translations.dart';
import 'complaint_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dark  = IHTheme.isDark(context);
    final s     = AppStrings.lang(state.language);

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(title: s.settings, showBack: true, light: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [

          // ── اللغة ──────────────────────────────────────────
          _Section(title: s.language_, icon: Icons.language_rounded, context: context),
          const SizedBox(height: 12),
          _LanguageSelector(state: state, context: context),

          const SizedBox(height: 28),

          // ── نوع المستخدم ───────────────────────────────────
          _Section(title: s.userType, icon: Icons.person_outline_rounded, context: context),
          const SizedBox(height: 12),
          _UserTypeTile(state: state, context: context),

          const SizedBox(height: 28),

          // ── المظهر ─────────────────────────────────────────
          _Section(title: s.appearance, icon: Icons.palette_outlined, context: context),
          const SizedBox(height: 12),
          _ThemeToggleTile(dark: dark, state: state, context: context),

          const SizedBox(height: 28),

          // ── التواصل والإبلاغ ──────────────────────────────
          _Section(title: s.contactReport, icon: Icons.campaign_outlined, context: context),
          const SizedBox(height: 12),

          _SettingTile(
            icon: Icons.feedback_outlined,
            title: s.appComplaint,
            subtitle: s.complaintSub,
            trailing: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/complaint'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: IHTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: IHTheme.primaryShadow),
                child: Text(s.sendBtn,
                  style: AppFonts.nunito(fontSize: 12,
                    fontWeight: FontWeight.w700, color: Colors.white)))),
            context: context,
            onTap: () => Navigator.pushNamed(context, '/complaint'),
          ),

          const SizedBox(height: 10),

          _DangerTile(s: s, context: context),

          const SizedBox(height: 28),

          // ── عن التطبيق ─────────────────────────────────────
          _Section(title: s.aboutApp, icon: Icons.info_outline_rounded, context: context),
          const SizedBox(height: 12),
          _SettingTile(
            icon: Icons.info_outline_rounded,
            title: 'Iraqi Heritage',
            subtitle: s.appVersion,
            context: context,
          ),
          const SizedBox(height: 8),
          _SettingTile(
            icon: Icons.history_edu_rounded,
            title: s.aboutApp,
            subtitle: s.sitesCount,
            context: context,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final BuildContext context;
  const _Section({required this.title, required this.icon, required this.context});

  @override
  Widget build(BuildContext _) => Row(children: [
    Container(width: 3, height: 18,
      decoration: BoxDecoration(
        gradient: IHTheme.primaryGradient,
        borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 10),
    Icon(icon, size: 16, color: IHTheme.prim(context)),
    const SizedBox(width: 6),
    Text(title, style: AppFonts.lora(fontSize: 15,
      fontWeight: FontWeight.w700,
      color: IHTheme.txtPrimary(context))),
  ]);
}

// ── Language Selector ─────────────────────────────────────────────────────────
class _LanguageSelector extends StatelessWidget {
  final AppState state; final BuildContext context;
  const _LanguageSelector({required this.state, required this.context});

  @override
  Widget build(BuildContext _) => Container(
    decoration: BoxDecoration(
      color: IHTheme.card(context),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: IHTheme.bdrLight(context)),
      boxShadow: IHTheme.shadow(context)),
    child: Column(children: [
      _LangOption(
        icon: Icons.language_rounded,
        color: const Color(0xFF009900),
        name: 'العربية',
        nameEn: 'Arabic',
        code: 'ar',
        selected: state.isArabic,
        isFirst: true,
        isLast: false,
        onTap: () => state.setLanguage('ar'),
        context: context,
      ),
      Divider(height: 1, color: IHTheme.bdrLight(context)),
      _LangOption(
        icon: Icons.language_rounded,
        color: const Color(0xFF003087),
        name: 'English',
        nameEn: 'English',
        code: 'en',
        selected: state.isEnglish,
        isFirst: false,
        isLast: false,
        onTap: () => state.setLanguage('en'),
        context: context,
      ),
      Divider(height: 1, color: IHTheme.bdrLight(context)),
      _LangOption(
        icon: Icons.language_rounded,
        color: const Color(0xFFE8B84B),
        name: 'کوردی',
        nameEn: 'Kurdish',
        code: 'ku',
        selected: state.isKurdish,
        isFirst: false,
        isLast: true,
        onTap: () => state.setLanguage('ku'),
        context: context,
      ),
    ]),
  );
}

class _LangOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name, nameEn, code;
  final bool selected, isFirst, isLast;
  final VoidCallback onTap;
  final BuildContext context;
  const _LangOption({
    required this.icon, required this.color,
    required this.name, required this.nameEn,
    required this.code, required this.selected,
    required this.isFirst, required this.isLast,
    required this.onTap, required this.context,
  });

  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected
          ? IHTheme.prim(context).withValues(alpha: .08)
          : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(18) : Radius.zero,
          bottom: isLast ? const Radius.circular(18) : Radius.zero)),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? .15 : .08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: selected ? .4 : .15),
              width: 1.5)),
          child: Center(
            child: Icon(icon, size: 18,
              color: selected ? color : color.withValues(alpha: .6)))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(name, style: AppFonts.lora(fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected
              ? IHTheme.prim(context)
              : IHTheme.txtPrimary(context))),
          Text(nameEn, style: AppFonts.nunito(fontSize: 11,
            color: IHTheme.txtMuted(context))),
        ])),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? IHTheme.prim(context) : Colors.transparent,
            border: Border.all(
              color: selected
                ? IHTheme.prim(context)
                : IHTheme.bdr(context),
              width: 2)),
          child: selected
            ? const Icon(Icons.check_rounded,
                color: Colors.white, size: 14)
            : null),
      ]),
    ),
  );
}

// ── User Type Tile ────────────────────────────────────────────────────────────
class _UserTypeTile extends StatelessWidget {
  final AppState state; final BuildContext context;
  const _UserTypeTile({required this.state, required this.context});

  @override
  Widget build(BuildContext _) {
    final hasType = state.userType != null;
    final s = AppStrings.lang(state.language);

    return GestureDetector(
      onTap: () => showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: .65),
        transitionDuration: const Duration(milliseconds: 400),
        transitionBuilder: (_, anim, __, child) => ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child)),
        pageBuilder: (_, __, ___) => const UserTypeCard(),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasType
              ? IHTheme.prim(context).withValues(alpha: .3)
              : IHTheme.bdrLight(context)),
          boxShadow: IHTheme.shadow(context)),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              gradient: hasType ? IHTheme.primaryGradient : null,
              color: hasType ? null : IHTheme.surf(context),
              borderRadius: BorderRadius.circular(13)),
            child: Center(child: Icon(
              hasType
                ? (state.isIraqi ? Icons.flag_rounded : Icons.flight_rounded)
                : Icons.help_outline_rounded,
              color: hasType ? Colors.white : IHTheme.txtMuted(context),
              size: 24))),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(s.userType, style: AppFonts.nunito(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: IHTheme.txtPrimary(context))),
            Text(
              hasType
                ? (state.isIraqi ? s.iraqiUser : s.touristUser)
                : s.userTypePrompt,
              style: AppFonts.nunito(fontSize: 11,
                color: hasType
                  ? IHTheme.prim(context)
                  : IHTheme.txtMuted(context))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: IHTheme.prim(context).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: IHTheme.prim(context).withValues(alpha: .2))),
            child: Text(s.changeBtn, style: AppFonts.nunito(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: IHTheme.prim(context)))),
        ]),
      ),
    );
  }
}

// ── Setting Tile ──────────────────────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final BuildContext context;
  final VoidCallback? onTap;
  const _SettingTile({required this.icon, required this.title,
    required this.subtitle, this.trailing, required this.context,
    this.onTap});

  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IHTheme.bdrLight(context)),
        boxShadow: IHTheme.shadow(context)),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: IHTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(title, style: AppFonts.nunito(fontSize: 14,
            fontWeight: FontWeight.w700,
            color: IHTheme.txtPrimary(context))),
          Text(subtitle, style: AppFonts.nunito(fontSize: 11,
            color: IHTheme.txtMuted(context))),
        ])),
        if (trailing != null) trailing!
        else if (onTap != null)
          Icon(Icons.chevron_left_rounded,
            color: IHTheme.txtMuted(context), size: 20),
      ]),
    ));
}

// ── Danger Tile ───────────────────────────────────────────────────────────────
class _DangerTile extends StatelessWidget {
  final AppStrings s;
  final BuildContext context;
  const _DangerTile({required this.s, required this.context});

  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/report-site'),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF44336).withValues(alpha: .35),
          width: 1.2),
        boxShadow: [BoxShadow(
          color: const Color(0xFFF44336).withValues(alpha: .1),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF44336).withValues(alpha: .15),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFF44336).withValues(alpha: .3))),
          child: const Center(
            child: Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD32F2F), size: 24))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(s.reportSite,
            style: AppFonts.lora(fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD32F2F))),
          const SizedBox(height: 3),
          Text(s.reportSiteSub,
            style: AppFonts.nunito(fontSize: 11,
              color: const Color(0xFFF44336).withValues(alpha: .8),
              height: 1.4)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF44336).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: const Color(0xFFF44336).withValues(alpha: .3))),
          child: Text(s.reportBtn,
            style: AppFonts.nunito(fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD32F2F)))),
      ]),
    ));
}

// ── Theme Toggle Tile ─────────────────────────────────────────────────────────
class _ThemeToggleTile extends StatelessWidget {
  final bool dark;
  final AppState state;
  final BuildContext context;
  const _ThemeToggleTile({required this.dark, required this.state, required this.context});

  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: () => state.toggleTheme(),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: dark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark
            ? const Color(0xFF4A4A7A).withValues(alpha: .5)
            : const Color(0xFFE8A040).withValues(alpha: .4)),
        boxShadow: [BoxShadow(
          color: dark
            ? const Color(0xFF000033).withValues(alpha: .3)
            : const Color(0xFFE8A040).withValues(alpha: .15),
          blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [

        // أيقونة الشمس أو القمر
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(anim),
            child: ScaleTransition(scale: anim, child: child)),
          child: Container(
            key: ValueKey(dark),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: dark
                ? const Color(0xFF2D2D5E)
                : const Color(0xFFFFEDD0),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: dark
                  ? const Color(0xFF6060CC).withValues(alpha: .3)
                  : const Color(0xFFFFAA00).withValues(alpha: .4),
                blurRadius: 8, spreadRadius: 1)]),
            child: Icon(
              dark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
              color: dark ? const Color(0xFFB0B0FF) : const Color(0xFFFF9500),
              size: 26)),
        ),

        const SizedBox(width: 14),

        // النص
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              key: ValueKey('title$dark'),
              dark ? AppStrings.lang(state.language).lightMode
                   : AppStrings.lang(state.language).darkMode,
              style: AppFonts.lora(fontSize: 15,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : const Color(0xFF3A2800)))),
          const SizedBox(height: 3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              key: ValueKey('sub$dark'),
              dark ? AppStrings.lang(state.language).enableLight
                   : AppStrings.lang(state.language).enableDark,
              style: AppFonts.nunito(fontSize: 12,
                color: dark
                  ? Colors.white.withValues(alpha: .5)
                  : const Color(0xFF3A2800).withValues(alpha: .5)))),
        ])),

        // مؤشر الحالة الحالية (نجوم ليلية / أشعة شمسية)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: dark
              ? const Color(0xFF2D2D5E)
              : const Color(0xFFFFEDD0),
            borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (dark) ...[
              Container(width: 5, height: 5, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFE0E0FF))),
              const SizedBox(width: 3),
              Container(width: 3, height: 3, decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0E0FF).withValues(alpha: .5))),
              const SizedBox(width: 3),
              Container(width: 4, height: 4, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFE0E0FF))),
            ] else ...[
              Container(width: 4, height: 4, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFFFAA00))),
              const SizedBox(width: 2),
              Container(width: 6, height: 6, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFFF9500))),
              const SizedBox(width: 2),
              Container(width: 4, height: 4, decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFFFAA00))),
            ],
          ]),
        ),
      ]),
    ),
  );
}
