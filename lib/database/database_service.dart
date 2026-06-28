// lib/database/database_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DatabaseService — بدون Drift، يستخدم shared_preferences
//  البيانات (sites/characters) مباشرة من iraq_data.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../data/iraq_data.dart';

// ─────────────────────────────────────────────────────
//  DAO
// ─────────────────────────────────────────────────────
class _AppDao {

  // ══ SITES ════════════════════════════════════════════

  Future<List<Site>> getAllSites() async => iraqSites;

  Future<List<Site>> getFeaturedSites() async =>
      iraqSites.where((s) => s.isFeatured).toList();

  Future<List<Site>> getUnescoSites() async =>
      iraqSites.where((s) => s.isUnesco).toList();

  Future<List<Site>> getShrines() async =>
      iraqSites.where((s) => s.type == 'مرقد مقدس').toList();

  Future<Site?> getSiteById(String id) async =>
      iraqSites.cast<Site?>().firstWhere((s) => s?.id == id, orElse: () => null);

  Future<List<Site>> getSitesByType(String type) async =>
      iraqSites.where((s) => s.type == type).toList();

  Future<List<Site>> searchSites({
    String query = '',
    String category = 'الكل',
    String? type,
  }) async {
    return iraqSites.where((s) {
      bool cond = true;
      if (query.isNotEmpty) {
        cond = cond &&
            (s.name.contains(query) ||
             s.nameEn.toLowerCase().contains(query.toLowerCase()) ||
             s.city.contains(query) ||
             s.civilization.contains(query));
      }
      if (category != 'الكل') cond = cond && s.civilization == category;
      if (type != null) cond = cond && s.type == type;
      return cond;
    }).toList();
  }

  Future<int> getSitesCount() async => iraqSites.length;

  // ══ CHARACTERS ═══════════════════════════════════════

  Future<List<HistoricalCharacter>> getAllCharacters() async => iraqCharacters;

  Future<List<HistoricalCharacter>> searchCharacters(String query) async {
    if (query.isEmpty) return iraqCharacters;
    return iraqCharacters.where((c) =>
        c.name.contains(query) ||
        c.nameEn.toLowerCase().contains(query.toLowerCase()) ||
        c.era.contains(query)).toList();
  }

  // ══ FAVORITES ════════════════════════════════════════

  Future<Set<String>> getFavSiteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('fav_sites')?.toSet() ?? {};
  }

  Future<Set<String>> getFavCharIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('fav_characters')?.toSet() ?? {};
  }

  // kept for backward compatibility
  Future<Set<String>> getFavoriteSiteIds() => getFavSiteIds();
  Future<Set<String>> getFavoriteCharacterIds() => getFavCharIds();

  Future<void> addFavorite(String itemId, String itemType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = itemType == 'site' ? 'fav_sites' : 'fav_characters';
    final list = prefs.getStringList(key) ?? [];
    if (!list.contains(itemId)) {
      list.add(itemId);
      await prefs.setStringList(key, list);
    }
  }

  Future<void> removeFavorite(String itemId, String itemType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = itemType == 'site' ? 'fav_sites' : 'fav_characters';
    final list = prefs.getStringList(key) ?? [];
    list.remove(itemId);
    await prefs.setStringList(key, list);
  }

  Future<bool> isFavorite(String itemId, String itemType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = itemType == 'site' ? 'fav_sites' : 'fav_characters';
    return (prefs.getStringList(key) ?? []).contains(itemId);
  }

  Future<void> toggleFavorite(String itemId, String itemType) async {
    final exists = await isFavorite(itemId, itemType);
    if (exists) {
      await removeFavorite(itemId, itemType);
    } else {
      await addFavorite(itemId, itemType);
    }
  }

  // ══ ACHIEVEMENTS ══════════════════════════════════════

  Future<Set<String>> getUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('unlocked_achievements')?.toSet() ?? {};
  }

  Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('unlocked_achievements') ?? [];
    if (!list.contains(achievementId)) {
      list.add(achievementId);
      await prefs.setStringList('unlocked_achievements', list);
    }
  }

  Future<void> unlockAchievements(List<String> ids) async {
    for (final id in ids) await unlockAchievement(id);
  }

  // ══ SETTINGS ══════════════════════════════════════════

  Future<String?> getSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('setting_$key');
  }

  Future<void> setSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_$key', value);
  }

  Future<void> deleteSetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('setting_$key');
  }

  // ══ SEED (no-op — data comes from iraq_data.dart) ═════
  Future<void> insertAllSites(List<Site> sites) async {}
  Future<void> insertAllCharacters(List<HistoricalCharacter> chars) async {}
}

// ─────────────────────────────────────────────────────
//  Singleton
// ─────────────────────────────────────────────────────
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _AppDao _dao = _AppDao();
  _AppDao get dao => _dao;

  Future<void> initialize() async {
    // لا شيء لتهيئته — shared_preferences جاهز تلقائياً
  }

  Future<void> reseed() async {}
  Future<void> close() async {}
}
