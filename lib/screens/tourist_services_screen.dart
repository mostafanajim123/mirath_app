import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../data/translations.dart';
import '../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class HotelInfo {
  final String name, nameEn, governorate, governorateEn;
  final String address, addressEn;
  final double rating;
  final int pricePerNight; // USD
  final String phone, imageEmoji;
  final String? imagePath;
  final List<String> amenities, amenitiesEn;

  const HotelInfo({
    required this.name, required this.nameEn,
    required this.governorate, required this.governorateEn,
    required this.address, required this.addressEn,
    required this.rating, required this.pricePerNight,
    required this.phone, required this.imageEmoji,
    this.imagePath,
    required this.amenities, required this.amenitiesEn,
  });
}

class GuideInfo {
  final String name, nameEn, specialty, specialtyEn;
  final String governorate, governorateEn;
  final List<String> languages;
  final String phone, whatsapp, bio, bioEn, emoji;
  final String? imageUrl;
  final double rating;
  final int experienceYears;

  const GuideInfo({
    required this.name, required this.nameEn,
    required this.specialty, required this.specialtyEn,
    required this.governorate, required this.governorateEn,
    required this.languages,
    required this.phone, required this.whatsapp,
    required this.bio, required this.bioEn,
    required this.emoji, required this.rating,
    required this.experienceYears,
    this.imageUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  STATIC DATA
// ─────────────────────────────────────────────────────────────────────────────

const List<HotelInfo> _hotels = [
  HotelInfo(
    name: 'فندق بابل روتانا',
    nameEn: 'Babylon Rotana Baghdad',
    governorate: 'بغداد',
    governorateEn: 'Baghdad',
    address: 'شارع أبو نواس، بغداد',
    addressEn: 'Abu Nuwas St, Baghdad',
    rating: 4.6,
    pricePerNight: 180,
    phone: '+9647901234567',
    imageEmoji: '🏨',
    imagePath: 'assets/images/hotels/babylon_rotana.jpg',
    amenities: ['واي فاي مجاني', 'مسبح', 'مطعم فاخر', 'مركز لياقة', 'كونسيرج'],
    amenitiesEn: ['Free WiFi', 'Pool', 'Fine Dining', 'Fitness Center', 'Concierge'],
  ),
  HotelInfo(
    name: 'فندق الرشيد',
    nameEn: 'Al Rashid Hotel',
    governorate: 'بغداد',
    governorateEn: 'Baghdad',
    address: 'المنطقة الخضراء، بغداد',
    addressEn: 'Green Zone, Baghdad',
    rating: 4.4,
    pricePerNight: 150,
    phone: '+9647811234567',
    imageEmoji: '🏩',
    imagePath: 'assets/images/hotels/al_rashid.jpg',
    amenities: ['واي فاي مجاني', 'موقف سيارات', 'مطعم', 'قاعة مؤتمرات'],
    amenitiesEn: ['Free WiFi', 'Parking', 'Restaurant', 'Conference Hall'],
  ),
  HotelInfo(
    name: 'فندق كريم',
    nameEn: 'Kareem Palace Hotel',
    governorate: 'أربيل',
    governorateEn: 'Erbil',
    address: 'شارع 100م، أربيل',
    addressEn: '100m Street, Erbil',
    rating: 4.7,
    pricePerNight: 120,
    phone: '+9647501234567',
    imageEmoji: '🏰',
    imagePath: 'assets/images/hotels/kareem_palace.jpg',
    amenities: ['واي فاي مجاني', 'مطعم', 'سبا', 'موقف مجاني'],
    amenitiesEn: ['Free WiFi', 'Restaurant', 'Spa', 'Free Parking'],
  ),
  HotelInfo(
    name: 'فندق النجف الدولي',
    nameEn: 'Najaf International Hotel',
    governorate: 'النجف',
    governorateEn: 'Najaf',
    address: 'قرب مرقد الإمام علي، النجف',
    addressEn: 'Near Imam Ali Shrine, Najaf',
    rating: 4.3,
    pricePerNight: 90,
    phone: '+9647601234567',
    imageEmoji: '🕌',
    imagePath: 'assets/images/hotels/najaf_international.jpg',
    amenities: ['واي فاي مجاني', 'مطبخ حلال', 'موقف', 'غرف عائلية'],
    amenitiesEn: ['Free WiFi', 'Halal Kitchen', 'Parking', 'Family Rooms'],
  ),
  HotelInfo(
    name: 'فندق البصرة الكبير',
    nameEn: 'Grand Basra Hotel',
    governorate: 'البصرة',
    governorateEn: 'Basra',
    address: 'كورنيش البصرة',
    addressEn: 'Basra Corniche',
    rating: 4.2,
    pricePerNight: 100,
    phone: '+9647701234567',
    imageEmoji: '🌊',
    imagePath: 'assets/images/hotels/grand_basra.jpg',
    amenities: ['واي فاي مجاني', 'إطلالة نهرية', 'مطعم', 'صالة أعمال'],
    amenitiesEn: ['Free WiFi', 'River View', 'Restaurant', 'Business Lounge'],
  ),
];

const List<GuideInfo> _guides = [
  GuideInfo(
    name: 'أحمد الراشدي',
    nameEn: 'Ahmed Al-Rashidi',
    specialty: 'آثار بابل وسومر',
    specialtyEn: 'Babylon & Sumerian Archaeology',
    governorate: 'بابل',
    governorateEn: 'Babylon',
    languages: ['العربية', 'English', 'Français'],
    phone: '+9647901111111',
    whatsapp: '+9647901111111',
    bio: 'مرشد سياحي معتمد بخبرة 12 سنة في المواقع الأثرية البابلية والسومرية. متخصص في رحلات الاستكشاف الأثري ومغامرات الصحراء.',
    bioEn: '12 years certified guide specializing in Babylonian & Sumerian sites. Expert in archaeological exploration and desert adventure tours.',
    emoji: '🏺',

    rating: 4.9,
    experienceYears: 12,
  ),
  GuideInfo(
    name: 'سارة الجبوري',
    nameEn: 'Sara Al-Jabouri',
    specialty: 'بغداد التاريخية والثقافة العباسية',
    specialtyEn: 'Historic Baghdad & Abbasid Culture',
    governorate: 'بغداد',
    governorateEn: 'Baghdad',
    languages: ['العربية', 'English', 'Deutsch'],
    phone: '+9647902222222',
    whatsapp: '+9647902222222',
    bio: 'مرشدة بخبرة 8 سنوات في بغداد التاريخية. متخصصة في الحارات العباسية والمتاحف والمطبخ العراقي الأصيل.',
    bioEn: '8 years guiding in historic Baghdad. Specialist in Abbasid quarters, museums, and authentic Iraqi cuisine experiences.',
    emoji: '🌆',

    rating: 4.8,
    experienceYears: 8,
  ),
  GuideInfo(
    name: 'كريم المعموري',
    nameEn: 'Kareem Al-Maamouri',
    specialty: 'الموصل ونينوى والشمال',
    specialtyEn: 'Mosul, Nineveh & Northern Iraq',
    governorate: 'نينوى',
    governorateEn: 'Nineveh',
    languages: ['العربية', 'English', 'Kurdî'],
    phone: '+9647903333333',
    whatsapp: '+9647903333333',
    bio: 'متخصص في آثار نينوى والموصل وإقليم كردستان. يقدم رحلات مغامرة إلى الجبال والمواقع الآشورية النادرة.',
    bioEn: 'Specialist in Nineveh, Mosul, and Kurdistan. Offers adventure trips to mountains and rare Assyrian sites.',
    emoji: '⛰️',

    rating: 4.7,
    experienceYears: 10,
  ),
  GuideInfo(
    name: 'علي الزيدي',
    nameEn: 'Ali Al-Zaidi',
    specialty: 'النجف وكربلاء والسياحة الدينية',
    specialtyEn: 'Najaf, Karbala & Religious Tourism',
    governorate: 'النجف',
    governorateEn: 'Najaf',
    languages: ['العربية', 'English', 'فارسی', 'Urdu'],
    phone: '+9647904444444',
    whatsapp: '+9647904444444',
    bio: 'متخصص بالسياحة الدينية والتراثية في النجف وكربلاء. يتحدث 4 لغات ومعتمد دولياً.',
    bioEn: 'Expert in religious and heritage tourism in Najaf and Karbala. Speaks 4 languages, internationally certified.',
    emoji: '🕌',

    rating: 4.9,
    experienceYears: 15,
  ),
  GuideInfo(
    name: 'ليلى البصري',
    nameEn: 'Layla Al-Basri',
    specialty: 'الجنوب العراقي والأهوار',
    specialtyEn: 'Southern Iraq & Mesopotamian Marshes',
    governorate: 'البصرة',
    governorateEn: 'Basra',
    languages: ['العربية', 'English'],
    phone: '+9647905555555',
    whatsapp: '+9647905555555',
    bio: 'رائدة في رحلات أهوار ميزوبوتاميا المدرجة على قوائم اليونسكو. تقدم تجارب فريدة مع الصيادين في الأهوار.',
    bioEn: 'Pioneer in UNESCO-listed Mesopotamian Marshes tours. Offers unique experiences with local fishermen.',
    emoji: '🌿',

    rating: 4.8,
    experienceYears: 7,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class TouristServicesScreen extends StatefulWidget {
  const TouristServicesScreen({super.key});
  @override State<TouristServicesScreen> createState() => _TouristServicesScreenState();
}

class _TouristServicesScreenState extends State<TouristServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = AppStrings.lang(state.language);
    final isEn = state.isEnglish;
    final dark = IHTheme.isDark(context);

    return Scaffold(
      backgroundColor: IHTheme.bgPrimary,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: IHTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(children: [
                // gradient background
                Container(
                  decoration: const BoxDecoration(gradient: IHTheme.heroGradient),
                ),
                // pattern overlay
                Positioned.fill(child: Opacity(opacity: .06,
                  child: Image.asset('assets/images/eras/pattern.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()))),
                // content
                Positioned(bottom: 60, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: isEn ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(20)),
                        child: Text('🌍  Welcome to Iraq',
                          style: AppFonts.nunito(fontSize: 11,
                            color: Colors.white, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 8),
                      Text(isEn ? s.touristServicesTitle : 'خدمات السياحة في العراق',
                        style: AppFonts.lora(fontSize: 22,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(isEn ? s.touristServicesSub : 'فنادق مختارة ومرشدون سياحيون معتمدون',
                        style: AppFonts.nunito(fontSize: 12,
                          color: Colors.white.withValues(alpha: .85))),
                    ],
                  ),
                ),
              ]),
            ),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: AppFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                Tab(icon: const Icon(Icons.hotel_rounded, size: 18),
                  text: isEn ? s.hotelsTitle : 'أفضل الفنادق'),
                Tab(icon: const Icon(Icons.tour_rounded, size: 18),
                  text: isEn ? s.guidesTitle : 'المرشدون السياحيون'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _HotelsTab(isEn: isEn, s: s),
            _GuidesTab(isEn: isEn, s: s),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HOTELS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _HotelsTab extends StatelessWidget {
  final bool isEn;
  final AppStrings s;
  const _HotelsTab({required this.isEn, required this.s});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // header note
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: IHTheme.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IHTheme.primary.withValues(alpha: .2))),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: IHTheme.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              isEn
                ? 'All hotels are carefully selected for quality and service. Prices are approximate.'
                : 'جميع الفنادق مختارة بعناية للجودة والخدمة. الأسعار تقريبية.',
              style: AppFonts.nunito(fontSize: 12, color: IHTheme.primary, height: 1.4))),
          ]),
        ),
        ..._hotels.map((h) => _HotelCard(hotel: h, isEn: isEn, s: s)),
      ],
    );
  }
}

class _HotelCard extends StatelessWidget {
  final HotelInfo hotel;
  final bool isEn;
  final AppStrings s;
  const _HotelCard({required this.hotel, required this.isEn, required this.s});

  void _call(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isEn ? 'Calling ${hotel.nameEn}...' : 'جارٍ الاتصال بـ ${hotel.name}...'),
      backgroundColor: IHTheme.primary, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: IHTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: IHTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // top section — emoji banner
        Container(
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [IHTheme.primary.withValues(alpha: .8),
                IHTheme.primaryLight.withValues(alpha: .6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            if (hotel.imagePath != null)
              Positioned.fill(
                child: Image.asset(
                  hotel.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(child: Text(hotel.imageEmoji,
                    style: const TextStyle(fontSize: 52))),
                ),
              )
            else
              Center(child: Text(hotel.imageEmoji,
                style: const TextStyle(fontSize: 52))),
            // rating badge
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: IHTheme.cardShadow),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                  const SizedBox(width: 3),
                  Text(hotel.rating.toStringAsFixed(1),
                    style: AppFonts.nunito(fontSize: 12,
                      fontWeight: FontWeight.w700, color: IHTheme.textPrimary)),
                ]),
              ),
            ),
            // gov badge
            Positioned(top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                  const SizedBox(width: 3),
                  Text(isEn ? hotel.governorateEn : hotel.governorate,
                    style: AppFonts.nunito(fontSize: 11,
                      color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
        // content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(isEn ? hotel.nameEn : hotel.name,
                style: AppFonts.lora(fontSize: 16,
                  fontWeight: FontWeight.w700, color: IHTheme.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: IHTheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('${hotel.pricePerNight} ${isEn ? s.priceNight : "\$ / ليلة"}',
                  style: AppFonts.nunito(fontSize: 12,
                    fontWeight: FontWeight.w700, color: IHTheme.primary))),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.place_rounded, size: 13, color: IHTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(isEn ? hotel.addressEn : hotel.address,
                style: AppFonts.nunito(fontSize: 12, color: IHTheme.textMuted))),
            ]),
            const SizedBox(height: 12),
            // amenities
            Wrap(spacing: 6, runSpacing: 6,
              children: (isEn ? hotel.amenitiesEn : hotel.amenities).map((a) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: IHTheme.bgPrimary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: IHTheme.border)),
                  child: Text(a, style: AppFonts.nunito(
                    fontSize: 11, color: IHTheme.textSecondary)),
                ),
              ).toList(),
            ),
            const SizedBox(height: 14),
            // call button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _call(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: IHTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.phone_rounded, size: 18),
                label: Text(isEn ? s.callBtn : 'اتصال',
                  style: AppFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  GUIDES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _GuidesTab extends StatelessWidget {
  final bool isEn;
  final AppStrings s;
  const _GuidesTab({required this.isEn, required this.s});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E6B3C).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF0E6B3C).withValues(alpha: .2))),
          child: Row(children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF0E6B3C), size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              isEn
                ? 'All guides are certified and experienced. Contact them directly to plan your trip.'
                : 'جميع المرشدين معتمدون وذوو خبرة. تواصل معهم مباشرة لتخطيط رحلتك.',
              style: AppFonts.nunito(fontSize: 12,
                color: const Color(0xFF0E6B3C), height: 1.4))),
          ]),
        ),
        ..._guides.map((g) => _GuideCard(guide: g, isEn: isEn, s: s)),
      ],
    );
  }
}

class _GuideCard extends StatelessWidget {
  final GuideInfo guide;
  final bool isEn;
  final AppStrings s;
  const _GuideCard({required this.guide, required this.isEn, required this.s});

  void _contact(BuildContext context, bool isWhatsApp) {
    HapticFeedback.lightImpact();
    final name = isEn ? guide.nameEn : guide.name;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isWhatsApp
        ? (isEn ? 'Opening WhatsApp for $name...' : 'فتح واتساب لـ $name...')
        : (isEn ? 'Calling $name...' : 'جارٍ الاتصال بـ $name...')),
      backgroundColor: isWhatsApp ? const Color(0xFF25D366) : IHTheme.primary,
      duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: IHTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: IHTheme.cardShadow),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // top row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // avatar
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: IHTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: IHTheme.primaryShadow),
              child: ClipOval(
                child: Center(child: Icon(Icons.person_rounded,
                    size: 38, color: Colors.white.withValues(alpha: 0.9))),
              )),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(isEn ? guide.nameEn : guide.name,
                  style: AppFonts.lora(fontSize: 15,
                    fontWeight: FontWeight.w700, color: IHTheme.textPrimary))),
                // rating
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded,
                    color: Color(0xFFFFB800), size: 14),
                  const SizedBox(width: 2),
                  Text(guide.rating.toStringAsFixed(1),
                    style: AppFonts.nunito(fontSize: 12,
                      fontWeight: FontWeight.w700, color: IHTheme.textPrimary)),
                ]),
              ]),
              const SizedBox(height: 4),
              // specialty
              Text(isEn ? guide.specialtyEn : guide.specialty,
                style: AppFonts.nunito(fontSize: 12,
                  color: IHTheme.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_rounded,
                  size: 12, color: IHTheme.textMuted),
                const SizedBox(width: 3),
                Text(isEn ? guide.governorateEn : guide.governorate,
                  style: AppFonts.nunito(fontSize: 11, color: IHTheme.textMuted)),
                const SizedBox(width: 10),
                const Icon(Icons.work_history_rounded,
                  size: 12, color: IHTheme.textMuted),
                const SizedBox(width: 3),
                Text(isEn
                  ? '${guide.experienceYears} yrs exp.'
                  : '${guide.experienceYears} سنوات خبرة',
                  style: AppFonts.nunito(fontSize: 11, color: IHTheme.textMuted)),
              ]),
            ])),
          ]),
          const SizedBox(height: 12),
          // bio
          Text(isEn ? guide.bioEn : guide.bio,
            style: AppFonts.nunito(fontSize: 12,
              color: IHTheme.textSecondary, height: 1.5)),
          const SizedBox(height: 12),
          // languages
          Row(children: [
            const Icon(Icons.translate_rounded, size: 14, color: IHTheme.primary),
            const SizedBox(width: 6),
            Expanded(child: Wrap(spacing: 6, children: guide.languages.map((lang) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: IHTheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(lang, style: AppFonts.nunito(
                  fontSize: 11, color: IHTheme.primary,
                  fontWeight: FontWeight.w600)),
              ),
            ).toList())),
          ]),
          const SizedBox(height: 14),
          // action buttons
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _contact(context, false),
              style: OutlinedButton.styleFrom(
                foregroundColor: IHTheme.primary,
                side: const BorderSide(color: IHTheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.phone_rounded, size: 16),
              label: Text(isEn ? s.callBtn : 'اتصال',
                style: AppFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _contact(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.chat_rounded, size: 16),
              label: Text(isEn ? s.whatsappBtn : 'واتساب',
                style: AppFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
            )),
          ]),
        ]),
      ),
    );
  }
}
