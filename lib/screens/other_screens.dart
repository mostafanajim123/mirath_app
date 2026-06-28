import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/achievements.dart';
import '../data/translations.dart';
import 'achievements_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  ALL SITES
// ═══════════════════════════════════════════════════════════════════════════
class AllSitesScreen extends StatefulWidget {
  const AllSitesScreen({super.key});
  @override State<AllSitesScreen> createState() => _AllSitesScreenState();
}

class _AllSitesScreenState extends State<AllSitesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    // context.select: يعيد البناء فقط عند تغيير filteredSites أو selectedCategory
    final sites = context.select<AppState, List<Site>>(
      (s) => s.filteredSites);
    final selectedCat = context.select<AppState, String>(
      (s) => s.selectedCategory);
    final state = context.read<AppState>();
    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      appBar: IHAppBar(
        title: '${AppStrings.lang(state.language).archaeologicalSites} (${sites.length})', showBack: true),
      body: Column(children: [
        // search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: IHCard(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppFonts.nunito(
                fontSize: 14, color: IHTheme.textPrimary),
              decoration: InputDecoration(
                hintText: AppStrings.lang(context.read<AppState>().language).search,
                hintStyle: AppFonts.nunito(
                  fontSize: 13, color: IHTheme.textLight),
                prefixIcon: const Icon(Icons.search_rounded,
                  color: IHTheme.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13)),
              onChanged: state.setSearch),
          ),
        ),
        // chips
        SizedBox(height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => IHChip(
              label: state.categories[i],
              selected: selectedCat == state.categories[i],
              onTap: () => state.setCategory(state.categories[i])),
          ),
        ),
        const SizedBox(height: 4),
        // grid
        Expanded(child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12,
            mainAxisSpacing: 12, childAspectRatio: .68),
          itemCount: sites.length,
          itemBuilder: (_, i) {
            final delay = ((i % 6) * .05).clamp(.0, .35);
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final v = CurvedAnimation(parent: _ctrl,
                  curve: Interval(delay, (delay+.4).clamp(0,1),
                    curve: Curves.easeOutCubic)).value;
                return Opacity(opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 18*(1-v)), child: child));
              },
              child: _SiteGridCard(site: sites[i]),
            );
          },
        )),
      ]),
    );
  }
}

class _SiteGridCard extends StatefulWidget {
  final Site site;
  const _SiteGridCard({required this.site});
  @override State<_SiteGridCard> createState() => _SiteGridCardState();
}

class _SiteGridCardState extends State<_SiteGridCard> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    return GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false);
      Navigator.pushNamed(context, '/detail', arguments: widget.site); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? .95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: IHTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _p ? IHTheme.primary : IHTheme.borderLight,
            width: _p ? 1 : .8),
          boxShadow: _p ? IHTheme.primaryShadow : IHTheme.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18)),
              child: IHImage(url: widget.site.imageUrl,
                height: 115, width: double.infinity)),
            if (widget.site.isUnesco)
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: IHTheme.primary,
                    borderRadius: BorderRadius.circular(7)),
                  child: Text('UNESCO', style: AppFonts.nunito(
                    fontSize: 8, fontWeight: FontWeight.w800,
                    color: Colors.white)))),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(widget.site.nameFor(lang), style: AppFonts.lora(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: IHTheme.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_rounded,
                  size: 11, color: IHTheme.primary),
                const SizedBox(width: 3),
                Text(widget.site.cityFor(lang), style: AppFonts.nunito(
                  fontSize: 10, color: IHTheme.textMuted)),
              ]),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: IHTheme.surface,
                  borderRadius: BorderRadius.circular(7)),
                child: Text(widget.site.civilizationFor(lang), style: AppFonts.nunito(
                  fontSize: 9, color: IHTheme.primary,
                  fontWeight: FontWeight.w700))),
            ]),
          ),
        ]),
      ),
    ),
  );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HISTORICAL ERAS
// ═══════════════════════════════════════════════════════════════════════════
class ErasScreen extends StatefulWidget {
  const ErasScreen({super.key});
  @override State<ErasScreen> createState() => _ErasScreenState();
}

class _ErasScreenState extends State<ErasScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 700))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final eras = context.watch<AppState>().eras;
    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180, pinned: true,
            backgroundColor: IHTheme.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 18))),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppStrings.lang(context.read<AppState>().language).historicalEras, style: AppFonts.lora(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
                child: Stack(children: [
                  Center(child: Text('𒀭', style: TextStyle(
                    fontSize: 80,
                    color: Colors.white.withValues(alpha: .08)))),
                  Positioned(bottom: 40, right: 20,
                    child: Text(AppStrings.lang(context.read<AppState>().language).fromPrehistory,
                      style: AppFonts.nunito(fontSize: 12,
                        color: Colors.white.withValues(alpha: .7)))),
                ])),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final delay = (i * .08).clamp(.0, .5);
                  final era = eras[i];
                  return AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, child) {
                      final v = CurvedAnimation(parent: _ctrl,
                        curve: Interval(delay, (delay+.4).clamp(0,1),
                          curve: Curves.easeOutCubic)).value;
                      return Opacity(opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20*(1-v)), child: child));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _EraDetailCard(era: era),
                    ),
                  );
                },
                childCount: eras.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EraDetailCard extends StatelessWidget {
  final Map<String, String> era;
  const _EraDetailCard({required this.era});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(era['color']!));
    return IHCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: .7)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16))),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(era['name']!, style: AppFonts.lora(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: Colors.white)),
              const SizedBox(height: 4),
              Text(era['period']!, style: AppFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: .85))),
            ])),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                shape: BoxShape.circle),
              child: const Icon(Icons.history_edu_rounded,
                color: Colors.white, size: 26)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(era['desc']!, style: AppFonts.nunito(
            fontSize: 14, color: IHTheme.textSecondary,
            height: 1.7))),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  CHARACTERS
// ═══════════════════════════════════════════════════════════════════════════
class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});
  @override State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 700))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final chars = context.watch<AppState>().allCharacters;
    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      appBar: IHAppBar(
        title: AppStrings.lang(context.read<AppState>().language).characters, showBack: true),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: chars.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final delay = ((i % 8) * .05).clamp(.0, .4);
          return AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) {
              final v = CurvedAnimation(parent: _ctrl,
                curve: Interval(delay, (delay+.4).clamp(0,1),
                  curve: Curves.easeOutCubic)).value;
              return Opacity(opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 18*(1-v)), child: child));
            },
            child: _CharListCard(char: chars[i]),
          );
        },
      ),
    );
  }
}

class _CharListCard extends StatefulWidget {
  final HistoricalCharacter char;
  const _CharListCard({required this.char});
  @override State<_CharListCard> createState() => _CharListCardState();
}

class _CharListCardState extends State<_CharListCard> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    return GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false);
      Navigator.pushNamed(context, '/char-detail', arguments: widget.char); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? .97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: IHTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _p ? IHTheme.primary : IHTheme.borderLight,
            width: _p ? 1 : .8),
          boxShadow: _p ? IHTheme.primaryShadow : IHTheme.cardShadow),
        child: Row(children: [
          // avatar
          Container(width: 64, height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: IHTheme.heroGradient,
              boxShadow: IHTheme.cardShadow),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.char.imageUrl.isNotEmpty
                ? IHImage(url: widget.char.imageUrl, width: 64, height: 64)
                : Center(child: Text(widget.char.nameFor(lang)[0],
                    style: AppFonts.lora(fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .7)))))),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.char.nameFor(lang), style: AppFonts.lora(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: IHTheme.textPrimary)),
            const SizedBox(height: 3),
            Text(widget.char.roleFor(lang), style: AppFonts.nunito(
              fontSize: 11, color: IHTheme.primary,
              fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: IHTheme.surface,
                  borderRadius: BorderRadius.circular(7)),
                child: Text(widget.char.civilizationFor(lang), style: AppFonts.nunito(
                  fontSize: 9, color: IHTheme.primary,
                  fontWeight: FontWeight.w700))),
              const SizedBox(width: 8),
              Text(widget.char.eraFor(lang), style: AppFonts.nunito(
                fontSize: 10, color: IHTheme.textMuted)),
            ]),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: IHTheme.primaryLight),
        ]),
      ),
    ),
  );
  }
}

// ── CHAR DETAIL ───────────────────────────────────────────────────────────────
class CharDetailScreen extends StatefulWidget {
  const CharDetailScreen({super.key});
  @override State<CharDetailScreen> createState() => _CharDetailScreenState();
}

class _CharDetailScreenState extends State<CharDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 700))..forward();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final char = ModalRoute.of(context)!.settings.arguments
      as HistoricalCharacter;
    final state = context.watch<AppState>();
    final isFav = state.isFavChar(char.id);

    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220, pinned: true,
            backgroundColor: IHTheme.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 18))),
            actions: [
              GestureDetector(
                onTap: () => state.toggleFavChar(char.id),
                child: Container(margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isFav ? null : null,
                    color: isFav
                      ? Colors.white.withValues(alpha: .3)
                      : Colors.white.withValues(alpha: .15),
                    shape: BoxShape.circle),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_outline,
                      key: ValueKey(isFav),
                      color: Colors.white, size: 20)))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
                child: Stack(children: [
                  Center(child: Text(char.nameFor(state.language)[0],
                    style: AppFonts.lora(fontSize: 100,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .08)))),
                  if (char.imageUrl.isNotEmpty)
                    Positioned.fill(child: IHImage(url: char.imageUrl,
                      fit: BoxFit.cover)),
                  Positioned.fill(child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent,
                          IHTheme.primary.withValues(alpha: .8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)))),
                  Positioned(bottom: 20, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(char.nameFor(state.language), style: AppFonts.lora(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                      Text(char.roleFor(state.language), style: AppFonts.nunito(
                        fontSize: 13, color: Colors.white.withValues(alpha: .85),
                        fontWeight: FontWeight.w600)),
                    ])),
                ])),
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final fade = CurvedAnimation(parent: _ctrl,
                  curve: Curves.easeOut);
                final slide = Tween<double>(begin: 24, end: 0).animate(
                  CurvedAnimation(parent: _ctrl,
                    curve: Curves.easeOutCubic));
                return Opacity(opacity: fade.value,
                  child: Transform.translate(
                    offset: Offset(0, slide.value), child: child));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // stats
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    IHStat(icon: Icons.history_edu_outlined,
                      label: AppStrings.lang(context.read<AppState>().language).civilization, value: char.civilizationFor(state.language)),
                    IHStat(icon: Icons.calendar_month_outlined,
                      label: AppStrings.lang(context.read<AppState>().language).era, value: char.eraFor(state.language)),
                    IHStat(icon: Icons.star_outline_rounded,
                      label: AppStrings.lang(context.read<AppState>().language).achievementsLabel,
                      value: '${char.achievements.length}'),
                  ]),
                  const SizedBox(height: 24),
                  const IHDivider(),
                  const SizedBox(height: 20),

                  // biography
                  Row(children: [
                    Container(width: 4, height: 22,
                      decoration: BoxDecoration(
                        gradient: IHTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(AppStrings.lang(context.read<AppState>().language).biography, style: AppFonts.lora(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: IHTheme.textPrimary)),
                  ]),
                  const SizedBox(height: 12),
                  IHCard(
                    padding: const EdgeInsets.all(18),
                    child: Text(char.descFor(state.language), style: AppFonts.nunito(
                      fontSize: 14, color: IHTheme.textSecondary,
                      height: 1.85))),

                  // achievements
                  if (char.achievements.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(children: [
                      Container(width: 4, height: 22,
                        decoration: BoxDecoration(
                          gradient: IHTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      Text(AppStrings.lang(context.read<AppState>().language).notableAchievements, style: AppFonts.lora(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: IHTheme.textPrimary)),
                    ]),
                    const SizedBox(height: 12),
                    ...char.achievementsFor(state.language).asMap().entries.map((e) {
                      final delay = .25 + e.key * .06;
                      return AnimatedBuilder(
                        animation: _ctrl,
                        builder: (_, child) {
                          final v = CurvedAnimation(parent: _ctrl,
                            curve: Interval(delay, (delay+.3).clamp(0,1),
                              curve: Curves.easeOut)).value;
                          return Opacity(opacity: v,
                            child: Transform.translate(
                              offset: Offset(16*(1-v), 0),
                              child: child));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                          decoration: BoxDecoration(
                            color: IHTheme.bgCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: IHTheme.borderLight, width: .8),
                            boxShadow: IHTheme.cardShadow),
                          child: Row(children: [
                            Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                gradient: IHTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: IHTheme.primaryShadow),
                              child: Center(child: Text('${e.key + 1}',
                                style: AppFonts.lora(fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(e.value,
                              style: AppFonts.nunito(
                                fontSize: 13, color: IHTheme.textSecondary,
                                height: 1.5))),
                          ]),
                        ),
                      );
                    }),
                  ],
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MAP - خريطة تقريبية أوفلاين بالكامل (بدون أي بلاطات/خرائط من الإنترنت)
//  + قائمة بكل المواقع مرتبة حسب الأقرب لموقع المستخدم
// ═══════════════════════════════════════════════════════════════════════════

// حدود تقريبية لخارطة العراق (خط العرض/الطول) — تُستخدم فقط لإسقاط نقاط
// المواقع على لوحة ثابتة محلياً، بدون أي اتصال بالإنترنت أو بلاطات خرائط.
class _IraqBounds {
  static const double minLat = 29.0, maxLat = 37.4;
  static const double minLng = 38.7, maxLng = 48.8;

  static Offset project(double lat, double lng) {
    final dx = ((lng - minLng) / (maxLng - minLng)).clamp(0.0, 1.0);
    final dy = (1 - (lat - minLat) / (maxLat - minLat)).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }
}

// حدود العراق الحقيقية (خط الطول، خط العرض) — بيانات جغرافية رسمية مبسّطة
// تُستخدم لرسم شكل الدولة الفعلي محلياً بالكامل، بدون أي بلاطات إنترنت.
const List<List<double>> _iraqOutline = [
  [45.420618, 35.977546], [46.07634, 35.677383], [46.151788, 35.093259], [45.64846, 34.748138],
  [45.416691, 33.967798], [46.109362, 33.017287], [47.334661, 32.469155], [47.849204, 31.709176],
  [47.685286, 30.984853], [48.004698, 30.985137], [48.014568, 30.452457], [48.567971, 29.926778],
  [47.974519, 29.975819], [47.302622, 30.05907], [46.568713, 29.099025], [44.709499, 29.178891],
  [41.889981, 31.190009], [40.399994, 31.889992], [39.195468, 32.161009], [38.792341, 33.378686],
  [41.006159, 34.419372], [41.383965, 35.628317], [41.289707, 36.358815], [41.837064, 36.605854],
  [42.349591, 37.229873], [42.779126, 37.385264], [43.942259, 37.256228], [44.293452, 37.001514],
  [44.772699, 37.170445], [45.420618, 35.977546],
];

Path _buildIraqPath(Size size) {
  final path = Path();
  for (var i = 0; i < _iraqOutline.length; i++) {
    final p = _IraqBounds.project(_iraqOutline[i][1], _iraqOutline[i][0]);
    final pt = Offset(p.dx * size.width, p.dy * size.height);
    if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
  }
  path.close();
  return path;
}

class _IraqShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _buildIraqPath(size);
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _IraqOutlinePainter extends CustomPainter {
  final Color lineColor;
  _IraqOutlinePainter({required this.lineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildIraqPath(size);
    canvas.drawPath(path, Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2);
  }
  @override
  bool shouldRepaint(covariant _IraqOutlinePainter oldDelegate) =>
    oldDelegate.lineColor != lineColor;
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override State<MapScreen> createState() => _MapScreenState();
}

enum _MapMode { real, offline, list }

class _MapScreenState extends State<MapScreen> {
  Site? _selected;
  bool _locating = false;
  _MapMode _mode = _MapMode.real;
  Position? _myPos;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // محاولة صامتة لجلب الموقع لترتيب القائمة، بدون إزعاج المستخدم بأي رسالة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _goToNearest(context.read<AppState>().allSites, silent: true);
    });
  }

  Future<void> _goToNearest(List<Site> sites, {bool silent = false}) async {
    if (!silent) setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted && !silent) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.lang(context.read<AppState>().language).locationPermission,
              style: AppFonts.nunito()),
            backgroundColor: IHTheme.primary));
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8)));

      if (!mounted) return;
      setState(() => _myPos = pos);

      // أقرب موقع
      Site? nearest;
      double minDist = double.infinity;
      for (final s in sites) {
        final d = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, s.lat, s.lng);
        if (d < minDist) { minDist = d; nearest = s; }
      }

      if (nearest != null && mounted && !silent) {
        setState(() => _selected = nearest);
        if (_mode == _MapMode.real) {
          _mapController.move(ll.LatLng(nearest.lat, nearest.lng), 9);
        }
        final km = (minDist / 1000).toStringAsFixed(0);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppStrings.lang(context.read<AppState>().language).nearestSite}: ${nearest.name} ($km km)',
            style: AppFonts.nunito(fontWeight: FontWeight.w600)),
          backgroundColor: IHTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12))));
      }
    } catch (e) {
      if (mounted && !silent) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.lang(context.read<AppState>().language).locationError)));
    } finally {
      if (mounted && !silent) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sites = context.watch<AppState>().allSites;
    final s = AppStrings.lang(context.read<AppState>().language);

    final sorted = [...sites];
    if (_myPos != null) {
      sorted.sort((a, b) {
        final da = Geolocator.distanceBetween(
          _myPos!.latitude, _myPos!.longitude, a.lat, a.lng);
        final db = Geolocator.distanceBetween(
          _myPos!.latitude, _myPos!.longitude, b.lat, b.lng);
        return da.compareTo(db);
      });
    }

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(title: s.mapTitle, showBack: true,
        actions: [
          // زر أقرب موقع
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: _locating ? null : () => _goToNearest(sites),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .4))),
                child: _locating
                  ? const SizedBox(width: 14, height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.my_location_rounded,
                        color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(s.nearestSite, style: AppFonts.nunito(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: Colors.white)),
                    ]),
              ),
            ),
          ),
        ]),
      body: Column(children: [
        // مفتاح التبديل: خريطة حقيقية / خريطة أوفلاين / قائمة
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Expanded(child: _MapListToggleBtn(
              label: s.realMapTab, icon: Icons.public_rounded,
              selected: _mode == _MapMode.real,
              onTap: () => setState(() => _mode = _MapMode.real))),
            const SizedBox(width: 8),
            Expanded(child: _MapListToggleBtn(
              label: s.mapViewTab, icon: Icons.map_rounded,
              selected: _mode == _MapMode.offline,
              onTap: () => setState(() => _mode = _MapMode.offline))),
            const SizedBox(width: 8),
            Expanded(child: _MapListToggleBtn(
              label: s.listViewTab, icon: Icons.view_list_rounded,
              selected: _mode == _MapMode.list,
              onTap: () => setState(() => _mode = _MapMode.list))),
          ]),
        ),
        Expanded(
          child: switch (_mode) {
            _MapMode.list => _SitesListView(
                sites: sorted,
                myPos: _myPos,
                onTap: (site) => Navigator.pushNamed(
                  context, '/detail', arguments: site),
                onEnableLocation: () => _goToNearest(sites),
              ),
            _MapMode.offline => _StaticMapView(
                sites: sites,
                selected: _selected,
                onSelect: (site) => setState(() =>
                  _selected = _selected?.id == site?.id ? null : site),
              ),
            _MapMode.real => _RealMapView(
                sites: sites,
                selected: _selected,
                mapController: _mapController,
                onSelect: (site) => setState(() =>
                  _selected = _selected?.id == site?.id ? null : site),
              ),
          },
        ),
      ]),
    );
  }
}

// ── زر تبديل بسيط (خريطة / قائمة) ─────────────────────────────────────────
class _MapListToggleBtn extends StatelessWidget {
  final String label; final IconData icon; final bool selected;
  final VoidCallback onTap;
  const _MapListToggleBtn({required this.label, required this.icon,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: selected ? IHTheme.primaryGradient : null,
        color: selected ? null : IHTheme.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Colors.transparent : IHTheme.bdr(context)),
        boxShadow: selected ? IHTheme.primaryShadow : IHTheme.shadow(context)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14,
          color: selected ? Colors.white : IHTheme.txtSecondary(context)),
        const SizedBox(width: 4),
        Text(label, style: AppFonts.nunito(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: selected ? Colors.white : IHTheme.txtSecondary(context))),
      ]),
    ),
  );
}

// ── الخريطة الثابتة التقريبية (أوفلاين بالكامل) ───────────────────────────
// ── الخريطة الحقيقية (بلاطات OpenStreetMap من الإنترنت) ──────────────────
class _RealMapView extends StatelessWidget {
  final List<Site> sites;
  final Site? selected;
  final MapController mapController;
  final ValueChanged<Site?> onSelect;
  const _RealMapView({required this.sites, required this.selected,
    required this.mapController, required this.onSelect});

  static const ll.LatLng _iraqCenter = ll.LatLng(33.2, 43.7);

  @override
  Widget build(BuildContext context) {
    final dark = IHTheme.isDark(context);
    final lang = context.read<AppState>().language;
    final s = AppStrings.lang(lang);
    final tileUrl = dark
      ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Stack(children: [
      FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: _iraqCenter,
          initialZoom: 6.0,
          minZoom: 5,
          maxZoom: 17,
          onTap: (_, __) => onSelect(null),
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl,
            subdomains: dark ? const ['a', 'b', 'c', 'd'] : const [],
            userAgentPackageName: 'com.example.iraqi_heritage',
          ),
          MarkerLayer(
            markers: sites.map((site) {
              final sel = selected?.id == site.id;
              return Marker(
                point: ll.LatLng(site.lat, site.lng),
                width: sel ? 44 : 32,
                height: sel ? 44 : 32,
                child: GestureDetector(
                  onTap: () => onSelect(site),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: sel ? IHTheme.primaryGradient : null,
                      color: sel ? null : site.isUnesco
                        ? IHTheme.primary : IHTheme.primaryLight,
                      border: Border.all(
                        color: Colors.white, width: sel ? 2.5 : 1.5),
                      boxShadow: sel ? IHTheme.primaryShadow : [
                        BoxShadow(color: Colors.black.withValues(alpha: .2),
                          blurRadius: 6, offset: const Offset(0, 2)),
                      ]),
                    child: Icon(
                      site.isUnesco ? Icons.star_rounded : Icons.location_pin,
                      color: Colors.white, size: sel ? 22 : 15),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),

      // ملاحظة المصدر
      Positioned(
        bottom: selected != null ? 200 : 8,
        right: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: IHTheme.card(context).withValues(alpha: .85),
            borderRadius: BorderRadius.circular(6)),
          child: Text(
            dark ? '© CARTO © OSM' : '© OpenStreetMap contributors',
            style: AppFonts.nunito(fontSize: 9,
              color: IHTheme.txtMuted(context))),
        ),
      ),

      // مفتاح الألوان
      Positioned(
        top: 12, right: 12,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: IHTheme.card(context).withValues(alpha: .92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: IHTheme.bdrLight(context)),
            boxShadow: IHTheme.shadow(context)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
            _LegendDot(color: IHTheme.primary, label: s.unescoLabel),
            const SizedBox(height: 6),
            _LegendDot(color: IHTheme.primaryLight, label: s.heritageLabel),
          ]),
        ),
      ),

      // بطاقة الموقع المختار
      if (selected != null)
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context, '/detail', arguments: selected),
            child: Container(
              decoration: BoxDecoration(
                color: IHTheme.card(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: IHTheme.bdrLight(context)),
                boxShadow: IHTheme.deepShadow),
              child: Row(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20)),
                  child: IHImage(url: selected!.imageUrl,
                    width: 90, height: 90)),
                const SizedBox(width: 14),
                Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(selected!.nameFor(lang),
                      style: AppFonts.lora(fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: IHTheme.txtPrimary(context))),
                    const SizedBox(height: 4),
                    Text(selected!.cityFor(lang) + ' · ' + selected!.civilizationFor(lang),
                      style: AppFonts.nunito(fontSize: 11,
                        color: IHTheme.txtMuted(context))),
                    if (selected!.isUnesco)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: IHTheme.prim(context).withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(s.unescoLabel,
                            style: AppFonts.nunito(fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: IHTheme.prim(context))),
                        ),
                      ),
                  ]),
                )),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: IHTheme.primLight(context))),
              ]),
            ),
          ),
        ),
    ]);
  }
}

class _StaticMapView extends StatelessWidget {
  final List<Site> sites;
  final Site? selected;
  final ValueChanged<Site?> onSelect;
  const _StaticMapView({required this.sites, required this.selected,
    required this.onSelect});

  static const _cities = [
    {'name': 'بغداد', 'lat': 33.3, 'lng': 44.4},
    {'name': 'الموصل', 'lat': 36.34, 'lng': 43.13},
    {'name': 'البصرة', 'lat': 30.5, 'lng': 47.8},
    {'name': 'أربيل', 'lat': 36.19, 'lng': 44.01},
  ];

  @override
  Widget build(BuildContext context) {
    final dark = IHTheme.isDark(context);
    final lang = context.read<AppState>().language;
    final s = AppStrings.lang(lang);
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Stack(children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(children: [
              // تعبئة بشكل حدود العراق الحقيقية (مضلّع محلي بالكامل)
              Positioned.fill(
                child: ClipPath(
                  clipper: _IraqShapeClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: dark
                          ? [const Color(0xFF2A2117), const Color(0xFF14100A)]
                          : [const Color(0xFFF3E6CE), const Color(0xFFE3CFA3)]),
                    ),
                    child: Stack(children: [
                      // نمط زخرفي خفيف بالخلفية
                      Positioned.fill(child: CustomPaint(
                        painter: _MapGridPainter(
                          lineColor: (dark ? Colors.white : Colors.black)
                            .withValues(alpha: .05)))),
                      Center(child: Icon(Icons.account_balance_rounded,
                        size: 110,
                        color: (dark ? Colors.white : Colors.black)
                          .withValues(alpha: .05))),
                    ]),
                  ),
                ),
              ),
              // حدّ خارجي واضح بشكل حدود العراق
              Positioned.fill(
                child: CustomPaint(
                  painter: _IraqOutlinePainter(
                    lineColor: IHTheme.prim(context).withValues(alpha: .55)),
                ),
              ),

              // أسماء مدن مرجعية + رموز المواقع
              Positioned.fill(child:
                  LayoutBuilder(builder: (ctx, constraints) {
                    final w = constraints.maxWidth, h = constraints.maxHeight;
                    const margin = .08;
                    Offset pos(double lat, double lng) {
                      final p = _IraqBounds.project(lat, lng);
                      return Offset(
                        margin * w + p.dx * (1 - 2 * margin) * w,
                        margin * h + p.dy * (1 - 2 * margin) * h);
                    }
                    return Stack(children: [
                      for (final city in _cities)
                        Positioned(
                          left: pos(city['lat'] as double, city['lng'] as double).dx - 28,
                          top: pos(city['lat'] as double, city['lng'] as double).dy + 10,
                          child: Text(city['name'] as String, style: AppFonts.nunito(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: IHTheme.txtMuted(context))),
                        ),
                      for (final site in sites)
                        Positioned(
                          left: pos(site.lat, site.lng).dx -
                            (selected?.id == site.id ? 22 : 16),
                          top: pos(site.lat, site.lng).dy -
                            (selected?.id == site.id ? 22 : 16),
                          child: GestureDetector(
                            onTap: () => onSelect(site),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: selected?.id == site.id ? 44 : 32,
                              height: selected?.id == site.id ? 44 : 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: selected?.id == site.id
                                  ? IHTheme.primaryGradient : null,
                                color: selected?.id == site.id ? null
                                  : site.isUnesco
                                    ? IHTheme.primary : IHTheme.primaryLight,
                                border: Border.all(
                                  color: Colors.white,
                                  width: selected?.id == site.id ? 2.5 : 1.5),
                                boxShadow: selected?.id == site.id
                                  ? IHTheme.primaryShadow : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .2),
                                      blurRadius: 6, offset: const Offset(0, 2)),
                                  ]),
                              child: Icon(
                                site.isUnesco ? Icons.star_rounded : Icons.location_pin,
                                color: Colors.white,
                                size: selected?.id == site.id ? 22 : 15),
                            ),
                          ),
                        ),
                    ]);
                  }),
              ),
            ]),
          ),
        ),

        // ملاحظة: خريطة تقريبية أوفلاين
        Positioned(
          bottom: selected != null ? 200 : 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: IHTheme.card(context).withValues(alpha: .9),
              borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.wifi_off_rounded, size: 11,
                color: IHTheme.txtMuted(context)),
              const SizedBox(width: 4),
              Text(s.approxMapNote, style: AppFonts.nunito(fontSize: 9,
                color: IHTheme.txtMuted(context))),
            ]),
          ),
        ),

        // مفتاح الألوان
        Positioned(
          top: 24, right: 24,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: IHTheme.card(context).withValues(alpha: .92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: IHTheme.bdrLight(context)),
              boxShadow: IHTheme.shadow(context)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
              _LegendDot(color: IHTheme.primary, label: s.unescoLabel),
              const SizedBox(height: 6),
              _LegendDot(color: IHTheme.primaryLight, label: s.heritageLabel),
            ]),
          ),
        ),

        // بطاقة الموقع المختار
        if (selected != null)
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(
                context, '/detail', arguments: selected),
              child: Container(
                decoration: BoxDecoration(
                  color: IHTheme.card(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: IHTheme.bdrLight(context)),
                  boxShadow: IHTheme.deepShadow),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20)),
                    child: IHImage(url: selected!.imageUrl,
                      width: 90, height: 90)),
                  const SizedBox(width: 14),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(selected!.nameFor(lang),
                        style: AppFonts.lora(fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: IHTheme.txtPrimary(context))),
                      const SizedBox(height: 4),
                      Text(selected!.cityFor(lang) + ' · ' + selected!.civilizationFor(lang),
                        style: AppFonts.nunito(fontSize: 11,
                          color: IHTheme.txtMuted(context))),
                      if (selected!.isUnesco)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: IHTheme.prim(context).withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(20)),
                            child: Text(s.unescoLabel,
                              style: AppFonts.nunito(fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: IHTheme.prim(context))),
                          ),
                        ),
                    ]),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: IHTheme.primLight(context))),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}

// رسم شبكة خفيفة جداً كخلفية زخرفية للوحة الخريطة (محلي بالكامل، بدون شبكة)
class _MapGridPainter extends CustomPainter {
  final Color lineColor;
  _MapGridPainter({required this.lineColor});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = lineColor..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) =>
    oldDelegate.lineColor != lineColor;
}

// ── قائمة المواقع (مرتبة حسب الأقرب إن توفّر الموقع) ──────────────────────
class _SitesListView extends StatelessWidget {
  final List<Site> sites;
  final Position? myPos;
  final ValueChanged<Site> onTap;
  final VoidCallback onEnableLocation;
  const _SitesListView({required this.sites, required this.myPos,
    required this.onTap, required this.onEnableLocation});

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppState>().language;
    final s = AppStrings.lang(lang);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: GestureDetector(
          onTap: myPos == null ? onEnableLocation : null,
          child: Row(children: [
            Icon(myPos != null
                ? Icons.near_me_rounded : Icons.location_searching_rounded,
              size: 14, color: IHTheme.prim(context)),
            const SizedBox(width: 6),
            Expanded(child: Text(
              myPos != null ? s.sortedByNearest : s.enableLocationToSort,
              style: AppFonts.nunito(fontSize: 11,
                color: IHTheme.txtMuted(context)))),
          ]),
        ),
      ),
      Expanded(
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
          itemCount: sites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final site = sites[i];
            final km = myPos != null
              ? (Geolocator.distanceBetween(myPos!.latitude, myPos!.longitude,
                  site.lat, site.lng) / 1000).toStringAsFixed(0)
              : null;
            return IHCard(
              padding: const EdgeInsets.all(10),
              onTap: () => onTap(site),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: IHImage(url: site.imageUrl, width: 64, height: 64)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(site.nameFor(lang), style: AppFonts.lora(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: IHTheme.txtPrimary(context)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(site.cityFor(lang) + ' · ' + site.civilizationFor(lang),
                    style: AppFonts.nunito(fontSize: 11,
                      color: IHTheme.txtMuted(context)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (site.isUnesco) Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: IHTheme.prim(context).withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(s.unescoLabel, style: AppFonts.nunito(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: IHTheme.prim(context))))),
                ])),
                if (km != null) ...[
                  const SizedBox(width: 6),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.near_me_rounded, size: 14,
                      color: IHTheme.prim(context)),
                    const SizedBox(height: 2),
                    Text('$km كم', style: AppFonts.nunito(fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: IHTheme.prim(context))),
                  ]),
                ],
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: IHTheme.primLight(context)),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color,
        border: Border.all(color: Colors.white, width: 1.5))),
    const SizedBox(width: 6),
    Text(label, style: AppFonts.nunito(fontSize: 11,
      fontWeight: FontWeight.w600,
      color: IHTheme.txtSecondary(context))),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
//  VIRTUAL MUSEUM
// ═══════════════════════════════════════════════════════════════════════════
class MuseumScreen extends StatelessWidget {
  const MuseumScreen({super.key});

  static const _items = [
    {'name': 'رأس المرأة الوركائية', 'period': '3000 ق.م',
     'museum': 'المتحف العراقي - بغداد', 'civ': 'سومرية',
     'desc': 'من أجمل التحف السومرية، منحوتة من الرخام الأبيض بدقة مذهلة تصوّر وجه أنثى بملامح مثالية.',
     'img': ''},
    {'name': 'كنوز نمرود الذهبية', 'period': '900 ق.م',
     'museum': 'المتحف العراقي - بغداد', 'civ': 'آشورية',
     'desc': 'مجموعة مذهلة من المجوهرات الذهبية تزن نصف طن اكتُشفت في قبور أميرات آشور عام 1988م.',
     'img': ''},
    {'name': 'مسلّة حمورابي (نسخة)', 'period': '1754 ق.م',
     'museum': 'متحف اللوفر - باريس', 'civ': 'بابلية',
     'desc': 'المسلّة الأصلية محفوظة في باريس، تضم 282 مادة قانونية نُقشت على حجر الديوريت الأسود.',
     'img': ''},
    {'name': 'ألواح ملحمة كلكامش', 'period': '2000 ق.م',
     'museum': 'المتحف البريطاني - لندن', 'civ': 'سومرية',
     'desc': 'الألواح الطينية التي تحكي أقدم قصة أدبية في التاريخ، كتبها كتّاب نيبور قبل أربعة آلاف عام.',
     'img': ''},
    {'name': 'تمثال اللاماسو', 'period': '880 ق.م',
     'museum': 'متحف المتروبوليتان - نيويورك', 'civ': 'آشورية',
     'desc': 'الثور المجنح برأس إنساني حارس بوابات المدن الآشورية، يزن أكثر من عشرين طناً.',
     'img': ''},
    {'name': 'ختم الملك شولجي', 'period': '2094 ق.م',
     'museum': 'المتحف العراقي - بغداد', 'civ': 'سومرية',
     'desc': 'ختم أسطواني نادر للملك شولجي ابن أورنمو، منقوش بالكتابة المسمارية والرموز الملكية.',
     'img': ''},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: IHTheme.bg(context),
    body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 160, pinned: true,
          backgroundColor: IHTheme.isDark(context) ? IHTheme.darkBgCard : IHTheme.primary,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 18))),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(AppStrings.lang(context.read<AppState>().language).virtualMuseum, style: AppFonts.lora(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            background: Container(
              decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
              child: Center(child: Icon(Icons.museum_rounded,
                size: 70, color: Colors.white.withValues(alpha: .1)))),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: IHCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        gradient: IHTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Icon(Icons.collections_rounded,
                        color: Colors.white.withValues(alpha: .5), size: 30))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_items[i]['name']!, style: AppFonts.lora(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: IHTheme.txtPrimary(context))),
                      const SizedBox(height: 3),
                      Text(_items[i]['museum']!, style: AppFonts.nunito(
                        fontSize: 10, color: IHTheme.prim(context),
                        fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_items[i]['desc']!, style: AppFonts.nunito(
                        fontSize: 11, color: IHTheme.txtMuted(context), height: 1.4),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: IHTheme.surf(context),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text(_items[i]['civ']!,
                            style: AppFonts.nunito(fontSize: 9,
                              color: IHTheme.prim(context),
                              fontWeight: FontWeight.w700))),
                        const SizedBox(width: 6),
                        Text(_items[i]['period']!, style: AppFonts.nunito(
                          fontSize: 10, color: IHTheme.txtMuted(context))),
                      ]),
                    ])),
                  ]),
                ),
              ),
              childCount: _items.length),
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  PROFILE / FAVORITES  (Local sign-in with image picker)
// ═══════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editing = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage(AppState state) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80, maxWidth: 400);
    if (picked != null && mounted) {
      state.setProfilePhoto(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dark = IHTheme.isDark(context);
    final hasProfile = state.profileName.isNotEmpty;

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220, pinned: true,
            backgroundColor: dark ? IHTheme.darkBgCard : IHTheme.primary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(
                  dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: dark ? IHTheme.darkPrimary : Colors.white),
                onPressed: () => state.toggleTheme(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      // Avatar
                      GestureDetector(
                        onTap: hasProfile ? () => _pickImage(state) : null,
                        child: Stack(children: [
                          Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .2),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .5),
                                width: 2.5)),
                            child: ClipOval(child: _buildAvatarContent(state))),
                          if (hasProfile)
                            Positioned(right: 0, bottom: 0,
                              child: Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: IHTheme.primaryGradient),
                                child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.white, size: 12))),
                        ]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, children: [
                        if (!hasProfile) ...[
                          Text(AppStrings.lang(context.read<AppState>().language).welcomeUser,
                            style: AppFonts.lora(fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(AppStrings.lang(context.read<AppState>().language).registerName,
                            style: AppFonts.nunito(fontSize: 12,
                              color: Colors.white.withValues(alpha: .8))),
                        ] else ...[
                          Text(state.profileName,
                            style: AppFonts.lora(fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('${state.favSites.length} ${AppStrings.lang(state.language).sitesAndChars}',
                            style: AppFonts.nunito(fontSize: 12,
                              color: Colors.white.withValues(alpha: .8))),
                        ],
                      ])),
                    ]),
                    const SizedBox(height: 14),
                    // Name input / edit button
                    if (!hasProfile || _editing)
                      _NameInputRow(
                        ctrl: _nameCtrl,
                        onSave: () {
                          final n = _nameCtrl.text.trim();
                          if (n.isNotEmpty) {
                            state.setProfileName(n);
                            setState(() => _editing = false);
                            _nameCtrl.clear();
                          }
                        },
                        onCancel: hasProfile
                          ? () => setState(() => _editing = false)
                          : null,
                      )
                    else
                      Row(children: [
                        _HeaderBtn(
                          icon: Icons.edit_rounded,
                          label: AppStrings.lang(state.language).editNameLabel,
                          onTap: () {
                            _nameCtrl.text = state.profileName;
                            setState(() => _editing = true);
                          }),
                        const SizedBox(width: 10),
                        _HeaderBtn(
                          icon: Icons.photo_camera_rounded,
                          label: AppStrings.lang(state.language).changePhotoLabel,
                          onTap: () => _pickImage(state)),
                      ]),
                  ]),
                )),
              ),
            ),
          ),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // theme toggle removed (exists in settings)

              // Achievements card
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/achievements'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
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
                      child: const Center(
                        child: Text('🏆',
                          style: TextStyle(fontSize: 20)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(AppStrings.lang(state.language).achievementsTitle, style: AppFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: IHTheme.txtPrimary(context))),
                      Text(
                        '${state.earnedAchievements.length} / ${allAchievements.length} · ${state.achievementPoints} ${AppStrings.lang(state.language).points}',
                        style: AppFonts.nunito(fontSize: 11,
                          color: IHTheme.txtMuted(context))),
                    ])),
                    // Mini progress bar
                    Column(crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                      SizedBox(
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: state.earnedAchievements.length /
                              allAchievements.length,
                            minHeight: 6,
                            backgroundColor:
                              IHTheme.surf(context),
                            valueColor: AlwaysStoppedAnimation(
                              IHTheme.prim(context))))),
                      const SizedBox(height: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                        size: 13, color: IHTheme.primLight(context)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // زياراتي
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/my-visits'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: IHTheme.card(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: IHTheme.bdrLight(context)),
                    boxShadow: IHTheme.shadow(context)),
                  child: Row(children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: IHTheme.primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text('📍',
                          style: TextStyle(fontSize: 20)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text('زياراتي', style: AppFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: IHTheme.txtPrimary(context))),
                      Text('المواقع التي زرتها بنفسك',
                        style: AppFonts.nunito(fontSize: 11,
                          color: IHTheme.txtMuted(context))),
                    ])),
                    Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: IHTheme.primLight(context)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(children: [
                Expanded(child: _StatBox(
                  icon: Icons.museum_rounded,
                  value: '${state.allSites.length}',
                  label: AppStrings.lang(state.language).archaeologicalSites)),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(
                  icon: Icons.favorite_rounded,
                  value: '${state.favSites.length}',
                  label: AppStrings.lang(state.language).favSites)),
                const SizedBox(width: 12),
                Expanded(child: _StatBox(
                  icon: Icons.person_rounded,
                  value: '${state.allCharacters.length}',
                  label: AppStrings.lang(state.language).characters)),
              ]),
              const SizedBox(height: 24),

              if (state.favSites.isNotEmpty) ...[
                IHSectionHeader(title: AppStrings.lang(state.language).favSites),
                const SizedBox(height: 12),
                ...state.favSites.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FavRow(
                    img: s.imageUrl, title: s.nameFor(state.language), sub: s.governorateFor(state.language),
                    onTap: () => Navigator.pushNamed(context, '/detail', arguments: s)))),
              ],

              if (state.favChars.isNotEmpty) ...[
                const SizedBox(height: 16),
                IHSectionHeader(title: AppStrings.lang(state.language).favChars_),
                const SizedBox(height: 12),
                ...state.favChars.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FavRow(
                    img: c.imageUrl, title: c.nameFor(state.language), sub: c.eraFor(state.language),
                    onTap: () => Navigator.pushNamed(context, '/char-detail', arguments: c)))),
              ],

              if (state.favSites.isEmpty && state.favChars.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    Icon(Icons.favorite_outline_rounded,
                      size: 64, color: IHTheme.primLight(context)),
                    const SizedBox(height: 16),
                    Text(AppStrings.lang(state.language).noFavsYet,
                      style: AppFonts.lora(fontSize: 16,
                        color: IHTheme.txtSecondary(context))),
                    const SizedBox(height: 8),
                    Text(AppStrings.lang(state.language).addFavsHint,
                      style: AppFonts.nunito(fontSize: 13,
                        color: IHTheme.txtMuted(context))),
                  ]))),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(AppState state) {
    if (state.profilePhoto != null) {
      return Image.file(File(state.profilePhoto!),
        width: 72, height: 72, fit: BoxFit.cover);
    }
    return Icon(Icons.person_rounded,
      color: Colors.white.withValues(alpha: .8), size: 36);
  }
}

class _NameInputRow extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  const _NameInputRow({required this.ctrl, required this.onSave, this.onCancel});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .4))),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.right,
        style: AppFonts.nunito(fontSize: 14,
          color: Colors.white, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: AppStrings.lang(context.read<AppState>().language).typeYourName,
          hintStyle: AppFonts.nunito(fontSize: 13,
            color: Colors.white.withValues(alpha: .6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14)),
        onSubmitted: (_) => onSave(),
      ),
    )),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: onSave,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .25),
          border: Border.all(color: Colors.white.withValues(alpha: .5))),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 20))),
    if (onCancel != null) ...[
      const SizedBox(width: 6),
      GestureDetector(
        onTap: onCancel,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: .15),
            border: Border.all(color: Colors.white.withValues(alpha: .3))),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 20))),
    ],
  ]);
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .35))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(label, style: AppFonts.nunito(fontSize: 12,
          fontWeight: FontWeight.w600, color: Colors.white)),
      ])),
  );
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget trailing;
  const _SettingCard({required this.icon, required this.title,
    required this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: IHTheme.card(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: IHTheme.bdrLight(context)),
      boxShadow: IHTheme.shadow(context)),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: IHTheme.prim(context).withValues(alpha: .12),
          borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: IHTheme.prim(context), size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppFonts.nunito(fontSize: 14,
          fontWeight: FontWeight.w700,
          color: IHTheme.txtPrimary(context))),
        Text(subtitle, style: AppFonts.nunito(fontSize: 11,
          color: IHTheme.txtMuted(context))),
      ])),
      trailing,
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final IconData icon; final String value, label;
  const _StatBox({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    decoration: BoxDecoration(
      color: IHTheme.card(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: IHTheme.bdrLight(context)),
      boxShadow: IHTheme.shadow(context)),
    child: Column(children: [
      Icon(icon, color: IHTheme.prim(context), size: 24),
      const SizedBox(height: 6),
      Text(value, style: AppFonts.lora(fontSize: 20,
        fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      Text(label, style: AppFonts.nunito(fontSize: 9,
        color: IHTheme.txtMuted(context)),
        textAlign: TextAlign.center),
    ]),
  );
}

class _FavRow extends StatelessWidget {
  final String img, title, sub;
  final VoidCallback onTap;
  const _FavRow({required this.img, required this.title,
    required this.sub, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IHTheme.bdrLight(context)),
        boxShadow: IHTheme.shadow(context)),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: IHImage(url: img, width: 56, height: 56)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppFonts.lora(fontSize: 14,
            fontWeight: FontWeight.w700,
            color: IHTheme.txtPrimary(context))),
          Text(sub, style: AppFonts.nunito(
            fontSize: 11, color: IHTheme.txtMuted(context))),
        ])),
        Icon(Icons.arrow_forward_ios_rounded,
          size: 13, color: IHTheme.primLight(context)),
      ]),
    ),
  );
}
