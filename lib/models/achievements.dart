// ── ACHIEVEMENT MODEL ─────────────────────────────────────────────────────────

enum AchievementRarity { bronze, silver, gold, platinum }

class Achievement {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final int requiredCount;
  final String Function(int count) condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.requiredCount,
    required this.condition,
  });
}

// ── ALL ACHIEVEMENTS ──────────────────────────────────────────────────────────
final List<Achievement> allAchievements = [
  Achievement(
    id: 'first_fav',
    title: 'أول خطوة',
    titleEn: 'First Step',
    description: 'أضف موقعاً إلى مفضلتك',
    icon: '⭐',
    rarity: AchievementRarity.bronze,
    requiredCount: 1,
    condition: (c) => 'favSites:$c',
  ),
  Achievement(
    id: 'explorer_3',
    title: 'مستكشف',
    titleEn: 'Explorer',
    description: 'احفظ ٣ مواقع أثرية',
    icon: '🗺️',
    rarity: AchievementRarity.bronze,
    requiredCount: 3,
    condition: (c) => 'favSites:$c',
  ),
  Achievement(
    id: 'historian_5',
    title: 'مؤرخ',
    titleEn: 'Historian',
    description: 'احفظ ٥ مواقع أثرية',
    icon: '📜',
    rarity: AchievementRarity.silver,
    requiredCount: 5,
    condition: (c) => 'favSites:$c',
  ),
  Achievement(
    id: 'guardian_10',
    title: 'حارس التراث',
    titleEn: 'Heritage Guardian',
    description: 'احفظ ١٠ مواقع أثرية',
    icon: '🏛️',
    rarity: AchievementRarity.gold,
    requiredCount: 10,
    condition: (c) => 'favSites:$c',
  ),
  Achievement(
    id: 'char_1',
    title: 'من الماضي',
    titleEn: 'From the Past',
    description: 'احفظ شخصية تاريخية',
    icon: '👤',
    rarity: AchievementRarity.bronze,
    requiredCount: 1,
    condition: (c) => 'favChars:$c',
  ),
  Achievement(
    id: 'char_5',
    title: 'سفير الحضارات',
    titleEn: 'Civilization Ambassador',
    description: 'احفظ ٥ شخصيات تاريخية',
    icon: '👑',
    rarity: AchievementRarity.silver,
    requiredCount: 5,
    condition: (c) => 'favChars:$c',
  ),
  Achievement(
    id: 'sharer_1',
    title: 'صوت التراث',
    titleEn: 'Heritage Voice',
    description: 'شارك بطاقة موقع على السوشيال',
    icon: '📤',
    rarity: AchievementRarity.bronze,
    requiredCount: 1,
    condition: (c) => 'shares:$c',
  ),
  Achievement(
    id: 'sharer_5',
    title: 'سفير الإرث',
    titleEn: 'Legacy Ambassador',
    description: 'شارك ٥ بطاقات',
    icon: '🌍',
    rarity: AchievementRarity.gold,
    requiredCount: 5,
    condition: (c) => 'shares:$c',
  ),
  Achievement(
    id: 'unesco_all',
    title: 'قائمة اليونسكو',
    titleEn: 'UNESCO List',
    description: 'احفظ جميع مواقع اليونسكو',
    icon: '🏅',
    rarity: AchievementRarity.platinum,
    requiredCount: 4,
    condition: (c) => 'unescoFav:$c',
  ),
  Achievement(
    id: 'night_owl',
    title: 'مستكشف الليل',
    titleEn: 'Night Explorer',
    description: 'فعّل الوضع الليلي',
    icon: '🌙',
    rarity: AchievementRarity.bronze,
    requiredCount: 1,
    condition: (c) => 'darkMode:$c',
  ),

  // ── إنجازات Check-in ──────────────────────────────────
  Achievement(
    id: 'checkin_first',
    title: 'زرته بنفسك',
    titleEn: 'In Person',
    description: 'سجّل زيارتك الأولى في موقع أثري',
    icon: '📍',
    rarity: AchievementRarity.bronze,
    requiredCount: 1,
    condition: (c) => 'checkins:$c',
  ),
  Achievement(
    id: 'checkin_3',
    title: 'رحّالة',
    titleEn: 'Wanderer',
    description: 'زر ٣ مواقع أثرية بنفسك',
    icon: '🧭',
    rarity: AchievementRarity.silver,
    requiredCount: 3,
    condition: (c) => 'checkins:$c',
  ),
  Achievement(
    id: 'checkin_10',
    title: 'مستكشف الحضارات',
    titleEn: 'Civilization Explorer',
    description: 'زر ١٠ مواقع أثرية بنفسك',
    icon: '🏺',
    rarity: AchievementRarity.gold,
    requiredCount: 10,
    condition: (c) => 'checkins:$c',
  ),
  Achievement(
    id: 'checkin_verified',
    title: 'شاهد عيان',
    titleEn: 'Eyewitness',
    description: 'سجّل زيارة مُتحقق منها بالـ GPS',
    icon: '✅',
    rarity: AchievementRarity.silver,
    requiredCount: 1,
    condition: (c) => 'checkin_verified:$c',
  ),
];
