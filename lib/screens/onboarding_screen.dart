import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import '../data/iraq_data.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  ONBOARDING DATA
// ══════════════════════════════════════════════════════════════════════════════
class _OnboardPage {
  final String titleAr, titleEn, titleKu, bodyAr, bodyEn, bodyKu, emoji;
  final Color accent;
  final _PainterType painter;
  const _OnboardPage({
    required this.titleAr, required this.titleEn, required this.titleKu,
    required this.bodyAr,  required this.bodyEn,  required this.bodyKu,
    required this.emoji,   required this.accent,
    required this.painter,
  });
}

enum _PainterType { ziggurat, cuneiform, gate, moon }

const _pages = [
  _OnboardPage(
    titleAr: 'أهلاً بك في ميراث',
    titleEn: 'Welcome to Heritage',
    titleKu: 'بەخێربێیت بۆ میراث',
    bodyAr:  'استكشف آلاف السنين من الحضارة العراقية —\nمن سومر إلى بغداد في راحة يدك',
    bodyEn:  'Explore thousands of years of Iraqi civilization —\nfrom Sumer to Baghdad in your hands',
    bodyKu:  'هەزاران ساڵی شارستانی عێراق بدۆزەرەوە —\nلە سومەر تا بەغدا لە دەستت',
    emoji: '𒀭',
    accent: Color(0xFFC4785A),
    painter: _PainterType.ziggurat,
  ),
  _OnboardPage(
    titleAr: 'مواقع أثرية حقيقية',
    titleEn: 'Real Heritage Sites',
    titleKu: 'شوێنە کۆنە ڕاستەقینەکان',
    bodyAr:  'أكثر من ٣٠ موقع أثري بصور وخرائط\nومعلومات تفصيلية باللغتين',
    bodyEn:  'Over 30 archaeological sites with photos,\nmaps and detailed info in both languages',
    bodyKu:  'زیاتر لە ٣٠ شوێنی کۆنی لەگەڵ وێنە، نەخشە\nو زانیاری وردی',
    emoji: '🏛️',
    accent: Color(0xFF808055),
    painter: _PainterType.cuneiform,
  ),
  _OnboardPage(
    titleAr: 'حضارات عريقة',
    titleEn: 'Ancient Civilizations',
    titleKu: 'شارستانییە کۆنەکان',
    bodyAr:  'سومرية · بابلية · آشورية · إسلامية\nكل حضارة بقصتها الكاملة',
    bodyEn:  'Sumerian · Babylonian · Assyrian · Islamic\nEvery civilization with its full story',
    bodyKu:  'سومەری · بابلی · ئاشووری · ئیسلامی\nهەر شارستانییەک لەگەڵ چیرۆکی تەواوی',
    emoji: '⚔️',
    accent: Color(0xFF9E5C42),
    painter: _PainterType.gate,
  ),
  _OnboardPage(
    titleAr: 'نبو مرشدك الذكي',
    titleEn: 'Nabu, Your Smart Guide',
    titleKu: 'نابو، ڕێنمایی زیرەکت',
    bodyAr:  'اسأل نبو 𒀭 عن أي موقع أو حضارة\nويجاوبك فوراً من قاعدة معرفته',
    bodyEn:  'Ask Nabu 𒀭 about any site or civilization\nand get instant answers from his knowledge base',
    bodyKu:  'لە نابو 𒀭 دەربارەی هەر شوێن یان شارستانییەک بپرسە\nو وەڵامی خێرا وەربگرە',
    emoji: '𒀭',
    accent: Color(0xFF5C7A6E),
    painter: _PainterType.moon,
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
//  ONBOARDING SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  final _pageCtrl = PageController();
  int _current = 0;
  bool _isArabic = true;  // خيار اللغة

  // اللغات المتاحة: 'ar' → 'ku' → 'en' → 'ar' ...
  String get _lang => _isArabic ? 'ar' : 'en';

  late AnimationController _entryCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _entryCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 600))..forward();
    _bgCtrl = AnimationController(vsync: this,
      duration: const Duration(seconds: 12))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 3200))..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero)
      .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    // ── فيديو الخلفية ──
    _videoCtrl = VideoPlayerController.asset('assets/videos/onboarding_bg.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoReady = true);
          _videoCtrl!.setLooping(true);
          _videoCtrl!.setVolume(0);
          _videoCtrl!.play();
        }
      }).catchError((_) {
        if (mounted) setState(() => _videoReady = false);
      });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _floatCtrl.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _current = i);
    _entryCtrl.forward(from: 0);
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await prefs.setBool('is_arabic', _isArabic);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final page = _pages[_current];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [

        // ── خلفية فيديو (أو gradient كـ fallback) ────────────
        if (_videoReady && _videoCtrl != null)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoCtrl!.value.size.width,
                height: _videoCtrl!.value.size.height,
                child: VideoPlayer(_videoCtrl!))))
        else
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(const Color(0xFF2A1508),
                      const Color(0xFF1A0F2E), _bgCtrl.value)!,
                    Color.lerp(const Color(0xFF4A2010),
                      const Color(0xFF2A1508), _bgCtrl.value)!,
                    Color.lerp(const Color(0xFF1A0A04),
                      const Color(0xFF0A0818), _bgCtrl.value)!,
                  ],
                ),
              ),
            ),
          ),
        // ── طبقة تعتيم فوق الفيديو ───────────────────────────
        if (_videoReady)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .45),
                    Colors.black.withValues(alpha: .25),
                    Colors.black.withValues(alpha: .6),
                  ])))),

        // ── نجوم ─────────────────────────────────────────────
        ...List.generate(40, (i) {
          final rng = Random(i * 7331);
          return Positioned(
            left: rng.nextDouble() * sw,
            top: rng.nextDouble() * sh * .65,
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) {
                final v = sin(_floatCtrl.value * pi + i * .7);
                return Opacity(
                  opacity: (.3 + v * .4).clamp(0.0, 1.0),
                  child: Container(
                    width: rng.nextDouble() * 2.5 + .5,
                    height: rng.nextDouble() * 2.5 + .5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white),
                  ),
                );
              },
            ),
          );
        }),

        // ── رسمة الصفحة ──────────────────────────────────────
        AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) => Positioned(
            top: sh * .06,
            left: 0, right: 0,
            child: Transform.translate(
              offset: Offset(0, sin(_floatCtrl.value * pi) * 10),
              child: SizedBox(
                height: sh * .42,
                child: CustomPaint(
                  painter: _getPagePainter(page),
                ),
              ),
            ),
          ),
        ),

        // ── زر تبديل اللغة ───────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16, right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // تخطي
              if (_current < _pages.length - 1)
                GestureDetector(
                  onTap: _finish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .2))),
                    child: Text(
                      _lang == 'ar' ? 'تخطي' : _lang == 'ku' ? 'تێپەڕیبە' : 'Skip',
                      style: AppFonts.nunito(
                        fontSize: 13, color: Colors.white70)),
                  ),
                )
              else
                const SizedBox(),

              // زر اللغة
              GestureDetector(
                onTap: () => setState(() => _isArabic = !_isArabic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: page.accent.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: page.accent.withValues(alpha: .5))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_lang == 'ar' ? 'EN' : 'عر',
                      style: AppFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                    const SizedBox(width: 6),
                    Icon(Icons.language_rounded,
                      size: 15, color: Colors.white.withValues(alpha: .8)),
                  ]),
                ),
              ),
            ],
          ),
        ),

        // ── المحتوى السفلي ────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: .7),
                  Colors.black.withValues(alpha: .95),
                ],
                stops: const [0, .3, 1],
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              28, 48, 28,
              MediaQuery.of(context).padding.bottom + 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: _isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                  children: [

                  // إيموجي / رمز
                  Text(page.emoji,
                    style: const TextStyle(fontSize: 42)),
                  const SizedBox(height: 12),

                  // العنوان
                  Text(
                    _lang == 'ar' ? page.titleAr : _lang == 'ku' ? page.titleKu : page.titleEn,
                    textDirection: _isArabic
                      ? TextDirection.rtl : TextDirection.ltr,
                    style: AppFonts.lora(
                      fontSize: 28, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1.2),
                  ),
                  const SizedBox(height: 14),

                  // الوصف
                  Text(
                    _lang == 'ar' ? page.bodyAr : _lang == 'ku' ? page.bodyKu : page.bodyEn,
                    textDirection: _isArabic
                      ? TextDirection.rtl : TextDirection.ltr,
                    style: AppFonts.nunito(
                      fontSize: 15, color: Colors.white70,
                      height: 1.65),
                  ),
                  const SizedBox(height: 36),

                  // مؤشرات الصفحات + زر التالي
                  Row(
                    mainAxisAlignment: _isArabic
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.spaceBetween,
                    children: [
                    // dots
                    Row(children: List.generate(_pages.length, (i) =>
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _current ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _current
                            ? page.accent
                            : Colors.white.withValues(alpha: .3),
                          borderRadius: BorderRadius.circular(4)),
                      ),
                    )),

                    // زر التالي / ابدأ
                    GestureDetector(
                      onTap: _next,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: page.accent,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: page.accent.withValues(alpha: .45),
                              blurRadius: 20, offset: const Offset(0, 6))
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            _current == _pages.length - 1
                              ? (_lang == 'ar' ? 'ابدأ الآن' : _lang == 'ku' ? 'دەست پێبکە' : "Let's Go")
                              : (_lang == 'ar' ? 'التالي' : _lang == 'ku' ? 'دواتر' : 'Next'),
                            style: AppFonts.nunito(
                              fontSize: 15, fontWeight: FontWeight.w700,
                              color: Colors.white)),
                          const SizedBox(width: 8),
                          Icon(
                            _current == _pages.length - 1
                              ? Icons.rocket_launch_rounded
                              : (_isArabic
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded),
                            color: Colors.white, size: 18),
                        ]),
                      ),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),

        // ── PageView شفاف فوق الكل للسويب ────────────────────
        PageView.builder(
          controller: _pageCtrl,
          onPageChanged: _onPageChanged,
          itemCount: _pages.length,
          itemBuilder: (_, __) => const SizedBox.expand(),
        ),

      ]),
    );
  }

  CustomPainter _getPagePainter(_OnboardPage page) {
    switch (page.painter) {
      case _PainterType.ziggurat:  return _ZigguratScene(accent: page.accent);
      case _PainterType.cuneiform: return _CuneiformScene(accent: page.accent);
      case _PainterType.gate:      return _GateScene(accent: page.accent);
      case _PainterType.moon:      return _MoonScene(accent: page.accent);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SCENE PAINTERS
// ══════════════════════════════════════════════════════════════════════════════

// ١. زقورة أور
class _ZigguratScene extends CustomPainter {
  final Color accent;
  _ZigguratScene({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w / 2;

    // هالة خلفية
    canvas.drawCircle(Offset(cx, h * .5),
      w * .38,
      Paint()..shader = RadialGradient(colors: [
        accent.withValues(alpha: .25),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(cx, h * .5), radius: w * .38)));

    // طوابق الزقورة
    final tiers = [
      [.08, .92, .88, 1.0],
      [.15, .85, .73, .88],
      [.23, .77, .60, .73],
      [.31, .69, .49, .60],
      [.38, .62, .40, .49],
      [.44, .56, .33, .40],
    ];

    for (int i = 0; i < tiers.length; i++) {
      final t = tiers[i];
      final alpha = .25 + i * .08;
      canvas.drawRect(
        Rect.fromLTRB(w*t[0], h*t[2], w*t[1], h*t[3]),
        Paint()..color = accent.withValues(alpha: alpha));
      // خط علوي مضيء
      canvas.drawLine(
        Offset(w*t[0], h*t[2]), Offset(w*t[1], h*t[2]),
        Paint()..color = accent.withValues(alpha: .6 + i*.06)
          ..strokeWidth = 1.2);
    }

    // رمز الشمس أعلى الزقورة
    canvas.drawCircle(Offset(cx, h * .28), w * .06,
      Paint()..color = accent.withValues(alpha: .9));
    canvas.drawCircle(Offset(cx, h * .28), w * .04,
      Paint()..color = Colors.white.withValues(alpha: .8));

    // خطوط الشعاع
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        Offset(cx + cos(a)*w*.07, h*.28 + sin(a)*w*.07),
        Offset(cx + cos(a)*w*.11, h*.28 + sin(a)*w*.11),
        Paint()..color = accent.withValues(alpha: .6)
          ..strokeWidth = 1.5..strokeCap = StrokeCap.round);
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ٢. ألواح مسمارية
class _CuneiformScene extends CustomPainter {
  final Color accent;
  _CuneiformScene({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;

    // ثلاث ألواح طينية
    final tablets = [
      [.15, .12, .45, .75],
      [.38, .05, .68, .70],
      [.55, .18, .88, .80],
    ];

    for (int t = 0; t < tablets.length; t++) {
      final tb = tablets[t];
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(w*tb[0], h*tb[1], w*tb[2], h*tb[3]),
        const Radius.circular(8));

      // جسم اللوح
      canvas.drawRRect(rect,
        Paint()..color = accent.withValues(alpha: .15 + t*.07));
      canvas.drawRRect(rect,
        Paint()..color = accent.withValues(alpha: .4)
          ..style = PaintingStyle.stroke..strokeWidth = 1);

      // خطوط الكتابة المسمارية
      final rows = 6;
      for (int r = 0; r < rows; r++) {
        final y = h*(tb[1] + .06) + r * (h*(tb[3]-tb[1]-0.08)/rows);
        final lineW = w * (tb[2]-tb[0]) * (.5 + Random(t*10+r).nextDouble()*.45);
        canvas.drawLine(
          Offset(w*tb[0] + w*.02, y),
          Offset(w*tb[0] + w*.02 + lineW, y),
          Paint()..color = accent.withValues(alpha: .5)
            ..strokeWidth = 1.5..strokeCap = StrokeCap.round);

        // إشارات مسمارية صغيرة
        for (int s = 0; s < 4; s++) {
          final sx = w*tb[0] + w*.03 + s * lineW / 4;
          canvas.drawLine(
            Offset(sx, y-3), Offset(sx+4, y),
            Paint()..color = accent.withValues(alpha: .6)
              ..strokeWidth = 1..strokeCap = StrokeCap.round);
        }
      }
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ٣. بوابة عشتار
class _GateScene extends CustomPainter {
  final Color accent;
  _GateScene({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w / 2;

    // هالة خلفية
    canvas.drawCircle(Offset(cx, h*.55), w*.35,
      Paint()..shader = RadialGradient(colors: [
        accent.withValues(alpha: .2), Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(cx, h*.55), radius: w*.35)));

    // الإطار الخارجي للبوابة
    final gateW = w * .55;
    final gateL = cx - gateW/2;
    final gateR = cx + gateW/2;

    // جدار البوابة
    canvas.drawRect(
      Rect.fromLTRB(gateL, h*.2, gateR, h*.95),
      Paint()..color = accent.withValues(alpha: .2));
    canvas.drawRect(
      Rect.fromLTRB(gateL, h*.2, gateR, h*.95),
      Paint()..color = accent.withValues(alpha: .5)
        ..style = PaintingStyle.stroke..strokeWidth = 2);

    // القوس العلوي
    final archPath = Path();
    archPath.moveTo(gateL + gateW*.2, h*.55);
    archPath.lineTo(gateL + gateW*.2, h*.38);
    archPath.arcToPoint(
      Offset(gateR - gateW*.2, h*.38),
      radius: Radius.circular(gateW*.3),
      clockwise: false);
    archPath.lineTo(gateR - gateW*.2, h*.55);
    archPath.close();
    canvas.drawPath(archPath,
      Paint()..color = Colors.black.withValues(alpha: .5));
    canvas.drawPath(archPath,
      Paint()..color = accent.withValues(alpha: .6)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // زخارف التنين والثور (نقاط مبسطة)
    final decorY = [h*.27, h*.32, h*.60, h*.68, h*.76, h*.84];
    for (final dy in decorY) {
      // يسار
      canvas.drawCircle(Offset(gateL + gateW*.12, dy), 4,
        Paint()..color = accent.withValues(alpha: .7));
      // يمين
      canvas.drawCircle(Offset(gateR - gateW*.12, dy), 4,
        Paint()..color = accent.withValues(alpha: .7));
    }

    // نجمة عشتار في المنتصف أعلى
    _drawStar(canvas, Offset(cx, h*.24), 12, accent);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color c) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final a = i * pi / 4 - pi/8;
      final rr = i.isEven ? r : r * .45;
      final p = Offset(center.dx + cos(a)*rr, center.dy + sin(a)*rr);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = c.withValues(alpha: .9));
  }

  @override bool shouldRepaint(_) => false;
}

// ٤. القمر والكتابة (نبو)
class _MoonScene extends CustomPainter {
  final Color accent;
  _MoonScene({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w/2;

    // هالة القمر
    canvas.drawCircle(Offset(cx, h*.35), w*.28,
      Paint()..shader = RadialGradient(colors: [
        accent.withValues(alpha: .3),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(cx, h*.35), radius: w*.28)));

    // القمر الهلال
    final moonPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx, h*.35), radius: w*.18));
    final holePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx + w*.1, h*.3), radius: w*.14));
    canvas.drawPath(
      Path.combine(PathOperation.difference, moonPath, holePath),
      Paint()..color = accent.withValues(alpha: .85));

    // نجوم حول القمر
    final starPos = [
      [.22, .18], [.75, .22], [.15, .50], [.80, .48],
      [.30, .65], [.68, .60],
    ];
    for (final sp in starPos) {
      canvas.drawCircle(
        Offset(w*sp[0], h*sp[1]),
        2.5,
        Paint()..color = Colors.white.withValues(alpha: .7));
    }

    // لوح الكتابة
    final tabRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - w*.25, h*.60, cx + w*.25, h*.88),
      const Radius.circular(6));
    canvas.drawRRect(tabRect,
      Paint()..color = accent.withValues(alpha: .18));
    canvas.drawRRect(tabRect,
      Paint()..color = accent.withValues(alpha: .45)
        ..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // سطور الكتابة
    final glyphs = ['𒀭', '𒂗', '𒍪', '𒈗', '𒆳'];
    for (int i = 0; i < 3; i++) {
      final y = h*.67 + i * h*.07;
      for (int j = 0; j < 3; j++) {
        final tp = TextPainter(
          text: TextSpan(
            text: glyphs[(i*3+j) % glyphs.length],
            style: TextStyle(
              fontSize: 18,
              color: accent.withValues(alpha: .7))),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - w*.2 + j*w*.14, y));
      }
    }
  }

  @override bool shouldRepaint(_) => false;
}
