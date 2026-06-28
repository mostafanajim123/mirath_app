// ═══════════════════════════════════════════════════════════════════════════
//  TRANSLATIONS — Arabic / English / Kurdish
//  استخدام: AppStrings.of(context).key  أو  AppStrings.t(state.language, key)
// ═══════════════════════════════════════════════════════════════════════════

class AppStrings {
  final String language;
  const AppStrings._(this.language);

  factory AppStrings.of(context) {
    // استخدام static من AppState مباشرة عند الاستدعاء
    return const AppStrings._('ar');
  }

  static AppStrings lang(String code) => AppStrings._(code);

  String get(String key) =>
    _data[key]?[language] ?? _data[key]?['ar'] ??
    _extraData[key]?[language] ?? _extraData[key]?['ar'] ?? key;

  // ── شورت كت ─────────────────────────────────────────────
  String get appName          => get('appName');
  String get appTagline       => get('appTagline');

  // ── الشاشة الرئيسية ─────────────────────────────────────
  String get discoverCivs     => get('discoverCivs');
  String get heroKicker       => get('heroKicker');
  String get heritageTitle    => get('heritageTitle');
  String get mapBtn           => get('mapBtn');
  String get searchHint       => get('searchHint');
  String get featuredSites    => get('featuredSites');
  String get viewAll          => get('viewAll');
  String get eras             => get('eras');
  String get unescoSites      => get('unescoSites');
  String get characters       => get('characters');

  // ── شريط التنقل ─────────────────────────────────────────
  String get navHome          => get('navHome');
  String get navMap           => get('navMap');
  String get navSites         => get('navSites');
  String get navChat          => get('navChat');
  String get navProfile       => get('navProfile');
  String get navSettings      => get('navSettings');

  // ── صفحة الإعدادات ──────────────────────────────────────
  String get settings         => get('settings');
  String get language_        => get('language_');
  String get userType         => get('userType');
  String get appearance       => get('appearance');
  String get lightMode        => get('lightMode');
  String get darkMode         => get('darkMode');
  String get enableLight      => get('enableLight');
  String get enableDark       => get('enableDark');
  String get contactReport    => get('contactReport');
  String get appComplaint     => get('appComplaint');
  String get complaintSub     => get('complaintSub');
  String get sendBtn          => get('sendBtn');
  String get reportSite       => get('reportSite');
  String get reportSiteSub    => get('reportSiteSub');
  String get reportBtn        => get('reportBtn');
  String get aboutApp         => get('aboutApp');
  String get appVersion       => get('appVersion');
  String get sitesCount       => get('sitesCount');
  String get userTypePrompt   => get('userTypePrompt');
  String get iraqiUser        => get('iraqiUser');
  String get touristUser      => get('touristUser');
  String get notSelected      => get('notSelected');
  String get changeBtn        => get('changeBtn');

  // ── التصفية ─────────────────────────────────────────────
  String get all              => get('all');
  String get sumerian         => get('sumerian');
  String get babylonian       => get('babylonian');
  String get assyrian         => get('assyrian');
  String get islamic          => get('islamic');
  String get akkadian         => get('akkadian');
  String get sassanid         => get('sassanid');
  String get multiple         => get('multiple');

  // ── الدردشة (نبو) ────────────────────────────────────────
  String get chatTitle        => get('chatTitle');
  String get chatHint         => get('chatHint');
  String get chatOnline       => get('chatOnline');

  // ── الإنجازات ────────────────────────────────────────────
  String get achievements     => get('achievements');
  String get points           => get('points');
  String get earned           => get('earned');
  String get locked           => get('locked');

  // ── المتحف ──────────────────────────────────────────────
  String get museum           => get('museum');
  // ── TOURIST SERVICES ──────────────────────────────────────
  String get touristServices      => get('touristServices');
  String get touristServicesTitle => get('touristServicesTitle');
  String get touristServicesSub   => get('touristServicesSub');
  String get hotelsTitle          => get('hotelsTitle');
  String get hotelsSub            => get('hotelsSub');
  String get guidesTitle          => get('guidesTitle');
  String get guidesSub            => get('guidesSub');
  String get callBtn              => get('callBtn');
  String get whatsappBtn          => get('whatsappBtn');
  String get ratingLabel          => get('ratingLabel');
  String get priceNight           => get('priceNight');
  String get govLabel             => get('govLabel');
  String get specialtyLabel       => get('specialtyLabel');
  String get langLabel            => get('langLabel');

  // ── الأخطاء والمشتركة ───────────────────────────────────
  String get noResults        => get('noResults');
  String get loading          => get('loading');
  String get errorOccurred    => get('errorOccurred');
  String get close            => get('close');
  String get save             => get('save');
  String get cancel           => get('cancel');
  String get favorites        => get('favorites');
  String get share            => get('share');
  String get noFavorites      => get('noFavorites');
  String get noFavChars       => get('noFavChars');
  String get profile          => get('profile');
  String get editName         => get('editName');
  String get yourName         => get('yourName');
  String get changePhoto      => get('changePhoto');

  // ── شاشة التفاصيل ───────────────────────────────────────
  String get location         => get('location');
  String get civilization     => get('civilization');
  String get period           => get('period');
  String get addFav           => get('addFav');
  String get removeFav        => get('removeFav');

  // ── أنواع المستخدمين (بطاقة) ────────────────────────────
  String get whoAreYou        => get('whoAreYou');
  String get iraqiDesc        => get('iraqiDesc');
  String get touristDesc      => get('touristDesc');
  String get confirm          => get('confirm');

  // ── شكوى وإبلاغ ─────────────────────────────────────────
  String get complaintTypes      => get('complaintTypes');
  String get techError           => get('techError');
  String get suggestion          => get('suggestion');
  String get inaccurateContent   => get('inaccurateContent');
  String get other               => get('other');
  String get writeComplaintFirst => get('writeComplaintFirst');
  String get complaintAboutApp   => get('complaintAboutApp');
  String get complaintHelp       => get('complaintHelp');
  String get explainProblem      => get('explainProblem');
  String get sending             => get('sending');
  String get sendComplaint       => get('sendComplaint');
  String get emailWillOpen       => get('emailWillOpen');
  String get thankYou            => get('thankYou');
  String get willReview          => get('willReview');
  String get backToSettings      => get('backToSettings');
  String get sendError           => get('sendError');
  String get reportDanger        => get('reportDanger');
  String get siteName            => get('siteName');
  String get urgencyLevel        => get('urgencyLevel');
  String get describeRisk        => get('describeRisk');
  String get addPhoto            => get('addPhoto');
  String get sendReport          => get('sendReport');
  String get fillRequired        => get('fillRequired');
}

// ═══════════════════════════════════════════════════════════════════════════
//  بيانات الترجمة
// ═══════════════════════════════════════════════════════════════════════════
const Map<String, Map<String, String>> _data = {

  'appName': {
    'ar': 'ميراث',
    'en': 'Mirath',
    'ku': 'میراث',
  },
  'appTagline': {
    'ar': 'تراث العراق عبر آلاف السنين',
    'en': 'Iraq\'s Heritage Through Millennia',
    'ku': 'میراتی عێراق لە ماوەی هەزاران ساڵ',
  },

  // الشاشة الرئيسية
  'discoverCivs': {
    'ar': 'اكتشف الحضارات',
    'en': 'Discover Civilizations',
    'ku': 'شارستانییەکان بدۆزەرەوە',
  },
  'heroKicker': {
    'ar': 'بلاد الرافدين • مهد الحضارة',
    'en': 'Mesopotamia • Cradle of Civilization',
    'ku': 'مێزۆپۆتامیا • زگماکی شارستانیەت',
  },
  'heritageTitle': {
    'ar': 'تراث العراق\nعبر آلاف السنين',
    'en': 'Iraq\'s Heritage\nThrough Millennia',
    'ku': 'میراتی عێراق\nلە ماوەی هەزاران ساڵ',
  },
  'mapBtn': {
    'ar': 'الخريطة',
    'en': 'Map',
    'ku': 'نەخشە',
  },
  'searchHint': {
    'ar': 'ابحث عن موقع أثري أو شخصية...',
    'en': 'Search for a site or figure...',
    'ku': 'گەڕان بۆ شوێنی کۆنی یان کەسێک...',
  },
  'featuredSites': {
    'ar': 'أبرز المواقع الأثرية',
    'en': 'Featured Archaeological Sites',
    'ku': 'شوێنە کۆنەکانی بەرچاو',
  },
  'viewAll': {
    'ar': 'عرض الكل',
    'en': 'View All',
    'ku': 'هەموو ببینە',
  },
  'eras': {
    'ar': 'الحقب التاريخية',
    'en': 'Historical Eras',
    'ku': 'سەردەمە مێژووییەکان',
  },
  'unescoSites': {
    'ar': 'مواقع اليونسكو',
    'en': 'UNESCO Sites',
    'ku': 'شوێنەکانی یونێسکۆ',
  },
  'characters': {
    'ar': 'شخصيات تاريخية',
    'en': 'Historical Figures',
    'ku': 'کەسایەتییە مێژووییەکان',
  },

  // شريط التنقل
  'navHome': {
    'ar': 'الرئيسية',
    'en': 'Home',
    'ku': 'سەرەکی',
  },
  'navMap': {
    'ar': 'الخريطة',
    'en': 'Map',
    'ku': 'نەخشە',
  },
  'navSites': {
    'ar': 'المواقع',
    'en': 'Sites',
    'ku': 'شوێنەکان',
  },
  'navChat': {
    'ar': 'نبو',
    'en': 'Nabu',
    'ku': 'نابو',
  },
  'navProfile': {
    'ar': 'ملفي',
    'en': 'Profile',
    'ku': 'پڕۆفایل',
  },
  'navSettings': {
    'ar': 'الإعدادات',
    'en': 'Settings',
    'ku': 'ڕێکخستنەکان',
  },

  // الإعدادات
  'settings': {
    'ar': 'الإعدادات',
    'en': 'Settings',
    'ku': 'ڕێکخستنەکان',
  },
  'language_': {
    'ar': 'اللغة',
    'en': 'Language',
    'ku': 'زمان',
  },
  'userType': {
    'ar': 'نوع المستخدم',
    'en': 'User Type',
    'ku': 'جۆری بەکارهێنەر',
  },
  'appearance': {
    'ar': 'المظهر',
    'en': 'Appearance',
    'ku': 'دیمەن',
  },
  'lightMode': {
    'ar': 'الوضع النهاري',
    'en': 'Light Mode',
    'ku': 'دۆخی ڕووناک',
  },
  'darkMode': {
    'ar': 'الوضع الليلي',
    'en': 'Dark Mode',
    'ku': 'دۆخی تاریک',
  },
  'enableLight': {
    'ar': 'تفعيل المظهر الفاتح',
    'en': 'Enable light theme',
    'ku': 'چالاککردنی ڕووناکی',
  },
  'enableDark': {
    'ar': 'تفعيل المظهر الداكن',
    'en': 'Enable dark theme',
    'ku': 'چالاککردنی تاریکی',
  },
  'contactReport': {
    'ar': 'التواصل والإبلاغ',
    'en': 'Contact & Report',
    'ku': 'پەیوەندی و ڕاپۆرتکردن',
  },
  'appComplaint': {
    'ar': 'شكوى عن التطبيق',
    'en': 'App Feedback',
    'ku': 'گلەیی لە ئەپ',
  },
  'complaintSub': {
    'ar': 'أبلغنا عن خطأ أو قدّم مقترحاً',
    'en': 'Report a bug or suggest an improvement',
    'ku': 'هەڵەیەک ڕاپۆرت بکە یان پێشنیاری بکە',
  },
  'sendBtn': {
    'ar': 'إرسال',
    'en': 'Send',
    'ku': 'ناردن',
  },
  'reportSite': {
    'ar': 'إبلاغ عن موقع بخطر',
    'en': 'Report an Endangered Site',
    'ku': 'ڕاپۆرتکردنی شوێنێکی مەترسیدار',
  },
  'reportSiteSub': {
    'ar': 'صوّر وأبلغ إذا كان الموقع في حالة انهيار أو تهديد',
    'en': 'Document and report sites at risk of damage or destruction',
    'ku': 'شوێنی مەترسیدار تۆمار بکە و ڕاپۆرت بکە',
  },
  'reportBtn': {
    'ar': 'إبلاغ',
    'en': 'Report',
    'ku': 'ڕاپۆرت',
  },
  'aboutApp': {
    'ar': 'عن التطبيق',
    'en': 'About',
    'ku': 'دەربارەی ئەپ',
  },
  'appVersion': {
    'ar': 'الإصدار 1.0.0 — استكشف تراث العراق',
    'en': 'Version 1.0.0 — Explore Iraq\'s Heritage',
    'ku': 'وەشان 1.0.0 — میراتی عێراق بدۆزەرەوە',
  },
  'sitesCount': {
    'ar': '32+ موقع من جميع الحضارات العراقية',
    'en': '32+ sites across all Iraqi civilizations',
    'ku': '32+ شوێن لە هەموو شارستانییەکانی عێراق',
  },
  'userTypePrompt': {
    'ar': 'لم تختر بعد — اضغط للاختيار',
    'en': 'Not selected — tap to choose',
    'ku': 'هەڵبژاردنی نییە — دەستبخە',
  },
  'iraqiUser': {
    'ar': 'عراقي مستكشف',
    'en': 'Iraqi Explorer',
    'ku': 'کاشێکی عێراقی',
  },
  'touristUser': {
    'ar': 'سائح أجنبي',
    'en': 'Foreign Tourist',
    'ku': 'گەشتیاری بیانی',
  },
  'notSelected': {
    'ar': 'لم تختر بعد',
    'en': 'Not selected',
    'ku': 'هەڵنەبژێردراوە',
  },
  'changeBtn': {
    'ar': 'تغيير',
    'en': 'Change',
    'ku': 'گۆڕانکاری',
  },

  // التصفية / الفلتر
  'all': {
    'ar': 'الكل',
    'en': 'All',
    'ku': 'هەموو',
  },
  'sumerian': {
    'ar': 'سومرية',
    'en': 'Sumerian',
    'ku': 'سومەری',
  },
  'babylonian': {
    'ar': 'بابلية',
    'en': 'Babylonian',
    'ku': 'بابلی',
  },
  'assyrian': {
    'ar': 'آشورية',
    'en': 'Assyrian',
    'ku': 'ئاشووری',
  },
  'islamic': {
    'ar': 'إسلامية',
    'en': 'Islamic',
    'ku': 'ئیسلامی',
  },
  'akkadian': {
    'ar': 'أكدية',
    'en': 'Akkadian',
    'ku': 'ئەکادی',
  },
  'sassanid': {
    'ar': 'ساسانية',
    'en': 'Sassanid',
    'ku': 'ساسانی',
  },
  'multiple': {
    'ar': 'متعددة',
    'en': 'Multiple',
    'ku': 'جۆراوجۆر',
  },

  // الدردشة
  'chatTitle': {
    'ar': 'نبو — المرشد الحضاري',
    'en': 'Nabu — Cultural Guide',
    'ku': 'نابو — ڕێنمایی شارستانی',
  },
  'chatHint': {
    'ar': 'اسألني عن الحضارات...',
    'en': 'Ask about civilizations...',
    'ku': 'دەربارەی شارستانییەکان بپرسە...',
  },
  'chatOnline': {
    'ar': 'متصل — يعرف تاريخ 7 حضارات',
    'en': 'Online — knows 7 civilizations',
    'ku': 'سەرهێڵ — 7 شارستانی دەزانێ',
  },

  // الإنجازات
  'achievements': {
    'ar': 'الإنجازات',
    'en': 'Achievements',
    'ku': 'دەستکەوتەکان',
  },
  'points': {
    'ar': 'نقطة',
    'en': 'pts',
    'ku': 'خاڵ',
  },
  'earned': {
    'ar': 'محققة',
    'en': 'Earned',
    'ku': 'بەدەستهاتوو',
  },
  'locked': {
    'ar': 'مقفلة',
    'en': 'Locked',
    'ku': 'قفڵکراو',
  },

  // المتحف
  'museum': {
    'ar': 'المتحف',
    'en': 'Museum',
    'ku': 'مۆزەخانە',
  },

  // ── خدمات السياحة ──────────────────────────────────────────
  'touristServices': {
    'ar': 'خدمات السياحة',
    'en': 'Tourist Services',
    'ku': 'خزمەتگوزارییەکانی گەشتیاری',
  },
  'touristServicesTitle': {
    'ar': 'خدمات السياحة في العراق',
    'en': 'Tourism Services in Iraq',
    'ku': 'خزمەتگوزارییەکانی گەشتیاری لە عێراق',
  },
  'touristServicesSub': {
    'ar': 'فنادق مختارة ومرشدون سياحيون معتمدون',
    'en': 'Curated hotels and certified tour guides',
    'ku': 'هۆتێلی هەلبژێردراو و ڕێنمایانی گەشتیاری پشکنراو',
  },
  'hotelsTitle': {
    'ar': 'أفضل الفنادق',
    'en': 'Best Hotels',
    'ku': 'باشترین هۆتێلەکان',
  },
  'hotelsSub': {
    'ar': 'فنادق مختارة على مستوى العراق',
    'en': 'Top-rated hotels across Iraq',
    'ku': 'باشترین هۆتێلەکان لەسەرانسەری عێراق',
  },
  'guidesTitle': {
    'ar': 'المرشدون السياحيون',
    'en': 'Tour Guides',
    'ku': 'ڕێنمایانی گەشتیاری',
  },
  'guidesSub': {
    'ar': 'مرشدون معتمدون لرحلات مغامرة لا تُنسى',
    'en': 'Certified guides for unforgettable adventures',
    'ku': 'ڕێنمایانی پشکنراو بۆ گەشتی بەیادماوە',
  },
  'callBtn': {
    'ar': 'اتصال',
    'en': 'Call',
    'ku': 'پەیوەندی',
  },
  'whatsappBtn': {
    'ar': 'واتساب',
    'en': 'WhatsApp',
    'ku': 'واتساپ',
  },
  'ratingLabel': {
    'ar': 'التقييم',
    'en': 'Rating',
    'ku': 'هەڵسەنگاندن',
  },
  'priceNight': {
    'ar': '\$ / ليلة',
    'en': '\$ / night',
    'ku': '\$ / شەو',
  },
  'govLabel': {
    'ar': 'المحافظة',
    'en': 'Governorate',
    'ku': 'پارێزگا',
  },
  'specialtyLabel': {
    'ar': 'التخصص',
    'en': 'Specialty',
    'ku': 'تایبەتمەندی',
  },
  'langLabel': {
    'ar': 'اللغات',
    'en': 'Languages',
    'ku': 'زمانەکان',
  },

  // مشتركة
  'noResults': {
    'ar': 'لا توجد نتائج',
    'en': 'No results found',
    'ku': 'هیچ ئەنجامێک نەدۆزرایەوە',
  },
  'loading': {
    'ar': 'جارٍ التحميل...',
    'en': 'Loading...',
    'ku': 'بارکردن...',
  },
  'errorOccurred': {
    'ar': 'حدث خطأ ما',
    'en': 'Something went wrong',
    'ku': 'هەڵەیەک ڕوویدا',
  },
  'close': {
    'ar': 'إغلاق',
    'en': 'Close',
    'ku': 'داخستن',
  },
  'save': {
    'ar': 'حفظ',
    'en': 'Save',
    'ku': 'پاشەکەوتکردن',
  },
  'cancel': {
    'ar': 'إلغاء',
    'en': 'Cancel',
    'ku': 'هەڵوەشاندنەوە',
  },
  'favorites': {
    'ar': 'المفضلة',
    'en': 'Favorites',
    'ku': 'دڵخوازەکان',
  },
  'share': {
    'ar': 'مشاركة',
    'en': 'Share',
    'ku': 'هاوبەشکردن',
  },
  'noFavorites': {
    'ar': 'لا توجد مواقع مفضلة بعد',
    'en': 'No favorite sites yet',
    'ku': 'هیچ شوێنی دڵخوازت نییە',
  },
  'noFavChars': {
    'ar': 'لا توجد شخصيات مفضلة بعد',
    'en': 'No favorite figures yet',
    'ku': 'هیچ کەسایەتییەکی دڵخوازت نییە',
  },
  'profile': {
    'ar': 'الملف الشخصي',
    'en': 'Profile',
    'ku': 'پڕۆفایل',
  },
  'editName': {
    'ar': 'تعديل الاسم',
    'en': 'Edit Name',
    'ku': 'ناو دەستکاری بکە',
  },
  'yourName': {
    'ar': 'اسمك',
    'en': 'Your Name',
    'ku': 'ناوت',
  },
  'changePhoto': {
    'ar': 'تغيير الصورة',
    'en': 'Change Photo',
    'ku': 'وێنە بگۆڕە',
  },

  // التفاصيل
  'location': {
    'ar': 'الموقع',
    'en': 'Location',
    'ku': 'شوێن',
  },
  'civilization': {
    'ar': 'الحضارة',
    'en': 'Civilization',
    'ku': 'شارستانی',
  },
  'period': {
    'ar': 'الحقبة',
    'en': 'Period',
    'ku': 'سەردەم',
  },
  'addFav': {
    'ar': 'إضافة للمفضلة',
    'en': 'Add to Favorites',
    'ku': 'زیادکردن بۆ دڵخوازەکان',
  },
  'removeFav': {
    'ar': 'إزالة من المفضلة',
    'en': 'Remove from Favorites',
    'ku': 'لابردن لە دڵخوازەکان',
  },

  // بطاقة نوع المستخدم
  'whoAreYou': {
    'ar': 'من أنت؟',
    'en': 'Who are you?',
    'ku': 'تۆ کێیت؟',
  },
  'iraqiDesc': {
    'ar': 'أنا عراقي أفتخر بحضارتي',
    'en': 'I\'m Iraqi, proud of my heritage',
    'ku': 'من عێراقیم، شانازی بە شارستانیەکەم دەکەم',
  },
  'touristDesc': {
    'ar': 'أنا سائح أريد استكشاف العراق',
    'en': 'I\'m a tourist exploring Iraq',
    'ku': 'من گەشتیارم، دەمەوێ عێراق بگەڕێم',
  },
  'confirm': {
    'ar': 'تأكيد',
    'en': 'Confirm',
    'ku': 'دڵنیاکردنەوە',
  },
};

// ═══════════════════════════════════════════════════════════════════════════
//  Extension — ترجمات إضافية
// ═══════════════════════════════════════════════════════════════════════════
extension AppStringsExtra on AppStrings {
  // AllSites
  String get archaeologicalSites  => get('archaeologicalSites');
  String get search               => get('search');

  // Eras
  String get historicalEras       => get('historicalEras');
  String get fromPrehistory       => get('fromPrehistory');

  // Characters
  String get era                  => get('era');
  String get achievementsLabel    => get('achievementsLabel');
  String get biography            => get('biography');
  String get notableAchievements  => get('notableAchievements');

  // Map
  String get mapTitle             => get('mapTitle');
  String get nearestSite          => get('nearestSite');
  String get locationPermission   => get('locationPermission');
  String get locationError        => get('locationError');
  String get unescoLabel          => get('unescoLabel');
  String get heritageLabel        => get('heritageLabel');
  String get approxMapNote        => get('approxMapNote');
  String get mapViewTab           => get('mapViewTab');
  String get realMapTab           => get('realMapTab');
  String get sacredShrine          => get('sacredShrine');
  String get listViewTab          => get('listViewTab');
  String get sortedByNearest      => get('sortedByNearest');
  String get enableLocationToSort => get('enableLocationToSort');

  // Museum
  String get virtualMuseum        => get('virtualMuseum');

  // Profile
  String get welcomeUser          => get('welcomeUser');
  String get registerName         => get('registerName');
  String get sitesAndChars        => get('sitesAndChars');
  String get editNameLabel        => get('editNameLabel');
  String get changePhotoLabel     => get('changePhotoLabel');
  String get favSites             => get('favSites');
  String get favChars_            => get('favChars_');
  String get noFavsYet            => get('noFavsYet');
  String get addFavsHint          => get('addFavsHint');
  String get typeYourName         => get('typeYourName');

  // Achievements screen
  String get achievementsTitle    => get('achievementsTitle');
  String get newAchievement       => get('newAchievement');
  String get bronze               => get('bronze');
  String get silver               => get('silver');
  String get gold                 => get('gold');
  String get platinum             => get('platinum');
  String get earnedTab            => get('earnedTab');
  String get lockedTab            => get('lockedTab');

  // Detail screen
  String get siteType             => get('siteType');
  String get history              => get('history');
  String get aboutSite            => get('aboutSite');
  String get exploreSite          => get('exploreSite');

  // Chat screen
  String get nabuTitle            => get('nabuTitle');
  String get nabuSubtitle         => get('nabuSubtitle');
  String get chatGreeting         => get('chatGreeting');
  String get chatInputHint        => get('chatInputHint');
  String get unescoTag            => get('unescoTag');
  String get nearestQ             => get('nearestQ');
  String get sumerQ               => get('sumerQ');
  String get babylonQ             => get('babylonQ');
  String get gilgameshQ           => get('gilgameshQ');
  String get unescoQ              => get('unescoQ');
  String get hammurabiQ           => get('hammurabiQ');
}

// بيانات الترجمات الإضافية — تُضاف لـ _data
final Map<String, Map<String, String>> _extraData = {
  'approxMapNote': {
    'ar': 'خريطة تقريبية توضيحية تعمل بدون إنترنت',
    'en': 'Approximate offline map',
    'ku': 'نەخشەیەکی نزیکەی ئۆفلاین',
  },
  'mapViewTab': {
    'ar': 'خريطة',
    'en': 'Map',
    'ku': 'نەخشە',
  },
  'realMapTab': {
    'ar': 'حقيقية',
    'en': 'Real',
    'ku': 'ڕاستەقینە',
  },
  'sacredShrine': {
    'ar': 'مرقد مقدس',
    'en': 'Holy Shrine',
    'ku': 'مزاری پیرۆز',
  },
  'listViewTab': {
    'ar': 'قائمة',
    'en': 'List',
    'ku': 'لیست',
  },
  'sortedByNearest': {
    'ar': 'مرتبة حسب الأقرب لموقعك',
    'en': 'Sorted by distance from you',
    'ku': 'ڕیزکراوە بەپێی نزیکی لە تۆوە',
  },
  'enableLocationToSort': {
    'ar': 'فعّل خدمة الموقع لترتيب المواقع حسب الأقرب',
    'en': 'Enable location to sort sites by distance',
    'ku': 'شوێن چالاک بکە بۆ ڕیزکردنی شوێنەکان',
  },
  'archaeologicalSites': {
    'ar': 'المواقع الأثرية',
    'en': 'Archaeological Sites',
    'ku': 'شوێنە کۆنەکان',
  },
  'search': {
    'ar': 'ابحث...',
    'en': 'Search...',
    'ku': 'گەڕان...',
  },
  'historicalEras': {
    'ar': 'العصور التاريخية',
    'en': 'Historical Eras',
    'ku': 'سەردەمە مێژووییەکان',
  },
  'fromPrehistory': {
    'ar': 'من 60,000 ق.م حتى اليوم',
    'en': 'From 60,000 BC to today',
    'ku': 'لە 60,000 پ.ز تا ئەمڕۆ',
  },
  'era': {
    'ar': 'العصر',
    'en': 'Era',
    'ku': 'سەردەم',
  },
  'achievementsLabel': {
    'ar': 'الإنجازات',
    'en': 'Achievements',
    'ku': 'دەستکەوتەکان',
  },
  'biography': {
    'ar': 'السيرة التاريخية',
    'en': 'Historical Biography',
    'ku': 'مێژووی ژیانی',
  },
  'notableAchievements': {
    'ar': 'أبرز الإنجازات',
    'en': 'Notable Achievements',
    'ku': 'دەستکەوتە گرنگەکان',
  },
  'mapTitle': {
    'ar': 'خريطة الآثار',
    'en': 'Heritage Map',
    'ku': 'نەخشەی کۆنینەکان',
  },
  'nearestSite': {
    'ar': 'أقرب موقع',
    'en': 'Nearest Site',
    'ku': 'نزیکترین شوێن',
  },
  'locationPermission': {
    'ar': 'يرجى السماح بالوصول للموقع',
    'en': 'Please allow location access',
    'ku': 'تکایە دەستپێگەیشتن بە شوێن ڕێپێبدە',
  },
  'locationError': {
    'ar': 'تعذّر الحصول على الموقع',
    'en': 'Could not get location',
    'ku': 'نەتوانرا شوێن بدۆزرێتەوە',
  },
  'unescoLabel': {
    'ar': 'يونسكو',
    'en': 'UNESCO',
    'ku': 'یونێسکۆ',
  },
  'heritageLabel': {
    'ar': 'تراثي',
    'en': 'Heritage',
    'ku': 'میراتی',
  },
  'virtualMuseum': {
    'ar': 'المتحف الافتراضي',
    'en': 'Virtual Museum',
    'ku': 'مۆزەخانەی خەیاڵی',
  },
  'welcomeUser': {
    'ar': 'مرحباً بك!',
    'en': 'Welcome!',
    'ku': 'بەخێربێیت!',
  },
  'registerName': {
    'ar': 'سجّل اسمك لتبدأ',
    'en': 'Enter your name to begin',
    'ku': 'ناوەکەت بنووسە بۆ دەستپێکردن',
  },
  'editNameLabel': {
    'ar': 'تعديل الاسم',
    'en': 'Edit Name',
    'ku': 'ناو دەستکاری بکە',
  },
  'changePhotoLabel': {
    'ar': 'تغيير الصورة',
    'en': 'Change Photo',
    'ku': 'وێنە بگۆڕە',
  },
  'favSites': {
    'ar': 'المواقع المفضلة',
    'en': 'Favorite Sites',
    'ku': 'شوێنە دڵخوازەکان',
  },
  'favChars_': {
    'ar': 'الشخصيات المفضلة',
    'en': 'Favorite Figures',
    'ku': 'کەسایەتییە دڵخوازەکان',
  },
  'noFavsYet': {
    'ar': 'لا توجد مفضلات بعد',
    'en': 'No favorites yet',
    'ku': 'هیچ دڵخوازێک نییە',
  },
  'addFavsHint': {
    'ar': 'أضف مواقع وشخصيات لمفضلتك',
    'en': 'Add sites and figures to your favorites',
    'ku': 'شوێن و کەسایەتی بزیادە بکە',
  },
  'typeYourName': {
    'ar': 'اكتب اسمك...',
    'en': 'Type your name...',
    'ku': 'ناوەکەت بنووسە...',
  },
  'achievementsTitle': {
    'ar': 'الإنجازات',
    'en': 'Achievements',
    'ku': 'دەستکەوتەکان',
  },
  'newAchievement': {
    'ar': 'إنجاز جديد!',
    'en': 'New Achievement!',
    'ku': 'دەستکەوتی نوێ!',
  },
  'bronze': {
    'ar': 'برونزي',
    'en': 'Bronze',
    'ku': 'بڕۆنز',
  },
  'silver': {
    'ar': 'فضي',
    'en': 'Silver',
    'ku': 'زیو',
  },
  'gold': {
    'ar': 'ذهبي',
    'en': 'Gold',
    'ku': 'زێڕ',
  },
  'platinum': {
    'ar': 'بلاتيني',
    'en': 'Platinum',
    'ku': 'پلاتین',
  },
  'earnedTab': {
    'ar': 'مفتوحة',
    'en': 'Earned',
    'ku': 'بەدەستهاتوو',
  },
  'lockedTab': {
    'ar': 'مقفلة',
    'en': 'Locked',
    'ku': 'قفڵکراو',
  },
  'siteType': {
    'ar': 'نوع الموقع',
    'en': 'Site Type',
    'ku': 'جۆری شوێن',
  },
  'history': {
    'ar': 'التاريخ',
    'en': 'History',
    'ku': 'مێژوو',
  },
  'aboutSite': {
    'ar': 'عن الموقع',
    'en': 'About the Site',
    'ku': 'دەربارەی شوێن',
  },
  'exploreSite': {
    'ar': 'استكشف الموقع',
    'en': 'Explore Site',
    'ku': 'شوێن بدۆزەرەوە',
  },
  'nabuTitle': {
    'ar': 'نبو',
    'en': 'Nabu',
    'ku': 'نابو',
  },
  'nabuSubtitle': {
    'ar': 'مرشدك التراثي · بلا إنترنت',
    'en': 'Your heritage guide · Offline',
    'ku': 'ڕێنمایی میراتیت · بێ ئینتەرنێت',
  },
  'chatGreeting': {
    'ar': 'اسألني عن أي موقع أثري، حضارة، أو شخصية تاريخية.\nأو قل "وين أقرب موقع مني" وسأخبرك!',
    'en': 'Ask me about any archaeological site, civilization, or historical figure.\nOr say "nearest site to me" and I\'ll tell you!',
    'ku': 'لەبارەی هەر شوێنێکی کۆنی، شارستانییەک، یان کەسایەتییەکی مێژووی بپرسە.\nیان بڵێ "نزیکترین شوێن لەم" تا ڕاهێنانت بدەم!',
  },
  'chatInputHint': {
    'ar': 'اسألني عن التراث العراقي...',
    'en': 'Ask about Iraqi heritage...',
    'ku': 'دەربارەی میراتی عێراق بپرسە...',
  },
  'unescoTag': {
    'ar': 'يونسكو',
    'en': 'UNESCO',
    'ku': 'یونێسکۆ',
  },
  'nearestQ': {
    'ar': 'وين أقرب موقع مني؟',
    'en': 'What\'s the nearest site to me?',
    'ku': 'نزیکترین شوێن لەم کوێیە؟',
  },
  'sumerQ': {
    'ar': 'حضارة سومر',
    'en': 'Sumerian civilization',
    'ku': 'شارستانی سومەر',
  },
  'babylonQ': {
    'ar': 'عمر مدينة بابل',
    'en': 'Age of Babylon',
    'ku': 'تەمەنی شاری بابل',
  },
  'gilgameshQ': {
    'ar': 'من هو كلكامش؟',
    'en': 'Who is Gilgamesh?',
    'ku': 'گیلگامێش کێیە؟',
  },
  'unescoQ': {
    'ar': 'مواقع اليونسكو',
    'en': 'UNESCO sites in Iraq',
    'ku': 'شوێنەکانی یونێسکۆ لە عێراق',
  },
  'hammurabiQ': {
    'ar': 'قانون حمورابي',
    'en': 'Hammurabi\'s Code',
    'ku': 'یاسای حەمووڕابی',
  },
  'sitesAndChars': {
    'ar': 'مواقع وشخصيات',
    'en': 'sites & figures',
    'ku': 'شوێن و کەسایەتی',
  },
  'complaintTypes': {
    'ar': 'نوع الشكوى',
    'en': 'Complaint Type',
    'ku': 'جۆری گلەیی',
  },
  'techError': {
    'ar': 'خطأ تقني',
    'en': 'Technical Error',
    'ku': 'هەڵەی تەکنیکی',
  },
  'suggestion': {
    'ar': 'مقترح تطوير',
    'en': 'Improvement Suggestion',
    'ku': 'پێشنیاری گەشەپێدان',
  },
  'inaccurateContent': {
    'ar': 'محتوى غير دقيق',
    'en': 'Inaccurate Content',
    'ku': 'ناوەڕۆکی نادروست',
  },
  'other': {
    'ar': 'أخرى',
    'en': 'Other',
    'ku': 'تری',
  },
  'writeComplaintFirst': {
    'ar': 'اكتب شكواك أولاً',
    'en': 'Write your complaint first',
    'ku': 'گلەییەکەت بنووسە یەکەم',
  },
  'complaintAboutApp': {
    'ar': 'شكوى عن التطبيق',
    'en': 'App Feedback',
    'ku': 'گلەیی لە ئەپ',
  },
  'complaintHelp': {
    'ar': 'شكواك تساعدنا نطور التطبيق — كل رأي مهم',
    'en': 'Your feedback helps us improve — every opinion counts',
    'ku': 'گلەییەکەت یارمەتیمان دەدات بەهتر بکەین — هەر بۆچوونێک گرنگە',
  },
  'explainProblem': {
    'ar': 'اشرح المشكلة أو مقترحك بالتفصيل...',
    'en': 'Explain the problem or suggestion in detail...',
    'ku': 'کێشەکە یان پێشنیارەکەت بە وردی ڕوون بکەرەوە...',
  },
  'sending': {
    'ar': 'جارٍ الإرسال...',
    'en': 'Sending...',
    'ku': 'ناردن...',
  },
  'sendComplaint': {
    'ar': 'إرسال الشكوى',
    'en': 'Send Feedback',
    'ku': 'ناردنی گلەیی',
  },
  'emailWillOpen': {
    'ar': 'سيتم فتح تطبيق البريد الإلكتروني لإرسال شكواك',
    'en': 'Your email app will open to send the feedback',
    'ku': 'ئیمەیڵەکەت دەکرێتەوە بۆ ناردنی گلەیی',
  },
  'thankYou': {
    'ar': 'شكراً على شكواك!',
    'en': 'Thank you for your feedback!',
    'ku': 'سوپاس بۆ گلەییەکەت!',
  },
  'willReview': {
    'ar': 'راح نراجعها ونعمل على تحسين التطبيق',
    'en': 'We will review it and work on improving the app',
    'ku': 'پێداچوونەوەمان بۆ دەکرێت و ئەپەکە باشتر دەکەین',
  },
  'backToSettings': {
    'ar': 'رجوع للإعدادات',
    'en': 'Back to Settings',
    'ku': 'گەڕانەوە بۆ ڕێکخستنەکان',
  },
  'sendError': {
    'ar': 'تعذّر الإرسال — جرّب لاحقاً',
    'en': 'Failed to send — try again later',
    'ku': 'ناردن سەرکەوتوو نەبوو — دواتر هەوڵ بدەرەوە',
  },
  'reportDanger': {
    'ar': 'إبلاغ عن موقع بخطر',
    'en': 'Report Endangered Site',
    'ku': 'ڕاپۆرتکردنی شوێنی مەترسیدار',
  },
  'siteName': {
    'ar': 'اسم الموقع',
    'en': 'Site Name',
    'ku': 'ناوی شوێن',
  },
  'urgencyLevel': {
    'ar': 'مستوى الخطورة',
    'en': 'Urgency Level',
    'ku': 'ئاستی مەترسی',
  },
  'siteLocation': {
    'ar': 'الموقع الجغرافي',
    'en': 'Location',
    'ku': 'شوێنی جوگرافی',
  },
  'describeRisk': {
    'ar': 'اشرح الخطر أو التهديد بالتفصيل...',
    'en': 'Describe the danger or threat in detail...',
    'ku': 'مەترسی یان گوشارەکە بە وردی شی بکەرەوە...',
  },
  'addPhoto': {
    'ar': 'أضف صورة',
    'en': 'Add Photo',
    'ku': 'وێنە زیاد بکە',
  },
  'sendReport': {
    'ar': 'إرسال البلاغ',
    'en': 'Send Report',
    'ku': 'ناردنی ڕاپۆرت',
  },
  'fillRequired': {
    'ar': 'أدخل اسم الموقع أولاً',
    'en': 'Enter site name first',
    'ku': 'ناوی شوێن داخل بکە یەکەم',
  },
  'urgLow': {
    'ar': 'خطر منخفض',
    'en': 'Low Risk',
    'ku': 'مەترسی کەم',
  },
  'urgMedium': {
    'ar': 'خطر متوسط',
    'en': 'Medium Risk',
    'ku': 'مەترسی مامناوەند',
  },
  'urgHigh': {
    'ar': 'خطر عالٍ',
    'en': 'High Risk',
    'ku': 'مەترسی بەرز',
  },
  'urgUrgent': {
    'ar': 'انهيار وشيك',
    'en': 'Imminent Collapse',
    'ku': 'کەوتنی نزیک',
  },
  'reportHelp': {
    'ar': 'إبلاغاتك تساعد في حماية تراثنا — سيتم التحقق من كل بلاغ',
    'en': 'Your reports help protect our heritage — every report is reviewed',
    'ku': 'ڕاپۆرتەکانت یارمەتی دەدەن میراتمان بپارێزرێت — هەر ڕاپۆرتێک پشکنین دەکرێت',
  },
  'siteNameHint': {
    'ar': 'مثال: زقورة أور، مدينة بابل...',
    'en': 'e.g. Ziggurat of Ur, City of Babylon...',
    'ku': 'نموونە: زیقوراتی ئور، شاری بابل...',
  },

};

// Extra data accessible via get() — merged in the main class
