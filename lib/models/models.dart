// ── SITE MODEL ───────────────────────────────────────────────────────────────
class Site {
  final String id, name, nameEn, city, governorate, description;
  final double lat, lng;
  final String civilization, type, builtYear, imageUrl;
  final bool isUnesco, isFeatured;
  final List<String> tags;
  // حقول إنكليزية كاملة (وصف + بيانات قصيرة) — تُستخدم لما تكون اللغة إنكليزية
  final String descriptionEn, cityEn, governorateEn, civilizationEn, typeEn, builtYearEn;

  const Site({
    required this.id, required this.name, required this.nameEn,
    required this.city, required this.governorate, required this.description,
    required this.lat, required this.lng, required this.civilization,
    required this.type, required this.builtYear, required this.imageUrl,
    this.isUnesco = false, this.isFeatured = false, this.tags = const [],
    this.descriptionEn = '', this.cityEn = '', this.governorateEn = '',
    this.civilizationEn = '', this.typeEn = '', this.builtYearEn = '',
  });

  // يرجع النص الإنكليزي إذا متوفر، وإلا يرجع العربي كاحتياط
  String descFor(String lang) =>
    lang == 'en' && descriptionEn.isNotEmpty ? descriptionEn : description;
  String cityFor(String lang) =>
    lang == 'en' && cityEn.isNotEmpty ? cityEn : city;
  String governorateFor(String lang) =>
    lang == 'en' && governorateEn.isNotEmpty ? governorateEn : governorate;
  String civilizationFor(String lang) =>
    lang == 'en' && civilizationEn.isNotEmpty ? civilizationEn : civilization;
  String typeFor(String lang) =>
    lang == 'en' && typeEn.isNotEmpty ? typeEn : type;
  String builtYearFor(String lang) =>
    lang == 'en' && builtYearEn.isNotEmpty ? builtYearEn : builtYear;
  String nameFor(String lang) => lang == 'en' ? nameEn : name;
}

// ── HISTORICAL CHARACTER MODEL ────────────────────────────────────────────────
class HistoricalCharacter {
  final String id, name, nameEn, era, civilization, role, description, imageUrl;
  final String birthYear, deathYear;
  final List<String> achievements;
  // حقول إنكليزية كاملة
  final String descriptionEn, eraEn, civilizationEn, roleEn,
    birthYearEn, deathYearEn;
  final List<String> achievementsEn;

  const HistoricalCharacter({
    required this.id, required this.name, required this.nameEn,
    required this.era, required this.civilization, required this.role,
    required this.description, required this.imageUrl,
    required this.birthYear, required this.deathYear,
    this.achievements = const [],
    this.descriptionEn = '', this.eraEn = '', this.civilizationEn = '',
    this.roleEn = '', this.birthYearEn = '', this.deathYearEn = '',
    this.achievementsEn = const [],
  });

  String descFor(String lang) =>
    lang == 'en' && descriptionEn.isNotEmpty ? descriptionEn : description;
  String eraFor(String lang) =>
    lang == 'en' && eraEn.isNotEmpty ? eraEn : era;
  String civilizationFor(String lang) =>
    lang == 'en' && civilizationEn.isNotEmpty ? civilizationEn : civilization;
  String roleFor(String lang) =>
    lang == 'en' && roleEn.isNotEmpty ? roleEn : role;
  String birthYearFor(String lang) =>
    lang == 'en' && birthYearEn.isNotEmpty ? birthYearEn : birthYear;
  String deathYearFor(String lang) =>
    lang == 'en' && deathYearEn.isNotEmpty ? deathYearEn : deathYear;
  List<String> achievementsFor(String lang) =>
    lang == 'en' && achievementsEn.isNotEmpty ? achievementsEn : achievements;
  String nameFor(String lang) => lang == 'en' ? nameEn : name;
}

// ── ARTICLE MODEL ────────────────────────────────────────────────────────────
class Article {
  final String id, title, subtitle, content, imageUrl, category, date;
  final int readMinutes, likes, views;

  const Article({
    required this.id, required this.title, required this.subtitle,
    required this.content, required this.imageUrl, required this.category,
    required this.date, required this.readMinutes,
    this.likes = 0, this.views = 0,
  });
}
