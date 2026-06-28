import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../data/translations.dart';

// ═══════════════════════════════════════════════════════════════
//  USER TYPE CARD — World-class, cinematic onboarding dialog
// ═══════════════════════════════════════════════════════════════

class UserTypeCard extends StatefulWidget {
  const UserTypeCard({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final state = context.read<AppState>();
    if (state.hasSeenUserTypeDialog || state.userType != null) return;
    // Mark as seen immediately (before the dialog even opens) so that any
    // other pending call to showIfNeeded (e.g. from another HomeScreen
    // instance) can never trigger a second dialog.
    state.markUserTypeDialogSeen();
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .85),
      transitionDuration: const Duration(milliseconds: 700),
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutExpo);
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: ScaleTransition(
            scale: Tween(begin: 0.88, end: 1.0).animate(curved),
            child: child));
      },
      pageBuilder: (_, __, ___) => const UserTypeCard(),
    );
  }

  @override State<UserTypeCard> createState() => _UserTypeCardState();
}

class _UserTypeCardState extends State<UserTypeCard>
    with TickerProviderStateMixin {

  String? _selected;
  String? _hovering;

  // Video
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  // Controllers
  late final AnimationController _bgAnim;      // Shifting bg gradient
  late final AnimationController _orbAnim;     // Floating orbs
  late final AnimationController _shimmerAnim; // Gold shimmer sweep
  late final AnimationController _entryAnim;   // Stagger entry
  late final AnimationController _particleAnim;// Particle burst on select
  late final AnimationController _btnAnim;     // Button pulse

  late final Animation<double> _headerSlide;
  late final Animation<double> _card1Slide;
  late final Animation<double> _card2Slide;
  late final Animation<double> _footerSlide;

  static const _iraqiGrad  = [Color(0xFF0F5132), Color(0xFF1B7A4A), Color(0xFF0A3D25)];
  static const _touristGrad = [Color(0xFF0D2F5E), Color(0xFF1A5FAB), Color(0xFF081C3A)];
  static const _goldColor   = Color(0xFFE8B84B);
  static const _bgDeep      = Color(0xFF080B14);
  static const _bgMid       = Color(0xFF0D1220);

  @override
  void initState() {
    super.initState();

    _bgAnim = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
    _orbAnim = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _shimmerAnim = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _entryAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _particleAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _btnAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _headerSlide = CurvedAnimation(
      parent: _entryAnim,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutExpo));
    _card1Slide = CurvedAnimation(
      parent: _entryAnim,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutExpo));
    _card2Slide = CurvedAnimation(
      parent: _entryAnim,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutExpo));
    _footerSlide = CurvedAnimation(
      parent: _entryAnim,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutExpo));

    _entryAnim.forward();

    // Init video
    _videoCtrl = VideoPlayerController.asset('assets/videos/usertype_bg.mp4')
      ..initialize().then((_) {
        if (mounted) {
          _videoCtrl!.setLooping(true);
          _videoCtrl!.setVolume(0);
          _videoCtrl!.play();
          setState(() => _videoReady = true);
        }
      }).catchError((_) {
        if (mounted) setState(() => _videoReady = false);
      });
  }

  @override
  void dispose() {
    _bgAnim.dispose(); _orbAnim.dispose(); _shimmerAnim.dispose();
    _entryAnim.dispose(); _particleAnim.dispose(); _btnAnim.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _onSelect(String type) {
    HapticFeedback.mediumImpact();
    setState(() => _selected = _selected == type ? null : type);
    _particleAnim.forward(from: 0);
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    HapticFeedback.heavyImpact();
    await context.read<AppState>().setUserType(_selected!);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sw  = MediaQuery.of(context).size.width;
    final sh  = MediaQuery.of(context).size.height;
    final lang = context.watch<AppState>().language;
    final cardW = (sw > 600 ? 520.0 : sw - 24.0);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: cardW,
          child: AnimatedBuilder(
            animation: Listenable.merge([_bgAnim, _orbAnim, _shimmerAnim, _entryAnim, _particleAnim, _btnAnim]),
            builder: (ctx, _) => _buildCard(ctx, cardW, sh, lang),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, double w, double sh, String lang) {
    return Container(
      constraints: BoxConstraints(maxHeight: sh * .92),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .75), blurRadius: 80, spreadRadius: 8),
          BoxShadow(
            color: (_selected == 'iraqi'
              ? const Color(0xFF1B7A4A)
              : _selected == 'tourist'
                ? const Color(0xFF1A5FAB)
                : _goldColor).withValues(alpha: .18 + _btnAnim.value * .1),
            blurRadius: 60, spreadRadius: -4),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Stack(clipBehavior: Clip.none, children: [

            // ── Animated deep background ────────────────────
            _buildBackground(w, sh),

            // ── Animated orbs ───────────────────────────────
            _buildOrbs(w, sh * .92),

            // ── Particle burst on selection ──────────────────
            if (_particleAnim.value > 0 && _particleAnim.value < 1)
              _buildParticles(w, sh * .92),

            // ── Shimmer line sweep ───────────────────────────
            _buildShimmerLine(w, sh * .92),

            // ── Content ──────────────────────────────────────
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [

                // Top badge
                _buildBadge(lang),

                // Header
                FadeTransition(opacity: _headerSlide,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, -.3), end: Offset.zero)
                      .animate(_headerSlide),
                    child: _buildHeader(lang, w))),

                // Card 1 — Iraqi
                FadeTransition(opacity: _card1Slide,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(-.15, 0), end: Offset.zero)
                      .animate(_card1Slide),
                    child: _buildChoiceCard(
                      context: context,
                      type: 'iraqi',
                      icon: '𒀭',
                      symbol: '𒈙',
                      imagePath: 'assets/images/usertype/iraqi.png', // ✓
                      gradColors: _iraqiGrad,
                      glowColor: const Color(0xFF1B7A4A),
                      titleAr: 'عراقي مستكشف',
                      titleEn: 'Iraqi Explorer',
                      titleKu: 'کاشێکی عێراقی',
                      descAr: 'أنت ابن هذه الأرض — اكتشف تراث أجدادك',
                      descEn: 'You are the land\'s child — uncover your ancestors',
                      descKu: 'تۆ کوڕی ئەم خاکیت — میراتی باپیرەکانت بدۆزەرەوە',
                      tagAr: 'ابن الرافدين ✦',
                      tagEn: 'Son of Mesopotamia ✦',
                      tagKu: 'کوڕی مێزۆپۆتامیا ✦',
                      lang: lang,
                    ))),

                const SizedBox(height: 2),

                // Divider with cuneiform
                _buildDivider(),

                const SizedBox(height: 2),

                // Card 2 — Tourist
                FadeTransition(opacity: _card2Slide,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(.15, 0), end: Offset.zero)
                      .animate(_card2Slide),
                    child: _buildChoiceCard(
                      context: context,
                      type: 'tourist',
                      icon: '𒌓',
                      symbol: '𒀭',
                      imagePath: 'assets/images/usertype/tourist.png',
                      gradColors: _touristGrad,
                      glowColor: const Color(0xFF1A5FAB),
                      titleAr: 'سائح أجنبي',
                      titleEn: 'Foreign Tourist',
                      titleKu: 'گەشتیاری بیانی',
                      descAr: 'مرحباً في حضارة خمسة آلاف سنة',
                      descEn: 'Welcome to 5,000 years of civilization',
                      descKu: 'بەخێربێیت بۆ 5,000 ساڵ شارستانی',
                      tagAr: 'مستكشف العالم ✦',
                      tagEn: 'World Explorer ✦',
                      tagKu: 'گەشتیاری جیهانی ✦',
                      lang: lang,
                    ))),

                // Confirm button
                FadeTransition(opacity: _footerSlide,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .3), end: Offset.zero)
                      .animate(_footerSlide),
                    child: _buildConfirmButton(lang))),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
              ]),
            ),

            // ── زر تغيير اللغة ───────────────────────────────
            Positioned(
              top: 16, left: 16,
              child: _buildLanguageButton(context, lang),
            ),

          ]),
        ),
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────────────────────
  Widget _buildBackground(double w, double sh) {
    final t = _bgAnim.value;
    final selColor = _selected == 'iraqi'
      ? Color.lerp(const Color(0xFF0A2A18), const Color(0xFF0D3520), t)!
      : _selected == 'tourist'
        ? Color.lerp(const Color(0xFF08172E), const Color(0xFF0A2045), t)!
        : Color.lerp(_bgDeep, _bgMid, t)!;

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              selColor,
              Color.lerp(const Color(0xFF0A0D18), const Color(0xFF080A12), t)!,
              const Color(0xFF060810),
            ],
            stops: const [0, .55, 1],
          ),
        ),
        child: CustomPaint(painter: _GridPainter(_bgAnim.value)),
      ),
    );
  }

  // ── Floating orbs ───────────────────────────────────────────────────────────
  Widget _buildOrbs(double w, double h) {
    final t   = _orbAnim.value;
    final sel = _selected;
    final c1  = sel == 'iraqi'
      ? const Color(0xFF1B7A4A)
      : sel == 'tourist' ? const Color(0xFF1A5FAB) : _goldColor;

    return Positioned.fill(child: Stack(children: [
      // Big orb top-right
      Positioned(
        right: -w * .15 + sin(t * pi) * 12,
        top:   -h * .05 + cos(t * pi) * 8,
        child: _orb(w * .55, c1.withValues(alpha: .07 + t * .04))),
      // Medium orb bottom-left
      Positioned(
        left:   -w * .1 + cos(t * pi) * 10,
        bottom: h * .1  + sin(t * pi) * 6,
        child:  _orb(w * .4,  const Color(0xFF9E5C42).withValues(alpha: .06 + t * .03))),
      // Small orb center
      Positioned(
        left:  w * .3 + sin(t * pi * 1.3) * 15,
        top:   h * .35 + cos(t * pi * 0.9) * 12,
        child: _orb(w * .18, c1.withValues(alpha: .04))),
    ]));
  }

  Widget _orb(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent])));

  // ── Particles on select ─────────────────────────────────────────────────────
  Widget _buildParticles(double w, double h) {
    final t = _particleAnim.value;
    final color = _selected == 'iraqi'
      ? const Color(0xFF2ECC71) : const Color(0xFF3498DB);

    return Positioned.fill(child: CustomPaint(
      painter: _ParticlePainter(t, w, h, color)));
  }

  // ── Shimmer sweep ───────────────────────────────────────────────────────────
  Widget _buildShimmerLine(double w, double h) {
    final t = _shimmerAnim.value;
    return Positioned(
      top: 0, left: 0, right: 0, bottom: 0,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + t * 4, -1),
              end:   Alignment(-1.0 + t * 4,  1),
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: .015),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Welcome pill ─────────────────────────────────────────────────────────────
  Widget _buildWelcomePill(String lang) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9E5C42), Color(0xFFE8B84B), Color(0xFF9E5C42)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: _goldColor.withValues(alpha: .4), blurRadius: 20, spreadRadius: 0),
            BoxShadow(color: Colors.black.withValues(alpha: .4), blurRadius: 8, offset: const Offset(0, 3)),
          ],
          border: Border.all(color: _goldColor.withValues(alpha: .5), width: .5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('𒀭', style: TextStyle(fontSize: 15, color: Colors.white)),
          const SizedBox(width: 8),
          Text(
            lang == 'ar' ? 'مرحباً بك في ميراث' : lang == 'ku' ? 'بەخێربێیت بۆ میراث' : 'Welcome to Heritage',
            style: AppFonts.lora(fontSize: 12.5, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: .3)),
          const SizedBox(width: 8),
          const Text('𒀭', style: TextStyle(fontSize: 15, color: Colors.white)),
        ]),
      ),
    );
  }

  // ── Badge (animated cuneiform strip) ────────────────────────────────────────
  Widget _buildLanguageButton(BuildContext context, String lang) {
    const labels = {'ar': 'عربي', 'en': 'English', 'ku': 'کوردی'};
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<AppState>().toggleLanguage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: .3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.language_rounded, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(labels[lang] ?? 'عربي', style: AppFonts.nunito(
            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _buildBadge(String lang) {
    return Container(
      margin: const EdgeInsets.only(top: 28, bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ...['𒀭','𒂗','𒆳','𒅗','𒂦'].map((s) => AnimatedBuilder(
          animation: _shimmerAnim,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Opacity(
              opacity: (.25 + .45 * sin(_shimmerAnim.value * 2 * pi +
                ['𒀭','𒂗','𒆳','𒅗','𒂦'].indexOf(s) * .8)).clamp(.1, .9),
              child: Text(s, style: TextStyle(
                fontSize: 14,
                color: _goldColor.withValues(alpha: .8),
              )),
            ),
          ),
        )),
      ]),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(String lang, double w) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(children: [

        // Video header
        Container(
          width: w - 48,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _goldColor.withValues(alpha: .2), width: 1),
            color: Colors.black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(fit: StackFit.expand, children: [

              // Video
              if (_videoReady && _videoCtrl != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoCtrl!.value.size.width,
                    height: _videoCtrl!.value.size.height,
                    child: VideoPlayer(_videoCtrl!),
                  ),
                )
              else
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A0F2E),
                        Color(0xFF2A1508),
                        Color(0xFF0D1220),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('𒀭', style: TextStyle(fontSize: 32, color: Color(0xFFE8B84B))),
                        const SizedBox(height: 4),
                        Text('ميراث العراق',
                          style: TextStyle(fontSize: 14, color: Color(0xFFE8B84B), fontFamily: 'Lora', fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),

              // Dark overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .15),
                      Colors.black.withValues(alpha: .45),
                    ],
                  ),
                ),
              ),

              // Gold shimmer on video
              AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-2 + _shimmerAnim.value * 5, -1),
                      end:   Alignment(-1.5 + _shimmerAnim.value * 5, 1),
                      colors: [
                        Colors.transparent,
                        _goldColor.withValues(alpha: .07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom gold line
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      _goldColor.withValues(alpha: .5),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 14),

        // Title
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [
              Colors.white,
              _goldColor,
              Colors.white,
            ],
            stops: [
              (0.0 + _shimmerAnim.value * 1.5).clamp(0, 1) - .3,
              (_shimmerAnim.value * 1.5).clamp(0, 1),
              (_shimmerAnim.value * 1.5 + .3).clamp(0, 1),
            ],
          ).createShader(b),
          child: Text(
            lang == 'ar' ? 'من أنت؟' : lang == 'ku' ? 'تۆ کێیت؟' : 'Who Are You?',
            style: AppFonts.lora(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: Colors.white, letterSpacing: -.3, height: 1),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _goldColor.withValues(alpha: .12)),
          ),
          child: Text(
            lang == 'ar'
              ? 'اختر هويتك لنصمم رحلتك التراثية'
              : lang == 'ku'
                ? 'ناسنامەکەت هەڵبژێرە تا گەشتی تایبەتت دیزاین بکەین'
                : 'Choose your identity to craft your heritage journey',
            style: AppFonts.nunito(fontSize: 13,
              color: Colors.white.withValues(alpha: .6), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }

  // ── Choice card ──────────────────────────────────────────────────────────────
  Widget _buildChoiceCard({
    required BuildContext context,
    required String type,
    required String icon,
    required String symbol,
    String? imagePath,
    required List<Color> gradColors,
    required Color glowColor,
    required String titleAr, required String titleEn, required String titleKu,
    required String descAr,  required String descEn,  required String descKu,
    required String tagAr,   required String tagEn,   required String tagKu,
    required String lang,
  }) {
    final isSelected = _selected == type;
    final title = lang == 'ar' ? titleAr : lang == 'ku' ? titleKu : titleEn;
    final desc  = lang == 'ar' ? descAr  : lang == 'ku' ? descKu  : descEn;
    final tag   = lang == 'ar' ? tagAr   : lang == 'ku' ? tagKu   : tagEn;

    return GestureDetector(
      onTap: () => _onSelect(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutExpo,
          padding: EdgeInsets.all(isSelected ? 1.5 : 1),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(
              colors: [glowColor.withValues(alpha: .8), gradColors[0], glowColor.withValues(alpha: .6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ) : null,
            color: isSelected ? null : Colors.white.withValues(alpha: .07),
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected ? [
              BoxShadow(color: glowColor.withValues(alpha: .5), blurRadius: 32, spreadRadius: -2, offset: const Offset(0, 8)),
              BoxShadow(color: glowColor.withValues(alpha: .25), blurRadius: 60, spreadRadius: -8),
            ] : [],
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: isSelected
                ? LinearGradient(
                    colors: [gradColors[0], gradColors[1], gradColors[2]],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    stops: const [0, .5, 1])
                : LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: .06),
                      Colors.white.withValues(alpha: .03),
                    ],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: isSelected ? null : Border.all(
                color: Colors.white.withValues(alpha: .1)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

              // ── Icon box ──────────────────────────────────
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, isSelected ? sin(_orbAnim.value * pi) * 5 : 0),
                  child: _buildIconBox(icon, symbol, imagePath, gradColors, glowColor, isSelected),
                ),
              ),

              const SizedBox(width: 16),

              // ── Text ──────────────────────────────────────
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title row
                  Row(children: [
                    Flexible(child: Text(title,
                      style: AppFonts.lora(
                        fontSize: 17, fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: isSelected ? [Shadow(
                          color: glowColor.withValues(alpha: .5), blurRadius: 12)] : null,
                      ))),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        builder: (_, v, __) => Transform.scale(
                          scale: v,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .95),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(
                                color: glowColor.withValues(alpha: .6), blurRadius: 8)]),
                            child: Icon(Icons.check_rounded,
                              size: 14,
                              color: gradColors[0]))),
                      ),
                    ],
                  ]),

                  const SizedBox(height: 5),

                  // Description
                  Text(desc,
                    style: AppFonts.nunito(fontSize: 12.5, height: 1.45,
                      color: Colors.white.withValues(alpha: isSelected ? .82 : .55))),

                  const SizedBox(height: 10),

                  // Tag
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [
                        glowColor.withValues(alpha: .4),
                        glowColor.withValues(alpha: .2),
                      ]) : null,
                      color: isSelected ? null : Colors.white.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                          ? glowColor.withValues(alpha: .5)
                          : Colors.white.withValues(alpha: .1)),
                    ),
                    child: Text(tag,
                      style: AppFonts.nunito(fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: isSelected ? .95 : .4),
                        letterSpacing: .2)),
                  ),
                ],
              )),

              const SizedBox(width: 10),

              // ── Right arrow/check ─────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected ? LinearGradient(
                    colors: [Colors.white.withValues(alpha: .25), Colors.white.withValues(alpha: .1)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ) : null,
                  color: isSelected ? null : Colors.transparent,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isSelected ? .35 : .15),
                    width: 1.5),
                  boxShadow: [BoxShadow(
                    color: Colors.white.withValues(alpha: isSelected ? .1 : 0), blurRadius: 8)],
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: isSelected ? 1.0 : .35),
                  size: isSelected ? 17 : 12)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox(String icon, String symbol, String? imagePath, List<Color> gradColors, Color glowColor, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutExpo,
      width: 68, height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? glowColor.withValues(alpha: .5) : Colors.white.withValues(alpha: .12),
          width: 1.5),
        boxShadow: isSelected ? [
          BoxShadow(color: glowColor.withValues(alpha: .4), blurRadius: 16, offset: const Offset(0, 4)),
        ] : [],
        color: Colors.white.withValues(alpha: .05),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(alignment: Alignment.center, children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradColors[0].withValues(alpha: .6),
                    gradColors[1].withValues(alpha: .4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Image
          if (imagePath != null)
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
                          color: isSelected
                            ? Colors.white.withValues(alpha: .9)
                            : Colors.white.withValues(alpha: .4),
                          size: 28,
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            _iconPlaceholder(isSelected, glowColor),

          if (isSelected) Positioned.fill(child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: RadialGradient(
                colors: [glowColor.withValues(alpha: .15), Colors.transparent],
                radius: .7)))),
        ]),
      ),
    );
  }

  Widget _iconPlaceholder(bool isSelected, Color glowColor) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.person_add_outlined,
        color: isSelected
          ? glowColor.withValues(alpha: .7)
          : Colors.white.withValues(alpha: .3),
        size: 22),
      const SizedBox(height: 3),
      Text('68×68',
        style: TextStyle(fontSize: 8,
          color: Colors.white.withValues(alpha: .2))),
    ]);
  }

  // ── Cuneiform divider ────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(children: [
        Expanded(child: Container(height: .5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, _goldColor.withValues(alpha: .3), Colors.transparent])))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('𒂗', style: TextStyle(
            fontSize: 13, color: _goldColor.withValues(alpha: .5)))),
        Expanded(child: Container(height: .5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent, _goldColor.withValues(alpha: .3), Colors.transparent])))),
      ]),
    );
  }

  // ── Confirm button ───────────────────────────────────────────────────────────
  Widget _buildConfirmButton(String lang) {
    final ready = _selected != null;
    final gradColors = _selected == 'iraqi' ? _iraqiGrad : _touristGrad;
    final glowColor  = _selected == 'iraqi'
      ? const Color(0xFF1B7A4A) : const Color(0xFF1A5FAB);
    final btnLabel = ready
      ? (lang == 'ar' ? 'ابدأ الرحلة' : lang == 'ku' ? 'سەفەر دەست پێبکە' : "Begin the Journey")
      : (lang == 'ar' ? 'اختر هويتك أولاً' : lang == 'ku' ? 'یەکێک هەڵبژێرە' : 'Choose your identity first');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(children: [

        // Main button
        GestureDetector(
          onTap: ready ? _confirm : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutExpo,
            height: 58,
            decoration: BoxDecoration(
              gradient: ready ? LinearGradient(
                colors: [gradColors[0], gradColors[1], gradColors[0]],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ) : null,
              color: ready ? null : Colors.white.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(20),
              border: ready
                ? Border.all(color: Colors.white.withValues(alpha: .15))
                : Border.all(color: Colors.white.withValues(alpha: .1)),
              boxShadow: ready ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: .4 + _btnAnim.value * .2),
                  blurRadius: 24 + _btnAnim.value * 12,
                  offset: const Offset(0, 6)),
                BoxShadow(
                  color: glowColor.withValues(alpha: .15),
                  blurRadius: 50),
              ] : [],
            ),
            child: Stack(alignment: Alignment.center, children: [
              // Shimmer on button
              if (ready) Positioned.fill(child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: _shimmerAnim,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-2 + _shimmerAnim.value * 5, 0),
                        end:   Alignment(-1.5 + _shimmerAnim.value * 5, 0),
                        colors: [Colors.transparent, Colors.white.withValues(alpha: .12), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              )),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(btnLabel,
                  style: AppFonts.lora(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: ready ? Colors.white : Colors.white.withValues(alpha: .3),
                    letterSpacing: .3)),
                if (ready) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                    color: Colors.white.withValues(alpha: .8), size: 18),
                ],
              ]),
            ]),
          ),
        ),

        const SizedBox(height: 14),

        // Footer hint
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('𒀭', style: TextStyle(fontSize: 11, color: _goldColor.withValues(alpha: .3))),
          const SizedBox(width: 8),
          Text(
            lang == 'ar'
              ? 'يمكنك تغيير هذا لاحقاً من الإعدادات'
              : lang == 'ku'
                ? 'دواتر دەتوانی لە ڕێکخستنەکان بیگۆڕیتەوە'
                : 'You can change this anytime in Settings',
            style: AppFonts.nunito(
              fontSize: 11, color: Colors.white.withValues(alpha: .28))),
          const SizedBox(width: 8),
          Text('𒀭', style: TextStyle(fontSize: 11, color: _goldColor.withValues(alpha: .3))),
        ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════

// Subtle grid / dot matrix background
class _GridPainter extends CustomPainter {
  final double t;
  _GridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8B84B).withValues(alpha: .025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .4;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), .8, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override bool shouldRepaint(_GridPainter o) => o.t != t;
}

// Particle burst on card select
class _ParticlePainter extends CustomPainter {
  final double t; // 0..1
  final double w, h;
  final Color color;
  _ParticlePainter(this.t, this.w, this.h, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final cx = w / 2;
    final cy = h * .55;
    final count = 22;

    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 60 + rng.nextDouble() * 120;
      final size_ = 2.5 + rng.nextDouble() * 3.5;
      final fade  = (1 - t) * (1 - t);
      final x = cx + cos(angle) * speed * t;
      final y = cy + sin(angle) * speed * t + 80 * t * t; // gravity

      canvas.drawCircle(
        Offset(x, y), size_ * (1 - t * .5),
        Paint()..color = color.withValues(alpha: fade * (.4 + rng.nextDouble() * .6)));
    }
  }

  @override bool shouldRepaint(_ParticlePainter o) => o.t != t || o.color != color;
}
