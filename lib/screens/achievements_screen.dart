import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/achievements.dart';
import '../theme/app_theme.dart';
import '../data/translations.dart';
import '../widgets/common_widgets.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final earned = state.earnedAchievements;
    final locked = state.lockedAchievements;
    final points = state.achievementPoints;
    final total  = allAchievements.length;
    final pct    = earned.length / total;

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HEADER ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200, pinned: true,
            backgroundColor: IHTheme.isDark(context)
              ? IHTheme.darkBgCard : IHTheme.primary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 18))),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: IHTheme.heroGradient),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(children: [
                      const Text('🏆', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(AppStrings.lang(context.read<AppState>().language).achievementsTitle, style: AppFonts.lora(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: Colors.white)),
                        Text('${earned.length} / $total ${AppStrings.lang(context.read<AppState>().language).earnedTab} · $points ${AppStrings.lang(context.read<AppState>().language).points}',
                          style: AppFonts.nunito(fontSize: 13,
                            color: Colors.white.withValues(alpha: .85))),
                      ])),
                    ]),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: .2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ]),
                )),
              ),
            ),
          ),

          // ── EARNED ─────────────────────────────────────────
          if (earned.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: IHSectionHeader(
                title: '${AppStrings.lang(context.read<AppState>().language).earnedTab} (${earned.length})'),
            )),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _AchievementCard(
                    achievement: earned[i], unlocked: true),
                  childCount: earned.length),
              ),
            ),
          ],

          // ── LOCKED ─────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: IHSectionHeader(
              title: '${AppStrings.lang(context.read<AppState>().language).lockedTab} (${locked.length})'),
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _AchievementCard(
                  achievement: locked[i], unlocked: false),
                childCount: locked.length),
            ),
          ),
        ],
      ),
    );
  }
}

// ── ACHIEVEMENT CARD ─────────────────────────────────────────────────────────
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  const _AchievementCard({required this.achievement, required this.unlocked});

  Color _rarityColor(BuildContext context) {
    switch (achievement.rarity) {
      case AchievementRarity.bronze:   return const Color(0xFFCD7F32);
      case AchievementRarity.silver:   return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:     return const Color(0xFFFFD700);
      case AchievementRarity.platinum: return const Color(0xFF00BFFF);
    }
  }

  String _rarityLabel(BuildContext context) {
    final s = AppStrings.lang(context.read<AppState>().language);
    switch (achievement.rarity) {
      case AchievementRarity.bronze:   return s.bronze;
      case AchievementRarity.silver:   return s.silver;
      case AchievementRarity.gold:     return s.gold;
      case AchievementRarity.platinum: return s.platinum;
    }
  }

  int _rarityPoints() {
    switch (achievement.rarity) {
      case AchievementRarity.bronze:   return 10;
      case AchievementRarity.silver:   return 25;
      case AchievementRarity.gold:     return 50;
      case AchievementRarity.platinum: return 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor(context);
    return Container(
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
            ? color.withValues(alpha: .5)
            : IHTheme.bdrLight(context),
          width: unlocked ? 1.5 : 1),
        boxShadow: unlocked
          ? [BoxShadow(color: color.withValues(alpha: .2),
              blurRadius: 12, offset: const Offset(0, 4))]
          : IHTheme.shadow(context),
      ),
      child: Stack(children: [
        if (!unlocked)
          Positioned.fill(child: Container(
            decoration: BoxDecoration(
              color: IHTheme.bg(context).withValues(alpha: .6),
              borderRadius: BorderRadius.circular(16)))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(children: [
              Text(unlocked ? achievement.icon : '🔒',
                style: TextStyle(fontSize: unlocked ? 26 : 20)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: unlocked
                    ? color.withValues(alpha: .15)
                    : IHTheme.surf(context),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(
                  unlocked ? '+${_rarityPoints()}' : _rarityLabel(context),
                  style: AppFonts.nunito(fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? color : IHTheme.txtMuted(context)))),
            ]),
            const SizedBox(height: 8),
            Text(achievement.title, style: AppFonts.lora(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: unlocked
                ? IHTheme.txtPrimary(context)
                : IHTheme.txtMuted(context))),
            const SizedBox(height: 3),
            Expanded(child: Text(achievement.description,
              style: AppFonts.nunito(fontSize: 10,
                color: IHTheme.txtMuted(context), height: 1.4),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ]),
    );
  }
}

// ── ACHIEVEMENT TOAST (shown on unlock) ──────────────────────────────────────
class AchievementToast extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;
  const AchievementToast({
    super.key, required this.achievement, required this.onDismiss});

  @override State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5), end: Offset.zero)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDismiss());
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  Color _rarityColor() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.bronze:   return const Color(0xFFCD7F32);
      case AchievementRarity.silver:   return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:     return const Color(0xFFFFD700);
      case AchievementRarity.platinum: return const Color(0xFF00BFFF);
    }
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slide,
    child: FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: widget.onDismiss,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: IHTheme.heroGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _rarityColor().withValues(alpha: .6), width: 1.5),
            boxShadow: [
              BoxShadow(color: _rarityColor().withValues(alpha: .3),
                blurRadius: 20, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withValues(alpha: .2),
                blurRadius: 10, offset: const Offset(0, 3)),
            ]),
          child: Row(children: [
            Text(widget.achievement.icon,
              style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
              Text(AppStrings.lang(context.read<AppState>().language).newAchievement, style: AppFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: .8))),
              Text(widget.achievement.title, style: AppFonts.lora(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: Colors.white)),
              Text(widget.achievement.description, style: AppFonts.nunito(
                fontSize: 11, color: Colors.white.withValues(alpha: .8))),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _rarityColor().withValues(alpha: .25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _rarityColor().withValues(alpha: .5))),
              child: Text('+${_points()}', style: AppFonts.lora(
                fontSize: 14, fontWeight: FontWeight.w800,
                color: _rarityColor()))),
          ]),
        ),
      ),
    ),
  );

  int _points() {
    switch (widget.achievement.rarity) {
      case AchievementRarity.bronze:   return 10;
      case AchievementRarity.silver:   return 25;
      case AchievementRarity.gold:     return 50;
      case AchievementRarity.platinum: return 100;
    }
  }
}
