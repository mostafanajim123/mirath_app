import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/knowledge_base.dart';

class ProximityNotificationService {
  static final ProximityNotificationService _instance = ProximityNotificationService._();
  factory ProximityNotificationService() => _instance;
  ProximityNotificationService._();

  static const double _radiusMeters = 500.0;
  StreamSubscription<Position>? _positionSub;
  final Set<String> _notifiedSites = {};
  Function(Site, String)? onNearSite;

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
      final dist = Geolocator.distanceBetween(pos.latitude, pos.longitude, site.latitude, site.longitude);
      if (dist <= _radiusMeters) {
        _notifiedSites.add(site.id);
        final info = "أنت بالقرب من ${site.name}";
        onNearSite?.call(site, info);
      }
    }
  }
}

class ProximityNotificationScreen extends StatefulWidget {
  const ProximityNotificationScreen({super.key});

  @override
  State<ProximityNotificationScreen> createState() => _ProximityNotificationScreenState();
}

class _ProximityNotificationScreenState extends State<ProximityNotificationScreen> {
  bool _enabled = false;
  bool _checking = true;
  final _service = ProximityNotificationService();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final perm = await Geolocator.checkPermission();
    setState(() {
      _enabled = (perm == LocationPermission.whileInUse || perm == LocationPermission.always);
      _checking = false;
    });
    if (_enabled) _service.start();
  }

  void _toggle(bool val) async {
    if (val) {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        setState(() => _enabled = true);
        _service.start();
      }
    } else {
      setState(() => _enabled = false);
      _service.stop();
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
            ]),
          ),
    );
  }
}
