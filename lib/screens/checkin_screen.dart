// lib/screens/checkin_screen.dart
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  شاشة Check-in — صورة + تحقق GPS في الموقع الأثري
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  الاستخدام:
//    Navigator.pushNamed(context, '/checkin', arguments: site);
//
//  المتطلبات في pubspec.yaml (كلها موجودة بالفعل):
//    - geolocator: ^13.0.2
//    - image_picker: ^1.1.2
//    - screenshot: ^3.0.0   (نستخدمه لإنشاء بطاقة الـ check-in)
//    - share_plus: ^10.0.0
//    - path_provider: ^2.1.4
//
//  الأذونات المطلوبة:
//
//  AndroidManifest.xml — أضف داخل <manifest>:
//    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//    <uses-permission android:name="android.permission.CAMERA"/>
//    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
//
//  ios/Runner/Info.plist — أضف:
//    <key>NSLocationWhenInUseUsageDescription</key>
//    <string>نحتاج موقعك للتحقق من وجودك في الموقع الأثري</string>
//    <key>NSCameraUsageDescription</key>
//    <string>نحتاج الكاميرا لالتقاط صورة تذكارية</string>
//    <key>NSPhotoLibraryUsageDescription</key>
//    <string>نحتاج الصالة لحفظ بطاقة الزيارة</string>
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../theme/app_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/models.dart';
import '../models/app_state.dart';
import '../models/achievements.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../data/translations.dart';
import '../database/database_service.dart';

// ═══════════════════════════════════════════════════════
//  نموذج بيانات الـ Check-in
// ═══════════════════════════════════════════════════════

class CheckIn {
  final String id;
  final String siteId;
  final String siteName;
  final String siteCity;
  final double lat;
  final double lng;
  final String photoPath; // مسار الصورة محلياً
  final DateTime visitedAt;
  final bool isVerified; // هل تم التحقق من الموقع؟

  const CheckIn({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.siteCity,
    required this.lat,
    required this.lng,
    required this.photoPath,
    required this.visitedAt,
    required this.isVerified,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'siteId': siteId,
    'siteName': siteName,
    'siteCity': siteCity,
    'lat': lat,
    'lng': lng,
    'photoPath': photoPath,
    'visitedAt': visitedAt.toIso8601String(),
    'isVerified': isVerified,
  };
}

// ═══════════════════════════════════════════════════════
//  حساب المسافة بين نقطتين (Haversine)
// ═══════════════════════════════════════════════════════

double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0; // نصف قطر الأرض بالمتر
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRad(lat1)) *
          math.cos(_toRad(lat2)) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _toRad(double deg) => deg * math.pi / 180;

// ═══════════════════════════════════════════════════════
//  CHECKIN SCREEN
// ═══════════════════════════════════════════════════════

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with TickerProviderStateMixin {
  // ── البيانات الأساسية ──
  late Site _site;
  bool _initialized = false;

  // ── مراحل الشاشة ──
  _Phase _phase = _Phase.idle;

  // ── GPS ──
  Position? _userPosition;
  double? _distanceToSite;
  static const double _verifyRadius = 500; // متر — نطاق القبول

  // ── الصورة ──
  File? _photo;
  final _picker = ImagePicker();

  // ── بطاقة المشاركة ──
  final _cardKey = GlobalKey();
  bool _sharing = false;

  // ── انيميشن ──
  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successScale = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _site = ModalRoute.of(context)!.settings.arguments as Site;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════
  //  منطق GPS (دقة عالية جداً + موافقة المستخدم)
  // ══════════════════════════════════════════════════

  Future<void> _checkLocation() async {
    // 1️⃣ طلب موافقة صريحة من المستخدم قبل الوصول للموقع
    final confirmLocation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: IHTheme.bg(context),
        title: Text(
          '🗺️ طلب الوصول إلى موقعك',
          style: AppFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: IHTheme.txtPrimary(context),
          ),
        ),
        content: Text(
          'نحتاج إلى الوصول إلى موقعك بدقة عالية جداً للتحقق من وجودك في الموقع الأثري.\n\nسيتم استخدام GPS بأعلى دقة متاحة.',
          style: AppFonts.nunito(
            fontSize: 14,
            height: 1.6,
            color: IHTheme.txtSecondary(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'لا شكراً',
              style: AppFonts.nunito(
                fontWeight: FontWeight.w600,
                color: IHTheme.txtMuted(context),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: IHTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'أوافق',
              style: AppFonts.nunito(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmLocation != true) {
      _showError('تم إلغاء التحقق من الموقع');
      return;
    }

    setState(() => _phase = _Phase.checkingGps);

    // 2️⃣ تحقق من تفعيل خدمة الموقع
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('⚠️ يرجى تفعيل خدمة الموقع (GPS) في إعدادات الجهاز');
      setState(() => _phase = _Phase.idle);
      return;
    }

    // 3️⃣ طلب إذن الموقع (مع شرح واضح)
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      _showError(
        '❌ تم رفض الإذن بشكل نهائي. يرجى فتح الإعدادات والسماح بالوصول إلى الموقع',
      );
      setState(() => _phase = _Phase.idle);
      return;
    }
    if (perm == LocationPermission.denied) {
      _showError('🔒 يرجى السماح للتطبيق بالوصول إلى موقعك');
      setState(() => _phase = _Phase.idle);
      return;
    }

    // 4️⃣ الحصول على الموقع بأعلى دقة متاحة
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best, // ⭐ أعلى دقة متاحة
          distanceFilter: 0, // كل تحديث موقع حتى لو بسنتيمترات
          timeLimit: const Duration(seconds: 20), // وقت أطول للحصول على دقة أفضل
        ),
      );

      final dist = _distanceMeters(
        position.latitude,
        position.longitude,
        _site.lat,
        _site.lng,
      );

      setState(() {
        _userPosition = position;
        _distanceToSite = dist;
        _phase = dist <= _verifyRadius
            ? _Phase.locationVerified
            : _Phase.locationFar;
      });
    } catch (e) {
      _showError('❌ تعذر الحصول على موقعك. حاول مجدداً: $e');
      setState(() => _phase = _Phase.idle);
    }
  }

  // ══════════════════════════════════════════════════
  //  منطق الكاميرا
  // ══════════════════════════════════════════════════

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return;
      setState(() {
        _photo = File(picked.path);
        _phase = _Phase.photoReady;
      });
    } catch (e) {
      _showError('تعذر الوصول إلى الكاميرا أو الصالة');
    }
  }

  // ══════════════════════════════════════════════════
  //  حفظ الـ Check-in في DB + Achievements
  // ══════════════════════════════════════════════════

  Future<void> _saveCheckIn() async {
    if (_photo == null) return;
    setState(() => _phase = _Phase.saving);

    // نسخ الصورة إلى مجلد دائم في التطبيق
    final appDir = await getApplicationDocumentsDirectory();
    final checkinsDir = Directory('${appDir.path}/checkins');
    if (!await checkinsDir.exists()) await checkinsDir.create(recursive: true);

    final fileName =
        'checkin_${_site.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPhoto = await _photo!.copy('${checkinsDir.path}/$fileName');

    // حفظ في DB عبر settings (مصفوفة JSON)
    final dao = DatabaseService().dao;
    final existing = await dao.getSetting('checkins_json') ?? '[]';
    final List checkins = List.from(
      (existing == '[]') ? [] : _parseJsonList(existing),
    );

    final checkIn = CheckIn(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      siteId: _site.id,
      siteName: _site.name,
      siteCity: _site.city,
      lat: _userPosition?.latitude ?? _site.lat,
      lng: _userPosition?.longitude ?? _site.lng,
      photoPath: savedPhoto.path,
      visitedAt: DateTime.now(),
      isVerified: _phase == _Phase.saving
          ? (_distanceToSite ?? double.infinity) <= _verifyRadius
          : false,
    );

    checkins.add(checkIn.toJson());
    await dao.setSetting('checkins_json', _encodeJson(checkins));

    // تحديث عداد الزيارات وفتح الإنجازات
    final state = context.read<AppState>();
    final visitCount =
        int.tryParse(await dao.getSetting('checkin_count') ?? '0') ?? 0;
    final newCount = visitCount + 1;
    await dao.setSetting('checkin_count', newCount.toString());

    // فتح إنجازات الـ Check-in
    _unlockCheckInAchievements(newCount, checkIn.isVerified, state);

    setState(() => _phase = _Phase.done);
    _successCtrl.forward();
  }

  void _unlockCheckInAchievements(
      int count, bool verified, AppState state) async {
    // الإنجازات موجودة في achievements.dart — نضيف check-in achievements جديدة
    // راجع ملف checkin_achievements.dart المرفق
    final dao = DatabaseService().dao;

    if (count >= 1) await dao.unlockAchievement('checkin_first');
    if (count >= 3) await dao.unlockAchievement('checkin_3');
    if (count >= 10) await dao.unlockAchievement('checkin_10');
    if (verified) await dao.unlockAchievement('checkin_verified');

    // إشعار AppState بالإنجاز لعرض التوست
    state.checkAchievementExternal('checkins', count);
    if (verified) state.checkAchievementExternal('checkin_verified', 1);
  }

  // ══════════════════════════════════════════════════
  //  مشاركة بطاقة الزيارة
  // ══════════════════════════════════════════════════

  Future<void> _shareCard() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      // التقاط صورة الـ RepaintBoundary
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/checkin_card_${_site.id}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      final state = context.read<AppState>();
      final lang = AppStrings.lang(state.language);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'زرت موقع ${_site.name} 📍 ${_site.city}\n#تراث_العراق #Iraqi_Heritage',
      );

      state.incrementShare();
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  // ══════════════════════════════════════════════════
  //  Helper
  // ══════════════════════════════════════════════════

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  List<dynamic> _parseJsonList(String raw) {
    try {
      return jsonDecode(raw) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  String _encodeJson(List list) => jsonEncode(list);

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} م';
    return '${(meters / 1000).toStringAsFixed(1)} كم';
  }

  // ══════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.isDark;

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(
        title: 'تسجيل الزيارة',
        showBack: true,
        actions: _phase == _Phase.done
            ? [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton.icon(
                    onPressed: _sharing ? null : _shareCard,
                    icon: _sharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.share_rounded,
                            color: Colors.white, size: 18),
                    label: Text('شارك',
                        style: AppFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ),
                ),
              ]
            : null,
      ),
      body: _phase == _Phase.done
          ? _buildSuccessView(isDark)
          : _buildFlowView(isDark),
    );
  }

  // ══════════════════════════════════════════════════
  //  واجهة التدفق (GPS → كاميرا → حفظ)
  // ══════════════════════════════════════════════════

  Widget _buildFlowView(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة الموقع
          _SiteInfoCard(site: _site),

          const SizedBox(height: 24),

          // ── الخطوة ١: التحقق من الموقع ──
          _StepCard(
            number: '١',
            title: 'تحقق من موقعك',
            subtitle: 'يجب أن تكون على بعد ${_verifyRadius.round()} م من الموقع',
            isDone: _phase.index >= _Phase.locationVerified.index,
            isActive: _phase == _Phase.idle ||
                _phase == _Phase.checkingGps ||
                _phase == _Phase.locationFar,
            isDark: isDark,
            child: _buildGpsContent(isDark),
          ),

          const SizedBox(height: 16),

          // ── الخطوة ٢: التقاط الصورة ──
          _StepCard(
            number: '٢',
            title: 'التقط صورة تذكارية',
            subtitle: 'صوّر نفسك أو الموقع',
            isDone: _phase == _Phase.photoReady || _phase == _Phase.saving,
            isActive: _phase == _Phase.locationVerified ||
                _phase == _Phase.locationFar ||
                _phase == _Phase.photoReady,
            isDark: isDark,
            child: _buildCameraContent(isDark),
          ),

          const SizedBox(height: 24),

          // زر الحفظ
          if (_photo != null)
            AnimatedOpacity(
              opacity: _photo != null ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: _SaveButton(
                loading: _phase == _Phase.saving,
                onTap: _saveCheckIn,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGpsContent(bool isDark) {
    switch (_phase) {
      case _Phase.idle:
        return _ActionButton(
          icon: Icons.location_on_rounded,
          label: 'تحقق من موقعي',
          color: IHTheme.primary,
          onTap: _checkLocation,
        );

      case _Phase.checkingGps:
        return const _LoadingRow(label: 'جاري تحديد موقعك...');

      case _Phase.locationVerified:
        return _StatusRow(
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          label: 'أنت في الموقع الصحيح ✓',
          sub: _distanceToSite != null
              ? 'المسافة: ${_formatDistance(_distanceToSite!)}'
              : null,
        );

      case _Phase.locationFar:
        return Column(
          children: [
            _StatusRow(
              icon: Icons.location_off_rounded,
              color: Colors.orange,
              label: 'أنت بعيد عن الموقع',
              sub: _distanceToSite != null
                  ? 'المسافة: ${_formatDistance(_distanceToSite!)} — المطلوب < ${_verifyRadius.round()} م'
                  : null,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'أعد المحاولة',
              color: IHTheme.primary,
              onTap: _checkLocation,
            ),
          ],
        );

      default:
        return _StatusRow(
          icon: Icons.check_circle_rounded,
          color: Colors.green,
          label: 'تم التحقق من الموقع',
        );
    }
  }

  Widget _buildCameraContent(bool isDark) {
    final canUse = _phase == _Phase.locationVerified ||
        _phase == _Phase.photoReady;

    if (!canUse) {
      return Opacity(
        opacity: 0.4,
        child: _ActionButton(
          icon: Icons.photo_camera_rounded,
          label: 'أكمل الخطوة الأولى أولاً',
          color: Colors.grey,
          onTap: null,
        ),
      );
    }

    if (_photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _photo!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: () => setState(() => _photo = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.camera_alt_rounded,
            label: 'الكاميرا',
            color: IHTheme.primary,
            onTap: () => _pickPhoto(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.photo_library_rounded,
            label: 'الصالة',
            color: IHTheme.secondary,
            onTap: () => _pickPhoto(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════
  //  واجهة النجاح
  // ══════════════════════════════════════════════════

  Widget _buildSuccessView(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── رأس النجاح ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: IHTheme.primaryGradient,
            ),
            child: ScaleTransition(
              scale: _successScale,
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.where_to_vote_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تم تسجيل زيارتك!',
                    style: AppFonts.amiriQuran(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _site.name,
                    style: AppFonts.nunito(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                  ),
                  if ((_distanceToSite ?? double.infinity) <= _verifyRadius)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'زيارة مُتحقق منها',
                            style: AppFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── بطاقة المشاركة ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RepaintBoundary(
              key: _cardKey,
              child: _CheckInShareCard(
                site: _site,
                photo: _photo,
                isVerified:
                    (_distanceToSite ?? double.infinity) <= _verifyRadius,
                visitedAt: DateTime.now(),
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── أزرار ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('العودة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: IHTheme.bdr(context)),
                      foregroundColor: IHTheme.txtPrimary(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _sharing ? null : _shareCard,
                    icon: _sharing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.share_rounded, size: 18),
                    label:
                        Text(_sharing ? 'جاري المشاركة...' : 'شارك الزيارة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IHTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  مرحلة الشاشة
// ═══════════════════════════════════════════════════════

enum _Phase {
  idle,
  checkingGps,
  locationVerified,
  locationFar,
  photoReady,
  saving,
  done,
}

// ═══════════════════════════════════════════════════════
//  WIDGETS مساعدة
// ═══════════════════════════════════════════════════════

class _SiteInfoCard extends StatelessWidget {
  final Site site;
  const _SiteInfoCard({required this.site});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IHTheme.bdr(context), width: 0.5),
        boxShadow: IHTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: IHTheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_rounded,
                color: IHTheme.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.name,
                  style: AppFonts.amiriQuran(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: IHTheme.txtPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${site.city} • ${site.civilization}',
                  style: AppFonts.nunito(
                    fontSize: 13,
                    color: IHTheme.txtSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                if (site.isUnesco)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🏛 موقع يونسكو',
                      style: AppFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final bool isDark;
  final Widget child;

  const _StepCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isActive,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? Colors.green.withValues(alpha: .5)
              : isActive
                  ? IHTheme.primary.withValues(alpha: .4)
                  : IHTheme.bdr(context),
          width: isDone || isActive ? 1.5 : 0.5,
        ),
        boxShadow: isActive ? IHTheme.cardShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // رقم الخطوة
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green
                      : isActive
                          ? IHTheme.primary
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : Text(
                        number,
                        style: AppFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: IHTheme.txtPrimary(context),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppFonts.nunito(
                        fontSize: 12,
                        color: IHTheme.txtSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? sub;

  const _StatusRow({
    required this.icon,
    required this.color,
    required this.label,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: AppFonts.nunito(
                    fontSize: 12,
                    color: IHTheme.txtSecondary(context),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────

class _LoadingRow extends StatelessWidget {
  final String label;
  const _LoadingRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: IHTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppFonts.nunito(
            fontSize: 14,
            color: IHTheme.txtSecondary(context),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SaveButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: IHTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(
                'حفظ الزيارة',
                style: AppFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  بطاقة المشاركة (تُصوَّر وتُشارك)
// ═══════════════════════════════════════════════════════

class _CheckInShareCard extends StatelessWidget {
  final Site site;
  final File? photo;
  final bool isVerified;
  final DateTime visitedAt;
  final bool isDark;

  const _CheckInShareCard({
    required this.site,
    required this.photo,
    required this.isVerified,
    required this.visitedAt,
    required this.isDark,
  });

  String _formatDate(DateTime d) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2E1F10), const Color(0xFF1A1208)]
              : [const Color(0xFFFFF8F0), const Color(0xFFF5E8D0)],
        ),
        border: Border.all(
          color: IHTheme.primary.withValues(alpha: .3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: IHTheme.primary.withValues(alpha: .2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── الصورة ──
          if (photo != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(19),
                    topRight: Radius.circular(19),
                  ),
                  child: Image.file(
                    photo!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // شعار التراث
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#تراث_العراق',
                      style: AppFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'زيارة مُتحقق منها',
                            style: AppFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: IHTheme.primary.withValues(alpha: .1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(19),
                  topRight: Radius.circular(19),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.account_balance_rounded,
                  color: IHTheme.primary, size: 56),
            ),

          // ── التفاصيل ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.name,
                  style: AppFonts.amiriQuran(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFF5E8D8)
                        : const Color(0xFF4A3427),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: IHTheme.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${site.city}، العراق',
                      style: AppFonts.nunito(
                        fontSize: 13,
                        color: IHTheme.txtSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded,
                        color: IHTheme.txtMuted(context), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(visitedAt),
                      style: AppFonts.nunito(
                        fontSize: 12,
                        color: IHTheme.txtMuted(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: IHTheme.primary.withValues(alpha: .15),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      site.civilization,
                      style: AppFonts.nunito(
                        fontSize: 12,
                        color: IHTheme.txtSecondary(context),
                      ),
                    ),
                    Text(
                      'Iraqi Heritage App',
                      style: AppFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: IHTheme.primary.withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
