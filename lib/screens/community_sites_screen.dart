// lib/screens/community_sites_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ميزة 2 — مواقع المجتمع: يضيف الزوار أماكن جديدة
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ── نموذج الموقع المجتمعي ──────────────────────────────
class CommunityPlace {
  final String id;
  final String name;
  final String description;
  final double rating;
  final double lat;
  final double lng;
  final String imagePath;
  final String addedBy;
  final DateTime addedAt;

  CommunityPlace({
    required this.id,
    required this.name,
    required this.description,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.imagePath,
    required this.addedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'rating': rating, 'lat': lat, 'lng': lng,
    'imagePath': imagePath, 'addedBy': addedBy,
    'addedAt': addedAt.toIso8601String(),
  };

  factory CommunityPlace.fromJson(Map<String, dynamic> j) => CommunityPlace(
    id: j['id'], name: j['name'], description: j['description'],
    rating: (j['rating'] as num).toDouble(),
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    imagePath: j['imagePath'], addedBy: j['addedBy'],
    addedAt: DateTime.parse(j['addedAt']),
  );
}

// ── خدمة حفظ المواقع ──────────────────────────────────
class CommunityService {
  static const _key = 'community_places';

  static Future<List<CommunityPlace>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => CommunityPlace.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> save(CommunityPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.add(place);
    await prefs.setStringList(
      _key,
      all.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await prefs.setStringList(
      _key,
      all.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}

// ── شاشة قائمة المواقع المجتمعية ──────────────────────
class CommunitySitesScreen extends StatefulWidget {
  const CommunitySitesScreen({super.key});
  @override State<CommunitySitesScreen> createState() => _CommunitySitesScreenState();
}

class _CommunitySitesScreenState extends State<CommunitySitesScreen> {
  List<CommunityPlace> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await CommunityService.loadAll();
    if (mounted) setState(() { _places = list.reversed.toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('مواقع المجتمع', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () { setState(() => _loading = true); _load(); },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('أضف موقعاً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCommunityPlaceScreen()));
          _load();
        },
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _places.isEmpty
          ? _emptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _places.length,
              itemBuilder: (_, i) => _PlaceCard(place: _places[i], onDelete: () async {
                await CommunityService.delete(_places[i].id);
                _load();
              }),
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.explore_off, size: 80, color: Color(0xFFD4AF37)),
      const SizedBox(height: 16),
      const Text('لا توجد مواقع مجتمعية بعد', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('كن أول من يضيف موقعاً!', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[600])),
    ]),
  );
}

// ── بطاقة الموقع ──────────────────────────────────────
class _PlaceCard extends StatelessWidget {
  final CommunityPlace place;
  final VoidCallback onDelete;
  const _PlaceCard({required this.place, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // الصورة
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: place.imagePath.isNotEmpty && File(place.imagePath).existsSync()
            ? Image.file(File(place.imagePath), height: 180, width: double.infinity, fit: BoxFit.cover)
            : Container(
                height: 180,
                color: const Color(0xFF1A1A2E).withOpacity(0.1),
                child: const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey)),
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(place.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
            ]),
            const SizedBox(height: 6),
            Text(place.description, style: TextStyle(fontFamily: 'Cairo', color: Colors.grey[700], height: 1.5)),
            const SizedBox(height: 10),
            Row(children: [
              // تقييم النجوم
              ...List.generate(5, (i) => Icon(
                i < place.rating.round() ? Icons.star : Icons.star_border,
                color: const Color(0xFFD4AF37), size: 20,
              )),
              const SizedBox(width: 8),
              Text('${place.rating.toStringAsFixed(1)}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
              const Spacer(),
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              Text(
                '${place.lat.toStringAsFixed(4)}, ${place.lng.toStringAsFixed(4)}',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[500]),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              'أضيف بتاريخ ${place.addedAt.day}/${place.addedAt.month}/${place.addedAt.year}',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey[400]),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── شاشة إضافة موقع جديد ──────────────────────────────
class AddCommunityPlaceScreen extends StatefulWidget {
  const AddCommunityPlaceScreen({super.key});
  @override State<AddCommunityPlaceScreen> createState() => _AddCommunityPlaceScreenState();
}

class _AddCommunityPlaceScreenState extends State<AddCommunityPlaceScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _imagePath = '';
  double _rating = 3.0;
  double? _lat, _lng;
  bool _loadingGps = false;
  bool _saving = false;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _getLocation() async {
    setState(() => _loadingGps = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى السماح بالوصول للموقع من الإعدادات')));
        setState(() => _loadingGps = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _lat = pos.latitude; _lng = pos.longitude; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحصول على الموقع: $e')));
    }
    setState(() => _loadingGps = false);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة اسم الموقع')));
      return;
    }
    if (_imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إضافة صورة')));
      return;
    }
    setState(() => _saving = true);
    final place = CommunityPlace(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      rating: _rating,
      lat: _lat ?? 0.0,
      lng: _lng ?? 0.0,
      imagePath: _imagePath,
      addedBy: 'مستخدم',
      addedAt: DateTime.now(),
    );
    await CommunityService.save(place);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ تم إضافة الموقع بنجاح!', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موقع جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // -- صورة الموقع --
          GestureDetector(
            onTap: () => _showImageOptions(),
            child: Container(
              height: 200, width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              ),
              child: _imagePath.isNotEmpty && File(_imagePath).existsSync()
                ? ClipRRect(borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(_imagePath), fit: BoxFit.cover))
                : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_a_photo, size: 50, color: Color(0xFFD4AF37)),
                    SizedBox(height: 8),
                    Text('اضغط لإضافة صورة', style: TextStyle(fontFamily: 'Cairo', color: Color(0xFFD4AF37), fontSize: 16)),
                  ]),
            ),
          ),
          const SizedBox(height: 24),

          // -- اسم الموقع --
          const Text('اسم الموقع *', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'مثال: مقام الشيخ فلان',
              hintStyle: const TextStyle(fontFamily: 'Cairo'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2)),
            ),
          ),
          const SizedBox(height: 20),

          // -- الوصف --
          const Text('رأيك ووصف المكان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            textDirection: TextDirection.rtl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب انطباعك عن المكان...',
              hintStyle: const TextStyle(fontFamily: 'Cairo'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2)),
            ),
          ),
          const SizedBox(height: 20),

          // -- التقييم --
          const Text('تقييمك للمكان', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [
            ...List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = i + 1.0),
              child: Icon(
                i < _rating.round() ? Icons.star : Icons.star_border,
                color: const Color(0xFFD4AF37), size: 36,
              ),
            )),
            const SizedBox(width: 12),
            Text('${_rating.toStringAsFixed(0)} / 5', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 24),

          // -- الموقع الجغرافي --
          const Text('الموقع الجغرافي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _loadingGps ? null : _getLocation,
            icon: _loadingGps
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.my_location),
            label: Text(_lat != null ? 'تم: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}' : 'احصل على موقعي الحالي',
              style: const TextStyle(fontFamily: 'Cairo')),
          ),
          const SizedBox(height: 36),

          // -- زر الحفظ --
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text('حفظ الموقع', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('اختر مصدر الصورة', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.camera_alt, color: Color(0xFFD4AF37)),
            title: const Text('الكاميرا', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library, color: Color(0xFF1A1A2E)),
            title: const Text('معرض الصور', style: TextStyle(fontFamily: 'Cairo')),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }
}
