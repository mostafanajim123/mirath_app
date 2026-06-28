import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../data/translations.dart';
import '../widgets/common_widgets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});
  @override State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 500))..forward();
    _contentCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600));
    Future.delayed(const Duration(milliseconds: 220), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose(); _contentCtrl.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final site = ModalRoute.of(context)!.settings.arguments as Site;
    final state = context.watch<AppState>();
    final isFav = state.isFavSite(site.id);

    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── HERO IMAGE ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 300, pinned: true,
            backgroundColor: IHTheme.primary, elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .9),
                  shape: BoxShape.circle,
                  boxShadow: IHTheme.cardShadow),
                child: const Icon(Icons.arrow_back_ios_rounded,
                  color: IHTheme.primary, size: 18))),
            actions: [
              GestureDetector(
                onTap: () => state.toggleFavSite(site.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isFav ? IHTheme.primaryGradient : null,
                    color: isFav ? null : Colors.white.withValues(alpha: .9),
                    shape: BoxShape.circle,
                    boxShadow: IHTheme.cardShadow),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_outline,
                      key: ValueKey(isFav),
                      color: isFav ? Colors.white : IHTheme.primary,
                      size: 20)))),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: AnimatedBuilder(
                animation: _heroCtrl,
                builder: (_, child) => Opacity(
                  opacity: _heroCtrl.value, child: child),
                child: Stack(children: [
                  IHImage(url: site.imageUrl,
                    width: double.infinity, height: 300),
                  Positioned.fill(child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent,
                          IHTheme.bgPrimary.withValues(alpha: .95)])))),
                ]),
              ),
            ),
          ),

          // ── CONTENT ─────────────────────────────────────
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _contentCtrl,
              builder: (_, child) {
                final fade = CurvedAnimation(
                  parent: _contentCtrl, curve: Curves.easeOut);
                final slide = Tween<double>(begin: 22, end: 0).animate(
                  CurvedAnimation(parent: _contentCtrl,
                    curve: Curves.easeOutCubic));
                return Opacity(opacity: fade.value,
                  child: Transform.translate(
                    offset: Offset(0, slide.value), child: child));
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // civilization badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: IHTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: IHTheme.primaryShadow),
                    child: Text(site.civilizationFor(state.language), style: AppFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: Colors.white))),
                  const SizedBox(height: 12),

                  // name
                  Text(site.nameFor(state.language), style: AppFonts.lora(
                    fontSize: 26, fontWeight: FontWeight.w700,
                    color: IHTheme.textPrimary, height: 1.2)),
                  const SizedBox(height: 8),

                  // location + date
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                      size: 15, color: IHTheme.primary),
                    const SizedBox(width: 4),
                    Text('${site.cityFor(state.language)} · ${site.governorateFor(state.language)}',
                      style: AppFonts.nunito(
                        fontSize: 13, color: IHTheme.textSecondary)),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded,
                      size: 14, color: IHTheme.primaryLight),
                    const SizedBox(width: 4),
                    Text(site.builtYearFor(state.language), style: AppFonts.nunito(
                      fontSize: 12, color: IHTheme.textMuted)),
                  ]),
                  const SizedBox(height: 16),

                  // tags
                  if (site.tags.isNotEmpty)
                    Wrap(spacing: 6, runSpacing: 6,
                      children: site.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: IHTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: IHTheme.border, width: .7)),
                        child: Text(t, style: AppFonts.nunito(
                          fontSize: 10,
                          color: IHTheme.textSecondary)))).toList()),

                  const SizedBox(height: 20),
                  const IHDivider(),
                  const SizedBox(height: 20),

                  // stats row
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    IHStat(icon: Icons.museum_outlined,
                      label: AppStrings.lang(context.read<AppState>().language).siteType, value: site.typeFor(state.language)),
                    IHStat(icon: Icons.history_edu_outlined,
                      label: AppStrings.lang(context.read<AppState>().language).civilization, value: site.civilizationFor(state.language)),
                    IHStat(icon: Icons.calendar_month_outlined,
                      label: AppStrings.lang(context.read<AppState>().language).history, value: site.builtYearFor(state.language)),
                  ]),
                  const SizedBox(height: 24),

                  // about section
                  Row(children: [
                    Container(width: 4, height: 22,
                      decoration: BoxDecoration(
                        gradient: IHTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Text(AppStrings.lang(context.read<AppState>().language).aboutSite, style: AppFonts.lora(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: IHTheme.textPrimary)),
                  ]),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: IHTheme.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: IHTheme.borderLight, width: .8),
                      boxShadow: IHTheme.cardShadow),
                    child: Text(site.descFor(state.language),
                      style: AppFonts.nunito(
                        fontSize: 14, color: IHTheme.textSecondary,
                        height: 1.85, letterSpacing: .1))),
                  const SizedBox(height: 24),

                  // buttons
                  // ── زر Check-in ──
                  IHButton(
                    label: 'سجّل زيارتي 📍',
                    icon: Icons.where_to_vote_rounded,
                    onTap: () => Navigator.pushNamed(
                      context, '/checkin', arguments: site),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: IHButton(
                      label: AppStrings.lang(context.read<AppState>().language).navMap,
                      icon: Icons.navigation_rounded,
                      outlined: true,
                      onTap: () => Navigator.pushNamed(
                        context, '/map', arguments: site))),
                    const SizedBox(width: 12),
                    Expanded(child: IHButton(
                      label: AppStrings.lang(context.read<AppState>().language).share,
                      icon: Icons.share_rounded,
                      outlined: true,
                      onTap: () => Navigator.pushNamed(
                        context, '/share-card', arguments: site))),
                  ]),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
