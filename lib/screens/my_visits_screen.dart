// lib/screens/my_visits_screen.dart
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  شاشة زياراتي — عرض كل الـ Check-ins المحفوظة
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';

import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../database/database_service.dart';
import 'checkin_screen.dart';

class MyVisitsScreen extends StatefulWidget {
  const MyVisitsScreen({super.key});

  @override
  State<MyVisitsScreen> createState() => _MyVisitsScreenState();
}

class _MyVisitsScreenState extends State<MyVisitsScreen> {
  List<CheckIn> _visits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final dao = DatabaseService().dao;
    final raw = await dao.getSetting('checkins_json') ?? '[]';
    final List data = jsonDecode(raw);

    final visits = data.map((e) {
      return CheckIn(
        id: e['id'] ?? '',
        siteId: e['siteId'] ?? '',
        siteName: e['siteName'] ?? '',
        siteCity: e['siteCity'] ?? '',
        lat: (e['lat'] as num?)?.toDouble() ?? 0,
        lng: (e['lng'] as num?)?.toDouble() ?? 0,
        photoPath: e['photoPath'] ?? '',
        visitedAt: DateTime.tryParse(e['visitedAt'] ?? '') ?? DateTime.now(),
        isVerified: e['isVerified'] == true,
      );
    }).toList();

    // ترتيب من الأحدث للأقدم
    visits.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    setState(() {
      _visits = visits;
      _loading = false;
    });
  }

  String _formatDate(DateTime d) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().isDark;

    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(
        title: 'زياراتي',
        showBack: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _visits.isEmpty
              ? _buildEmpty(isDark)
              : _buildList(isDark),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_outlined,
              color: IHTheme.txtMuted(context), size: 72),
          const SizedBox(height: 16),
          Text(
            'لم تسجل أي زيارة بعد',
            style: AppFonts.amiriQuran(
              fontSize: 18,
              color: IHTheme.txtPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اذهب إلى أي موقع أثري وسجّل زيارتك!',
            style: AppFonts.nunito(
              fontSize: 14,
              color: IHTheme.txtSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(bool isDark) {
    return Column(
      children: [
        // إحصائية سريعة
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: IHTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: _visits.length.toString(),
                label: 'موقع زرته',
                icon: Icons.place_rounded,
              ),
              Container(
                  width: 1, height: 40, color: Colors.white.withValues(alpha: .3)),
              _StatItem(
                value: _visits
                    .where((v) => v.isVerified)
                    .length
                    .toString(),
                label: 'متحقق منها',
                icon: Icons.verified_rounded,
              ),
              Container(
                  width: 1, height: 40, color: Colors.white.withValues(alpha: .3)),
              _StatItem(
                value: _visits
                    .map((v) => v.siteCity)
                    .toSet()
                    .length
                    .toString(),
                label: 'مدينة',
                icon: Icons.location_city_rounded,
              ),
            ],
          ),
        ),

        // قائمة الزيارات
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: _visits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => _VisitCard(
              visit: _visits[i],
              formattedDate: _formatDate(_visits[i].visitedAt),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: .8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppFonts.nunito(
            fontSize: 11,
            color: Colors.white.withValues(alpha: .8),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────

class _VisitCard extends StatelessWidget {
  final CheckIn visit;
  final String formattedDate;

  const _VisitCard({required this.visit, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        visit.photoPath.isNotEmpty && File(visit.photoPath).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: IHTheme.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IHTheme.bdr(context), width: 0.5),
        boxShadow: IHTheme.cardShadow,
      ),
      child: Row(
        children: [
          // صورة أو أيقونة
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: hasPhoto
                ? Image.file(
                    File(visit.photoPath),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 90,
                    height: 90,
                    color: IHTheme.primary.withValues(alpha: .1),
                    alignment: Alignment.center,
                    child: Icon(Icons.account_balance_rounded,
                        color: IHTheme.primary, size: 36),
                  ),
          ),

          // المعلومات
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          visit.siteName,
                          style: AppFonts.amiriQuran(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: IHTheme.txtPrimary(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (visit.isVerified)
                        Tooltip(
                          message: 'متحقق منها بالـ GPS',
                          child: Icon(Icons.verified_rounded,
                              color: Colors.green, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: IHTheme.primary, size: 13),
                      const SizedBox(width: 3),
                      Text(
                        visit.siteCity,
                        style: AppFonts.nunito(
                          fontSize: 12,
                          color: IHTheme.txtSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: AppFonts.nunito(
                      fontSize: 11,
                      color: IHTheme.txtMuted(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
