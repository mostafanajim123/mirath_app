import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/user_type_card.dart';
import 'tourist_services_screen.dart';
import 'package:video_player/video_player.dart';
import '../data/translations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _heroCtrl;
  late AnimationController _contentCtrl;
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  bool _userTypeChecked = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 700))..forward();
    _contentCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 800));
    _initVideo();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  Future<void> _initVideo() async {
    try {
      _videoCtrl = VideoPlayerController.asset(
        'assets/videos/home_bg.mp4',
      );
      await _videoCtrl!.initialize();
      await _videoCtrl!.setLooping(true);
      await _videoCtrl!.setVolume(0);
      await _videoCtrl!.play();
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {
      _videoReady = false;
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final sw = MediaQuery.of(context).size.width;

    if (!state.isLoading && !_userTypeChecked) {
      _userTypeChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) UserTypeCard.showIfNeeded(context);
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: IHTheme.bgPrimary,
      drawer: state.isLoading ? null : _buildDrawer(context, state),
      body: state.isLoading
        ? const Center(
            child: CircularProgressIndicator(color: IHTheme.primary))
        : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO SLIVER ──────────────────────────────────
          SliverToBoxAdapter(child: _buildHero(context, sw)),

          // ── SEARCH ───────────────────────────────────────
          SliverToBoxAdapter(child: _buildSearch(state)),

          // ── FEATURED SITES ───────────────────────────────
          SliverToBoxAdapter(child: _buildFeatured(state)),

          // ── UNESCO ───────────────────────────────────────
          SliverToBoxAdapter(child: _buildUnesco(state)),

          // ── TOURIST SERVICES BANNER (للسياح فقط) ────────────
          if (state.isTourist)
            SliverToBoxAdapter(child: _buildTouristServicesBanner(state)),

          // ── CHARACTERS ───────────────────────────────────
          SliverToBoxAdapter(child: _buildCharacters(state)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: state.isLoading ? null : _buildNav(context),
      // transparent so floating pill shadow shows
    );
  }

  // ── HERO ──────────────────────────────────────────────────
  Widget _buildHero(BuildContext context, double sw) {
    final state = context.read<AppState>();
    final s = AppStrings.lang(state.language);
    final fade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    final slide = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: _heroCtrl,
      builder: (_, __) => Container(
        height: 360,
        decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
        child: Stack(children: [

          // ── فيديو الخلفية ──────────────────────────────
          if (_videoReady && _videoCtrl != null)
            Positioned.fill(
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width:  _videoCtrl!.value.size.width,
                    height: _videoCtrl!.value.size.height,
                    child: VideoPlayer(_videoCtrl!),
                  ),
                ),
              ),
            ),

          // ── طبقة تعتيم فوق الفيديو ─────────────────────
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _videoReady ? 0.55 : 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xCC2A0E05),
                      Color(0x884A1A08),
                      Color(0xDD1A0804),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── gradient أصلي (يظهر لو ما في فيديو) ────────
          if (!_videoReady)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(gradient: IHTheme.heroGradient))),

          // pattern overlay
          Positioned.fill(child: Opacity(opacity: .06,
            child: Image.asset('assets/images/eras/pattern.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox()))),

          // top bar
          Positioned(top: 0, left: 0, right: 0,
            child: SafeArea(child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 14),
              child: Opacity(opacity: fade.value,
                child: Row(children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 22))),
                const Spacer(),
                const SizedBox(),
                const Spacer(),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                    child: Container(width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.settings_rounded,
                        color: Colors.white, size: 22))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.person_outline_rounded,
                        color: Colors.white, size: 22))),
                ]),
              ])),
            )),
          ),

          // ── ziggurat silhouette decoration ──────────────
          Positioned(bottom: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Opacity(opacity: .10,
                child: CustomPaint(
                  size: Size(sw, 90),
                  painter: _ZigguratPainter())))),

          // ── bottom fade — smooth transition into page ───
          Positioned(bottom: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      IHTheme.bg(context).withValues(alpha: .55),
                      IHTheme.bg(context),
                    ]))))),

          // hero content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Opacity(opacity: fade.value,
                child: Transform.translate(
                  offset: Offset(0, slide.value),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const SizedBox(height: 40),
                    // decorative cuneiform glyph
                    Opacity(opacity: .14,
                      child: Text('𒀭𒂍𒈗',
                        style: TextStyle(fontSize: sw * .11,
                          color: Colors.white, fontWeight: FontWeight.w700,
                          letterSpacing: 4))),
                    const SizedBox(height: 6),
                    // kicker badge — gradient accent line + text
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      Text(s.heroKicker,
                        textAlign: TextAlign.right,
                        style: AppFonts.nunito(fontSize: 11,
                          color: Colors.white.withValues(alpha: .85),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1)),
                      const SizedBox(width: 8),
                      Container(width: 26, height: 2,
                        decoration: BoxDecoration(
                          color: IHTheme.primaryLight,
                          borderRadius: BorderRadius.circular(2))),
                    ]),
                    const SizedBox(height: 14),
                    // main title — right aligned
                    Text(s.heritageTitle,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: AppFonts.cairo(
                        fontSize: sw * .054, fontWeight: FontWeight.w800,
                        color: Colors.white, height: 1.25,
                        shadows: [Shadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 12, offset: const Offset(0, 3))])),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── DRAWER ────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, AppState state) {
    final s = AppStrings.lang(state.language);
    final dark = IHTheme.isDark(context);
    return Drawer(
      backgroundColor: IHTheme.bg(context),
      child: SafeArea(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              Text(s.appTagline,
                style: AppFonts.nunito(fontSize: 12,
                  color: Colors.white.withValues(alpha: .75))),
            ]),
          ),
          const SizedBox(height: 8),
          // Nav items — scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: s.navHome,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerItem(
                  icon: Icons.explore_rounded,
                  label: s.featuredSites,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/all-sites');
                  },
                ),
                _DrawerItem(
                  icon: Icons.map_rounded,
                  label: s.navMap,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/map');
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_search_rounded,
                  label: s.characters,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/characters');
                  },
                ),
                _DrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: s.navChat,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chat');
                  },
                ),
                if (state.isTourist)
                  _DrawerItem(
                    icon: Icons.travel_explore_rounded,
                    label: state.isEnglish ? 'Tourist Services' : 'خدمات السياحة',
                    highlight: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tourist-services');
                    },
                  ),
                _DrawerItem(
                  icon: Icons.emoji_events_outlined,
                  label: s.achievements,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/achievements');
                  },
                ),
                _DrawerItem(
                  icon: Icons.catching_pokemon,
                  label: 'صيد الوحوش العراقية 🐉',
                  highlight: true,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/monster-hunt');
                  },
                ),
                _DrawerItem(
                  icon: Icons.add_location_alt_rounded,
                  label: 'مواقع المجتمع 📍',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/community-sites');
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_active_rounded,
                  label: 'إشعارات المواقع 🔔',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/proximity-settings');
                  },
                ),
              ]),
            ),
          ),
          Divider(color: IHTheme.bdrLight(context)),
          _DrawerItem(
            icon: Icons.person_outline_rounded,
            label: s.navProfile,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          _DrawerItem(
            icon: Icons.settings_rounded,
            label: s.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  // ── SEARCH ────────────────────────────────────────────────
  Widget _buildSearch(AppState state) { final context = this.context; final s = AppStrings.lang(state.language); return FadeTransition(
    opacity: CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: IHCard(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.textPrimary),
          decoration: InputDecoration(
            hintText: s.searchHint,
            hintStyle: AppFonts.nunito(
              fontSize: 13, color: IHTheme.textLight),
            prefixIcon: const Icon(Icons.search_rounded,
              color: IHTheme.primary),
            suffixIcon: const Icon(Icons.tune_rounded,
              color: IHTheme.primaryLight, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14)),
          onChanged: (q) {
            state.setSearch(q);
            if (q.isNotEmpty) {
              Navigator.pushNamed(context, '/all-sites');
            }
          }),
      ),
    ),
  ); }

  // ── FEATURED SITES ────────────────────────────────────────
  Widget _buildFeatured(AppState state) {
    final sites = state.featuredSites.take(10).toList();
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) {
        final v = CurvedAnimation(parent: _contentCtrl,
          curve: const Interval(.1, .7, curve: Curves.easeOut)).value;
        return Opacity(opacity: v,
          child: Transform.translate(
            offset: Offset(0, 20*(1-v)), child: child));
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        IHSectionHeader(title: AppStrings.lang(state.language).featuredSites,
          action: AppStrings.lang(state.language).viewAll,
          onAction: () => Navigator.pushNamed(context, '/all-sites')),
        const SizedBox(height: 14),
        SizedBox(height: 290,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: sites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final delay = (i * .06).clamp(.0, .5);
              return AnimatedBuilder(
                animation: _contentCtrl,
                builder: (_, child) {
                  final v = CurvedAnimation(parent: _contentCtrl,
                    curve: Interval(delay, (delay+.4).clamp(0,1),
                      curve: Curves.easeOutCubic)).value;
                  return Opacity(opacity: v,
                    child: Transform.translate(
                      offset: Offset(0, 20*(1-v)), child: child));
                },
                child: _SiteCard(site: sites[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ── ERAS ──────────────────────────────────────────────────
  Widget _buildEras(AppState state) => AnimatedBuilder(
    animation: _contentCtrl,
    builder: (_, child) {
      final v = CurvedAnimation(parent: _contentCtrl,
        curve: const Interval(.2, .8, curve: Curves.easeOut)).value;
      return Opacity(opacity: v, child: child);
    },
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 28),
      IHSectionHeader(title: AppStrings.lang(state.language).eras,
        action: AppStrings.lang(state.language).viewAll,
        onAction: () => Navigator.pushNamed(context, '/eras')),
      const SizedBox(height: 14),
      SizedBox(height: 130,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: state.eras.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _EraCard(era: state.eras[i]),
        ),
      ),
    ]),
  );

  // ── UNESCO ────────────────────────────────────────────────
  Widget _buildUnesco(AppState state) {
    final sites = state.unescoSites.take(6).toList();
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) {
        final v = CurvedAnimation(parent: _contentCtrl,
          curve: const Interval(.3, .9, curve: Curves.easeOut)).value;
        return Opacity(opacity: v, child: child);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 28),
        IHSectionHeader(title: AppStrings.lang(state.language).unescoSites),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: sites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _UnescoRow(site: sites[i]),
        ),
      ]),
    );
  }

  // ── TOURIST SERVICES BANNER ──────────────────────────────
  Widget _buildTouristServicesBanner(AppState state) {
    final isEn = state.isEnglish;
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) {
        final v = CurvedAnimation(parent: _contentCtrl,
          curve: const Interval(.3, .9, curve: Curves.easeOut)).value;
        return Opacity(opacity: v, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/tourist-services'),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: IHTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: IHTheme.primaryShadow),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('🌍',
                  style: TextStyle(fontSize: 28)))),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isEn ? 'Tourist Services' : 'خدمات السياحة',
                  style: AppFonts.lora(fontSize: 17,
                    fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  isEn
                    ? 'Hotels & certified tour guides'
                    : 'أفضل الفنادق والمرشدون السياحيون',
                  style: AppFonts.nunito(fontSize: 12,
                    color: Colors.white.withValues(alpha: .85))),
              ])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16)),
            ]),
          ),
        ),
      ),
    );
  }

  // ── مراقد أهل البيت ──────────────────────────────────────
  Widget _buildShrines(AppState state) {
    final shrines = state.featuredShrines;
    if (shrines.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) {
        final v = CurvedAnimation(parent: _contentCtrl,
          curve: const Interval(.28, .88, curve: Curves.easeOut)).value;
        return Opacity(opacity: v, child: child);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 28),
        // ── Header مميز بلون ذهبي ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color(0xFFD4AF37), Color(0xFFB8860B)]),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.mosque_rounded,
                color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text('مراقد أهل البيت ع',
                style: AppFonts.amiri(fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB8860B)))),
            TextButton(
              onPressed: () {},
              child: Text(AppStrings.lang(state.language).viewAll,
                style: AppFonts.nunito(fontSize: 12,
                  color: const Color(0xFFB8860B),
                  fontWeight: FontWeight.w700))),
          ])),
        const SizedBox(height: 14),
        SizedBox(height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: shrines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => _ShrineCard(site: shrines[i]),
          )),
      ]),
    );
  }

  // ── CHARACTERS ────────────────────────────────────────────
  Widget _buildCharacters(AppState state) {
    final chars = state.allCharacters.take(6).toList();
    return AnimatedBuilder(
      animation: _contentCtrl,
      builder: (_, child) {
        final v = CurvedAnimation(parent: _contentCtrl,
          curve: const Interval(.35, .95, curve: Curves.easeOut)).value;
        return Opacity(opacity: v, child: child);
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 28),
        IHSectionHeader(title: AppStrings.lang(state.language).characters,
          action: AppStrings.lang(state.language).viewAll,
          onAction: () => Navigator.pushNamed(context, '/characters')),
        const SizedBox(height: 14),
        SizedBox(height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: chars.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _CharCard(char: chars[i]),
          ),
        ),
      ]),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────
  Widget _buildNav(BuildContext context) => _AnimatedBottomNav();
}

// ── SITE CARD ─────────────────────────────────────────────────────────────────
class _SiteCard extends StatefulWidget {
  final Site site;
  const _SiteCard({required this.site});
  @override State<_SiteCard> createState() => _SiteCardState();
}

class _SiteCardState extends State<_SiteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _shimmer;
  bool _pressed = false;

  // Map civilization → gradient colors
  static List<Color> _civColors(String civ) {
    if (civ.contains('بابل') || civ.contains('Bab'))
      return [const Color(0xFF4A6B8B), const Color(0xFF2A3F5F)];
    if (civ.contains('سومر') || civ.contains('Sum'))
      return [const Color(0xFF6B8B4A), const Color(0xFF3F5F2A)];
    if (civ.contains('آشور') || civ.contains('Ass'))
      return [const Color(0xFF8B6B4A), const Color(0xFF5F3F2A)];
    if (civ.contains('إسلام') || civ.contains('Islam'))
      return [const Color(0xFF4A8B6B), const Color(0xFF2A5F3F)];
    if (civ.contains('أكاد') || civ.contains('Akk'))
      return [const Color(0xFF8B4A4A), const Color(0xFF5F2A2A)];
    if (civ.contains('ساسان') || civ.contains('Sas'))
      return [const Color(0xFF6B4A8B), const Color(0xFF3F2A5F)];
    return [IHTheme.primary, IHTheme.primaryLight];
  }

  // Map site type → icon
  static IconData _typeIcon(String type) {
    if (type.contains('زقورة') || type.contains('Zig')) return Icons.account_balance_rounded;
    if (type.contains('مدينة') || type.contains('City')) return Icons.location_city_rounded;
    if (type.contains('متحف') || type.contains('Mus')) return Icons.museum_rounded;
    if (type.contains('قوس') || type.contains('Arch')) return Icons.account_balance_rounded;
    if (type.contains('مسجد') || type.contains('Mosq')) return Icons.mosque_rounded;
    if (type.contains('بوابة') || type.contains('Gate')) return Icons.fort_rounded;
    if (type.contains('قلعة') || type.contains('Castle')) return Icons.castle_rounded;
    return Icons.explore_rounded;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _shimmer = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    final colors = _civColors(widget.site.civilization);

    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true); _ctrl.forward(); },
      onTapUp: (_) { setState(() => _pressed = false); _ctrl.reverse(); },
      onTapCancel: () { setState(() => _pressed = false); _ctrl.reverse(); },
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: widget.site),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: 190,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: _pressed ? .5 : .3),
                  blurRadius: _pressed ? 20 : 14,
                  offset: const Offset(0, 6)),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 4, offset: const Offset(0, 2)),
              ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── IMAGE / ILLUSTRATION AREA ─────────────────────
                SizedBox(
                  height: 138,
                  child: Stack(children: [
                    // gradient background (always visible, behind image)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors[0], colors[1]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)))),
                    // real site image
                    Positioned.fill(
                      child: Image.asset(
                        widget.site.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    // darken overlay for text legibility
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: .05),
                              Colors.black.withValues(alpha: .25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // bottom fade
                    Positioned(bottom: 0, left: 0, right: 0,
                      child: Container(height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent,
                              colors[1].withValues(alpha: .8)])))),
                    // UNESCO badge
                    if (widget.site.isUnesco)
                      Positioned(top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: .15),
                              blurRadius: 6)]),
                          child: Text('UNESCO', style: AppFonts.nunito(
                            fontSize: 8, fontWeight: FontWeight.w800,
                            color: IHTheme.primary)))),
                    // civilization badge bottom left
                    Positioned(bottom: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .4), width: 1)),
                        child: Text(widget.site.civilizationFor(lang), style: AppFonts.nunito(
                          fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)))),
                  ]),
                ),
                // ── CONTENT AREA ──────────────────────────────────
                Container(
                  color: IHTheme.bgCard,
                  padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    Text(widget.site.nameFor(lang),
                      style: AppFonts.lora(fontSize: 13,
                        fontWeight: FontWeight.w700, color: IHTheme.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: colors[0].withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(6)),
                        child: Icon(Icons.location_on_rounded,
                          size: 11, color: colors[0])),
                      const SizedBox(width: 4),
                      Flexible(child: Text(widget.site.cityFor(lang), style: AppFonts.nunito(
                        fontSize: 11, color: IHTheme.textMuted),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors[0].withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(widget.site.builtYearFor(lang), style: AppFonts.nunito(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: colors[0]),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── SHRINE CARD ───────────────────────────────────────────────────────────────
class _ShrineCard extends StatefulWidget {
  final Site site;
  const _ShrineCard({required this.site});
  @override State<_ShrineCard> createState() => _ShrineCardState();
}

class _ShrineCardState extends State<_ShrineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 160));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: widget.site),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: 175,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: .25),
                  blurRadius: 16, offset: const Offset(0, 6)),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .08),
                  blurRadius: 8, offset: const Offset(0, 2)),
              ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── صورة المرقد ───────────────────────────────
                SizedBox(height: 120,
                  child: Stack(fit: StackFit.expand, children: [
                    IHImage(url: widget.site.imageUrl, fit: BoxFit.cover),
                    // overlay ذهبي خفيف
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF1A0A00).withValues(alpha: .7),
                          ]))),
                    // شارة "مرقد مقدس"
                    Positioned(top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFD4AF37), Color(0xFF9A7A1A)]),
                          borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded,
                            color: Colors.white, size: 9),
                          const SizedBox(width: 3),
                          Text(AppStrings.lang(lang).sacredShrine, style: AppFonts.nunito(
                            fontSize: 8, fontWeight: FontWeight.w800,
                            color: Colors.white)),
                        ]))),
                    // اسم المدينة في الأسفل
                    Positioned(bottom: 8, left: 10,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_on_rounded,
                          color: Colors.white70, size: 11),
                        const SizedBox(width: 3),
                        Text(widget.site.cityFor(lang), style: AppFonts.nunito(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: Colors.white70)),
                      ])),
                  ])),
                // ── معلومات المرقد ─────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8E7), Color(0xFFFFF0C8)]),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: .3),
                      width: .8)),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(widget.site.nameFor(lang),
                      style: AppFonts.amiri(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        color: const Color(0xFF5C3A1A)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(widget.site.descFor(lang),
                      style: AppFonts.nunito(
                        fontSize: 9.5, color: const Color(0xFF7A5A3A),
                        height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  ])),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── HEX PATTERN PAINTER ───────────────────────────────────────────────────────
class _HexPatternPainter extends CustomPainter {
  final Color color;
  const _HexPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1;
    const r = 14.0;
    const h = r * 1.732;
    for (double y = -r; y < size.height + r; y += h) {
      for (double x = -r; x < size.width + r; x += r * 3) {
        final offset = (y ~/ h) % 2 == 0 ? 0.0 : r * 1.5;
        _drawHex(canvas, paint, Offset(x + offset, y), r);
      }
    }
  }

  void _drawHex(Canvas c, Paint p, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * 3.14159 / 180;
      final pt = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    c.drawPath(path, p);
  }

  @override bool shouldRepaint(_HexPatternPainter old) => old.color != color;
}

// ── ERA CARD ──────────────────────────────────────────────────────────────────
class _EraCard extends StatelessWidget {
  final Map<String, String> era;
  const _EraCard({required this.era});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(era['color']!));
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/eras'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: .7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(
            color: color.withValues(alpha: .3),
            blurRadius: 10, offset: const Offset(0, 4))]),
        child: Stack(children: [
          // صورة الحقبة
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IHImage(url: era['image'] ?? '', fit: BoxFit.cover))),
          // تدرج غامق فوق الصورة
          Positioned.fill(child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [color.withValues(alpha: .55), color.withValues(alpha: .85)],
                begin: Alignment.topLeft, end: Alignment.bottomRight)))),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(era['name']!, style: AppFonts.lora(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white,
                height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(era['period']!, style: AppFonts.nunito(
                  fontSize: 9, color: Colors.white.withValues(alpha: .8),
                  fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── UNESCO ROW ────────────────────────────────────────────────────────────────
class _UnescoRow extends StatelessWidget {
  final Site site;
  const _UnescoRow({required this.site});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    return GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/detail', arguments: site),
    child: IHCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(children: [
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                color: IHTheme.primary, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Expanded(child: Text(site.nameFor(lang), style: AppFonts.lora(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: IHTheme.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 5),
          Text(site.descFor(lang), style: AppFonts.nunito(
            fontSize: 11, color: IHTheme.textMuted, height: 1.4),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_rounded, size: 11, color: IHTheme.primary),
            const SizedBox(width: 3),
            Text(site.governorateFor(lang), style: AppFonts.nunito(
              fontSize: 10, color: IHTheme.textSecondary)),
            const SizedBox(width: 10),
            const Icon(Icons.history_rounded, size: 11, color: IHTheme.primaryLight),
            const SizedBox(width: 3),
            Text(site.builtYearFor(lang), style: AppFonts.nunito(
              fontSize: 10, color: IHTheme.textMuted)),
          ]),
        ])),
        const SizedBox(width: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IHImage(url: site.imageUrl, width: 72, height: 72)),
      ]),
    ),
  );
  }
}

// ── CHAR CARD ─────────────────────────────────────────────────────────────────
class _CharCard extends StatefulWidget {
  final HistoricalCharacter char;
  const _CharCard({required this.char});
  @override State<_CharCard> createState() => _CharCardState();
}

class _CharCardState extends State<_CharCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _float;

  // Map role → icon
  static IconData _roleIcon(String role) {
    if (role.contains('ملك') || role.contains('King')) return Icons.account_balance_rounded;
    if (role.contains('نبي') || role.contains('Prophet')) return Icons.auto_awesome_rounded;
    if (role.contains('عالم') || role.contains('Scholar')) return Icons.menu_book_rounded;
    if (role.contains('شاعر') || role.contains('Poet')) return Icons.edit_note_rounded;
    if (role.contains('قائد') || role.contains('General')) return Icons.shield_rounded;
    if (role.contains('طبيب') || role.contains('Doctor')) return Icons.local_hospital_rounded;
    return Icons.person_rounded;
  }

  // Map civilization → accent color
  static Color _civColor(String civ) {
    if (civ.contains('بابل')) return const Color(0xFF4A6B8B);
    if (civ.contains('سومر')) return const Color(0xFF6B8B4A);
    if (civ.contains('آشور')) return const Color(0xFF8B6B4A);
    if (civ.contains('إسلام')) return const Color(0xFF4A8B6B);
    if (civ.contains('أكاد')) return const Color(0xFF8B4A4A);
    return IHTheme.primary;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 180));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _float = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppState>().language;
    final accent = _civColor(widget.char.civilization);
    final icon = _roleIcon(widget.char.role);
    final charName = widget.char.nameFor(lang);
    final initials = charName.isNotEmpty
      ? charName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
      : '؟';

    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); },
      onTapUp: (_) { _ctrl.reverse(); },
      onTapCancel: () { _ctrl.reverse(); },
      onTap: () => Navigator.pushNamed(context, '/char-detail', arguments: widget.char),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: SizedBox(
          width: 130,
          child: Container(
            decoration: BoxDecoration(
              color: IHTheme.bgCard,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: .25),
                  blurRadius: 12, offset: const Offset(0, 5)),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .06),
                  blurRadius: 3, offset: const Offset(0, 1)),
              ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: [
                // ── AVATAR AREA ───────────────────────────────
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: .65)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Stack(children: [
                    // pattern
                    Positioned.fill(child: CustomPaint(
                      painter: _HexPatternPainter(
                        color: Colors.white.withValues(alpha: .07)))),
                    // avatar circle with image or initials
                    Center(child: Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .35), width: 2)),
                      child: ClipOval(
                        child: IHImage(
                          url: widget.char.imageUrl,
                          width: 58, height: 58,
                          fit: BoxFit.cover,
                        ),
                      ))),
                    // role icon badge - top right
                    Positioned(top: 8, right: 8,
                      child: Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          shape: BoxShape.circle),
                        child: Icon(icon, color: Colors.white, size: 13))),
                    // bottom fade
                    Positioned(bottom: 0, left: 0, right: 0,
                      child: Container(height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent,
                              accent.withValues(alpha: .5)])))),
                    // civilization tag
                    Positioned(bottom: 7, left: 0, right: 0,
                      child: Center(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: .3))),
                        child: Text(widget.char.civilizationFor(lang),
                          style: AppFonts.nunito(fontSize: 8,
                            fontWeight: FontWeight.w700, color: Colors.white),
                          maxLines: 1, overflow: TextOverflow.ellipsis)))),
                  ]),
                ),
                // ── INFO AREA ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 9, 8, 11),
                  child: Column(children: [
                    Text(charName,
                      style: AppFonts.lora(fontSize: 12,
                        fontWeight: FontWeight.w700, color: IHTheme.textPrimary),
                      textAlign: TextAlign.center,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(widget.char.eraFor(lang),
                        style: AppFonts.nunito(fontSize: 9,
                          fontWeight: FontWeight.w600, color: accent),
                        textAlign: TextAlign.center,
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── NAV ITEM ──────────────────────────────────────────────────────────────────
// ── ANIMATED BOTTOM NAV ───────────────────────────────────────────────────────
class _AnimatedBottomNav extends StatefulWidget {
  @override State<_AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<_AnimatedBottomNav>
    with TickerProviderStateMixin {
  int _selected = 0;
  late AnimationController _pulseCtrl;
  late AnimationController _glowCtrl;
  late Animation<double> _pulse;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _glowCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override void dispose() {
    _pulseCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onTap(int idx, VoidCallback action) {
    setState(() => _selected = idx);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.lang(context.read<AppState>().language);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
      ? const Color(0xFF1E1208).withValues(alpha: .96)
      : const Color(0xFFFFF8F0).withValues(alpha: .97);
    final borderColor = isDark
      ? IHTheme.primary.withValues(alpha: .25)
      : IHTheme.primary.withValues(alpha: .18);

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 4),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // ── Floating pill bar ──
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                decoration: BoxDecoration(
                  color: navBg,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: IHTheme.primary.withValues(alpha: .18),
                      blurRadius: 24, spreadRadius: 0,
                      offset: const Offset(0, 8)),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .10),
                      blurRadius: 12, offset: const Offset(0, 4)),
                    // inner top highlight
                    BoxShadow(
                      color: Colors.white.withValues(alpha: isDark ? .04 : .8),
                      blurRadius: 1, spreadRadius: 0,
                      offset: const Offset(0, -1)),
                  ]),
                child: Row(
                  children: [
                    // Left two items
                    Expanded(child: Row(
                      children: [
                        Expanded(child: _NavItem(icon: Icons.home_rounded,   label: s.navHome,
                          selected: _selected == 0,
                          onTap: () => _onTap(0, () {}))),
                        Expanded(child: _NavItem(icon: Icons.explore_rounded, label: s.navSites,
                          selected: _selected == 1,
                          onTap: () => _onTap(1,
                            () => Navigator.pushNamed(context, '/all-sites')))),
                      ],
                    )),
                    // Center spacer for FAB
                    const SizedBox(width: 72),
                    // Right two items
                    Expanded(child: Row(
                      children: [
                        Expanded(child: _NavItem(icon: Icons.map_rounded,    label: s.navMap,
                          selected: _selected == 2,
                          onTap: () => _onTap(2,
                            () => Navigator.pushNamed(context, '/map')))),
                        Expanded(child: _NavItem(icon: Icons.person_rounded, label: s.navProfile,
                          selected: _selected == 3,
                          onTap: () => _onTap(3,
                            () => Navigator.pushNamed(context, '/profile')))),
                      ],
                    )),
                  ],
                ),
              ),

              // ── Center FAB — lifted above bar ──
              Positioned(
                top: -22,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                  child: SizedBox(
                    width: 72, height: 72,
                    child: Stack(alignment: Alignment.center, children: [

                      // Outer glow ring 1
                      AnimatedBuilder(
                        animation: _glow,
                        builder: (_, __) => Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: IHTheme.primary.withValues(alpha: _glow.value * .35),
                              blurRadius: 24, spreadRadius: 4)]))),

                      // Outer ring — cuneiform frame
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) => Transform.scale(
                          scale: _pulse.value, child: child),
                        child: Container(
                          width: 66, height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(colors: [
                              IHTheme.primaryLight.withValues(alpha: .0),
                              IHTheme.primary.withValues(alpha: .6),
                              IHTheme.primaryDark.withValues(alpha: .3),
                              IHTheme.primaryLight.withValues(alpha: .0),
                            ])))),

                      // Main button circle
                      Container(
                        width: 58, height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFDFA48A),
                              Color(0xFFC4785A),
                              Color(0xFF9E5C42),
                              Color(0xFF7A3E2A),
                            ]),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9E5C42).withValues(alpha: .55),
                              blurRadius: 18, offset: const Offset(0, 6)),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .2),
                              blurRadius: 8, offset: const Offset(0, 3)),
                          ]),
                        child: Stack(alignment: Alignment.center, children: [
                          // Cuneiform engraving lines — decorative
                          CustomPaint(
                            size: const Size(58, 58),
                            painter: _CuneiformRingPainter()),
                          // Symbol
                          const Text('𒀭',
                            style: TextStyle(fontSize: 28, color: Colors.white,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 4)])),
                        ])),

                      // Top highlight shimmer
                      Positioned(
                        top: 7, left: 18,
                        child: Container(
                          width: 22, height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(colors: [
                              Colors.white.withValues(alpha: .55),
                              Colors.white.withValues(alpha: 0),
                            ])))),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Decorative cuneiform ring lines on center button
class _CuneiformRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 5;
    // Dashed circle
    const segments = 24;
    for (int i = 0; i < segments; i++) {
      if (i % 2 == 0) continue;
      final a1 = (i / segments) * 2 * pi;
      final a2 = ((i + 0.7) / segments) * 2 * pi;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r),
        a1, a2 - a1, false, paint);
    }
    // 8 small radial tick marks
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: .25)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi - pi / 2;
      final x1 = cx + cos(angle) * (r - 4);
      final y1 = cy + sin(angle) * (r - 4);
      final x2 = cx + cos(angle) * (r + 1);
      final y2 = cy + sin(angle) * (r + 1);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }
  }
  @override bool shouldRepaint(_CuneiformRingPainter old) => false;
}

// ── ZIGGURAT SILHOUETTE PAINTER ───────────────────────────────────────────────
class _ZigguratPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    void tower(double cx, double baseW, double h, double levels) {
      final levelH = h / levels;
      for (int i = 0; i < levels; i++) {
        final w = baseW * (1 - i / levels * .55);
        final rect = Rect.fromCenter(
          center: Offset(cx, size.height - i * levelH - levelH / 2),
          width: w, height: levelH - 3);
        canvas.drawRect(rect, paint);
      }
    }
    tower(size.width * .18, 70, 60, 3);
    tower(size.width * .5, 110, 85, 4);
    tower(size.width * .82, 60, 50, 3);
  }
  @override bool shouldRepaint(_ZigguratPainter old) => false;
}

// ── NAV ITEM ──────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final IconData icon; final String label;
  final bool selected; final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
    required this.selected, required this.onTap});
  @override State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 320));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.78), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.08), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0),  weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _lift = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -7.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 0.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _lift.value),
          child: Transform.scale(scale: _scale.value, child: child)),
        child: Column(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 40, height: 24,
              decoration: BoxDecoration(
                gradient: widget.selected ? LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [IHTheme.primaryLight, IHTheme.primary, IHTheme.primaryDark])
                  : null,
                color: widget.selected ? null
                  : (isDark
                    ? Colors.white.withValues(alpha: .05)
                    : IHTheme.primary.withValues(alpha: .07)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: widget.selected ? [
                  BoxShadow(
                    color: IHTheme.primary.withValues(alpha: .45),
                    blurRadius: 12, offset: const Offset(0, 4)),
                  BoxShadow(
                    color: IHTheme.primaryLight.withValues(alpha: .3),
                    blurRadius: 6, offset: const Offset(0, -1)),
                ] : null),
              child: Stack(alignment: Alignment.center, children: [
                // Inner top sheen
                if (widget.selected)
                  Positioned(top: 3, left: 8,
                    child: Container(width: 14, height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white.withValues(alpha: .3)))),
                Icon(widget.icon,
                  color: widget.selected ? Colors.white
                    : (isDark ? IHTheme.darkTextMuted : IHTheme.textMuted),
                  size: 17),
              ])),
            const SizedBox(height: 1),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppFonts.nunito(
                fontSize: 9.5,
                fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w500,
                color: widget.selected ? IHTheme.primary
                  : (isDark ? IHTheme.darkTextMuted : IHTheme.textMuted),
                letterSpacing: widget.selected ? .3 : 0),
              child: Text(widget.label, maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center)),
            // Animated dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: widget.selected ? 4 : 0,
              height: widget.selected ? 4 : 0,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: IHTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: IHTheme.primary.withValues(alpha: widget.selected ? .6 : 0),
                    blurRadius: 6, spreadRadius: 1)
                ])),
          ]),
      ),
    );
  }
}

// ── DRAWER ITEM ───────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  const _DrawerItem({required this.icon, required this.label,
    required this.onTap, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    if (highlight) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: IHTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: IHTheme.primaryShadow),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
              const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white60, size: 14),
            ]),
          ),
        ),
      );
    }
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: IHTheme.prim(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: IHTheme.prim(context), size: 20)),
      title: Text(label, style: AppFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: IHTheme.txtPrimary(context))),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
