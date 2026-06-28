// lib/screens/proximity_notification_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ميزة 3 — إشعارات GPS الذكية
//  ينبّه المستخدم لما يقترب من موقع أثري (500م)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';
import '../data/iraq_data.dart';
import '../data/knowledge_base.dart';

// ── خدمة الإشعارات الجغرافية ──────────────────────────
class ProximityNotificationService {
  static final ProximityNotificationService _instance = ProximityNotificationService._();
  factory ProximityNotificationService() => _instance;
  ProximityNotificationService._();

  static const double _radiusMeters = 500.0;
  StreamSubscription<Position>? _positionSub;
  final Set<String> _notifiedSites = {};
  Function(Site, String)? onNearSite; // callback للواجهة

  Future<void> start() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) return;

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50),
    ).listen(_onPositionUpdate);
  }

  void stop() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void _onPositionUpdate(Position pos) {
    for (final site in iraqSites) {
      if (_notifiedSites.contains(site.id)) continue;
      final dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, site.lat, site.lng);
      if (dist <= _radiusMeters) {
        _notifiedSites.add(site.id);
        final info = _getAIInfo(site);
        onNearSite?.call(site, info);
      }
    }
  }

  String _getAIInfo(Site site) {
    final kb = IraqiKnowledgeBase();
    // ابحث في قاعدة المعرفة عن معلومات الموقع
    final query = site.name;
    final response = kb.getResponse(query, 'ar');
    if (response != null && response.isNotEmpty && !response.contains('عذراً')) {
      return response.length > 200 ? response.substring(0, 200) + '...' : response;
    }
    return 'أنت على بعد أقل من 500 متر من ${site.name} — ${site.description.length > 150 ? site.description.substring(0, 150) + "..." : site.description}';
  }
}

// ── ويدجت الإشعار المنبثق ──────────────────────────────
class ProximityAlertBanner extends StatefulWidget {
  final Site site;
  final String info;
  final VoidCallback onDismiss;
  const ProximityAlertBanner({super.key, required this.site, required this.info, required this.onDismiss});

  @override State<ProximityAlertBanner> createState() => _ProximityAlertBannerState();
}

class _ProximityAlertBannerState extends State<ProximityAlertBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 8), () { if (mounted) _dismiss(); });
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF2D1B69)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📍 أنت قريب من موقع أثري!', style: TextStyle(
                fontFamily: 'Cairo', color: Color(0xFFD4AF37), fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 4),
              Text(widget.site.name, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(widget.info, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 12, height: 1.4)),
            ])),
            IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: _dismiss),
          ]),
        ),
      ),
    );
  }
}

// ── شاشة إعدادات الإشعارات ──────────────────────────────
class ProximitySettingsScreen extends StatefulWidget {
  const ProximitySettingsScreen({super.key});
  @override State<ProximitySettingsScreen> createState() => _ProximitySettingsScreenState();
}

class _ProximitySettingsScreenState extends State<ProximitySettingsScreen> {
  bool _enabled = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkPerm();
  }

  Future<void> _checkPerm() async {
    final perm = await Geolocator.checkPermission();
    setState(() {
      _enabled = perm == LocationPermission.always || perm == LocationPermission.whileInUse;
      _checking = false;
    });
  }

  Future<void> _toggle(bool val) async {
    if (val) {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يرجى السماح بالموقع من إعدادات الهاتف', style: TextStyle(fontFamily: 'Cairo'))));
        return;
      }
      await ProximityNotificationService().start();
      setState(() => _enabled = true);
    } else {
      ProximityNotificationService().stop();
      setState(() => _enabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إشعارات المواقع الأثرية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _checking
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications_active, color: Color(0xFFD4AF37), size: 40),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('إشعارات GPS الذكية', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('ينبّهك لما تقترب من موقع أثري', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600])),
                  ])),
                  Switch(value: _enabled, onChanged: _toggle, activeColor: const Color(0xFFD4AF37)),
                ]),
              ),
              const SizedBox(height: 24),
              const Text('كيف يعمل؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...[ 
                ('📍', 'يراقب موقعك باستمرار عبر GPS'),
                ('🏛️', 'لما تصير على بعد 500 متر من موقع أثري'),
                ('🔔', 'يظهر لك إشعار بمعلومات عن المكان'),
                ('🤖', 'المعلومات من قاعدة معرفة الذكاء الاصطناعي'),
              ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Text(item.$1, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(item.$2, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15)),
                ]),
              )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text('يحتاج هذا الإعداد إذن الوصول للموقع الجغرافي',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
                ]),
              ),
            ]),
          ),
    );
  }
}
