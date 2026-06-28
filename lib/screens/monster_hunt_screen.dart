// lib/screens/monster_hunt_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ميزة 1 — صيد الوحوش العراقية + عجلة الحظ + جوائز
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ── نماذج البيانات ─────────────────────────────────────
class IraqiMonster {
  final String id, name, description, emoji;
  final int points;
  final String rarity; // عادي، نادر، أسطوري
  const IraqiMonster({required this.id, required this.name, required this.description,
    required this.emoji, required this.points, required this.rarity});
}

class IraqiWeapon {
  final String id, name, emoji;
  final double catchRate; // نسبة النجاح 0.0 - 1.0
  const IraqiWeapon({required this.id, required this.name, required this.emoji, required this.catchRate});
}

class HuntPrize {
  final String title, description, emoji, partner;
  const HuntPrize({required this.title, required this.description, required this.emoji, required this.partner});
}

// ── البيانات الثابتة ───────────────────────────────────
const _monsters = [
  IraqiMonster(id: 'm1', name: 'اللاماسو', description: 'المخلوق الأسطوري الآشوري — جسد الثور وجناح النسر ووجه الإنسان', emoji: '🦁', points: 100, rarity: 'أسطوري'),
  IraqiMonster(id: 'm2', name: 'الأسد البابلي', description: 'حارس بوابة عشتار في بابل العظيمة', emoji: '🦁', points: 80, rarity: 'نادر'),
  IraqiMonster(id: 'm3', name: 'تنين الفرات', description: 'وحش أسطوري من أعماق نهر الفرات القديم', emoji: '🐉', points: 120, rarity: 'أسطوري'),
  IraqiMonster(id: 'm4', name: 'عنقاء بابل', description: 'الطائر الخرافي الذي يولد من الرماد', emoji: '🦅', points: 90, rarity: 'نادر'),
  IraqiMonster(id: 'm5', name: 'ثور السماء', description: 'مخلوق سومري أرسله الآلهة للانتقام', emoji: '🐂', points: 70, rarity: 'نادر'),
  IraqiMonster(id: 'm6', name: 'هُمبابا', description: 'حارس غابة الأرز في ملحمة جلجامش', emoji: '👹', points: 150, rarity: 'أسطوري'),
  IraqiMonster(id: 'm7', name: 'أفعى عشتار', description: 'الأفعى المقدسة لإلهة الحب والحرب', emoji: '🐍', points: 60, rarity: 'عادي'),
  IraqiMonster(id: 'm8', name: 'عقرب الصحراء', description: 'الحارس البابلي لمدخل الجبال المظلمة', emoji: '🦂', points: 50, rarity: 'عادي'),
];

const _weapons = [
  IraqiWeapon(id: 'w1', name: 'البرنو العراقي', emoji: '🔫', catchRate: 0.85),
  IraqiWeapon(id: 'w2', name: 'قوس سومري', emoji: '🏹', catchRate: 0.65),
  IraqiWeapon(id: 'w3', name: 'سيف بابلي', emoji: '⚔️', catchRate: 0.75),
  IraqiWeapon(id: 'w4', name: 'رمح آشوري', emoji: '🗡️', catchRate: 0.55),
];

const _prizes = [
  HuntPrize(title: 'وجبة غداء مجانية', description: 'وجبة كاملة لشخص واحد في فندق بابل', emoji: '🍽️', partner: 'فندق بابل'),
  HuntPrize(title: 'خصم 20% على الإقامة', description: 'خصم على ليلة واحدة في الفندق', emoji: '🏨', partner: 'فندق إيشتار'),
  HuntPrize(title: 'جولة سياحية مجانية', description: 'جولة إرشادية لمدة ساعتين', emoji: '🗺️', partner: 'شركة السياحة العراقية'),
  HuntPrize(title: 'هدية تراثية', description: 'تمثال أثري مصنوع يدوياً', emoji: '🏺', partner: 'متجر التراث'),
  HuntPrize(title: 'حقيبة ترحيبية', description: 'حقيبة هدايا تراثية عراقية', emoji: '🎁', partner: 'فندق بابل'),
  HuntPrize(title: 'قهوة عراقية مجانية', description: 'جلسة قهوة عراقية أصيلة', emoji: '☕', partner: 'مقهى الرافدين'),
];

// ── خدمة حفظ بيانات الصيد ──────────────────────────────
class HuntService {
  static Future<int> getPoints() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('hunt_points') ?? 0;
  }
  static Future<void> addPoints(int pts) async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt('hunt_points') ?? 0;
    await p.setInt('hunt_points', cur + pts);
  }
  static Future<List<String>> getCaught() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('caught_monsters') ?? [];
  }
  static Future<void> addCaught(String id) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList('caught_monsters') ?? [];
    if (!list.contains(id)) { list.add(id); await p.setStringList('caught_monsters', list); }
  }
  static Future<int> getSpins() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('wheel_spins') ?? 0;
  }
  static Future<void> addSpin() async {
    final p = await SharedPreferences.getInstance();
    final cur = p.getInt('wheel_spins') ?? 0;
    await p.setInt('wheel_spins', cur + 1);
  }
}

// ── الشاشة الرئيسية للصيد ─────────────────────────────
class MonsterHuntScreen extends StatefulWidget {
  const MonsterHuntScreen({super.key});
  @override State<MonsterHuntScreen> createState() => _MonsterHuntScreenState();
}

class _MonsterHuntScreenState extends State<MonsterHuntScreen> with TickerProviderStateMixin {
  int _points = 0;
  List<String> _caught = [];
  IraqiMonster? _currentMonster;
  IraqiWeapon? _selectedWeapon;
  bool _hunting = false;
  String _huntResult = '';
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _load();
    _spawnMonster();
  }

  Future<void> _load() async {
    final pts = await HuntService.getPoints();
    final caught = await HuntService.getCaught();
    setState(() { _points = pts; _caught = caught; });
  }

  void _spawnMonster() {
    final rnd = Random();
    setState(() {
      _currentMonster = _monsters[rnd.nextInt(_monsters.length)];
      _huntResult = '';
      _selectedWeapon = null;
    });
  }

  Future<void> _hunt() async {
    if (_selectedWeapon == null || _currentMonster == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('اختر سلاحاً أولاً!', style: TextStyle(fontFamily: 'Cairo'))));
      return;
    }
    setState(() => _hunting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final success = Random().nextDouble() < _selectedWeapon!.catchRate;
    if (success) {
      await HuntService.addPoints(_currentMonster!.points);
      await HuntService.addCaught(_currentMonster!.id);
      final pts = await HuntService.getPoints();
      final caught = await HuntService.getCaught();
      setState(() {
        _points = pts; _caught = caught;
        _huntResult = '✅ اصطدت ${_currentMonster!.name}! +${_currentMonster!.points} نقطة';
        _hunting = false;
      });
      // تحقق إذا يستحق دورة على العجلة
      if (_points >= 500) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) _showWheelDialog();
      }
    } else {
      _shakeCtrl.forward(from: 0);
      setState(() { _huntResult = '❌ فشل الصيد! حاول مرة أخرى'; _hunting = false; });
    }
  }

  void _showWheelDialog() {
    showDialog(context: context, barrierDismissible: false,
      builder: (_) => _WheelDialog(points: _points, onSpin: (prize) async {
        await HuntService.addPoints(-500);
        await HuntService.addSpin();
        final pts = await HuntService.getPoints();
        setState(() => _points = pts);
        if (mounted) {
          Navigator.pop(context);
          _showPrizeDialog(prize);
        }
      }));
  }

  void _showPrizeDialog(HuntPrize prize) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('🎉 تهانينا!', style: const TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(prize.emoji, style: const TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        Text(prize.title, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(prize.description, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text('بالشراكة مع: ${prize.partner}', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Color(0xFFD4AF37)))),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
        child: const Text('حسناً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('صيد الوحوش العراقية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800)),
        actions: [
          Padding(padding: const EdgeInsets.only(left: 16), child:
            Row(children: [
              const Icon(Icons.star, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 4),
              Text('$_points نقطة', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: Color(0xFFD4AF37))),
            ])),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // -- نقاط الرقي --
          _ProgressBar(points: _points),
          const SizedBox(height: 20),

          // -- الوحش الحالي --
          if (_currentMonster != null) _MonsterCard(monster: _currentMonster!, shake: _shake),
          const SizedBox(height: 20),

          // -- نتيجة الصيد --
          if (_huntResult.isNotEmpty)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _huntResult.startsWith('✅') ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _huntResult.startsWith('✅') ? Colors.green : Colors.red, width: 1.5),
              ),
              child: Text(_huntResult, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 20),

          // -- اختيار الأسلحة --
          const Align(alignment: Alignment.centerRight,
            child: Text('اختر سلاحك:', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700))),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10,
            children: _weapons.map((w) => _WeaponChip(weapon: w,
              selected: _selectedWeapon?.id == w.id,
              onTap: () => setState(() => _selectedWeapon = w),
            )).toList()),
          const SizedBox(height: 24),

          // -- زر الصيد --
          Row(children: [
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _hunting ? null : _hunt,
              child: _hunting
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black))
                : const Text('🎯 صيد!', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
            )),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D1B69), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _spawnMonster,
              child: const Text('🔄', style: TextStyle(fontSize: 22)),
            ),
          ]),
          const SizedBox(height: 28),

          // -- الوحوش المصطادة --
          if (_caught.isNotEmpty) _CaughtSection(caughtIds: _caught),

          // -- عجلة الحظ --
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _points >= 500 ? _showWheelDialog : null,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _points >= 500
                  ? [const Color(0xFFD4AF37), const Color(0xFFF0C040)]
                  : [const Color(0xFF2D2D2D), const Color(0xFF3D3D3D)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🎡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('عجلة الحظ', style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
                  Text(_points >= 500 ? 'اضغط للدوران! 🎉' : 'تحتاج 500 نقطة (لديك $_points)',
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.black87)),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  @override
  void dispose() { _shakeCtrl.dispose(); super.dispose(); }
}

// ── مكونات مساعدة ──────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int points;
  const _ProgressBar({required this.points});
  @override
  Widget build(BuildContext context) {
    final progress = (points % 500) / 500.0;
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('التقدم نحو عجلة الحظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 13)),
          Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFD4AF37), fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress, minHeight: 10,
            backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)))),
        const SizedBox(height: 6),
        Text('${points % 500} / 500 نقطة', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white54, fontSize: 12)),
      ]));
  }
}

class _MonsterCard extends StatelessWidget {
  final IraqiMonster monster;
  final Animation<double> shake;
  const _MonsterCard({required this.monster, required this.shake});

  Color get _rarityColor {
    switch (monster.rarity) {
      case 'أسطوري': return const Color(0xFFFF6B00);
      case 'نادر': return const Color(0xFF7B68EE);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shake,
      builder: (_, child) {
        final offset = sin(shake.value * pi * 6) * 8;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF1A1A2E), _rarityColor.withOpacity(0.3)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _rarityColor, width: 2),
        ),
        child: Column(children: [
          Text(monster.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: _rarityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(monster.rarity, style: TextStyle(fontFamily: 'Cairo', color: _rarityColor, fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          Text(monster.name, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(monster.description, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70, fontSize: 14, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star, color: Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 4),
            Text('${monster.points} نقطة', style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFD4AF37), fontWeight: FontWeight.w700, fontSize: 18)),
          ]),
        ]),
      ),
    );
  }
}

class _WeaponChip extends StatelessWidget {
  final IraqiWeapon weapon;
  final bool selected;
  final VoidCallback onTap;
  const _WeaponChip({required this.weapon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : Colors.white24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(weapon.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(weapon.name, style: TextStyle(fontFamily: 'Cairo', color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            Text('${(weapon.catchRate * 100).toInt()}% نجاح',
              style: TextStyle(fontFamily: 'Cairo', color: selected ? Colors.black87 : Colors.white54, fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

class _CaughtSection extends StatelessWidget {
  final List<String> caughtIds;
  const _CaughtSection({required this.caughtIds});

  @override
  Widget build(BuildContext context) {
    final caught = _monsters.where((m) => caughtIds.contains(m.id)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('وحوشك المصطادة (${caught.length}/${_monsters.length})',
        style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8,
        children: caught.map((m) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(m.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(m.name, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 13)),
          ]),
        )).toList()),
    ]);
  }
}

// ── عجلة الحظ ──────────────────────────────────────────
class _WheelDialog extends StatefulWidget {
  final int points;
  final Function(HuntPrize) onSpin;
  const _WheelDialog({required this.points, required this.onSpin});
  @override State<_WheelDialog> createState() => _WheelDialogState();
}

class _WheelDialogState extends State<_WheelDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;
  bool _spinning = false;
  int _selectedIndex = 0;

  static const _colors = [
    Color(0xFFD4AF37), Color(0xFF6B4EFF), Color(0xFFFF6B6B),
    Color(0xFF4ECDC4), Color(0xFF45B7D1), Color(0xFFFF8E53),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  void _spin() async {
    if (_spinning) return;
    setState(() => _spinning = true);
    _selectedIndex = Random().nextInt(_prizes.length);
    final extraRounds = 5 + Random().nextInt(3);
    final targetAngle = extraRounds + (_selectedIndex / _prizes.length);
    _rotation = Tween<double>(begin: 0, end: targetAngle).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.reset();
    await _ctrl.forward();
    setState(() => _spinning = false);
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onSpin(_prizes[_selectedIndex]);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎡 عجلة الحظ', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('سيتم خصم 500 نقطة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          // العجلة
          AnimatedBuilder(
            animation: _rotation,
            builder: (_, child) => Transform.rotate(
              angle: _rotation.value * 2 * pi,
              child: child,
            ),
            child: SizedBox(
              height: 200, width: 200,
              child: CustomPaint(painter: _WheelPainter(prizes: _prizes, colors: _colors)),
            ),
          ),
          // السهم
          const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37), size: 40),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _spinning ? null : _spin,
            child: Text(_spinning ? 'يدور...' : 'أدر العجلة!',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _spinning ? null : () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.white54)),
          ),
        ]),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<HuntPrize> prizes;
  final List<Color> colors;
  _WheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sliceAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final start = i * sliceAngle - pi / 2;
      final paint = Paint()..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sliceAngle, true, paint);

      // نص الجائزة
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + sliceAngle / 2);
      final tp = TextPainter(
        text: TextSpan(text: prizes[i].emoji, style: const TextStyle(fontSize: 22)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(radius * 0.55 - tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // دائرة وسط
    canvas.drawCircle(center, radius * 0.15, Paint()..color = const Color(0xFF1A1A2E));
    canvas.drawCircle(center, radius * 0.15, Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  @override
  bool shouldRepaint(_) => false;
}
