import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/app_state.dart';
import 'models/achievements.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/other_screens.dart';
import 'screens/achievements_screen.dart';
import 'screens/share_card_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/complaint_screen.dart';
import 'screens/tourist_services_screen.dart';
import 'screens/checkin_screen.dart';
import 'screens/my_visits_screen.dart';
import 'screens/community_sites_screen.dart';
import 'screens/monster_hunt_screen.dart';
import 'screens/proximity_notification_service.dart';
import 'widgets/common_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const IraqiHeritageApp());
}

class IraqiHeritageApp extends StatelessWidget {
  const IraqiHeritageApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppState(),
    child: Consumer<AppState>(
      builder: (_, state, __) => MaterialApp(
      title: 'Iraqi Heritage',
      debugShowCheckedModeBanner: false,
      theme: IHTheme.theme,
      darkTheme: IHTheme.darkTheme,
      themeMode: state.themeMode,
      locale: state.isEnglish
        ? const Locale('en')
        : const Locale('ar'), // Kurdish uses Arabic text direction
      supportedLocales: const [
        Locale('ar'), Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/home',
      builder: (ctx, child) => _AchievementOverlay(child: child!),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/settings':    page = const SettingsScreen(); break;
          case '/complaint':   page = const ComplaintScreen(); break;
          case '/tourist-services': page = const TouristServicesScreen(); break;
          case '/report-site': page = const ReportSiteScreen(); break;
          case '/home':        page = const HomeScreen(); break;
          case '/detail':      page = const DetailScreen(); break;
          case '/all-sites':   page = const AllSitesScreen(); break;
          case '/eras':        page = const ErasScreen(); break;
          case '/characters':  page = const CharactersScreen(); break;
          case '/char-detail': page = const CharDetailScreen(); break;
          case '/map':         page = MapScreen(); break;
          case '/museum':      page = MuseumScreen(); break;
          case '/profile':      page = ProfileScreen(); break;
          case '/achievements': page = const AchievementsScreen(); break;
          case '/chat':         page = const ChatScreen(); break;
          case '/checkin':      page = const CheckInScreen(); break;
          case '/my-visits':    page = const MyVisitsScreen(); break;
          case '/community-sites': page = const CommunitySitesScreen(); break;
          case '/monster-hunt': page = const MonsterHuntScreen(); break;
          case '/proximity-settings': page = const ProximitySettingsScreen(); break;
          case '/share-card':
            final site = settings.arguments;
            page = site != null
              ? ShareCardScreen(site: site as dynamic)
              : const HomeScreen();
            break;
          default:             page = const HomeScreen();
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            final curved = CurvedAnimation(
              parent: anim, curve: Curves.easeOutCubic);
            final scale = Tween<double>(begin: .96, end: 1.0).animate(curved);
            final slide = Tween<Offset>(
              begin: const Offset(0, .03), end: Offset.zero,
            ).animate(curved);
            final outCurved = CurvedAnimation(
              parent: secAnim, curve: Curves.easeInCubic);
            final outScale = Tween<double>(begin: 1.0, end: .97).animate(outCurved);
            final outFade  = Tween<double>(begin: 1.0, end: 0.0).animate(outCurved);

            return FadeTransition(
              opacity: outFade,
              child: ScaleTransition(
                scale: outScale,
                child: FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
    ),
  );
}

// ── ACHIEVEMENT OVERLAY ───────────────────────────────────────────────────────
class _AchievementOverlay extends StatefulWidget {
  final Widget child;
  const _AchievementOverlay({required this.child});
  @override State<_AchievementOverlay> createState() =>
    _AchievementOverlayState();
}

class _AchievementOverlayState extends State<_AchievementOverlay> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final latest = state.latestUnlocked;

    return Stack(children: [
      widget.child,
      if (latest != null)
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 0, right: 0,
          child: AchievementToast(
            achievement: latest,
            onDismiss: () => context.read<AppState>().clearLatestUnlocked(),
          ),
        ),
    ]);
  }
}
