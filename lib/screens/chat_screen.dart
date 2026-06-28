import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../data/iraq_data.dart';
import '../data/knowledge_base.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../data/translations.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';

// ── CHAT MESSAGE ──────────────────────────────────────────────────────────────
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final List<Site>? suggestedSites;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.suggestedSites,
  }) : time = DateTime.now();
}

// ── LOCAL AI ENGINE ───────────────────────────────────────────────────────────
class _LocalAI {

  // Score a knowledge entry against the user question
  static double _score(KnowledgeEntry entry, String question) {
    final q = question.toLowerCase();
    double score = 0;
    for (final kw in entry.keywords) {
      if (kw == '__default__') continue;
      if (q.contains(kw.toLowerCase())) {
        // Longer keyword = more specific match = higher score
        score += kw.length * 1.5;
      }
    }
    return score;
  }

  static ({String answer, List<Site> sites}) answer(String question) {
    // --- Nearest site detection
    final nearbyKws = ['أقرب','قريب','قربي','جنبي','موقعي','مكاني','nearest','nearby'];
    if (nearbyKws.any((k) => question.contains(k))) {
      return (
        answer: '__NEARBY__',
        sites: [],
      );
    }

    // --- Score all entries
    KnowledgeEntry? best;
    double bestScore = 0;

    for (final entry in knowledgeBase) {
      if (entry.keywords.contains('__default__')) continue;
      final s = _score(entry, question);
      if (s > bestScore) { bestScore = s; best = entry; }
    }

    // --- Try site name match if no keyword hit
    if (bestScore == 0) {
      for (final site in iraqSites) {
        if (question.contains(site.name) || question.contains(site.nameEn)) {
          return (
            answer: _buildSiteAnswer(site),
            sites: [site],
          );
        }
      }
      // Try character match
      for (final char in iraqCharacters) {
        if (question.contains(char.name) || question.contains(char.nameEn)) {
          return (
            answer: _buildCharAnswer(char),
            sites: [],
          );
        }
      }
    }

    // --- Use best match or default
    final entry = best ??
      knowledgeBase.firstWhere((e) => e.keywords.contains('__default__'));

    final sites = entry.relatedSiteIds != null
      ? iraqSites.where((s) =>
          entry.relatedSiteIds!.contains(s.id)).toList()
      : <Site>[];

    return (answer: entry.answer, sites: sites);
  }

  static String _buildSiteAnswer(Site site) {
    final buf = StringBuffer();
    buf.writeln('🏛️ ${site.name}');
    if (site.nameEn.isNotEmpty) buf.writeln('(${site.nameEn})');
    buf.writeln();
    buf.writeln('${site.city}, ${site.governorate}');
    buf.writeln('${AppStrings.lang('ar').civilization}: ${site.civilization}');
    buf.writeln('${AppStrings.lang("ar").history}: ${site.builtYear}');
    if (site.isUnesco) buf.writeln('UNESCO');
    buf.writeln();
    // First 300 chars of description
    final desc = site.description;
    buf.write(desc.length > 300 ? '${desc.substring(0, 300)}...' : desc);
    return buf.toString();
  }

  static String _buildCharAnswer(HistoricalCharacter char) {
    final buf = StringBuffer();
    buf.writeln('👑 ${char.name}');
    buf.writeln('(${char.nameEn})');
    buf.writeln();
    buf.writeln('${AppStrings.lang("ar").era}: ${char.era}');
    buf.writeln('${AppStrings.lang('ar').civilization}: ${char.civilization}');
    buf.writeln('${char.role}');
    buf.writeln();
    final desc = char.description;
    buf.write(desc.length > 350 ? '${desc.substring(0, 350)}...' : desc);
    buf.writeln();
    if (char.achievements.isNotEmpty) {
      buf.writeln('${AppStrings.lang("ar").notableAchievements}:');
      for (final a in char.achievements.take(3)) {
        buf.writeln('• $a');
      }
    }
    return buf.toString();
  }
}

// ── CHAT SCREEN ───────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl   = TextEditingController();
  final ScrollController _scroll      = ScrollController();
  final List<ChatMessage> _messages   = [];
  bool _loading = false;
  bool _greetingAdded = false;

  String get _lang => context.read<AppState>().language;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_greetingAdded) {
      _greetingAdded = true;
      final lang = context.read<AppState>().language;
      final s = AppStrings.lang(lang);
      _messages.add(ChatMessage(
        text: s.chatGreeting,
        isUser: false,
      ));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();

    // Simulate thinking delay (feels natural)
    await Future.delayed(const Duration(milliseconds: 600));

    final result = _LocalAI.answer(text);

    if (result.answer == '__NEARBY__') {
      await _handleNearest();
    } else {
      setState(() {
        _messages.add(ChatMessage(
          text: result.answer,
          isUser: false,
          suggestedSites: result.sites.isNotEmpty ? result.sites : null,
        ));
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  Future<void> _handleNearest() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() {
          _messages.add(ChatMessage(
            text: '⚠️ لم أتمكن من الوصول لموقعك.\n\n'
              'يرجى السماح للتطبيق بالوصول للموقع من إعدادات الجهاز.\n\n'
              'بدلاً من ذلك، يمكنك فتح الخريطة والضغط على زر "أقرب موقع" مباشرة! 🗺️',
            isUser: false,
          ));
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8)));

      // Find nearest 3 sites
      final withDist = iraqSites.map((s) {
        final d = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, s.lat, s.lng);
        return (site: s, dist: d);
      }).toList()
        ..sort((a, b) => a.dist.compareTo(b.dist));

      final top3 = withDist.take(3).toList();
      final nearest = top3.first;
      final km = (nearest.dist / 1000).toStringAsFixed(0);

      final buf = StringBuffer();
      buf.writeln('${AppStrings.lang("ar").nearestSite}:\n');
      for (int i = 0; i < top3.length; i++) {
        final d = (top3[i].dist / 1000).toStringAsFixed(0);
        buf.writeln('${i + 1}. 🏛️ ${top3[i].site.name}');
        buf.writeln('   ${top3[i].site.city} — $d km\n');
      }
      buf.writeln('${AppStrings.lang(_lang).nearestSite}: ${nearest.site.name} ($km km)');

      setState(() {
        _messages.add(ChatMessage(
          text: buf.toString(),
          isUser: false,
          suggestedSites: top3.map((e) => e.site).toList(),
        ));
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _messages.add(ChatMessage(
          text: AppStrings.lang(context.read<AppState>().language).locationError,
          isUser: false,
        ));
        _loading = false;
      });
    }
  }

  void _scrollToBottom() => Future.delayed(
    const Duration(milliseconds: 150), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
      }
    });

  @override
  Widget build(BuildContext context) {
    final _suggestions = [
      AppStrings.lang(context.read<AppState>().language).nearestQ,
      AppStrings.lang(context.read<AppState>().language).sumerQ,
      AppStrings.lang(context.read<AppState>().language).babylonQ,
      AppStrings.lang(context.read<AppState>().language).gilgameshQ,
      AppStrings.lang(context.read<AppState>().language).unescoQ,
      AppStrings.lang(context.read<AppState>().language).hammurabiQ,
    ];
    final dark = IHTheme.isDark(context);
    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: AppBar(
        backgroundColor: dark ? IHTheme.darkBgCard : IHTheme.primary,
        elevation: 2,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18))),
        title: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: IHTheme.primaryGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: .3), width: 1.5)),
            child: const Center(
              child: Text('𒀭',
                style: TextStyle(fontSize: 20, color: Colors.white)))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, children: [
            Text(AppStrings.lang(context.read<AppState>().language).nabuTitle, style: AppFonts.lora(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: Colors.white)),
            Text(AppStrings.lang(context.read<AppState>().language).nabuSubtitle,
              style: AppFonts.nunito(fontSize: 10,
                color: Colors.white.withValues(alpha: .8))),
          ]),
        ]),
      ),
      body: Column(children: [
        // Messages
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          physics: const BouncingScrollPhysics(),
          itemCount: _messages.length + (_loading ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _messages.length) return const _TypingBubble();
            return _MessageBubble(
              msg: _messages[i],
              onSiteTap: (s) =>
                Navigator.pushNamed(context, '/detail', arguments: s));
          },
        )),

        // Suggestions (only at start)
        if (_messages.length <= 1)
          _Suggestions(items: _suggestions, onTap: _send),

        // Input
        _Input(ctrl: _ctrl, loading: _loading, onSend: () => _send(_ctrl.text)),
      ]),
    );
  }
}

// ── MESSAGE BUBBLE ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final void Function(Site) onSiteTap;
  const _MessageBubble({required this.msg, required this.onSiteTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: msg.isUser
        ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
      Row(
        mainAxisAlignment: msg.isUser
          ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        if (!msg.isUser) ...[
          Container(
            width: 32, height: 32,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: IHTheme.primaryGradient),
            child: const Center(
              child: Text('𒀭',
                style: TextStyle(fontSize: 15, color: Colors.white)))),
        ],
        Flexible(child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * .78),
          padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: msg.isUser ? IHTheme.primaryGradient : null,
            color: msg.isUser ? null : IHTheme.card(context),
            borderRadius: BorderRadius.only(
              topLeft:     const Radius.circular(18),
              topRight:    const Radius.circular(18),
              bottomLeft:  Radius.circular(msg.isUser ? 18 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4  : 18)),
            border: msg.isUser ? null : Border.all(
              color: IHTheme.bdrLight(context)),
            boxShadow: msg.isUser
              ? IHTheme.primaryShadow : IHTheme.shadow(context)),
          child: Text(msg.text,
            style: AppFonts.nunito(fontSize: 13.5,
              height: 1.6,
              color: msg.isUser
                ? Colors.white
                : IHTheme.txtPrimary(context))),
        )),
        if (msg.isUser) const SizedBox(width: 4),
      ]),

      // Related sites chips
      if (msg.suggestedSites != null &&
          msg.suggestedSites!.isNotEmpty) ...[
        const SizedBox(height: 8),
        SizedBox(height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 40),
            itemCount: msg.suggestedSites!.length,
            itemBuilder: (_, i) {
              final s = msg.suggestedSites![i];
              return GestureDetector(
                onTap: () => onSiteTap(s),
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: IHTheme.card(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: IHTheme.bdrLight(context)),
                    boxShadow: IHTheme.shadow(context)),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(14)),
                      child: IHImage(url: s.imageUrl,
                        width: 60, height: 88)),
                    Expanded(child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(s.name, style: AppFonts.lora(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: IHTheme.txtPrimary(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(s.city, style: AppFonts.nunito(
                          fontSize: 9,
                          color: IHTheme.txtMuted(context))),
                        if (s.isUnesco)
                          Text(AppStrings.lang(context.read<AppState>().language).unescoTag,
                            style: AppFonts.nunito(
                              fontSize: 9,
                              color: IHTheme.prim(context),
                              fontWeight: FontWeight.w600)),
                      ])))
                  ]),
                ),
              );
            },
          )),
      ],

      Padding(
        padding: EdgeInsets.only(
          top: 3, right: msg.isUser ? 4 : 42),
        child: Text(
          '${msg.time.hour.toString().padLeft(2,'0')}:'
          '${msg.time.minute.toString().padLeft(2,'0')}',
          style: AppFonts.nunito(
            fontSize: 9,
            color: IHTheme.txtMuted(context)))),
    ]),
  );
}

// ── TYPING BUBBLE ─────────────────────────────────────────────────────────────
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();
  @override State<_TypingBubble> createState() => _TypingState();
}

class _TypingState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Container(
        width: 32, height: 32,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: IHTheme.primaryGradient),
        child: const Center(
          child: Text('𒀭',
            style: TextStyle(fontSize: 15, color: Colors.white)))),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: const BorderRadius.only(
            topLeft:    Radius.circular(18),
            topRight:   Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft:  Radius.circular(4)),
          border: Border.all(color: IHTheme.bdrLight(context))),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i * 0.33;
              final v = ((_c.value - delay) % 1.0).abs();
              final scale = 1.0 + .45 * (v < .5 ? v * 2 : (1 - v) * 2);
              return Transform.scale(scale: scale,
                child: Container(
                  width: 7, height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: IHTheme.prim(context)
                      .withValues(alpha: .55 + .45 * (1 - v)))));
            }),
          ),
        )),
    ]),
  );
}

// ── SUGGESTIONS ───────────────────────────────────────────────────────────────
class _Suggestions extends StatelessWidget {
  final List<String> items;
  final void Function(String) onTap;
  const _Suggestions({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 44,
    margin: const EdgeInsets.only(bottom: 4),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: items.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => onTap(items[i]),
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: IHTheme.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: IHTheme.bdr(context)),
            boxShadow: IHTheme.shadow(context)),
          child: Text(items[i], style: AppFonts.nunito(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: IHTheme.prim(context))),
        ),
      ),
    ),
  );
}

// ── INPUT BAR ─────────────────────────────────────────────────────────────────
class _Input extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final VoidCallback onSend;
  const _Input({required this.ctrl, required this.loading, required this.onSend});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(
      color: IHTheme.card(context),
      border: Border(top: BorderSide(
        color: IHTheme.bdrLight(context)))),
    child: Row(children: [
      Expanded(child: Container(
        decoration: BoxDecoration(
          color: IHTheme.surf(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: IHTheme.bdr(context))),
        child: TextField(
          controller: ctrl,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: AppFonts.nunito(fontSize: 14,
            color: IHTheme.txtPrimary(context)),
          decoration: InputDecoration(
            hintText: AppStrings.lang(context.read<AppState>().language).chatInputHint,
            hintStyle: AppFonts.nunito(fontSize: 13,
              color: IHTheme.txtMuted(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10)),
          onSubmitted: (_) => onSend(),
          maxLines: null),
      )),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: loading ? null : onSend,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: loading ? null : IHTheme.primaryGradient,
            color: loading ? IHTheme.surf(context) : null,
            boxShadow: loading ? [] : IHTheme.primaryShadow),
          child: loading
            ? Center(child: SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: IHTheme.prim(context))))
            : const Icon(Icons.send_rounded,
                color: Colors.white, size: 20))),
    ]),
  );
}
