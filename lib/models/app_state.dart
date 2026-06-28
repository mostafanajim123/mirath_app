// lib/models/app_state.dart
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  AppState المحدّث — يستخدم SQLite (Drift) بدلاً من
//  البيانات الهاردكود و SharedPreferences
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/translations.dart';
import '../models/achievements.dart';
import '../database/database_service.dart';

class AppState extends ChangeNotifier {
  // ── البيانات المحملة من DB ───────────────────────────
  List<Site> _allSites      = [];
  List<HistoricalCharacter> _allCharacters = [];

  List<Site> get allSites      => _allSites;
  List<HistoricalCharacter> get allCharacters => _allCharacters;
  List<Site> get allShrines    => _allSites.where((s) => s.type == 'مرقد مقدس').toList();

  // ── حالة التحميل ────────────────────────────────────
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AppState() { _init(); }

  // ── تهيئة شاملة ─────────────────────────────────────
  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    // 1. تهيئة قاعدة البيانات (seed عند أول تشغيل)
    await DatabaseService().initialize();
    final dao = DatabaseService().dao;

    // 2. تحميل البيانات الأساسية
    _allSites      = await dao.getAllSites();
    _allCharacters = await dao.getAllCharacters();

    // 3. تحميل المفضلة
    final favS = await dao.getFavSiteIds();
    final favC = await dao.getFavCharIds();
    _favSites.addAll(favS);
    _favChars.addAll(favC);

    // 4. تحميل الإنجازات
    final unlocked = await dao.getUnlockedAchievements();
    _unlockedAchievements.addAll(unlocked);

    // 5. تحميل الإعدادات
    _profileName  = await dao.getSetting('profile_name')  ?? '';
    _profilePhoto = await dao.getSetting('profile_photo');
    _isDark       = (await dao.getSetting('dark_mode')) == 'true';
    final savedLang = await dao.getSetting('language');
    final oldArabic = await dao.getSetting('is_arabic');
    _language    = savedLang ?? (oldArabic == 'false' ? 'en' : 'ar');
    _userType    = await dao.getSetting('user_type');
    _hasSeenUserTypeDialog = (await dao.getSetting('seen_user_type_dialog')) == 'true';
    _themeMode   = _isDark ? ThemeMode.dark : ThemeMode.light;
    _shareCount  = int.tryParse(await dao.getSetting('share_count') ?? '0') ?? 0;

    _invalidateFilterCache();
    _isLoading = false;
    notifyListeners();
  }

  // ── THEME ─────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDark = false;
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _isDark;

  void toggleTheme() async {
    _isDark = !_isDark;
    _themeMode = _isDark ? ThemeMode.dark : ThemeMode.light;
    if (_isDark) _checkAchievement('darkMode', 1);
    notifyListeners();
    await DatabaseService().dao.setSetting('dark_mode', _isDark.toString());
  }

  // ── LANGUAGE ──────────────────────────────────────────
  String _language = 'ar';
  String get language => _language;
  bool get isArabic  => _language == 'ar';
  bool get isEnglish => _language == 'en';
  bool get isKurdish => _language == 'ku';

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    await DatabaseService().dao.setSetting('language', lang);
  }

  void toggleLanguage() async => setLanguage(_language == 'ar' ? 'en' : 'ar');

  void cycleLanguage() async {
    const order = ['ar', 'en', 'ku'];
    final next = order[(order.indexOf(_language) + 1) % order.length];
    await setLanguage(next);
  }

  // ── USER TYPE ─────────────────────────────────────────
  String? _userType;
  String? get userType => _userType;
  bool get isIraqi   => _userType == 'iraqi';
  bool get isTourist => _userType == 'tourist';

  bool _hasSeenUserTypeDialog = false;
  bool get hasSeenUserTypeDialog => _hasSeenUserTypeDialog;

  Future<void> markUserTypeDialogSeen() async {
    if (_hasSeenUserTypeDialog) return;
    _hasSeenUserTypeDialog = true;
    await DatabaseService().dao.setSetting('seen_user_type_dialog', 'true');
  }

  Future<void> setUserType(String type) async {
    _userType = type;
    _hasSeenUserTypeDialog = true;
    notifyListeners();
    await DatabaseService().dao.setSetting('user_type', type);
    await DatabaseService().dao.setSetting('seen_user_type_dialog', 'true');
  }

  // ── PROFILE ───────────────────────────────────────────────
  String _profileName  = '';
  String? _profilePhoto;
  String get profileName  => _profileName;
  String? get profilePhoto => _profilePhoto;

  void setProfileName(String name) async {
    _profileName = name;
    notifyListeners();
    await DatabaseService().dao.setSetting('profile_name', name);
  }

  void setProfilePhoto(String path) async {
    _profilePhoto = path;
    notifyListeners();
    await DatabaseService().dao.setSetting('profile_photo', path);
  }

  // ── SEARCH & CATEGORY ─────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearch(String q) {
    if (_searchQuery == q) return;
    _searchQuery = q;
    _invalidateFilterCache();
    notifyListeners();
  }

  String _selectedCategory = 'الكل';
  String get selectedCategory => _selectedCategory;

  void setCategory(String c) {
    if (_selectedCategory == c) return;
    _selectedCategory = c;
    _invalidateFilterCache();
    notifyListeners();
  }

  final List<String> categories = [
    'الكل','سومرية','بابلية','آشورية',
    'إسلامية','أكدية','ساسانية','متعددة',
  ];

  final List<Map<String, String>> eras = [
    {'name': 'ما قبل التاريخ', 'period': '60,000 - 5,000 ق.م',
     'desc': 'من كهف شانيدار إلى أولى التجمعات البشرية على ضفاف الرافدين',
     'image': 'assets/images/eras/prehistoric.jpg', 'color': '0xFF8B6B4A'},
    {'name': 'العصر السومري', 'period': '5,000 - 2,000 ق.م',
     'desc': 'ولادة الكتابة والمدن والحضارة في أوروك ونيبور وأور العظيمة',
     'image': 'assets/images/eras/sumerian.jpg', 'color': '0xFF6B8B4A'},
    {'name': 'العصر الأكدي', 'period': '2,334 - 2,150 ق.م',
     'desc': 'أول إمبراطورية في التاريخ يؤسسها سرجون الأكدي العبقري',
     'image': 'assets/images/eras/akkadian.jpg', 'color': '0xFF8B4A4A'},
    {'name': 'العصر البابلي', 'period': '2,000 - 539 ق.م',
     'desc': 'بابل عاصمة العالم وحمورابي وحدائق بابل المعلقة',
     'image': 'assets/images/eras/babylonian.jpg', 'color': '0xFF4A6B8B'},
    {'name': 'العصر الآشوري', 'period': '2,500 - 612 ق.م',
     'desc': 'إمبراطورية نينوى ونمرود والمكتبة الكبرى واللاماسو',
     'image': 'assets/images/eras/assyrian.jpg', 'color': '0xFF8B6B4A'},
    {'name': 'العصر الإسلامي', 'period': '637 م - الآن',
     'desc': 'بغداد عاصمة العالم وهارون الرشيد وازدهار الحضارة الإسلامية',
     'image': 'assets/images/eras/islamic.jpg', 'color': '0xFF4A8B6B'},
  ];

  // ── FILTERED SITES — مع Cache ──────────────────────
  List<Site>? _filteredCache;

  void _invalidateFilterCache() => _filteredCache = null;

  List<Site> get filteredSites {
    _filteredCache ??= _allSites.where((s) {
      final matchQ = _searchQuery.isEmpty ||
        s.name.contains(_searchQuery) ||
        s.city.contains(_searchQuery) ||
        s.civilization.contains(_searchQuery);
      final matchC = _selectedCategory == 'الكل' ||
        s.civilization == _selectedCategory;
      return matchQ && matchC;
    }).toList();
    return _filteredCache!;
  }

  // ⚡ بحث متقدم عبر SQL مباشرة (للفلترة المعقدة)
  Future<List<Site>> advancedSearch({
    String query = '',
    String category = 'الكل',
    String? type,
  }) async {
    return DatabaseService().dao.searchSites(
      query: query,
      category: category,
      type: type,
    );
  }

  List<Site> get featuredSites   => _allSites.where((s) => s.isFeatured).toList();
  List<Site> get unescoSites     => _allSites.where((s) => s.isUnesco).toList();
  List<Site> get featuredShrines => _allSites.where((s) => s.isFeatured && s.type == 'مرقد مقدس').toList();

  // ── FAVORITES ─────────────────────────────────────────────
  final Set<String> _favSites = {};
  final Set<String> _favChars = {};

  bool isFavSite(String id) => _favSites.contains(id);
  bool isFavChar(String id) => _favChars.contains(id);

  void toggleFavSite(String id) async {
    _favSites.contains(id) ? _favSites.remove(id) : _favSites.add(id);
    notifyListeners();
    _checkAchievement('favSites', _favSites.length);
    final unescoFavCount = _allSites
      .where((s) => s.isUnesco && _favSites.contains(s.id)).length;
    _checkAchievement('unescoFav', unescoFavCount);
    await DatabaseService().dao.toggleFavorite(id, 'site');
  }

  void toggleFavChar(String id) async {
    _favChars.contains(id) ? _favChars.remove(id) : _favChars.add(id);
    notifyListeners();
    _checkAchievement('favChars', _favChars.length);
    await DatabaseService().dao.toggleFavorite(id, 'character');
  }

  List<Site> get favSites =>
    _allSites.where((s) => _favSites.contains(s.id)).toList();
  List<HistoricalCharacter> get favChars =>
    _allCharacters.where((c) => _favChars.contains(c.id)).toList();

  // ── SHARE COUNT ───────────────────────────────────────────
  int _shareCount = 0;
  int get shareCount => _shareCount;

  void incrementShare() async {
    _shareCount++;
    notifyListeners();
    _checkAchievement('shares', _shareCount);
    await DatabaseService().dao.setSetting('share_count', _shareCount.toString());
  }

  // ── ACHIEVEMENTS ──────────────────────────────────────────
  final Set<String> _unlockedAchievements = {};
  Achievement? _latestUnlocked;

  Set<String> get unlockedAchievements => _unlockedAchievements;
  Achievement? get latestUnlocked => _latestUnlocked;

  bool isUnlocked(String id) => _unlockedAchievements.contains(id);

  List<Achievement> get earnedAchievements => allAchievements
    .where((a) => _unlockedAchievements.contains(a.id)).toList();

  List<Achievement> get lockedAchievements => allAchievements
    .where((a) => !_unlockedAchievements.contains(a.id)).toList();

  int get achievementPoints => earnedAchievements.fold(0, (sum, a) {
    switch (a.rarity) {
      case AchievementRarity.bronze:   return sum + 10;
      case AchievementRarity.silver:   return sum + 25;
      case AchievementRarity.gold:     return sum + 50;
      case AchievementRarity.platinum: return sum + 100;
    }
  });

  void checkAchievementExternal(String type, int count) =>
      _checkAchievement(type, count);

  void _checkAchievement(String type, int count) async {
    bool newUnlock = false;
    for (final a in allAchievements) {
      if (_unlockedAchievements.contains(a.id)) continue;
      final condKey = a.condition(a.requiredCount);
      final parts   = condKey.split(':');
      if (parts[0] == type && count >= int.parse(parts[1])) {
        _unlockedAchievements.add(a.id);
        _latestUnlocked = a;
        newUnlock = true;
        await DatabaseService().dao.unlockAchievement(a.id);
      }
    }
    if (newUnlock) notifyListeners();
  }

  void clearLatestUnlocked() {
    _latestUnlocked = null;
    notifyListeners();
  }

  // ── MUSEUM INDEX ──────────────────────────────────────────
  int _museumIndex = 0;
  int get museumIndex => _museumIndex;
  void setMuseumIndex(int i) { _museumIndex = i; notifyListeners(); }
}
