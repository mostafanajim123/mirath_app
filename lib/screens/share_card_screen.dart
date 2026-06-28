import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../data/translations.dart';
import '../widgets/common_widgets.dart';

class ShareCardScreen extends StatefulWidget {
  final Site site;
  const ShareCardScreen({super.key, required this.site});

  @override State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _cardKey = GlobalKey();
  int _selectedStyle = 0;
  bool _sharing = false;

  final _styles = <Map<String, Object>>[
    {'label': 'Classic', 'icon': Icons.auto_awesome_outlined},
    {'label': 'Gold',    'icon': Icons.star_outline_rounded},
    {'label': 'Night',   'icon': Icons.nightlight_round},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(
        title: 'مشاركة الموقع', showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TextButton.icon(
              onPressed: _sharing ? null : _shareCard,
              icon: _sharing
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share_rounded, color: Colors.white, size: 18),
              label: Text(AppStrings.lang(context.read<AppState>().language).share, style: AppFonts.nunito(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Style selector
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_styles.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => setState(() => _selectedStyle = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _selectedStyle == i
                      ? IHTheme.primaryGradient : null,
                    color: _selectedStyle == i
                      ? null : IHTheme.card(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedStyle == i
                        ? Colors.transparent
                        : IHTheme.bdr(context)),
                    boxShadow: _selectedStyle == i
                      ? IHTheme.primaryShadow : []),
                  child: Text(
                    '${_styles[i]['label']}',
                    style: AppFonts.nunito(fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _selectedStyle == i
                        ? Colors.white
                        : IHTheme.txtSecondary(context))),
                ),
              ),
            )),
          ),
        ),

        // Card preview
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: RepaintBoundary(
            key: _cardKey,
            child: _buildCard(context),
          ),
        ))),

        // Share button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: IHButton(
            label: _sharing ? AppStrings.lang(context.read<AppState>().language).sending : AppStrings.lang(context.read<AppState>().language).share,
            onTap: _sharing ? () {} : _shareCard,
            icon: Icons.share_rounded,
          ),
        ),
      ]),
    );
  }

  Widget _buildCard(BuildContext context) {
    final site = widget.site;
    switch (_selectedStyle) {
      case 1: return _GoldenCard(site: site);
      case 2: return _NightCard(site: site);
      default: return _ClassicCard(site: site);
    }
  }

  Future<void> _shareCard() async {
    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/mirath_${site.id}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '🏛️ ${site.name}\n'
          '📍 ${site.city} · ${site.civilization}\n'
          '${site.isUnesco ? "🌍 موقع يونسكو للتراث العالمي\n" : ""}'
          '\nاكتشف تراث العراق على تطبيق mirath',
      );

      if (mounted) {
        context.read<AppState>().incrementShare();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت المشاركة! 🎉',
              style: AppFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: IHTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذّرت المشاركة: $e')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Site get site => widget.site;
}

// ── CARD STYLE 1: CLASSIC ─────────────────────────────────────────────────────
class _ClassicCard extends StatelessWidget {
  final Site site;
  const _ClassicCard({required this.site});

  @override
  Widget build(BuildContext context) => Container(
    width: 340, height: 420,
    decoration: BoxDecoration(
      color: const Color(0xFF2A1A0A),
      borderRadius: BorderRadius.circular(24),
      boxShadow: IHTheme.deepShadow,
    ),
    child: Column(children: [
      // Image
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(children: [
          IHImage(url: site.imageUrl, width: 340, height: 220),
          // Gradient overlay
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent,
                const Color(0xFF2A1A0A).withValues(alpha: .9)])))),
          // UNESCO badge
          if (site.isUnesco)
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: IHTheme.primary,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                    color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(AppStrings.lang(context.read<AppState>().language).unescoLabel, style: AppFonts.nunito(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: Colors.white)),
                ]))),
          // Site name on image
          Positioned(bottom: 12, left: 14, right: 14,
            child: Text(site.name, style: AppFonts.lora(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [const Shadow(blurRadius: 8,
                color: Colors.black)]))),
        ]),
      ),
      // Info
      Expanded(child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(children: [
            const Icon(Icons.location_on_rounded,
              color: IHTheme.primaryLight, size: 14),
            const SizedBox(width: 4),
            Text('${site.city} · ${site.governorate}',
              style: AppFonts.nunito(fontSize: 12,
                color: IHTheme.primaryLight)),
          ]),
          const SizedBox(height: 6),
          Text(site.description, style: AppFonts.nunito(
            fontSize: 11, color: Colors.white70, height: 1.5),
            maxLines: 3, overflow: TextOverflow.ellipsis),
          const Spacer(),
          // Footer
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: IHTheme.primaryLight.withValues(alpha: .4)),
                borderRadius: BorderRadius.circular(8)),
              child: Text(site.civilization, style: AppFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: IHTheme.primaryLight))),
            const Spacer(),
            Text('mirath 🏛️', style: AppFonts.lora(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: IHTheme.primaryLight)),
          ]),
          const SizedBox(height: 12),
        ]),
      )),
    ]),
  );
}

// ── CARD STYLE 2: GOLDEN ─────────────────────────────────────────────────────
class _GoldenCard extends StatelessWidget {
  final Site site;
  const _GoldenCard({required this.site});

  @override
  Widget build(BuildContext context) => Container(
    width: 340, height: 420,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A0F00), Color(0xFF3D2200), Color(0xFF1A0F00)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: .5),
        width: 1.5),
      boxShadow: [BoxShadow(
        color: const Color(0xFFFFD700).withValues(alpha: .2),
        blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Stack(children: [
      // Decorative circles
      Positioned(top: -30, right: -30,
        child: Container(width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withValues(alpha: .05)))),
      Positioned(bottom: -20, left: -20,
        child: Container(width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFD700).withValues(alpha: .05)))),
      Column(children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Stack(children: [
            IHImage(url: site.imageUrl, width: 340, height: 200),
            Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent,
                  const Color(0xFF3D2200).withValues(alpha: .95)])))),
            // Gold border top
            Positioned(bottom: 0, left: 0, right: 0,
              child: Container(height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    Color(0xFFFFD700),
                    Colors.transparent])))),
          ]),
        ),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(site.name, style: AppFonts.lora(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: const Color(0xFFFFD700)),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.location_on_rounded,
                color: Color(0xFFFFD700), size: 13),
              const SizedBox(width: 3),
              Text('${site.city} · ${site.civilization}',
                style: AppFonts.nunito(fontSize: 11,
                  color: const Color(0xFFFFD700).withValues(alpha: .8))),
            ]),
            const SizedBox(height: 10),
            Text(site.description, style: AppFonts.nunito(
              fontSize: 11,
              color: Colors.white.withValues(alpha: .7), height: 1.5),
              maxLines: 2, textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              if (site.isUnesco)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: .5)),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(AppStrings.lang(context.read<AppState>().language).unescoLabel,
                    style: AppFonts.nunito(fontSize: 10,
                      color: const Color(0xFFFFD700),
                      fontWeight: FontWeight.w600)))
              else const SizedBox(),
              Text('mirath ✨', style: AppFonts.lora(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD700))),
            ]),
          ]),
        )),
      ]),
    ]),
  );
}

// ── CARD STYLE 3: NIGHT ───────────────────────────────────────────────────────
class _NightCard extends StatelessWidget {
  final Site site;
  const _NightCard({required this.site});

  @override
  Widget build(BuildContext context) => Container(
    width: 340, height: 420,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0A0A1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFF4A6FA5).withValues(alpha: .4)),
      boxShadow: [BoxShadow(
        color: const Color(0xFF4A6FA5).withValues(alpha: .2),
        blurRadius: 24, offset: const Offset(0, 8))],
    ),
    child: Column(children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.3, 0.3, 0.3, 0, 0,
              0.3, 0.3, 0.3, 0, 0,
              0.5, 0.5, 0.5, 0, 0,
              0,   0,   0,   1, 0]),
            child: IHImage(url: site.imageUrl, width: 340, height: 200)),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A1A).withValues(alpha: .3),
                const Color(0xFF16213E).withValues(alpha: .9)])))),
          // Stars decoration
          Positioned(top: 12, left: 12,
            child: Text('✦ ✧ ✦', style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: .4),
              letterSpacing: 4))),
          Positioned(bottom: 12, left: 14, right: 14,
            child: Text(site.name, style: AppFonts.lora(
              fontSize: 19, fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [const Shadow(blurRadius: 10,
                color: Color(0xFF4A6FA5))]))),
        ]),
      ),
      Expanded(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(children: [
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4A9EFF))),
            const SizedBox(width: 6),
            Text('${site.city} · ${site.governorate}',
              style: AppFonts.nunito(fontSize: 12,
                color: const Color(0xFF4A9EFF))),
          ]),
          const SizedBox(height: 8),
          Text(site.description, style: AppFonts.nunito(
            fontSize: 11,
            color: Colors.white.withValues(alpha: .65), height: 1.5),
            maxLines: 3, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A6FA5).withValues(alpha: .2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF4A6FA5).withValues(alpha: .4))),
              child: Text(site.civilization, style: AppFonts.nunito(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: const Color(0xFF4A9EFF)))),
            const Spacer(),
            Text('mirath 🌙', style: AppFonts.lora(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: const Color(0xFF4A9EFF))),
          ]),
        ]),
      )),
    ]),
  );
}

IconData _themeIcon(String name) {
  switch (name) {
    case 'gold':    return Icons.star_outline_rounded;
    case 'night':   return Icons.nightlight_round;
    default:        return Icons.auto_awesome_outlined;
  }
}
