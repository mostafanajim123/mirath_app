import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../data/translations.dart';
import '../widgets/common_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  COMPLAINT SCREEN — شكوى عن التطبيق
// ══════════════════════════════════════════════════════════════════════════════
class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});
  @override State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _textCtrl = TextEditingController();
  String _type = 'bug';
  bool _sent = false;
  bool _sending = false;

  String get _lang => context.read<AppState>().language;

  List<Map<String, String>> get _types => [
    {'key': 'bug',     'icon': '🐛', 'label': AppStrings.lang(_lang).techError},
    {'key': 'suggest', 'icon': '💡', 'label': AppStrings.lang(_lang).suggestion},
    {'key': 'content', 'icon': '📝', 'label': AppStrings.lang(_lang).inaccurateContent},
    {'key': 'other',   'icon': '💬', 'label': AppStrings.lang(_lang).other},
  ];

  @override
  void dispose() { _textCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.lang(_lang).writeComplaintFirst)));
      return;
    }
    setState(() => _sending = true);

    final typeName = _types.firstWhere((t) => t['key'] == _type)['label']!;
    final body = '$typeName\n\n${_textCtrl.text.trim()}';
    final subject = 'Iraqi Heritage Feedback — $typeName';
    final encoded = Uri.encodeComponent(body);
    final uri = Uri.parse(
      'mailto:support@iraqi-heritage.app?subject=${Uri.encodeComponent(subject)}&body=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Share.share('$subject\n\n$body');
      }
      setState(() { _sent = true; _sending = false; });
    } catch (_) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.lang(_lang).sendError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(title: AppStrings.lang(_lang).complaintAboutApp, showBack: true, light: true),
      body: _sent ? _buildSuccess(context) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IHTheme.prim(context).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: IHTheme.prim(context).withValues(alpha: .2))),
        child: Row(children: [
          const Text('📣', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(child: Text(
            AppStrings.lang(_lang).complaintHelp,
            style: AppFonts.nunito(fontSize: 13,
              color: IHTheme.txtSecondary(context), height: 1.5))),
        ])),

      const SizedBox(height: 24),

      Text(AppStrings.lang(_lang).complaintTypes, style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10,
        children: _types.map((t) {
          final sel = _type == t['key'];
          return GestureDetector(
            onTap: () => setState(() => _type = t['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: sel ? IHTheme.primaryGradient : null,
                color: sel ? null : IHTheme.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? Colors.transparent : IHTheme.bdr(context)),
                boxShadow: sel ? IHTheme.primaryShadow : IHTheme.shadow(context)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(t['icon']!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(t['label']!, style: AppFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : IHTheme.txtPrimary(context))),
              ])));
        }).toList()),

      const SizedBox(height: 24),

      Text(AppStrings.lang(_lang).explainProblem, style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: IHTheme.bdr(context))),
        child: TextField(
          controller: _textCtrl,
          maxLines: 6,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.txtPrimary(context)),
          decoration: InputDecoration(
            hintText: AppStrings.lang(_lang).explainProblem,
            hintStyle: AppFonts.nunito(fontSize: 13, color: IHTheme.txtMuted(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16)),
        )),

      const SizedBox(height: 28),

      IHButton(
        label: _sending ? AppStrings.lang(_lang).sending : AppStrings.lang(_lang).sendComplaint,
        icon: Icons.send_rounded,
        onTap: _sending ? () {} : _send,
      ),
      const SizedBox(height: 16),
      Text(AppStrings.lang(_lang).emailWillOpen,
        style: AppFonts.nunito(fontSize: 11, color: IHTheme.txtMuted(context)),
        textAlign: TextAlign.center),
    ],
  );

  Widget _buildSuccess(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            gradient: IHTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: IHTheme.primaryShadow),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40)),
        const SizedBox(height: 24),
        Text(AppStrings.lang(_lang).thankYou, style: AppFonts.lora(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: IHTheme.txtPrimary(context))),
        const SizedBox(height: 10),
        Text(AppStrings.lang(_lang).willReview,
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.txtSecondary(context)),
          textAlign: TextAlign.center),
        const SizedBox(height: 32),
        IHButton(
          label: AppStrings.lang(_lang).backToSettings,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context)),
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  REPORT SITE SCREEN — إبلاغ عن موقع بخطر
// ══════════════════════════════════════════════════════════════════════════════
class ReportSiteScreen extends StatefulWidget {
  const ReportSiteScreen({super.key});
  @override State<ReportSiteScreen> createState() => _ReportSiteScreenState();
}

class _ReportSiteScreenState extends State<ReportSiteScreen> {
  final _textCtrl = TextEditingController();
  final _siteCtrl = TextEditingController();
  final _picker   = ImagePicker();
  final List<XFile> _images = [];
  String _urgency = 'medium';
  bool _sent      = false;
  bool _sending   = false;

  String get _lang => context.read<AppState>().language;

  final _urgencies = [
    {'key': 'low',    'label': 'خطر منخفض',   'color': 0xFF4CAF50, 'icon': '🟡'},
    {'key': 'medium', 'label': 'خطر متوسط',   'color': 0xFFFF9800, 'icon': '🟠'},
    {'key': 'high',   'label': 'خطر عالٍ',    'color': 0xFFF44336, 'icon': '🔴'},
    {'key': 'urgent', 'label': 'انهيار وشيك', 'color': 0xFF9C27B0, 'icon': '🆘'},
  ];

  @override
  void dispose() { _textCtrl.dispose(); _siteCtrl.dispose(); super.dispose(); }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 75, limit: 5);
    if (picked.isNotEmpty) {
      setState(() { _images.clear(); _images.addAll(picked.take(5)); });
    }
  }

  Future<void> _pickCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (picked != null) setState(() => _images.add(picked));
  }

  Future<void> _send() async {
    if (_siteCtrl.text.trim().isEmpty || _textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.lang(_lang).fillRequired)));
      return;
    }
    setState(() => _sending = true);

    final urgName = _urgencies.firstWhere((u) => u['key'] == _urgency)['label']!;
    final body =
      'الموقع: ${_siteCtrl.text.trim()}\n'
      'مستوى الخطر: $urgName\n'
      'عدد الصور: ${_images.length}\n\n'
      '${_textCtrl.text.trim()}';
    final subject = 'إبلاغ خطر — ${_siteCtrl.text.trim()} — $urgName';

    try {
      if (_images.isNotEmpty) {
        await Share.shareXFiles(_images, text: '$subject\n\n$body', subject: subject);
      } else {
        final uri = Uri.parse(
          'mailto:report@iraqi-heritage.app'
          '?subject=${Uri.encodeComponent(subject)}'
          '&body=${Uri.encodeComponent(body)}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await Share.share('$subject\n\n$body');
        }
      }
      setState(() { _sent = true; _sending = false; });
    } catch (_) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.lang(_lang).sendError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();
    return Scaffold(
      backgroundColor: IHTheme.bg(context),
      appBar: IHAppBar(
        title: AppStrings.lang(_lang).reportDanger, showBack: true, light: true),
      body: _sent ? _buildSuccess(context) : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF44336).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF44336).withValues(alpha: .3))),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 26),
          const SizedBox(width: 12),
          Expanded(child: Text(
            AppStrings.lang(_lang).get('reportHelp'),
            style: AppFonts.nunito(fontSize: 13,
              color: IHTheme.txtSecondary(context), height: 1.5))),
        ])),

      const SizedBox(height: 24),

      Text('${AppStrings.lang(_lang).siteName} *', style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: IHTheme.bdr(context))),
        child: TextField(
          controller: _siteCtrl,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.txtPrimary(context)),
          decoration: InputDecoration(
            hintText: AppStrings.lang(_lang).get('siteNameHint'),
            hintStyle: AppFonts.nunito(fontSize: 13, color: IHTheme.txtMuted(context)),
            prefixIcon: Icon(Icons.location_on_rounded, color: IHTheme.prim(context), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)))),

      const SizedBox(height: 20),

      Text('${AppStrings.lang(_lang).urgencyLevel} *', style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 12),
      Column(
        children: _urgencies.map((u) {
          final sel = _urgency == u['key'];
          final color = Color(u['color'] as int);
          return GestureDetector(
            onTap: () => setState(() => _urgency = u['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? color.withValues(alpha: .12) : IHTheme.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? color : IHTheme.bdr(context), width: sel ? 1.5 : 1),
                boxShadow: sel
                  ? [BoxShadow(color: color.withValues(alpha: .2), blurRadius: 10, offset: const Offset(0, 4))]
                  : IHTheme.shadow(context)),
              child: Row(children: [
                Text(u['icon'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text(u['label'] as String,
                  style: AppFonts.lora(fontSize: 14, fontWeight: FontWeight.w700,
                    color: sel ? color : IHTheme.txtPrimary(context)))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? color : Colors.transparent,
                    border: Border.all(color: sel ? color : IHTheme.bdr(context), width: 2)),
                  child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null),
              ]),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 20),

      Text('${AppStrings.lang(_lang).describeRisk} *', style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: IHTheme.bdr(context))),
        child: TextField(
          controller: _textCtrl,
          maxLines: 5,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.txtPrimary(context)),
          decoration: InputDecoration(
            hintText: AppStrings.lang(_lang).describeRisk,
            hintStyle: AppFonts.nunito(fontSize: 12, color: IHTheme.txtMuted(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16)))),

      const SizedBox(height: 20),

      Text(AppStrings.lang(_lang).addPhoto, style: AppFonts.lora(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      const SizedBox(height: 10),

      Row(children: [
        Expanded(child: _ImgButton(
          icon: Icons.camera_alt_rounded,
          label: 'التقاط صورة',
          onTap: _pickCamera,
          ctx: context)),
        const SizedBox(width: 12),
        Expanded(child: _ImgButton(
          icon: Icons.photo_library_rounded,
          label: 'من المعرض',
          onTap: _pickImages,
          ctx: context)),
      ]),

      if (_images.isNotEmpty) ...[
        const SizedBox(height: 14),
        SizedBox(height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_images[i].path),
                  width: 100, height: 100, fit: BoxFit.cover)),
              Positioned(top: 4, right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _images.removeAt(i)),
                  child: Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14)))),
            ]))),
      ],

      const SizedBox(height: 28),

      IHButton(
        label: _sending ? AppStrings.lang(_lang).sending : AppStrings.lang(_lang).sendReport,
        icon: Icons.warning_amber_rounded,
        onTap: _sending ? () {} : _send,
      ),
      const SizedBox(height: 16),
      Text(
        _images.isNotEmpty
          ? 'سيتم مشاركة الصور والبلاغ عبر تطبيق المشاركة'
          : 'سيتم إرسال البلاغ عبر البريد الإلكتروني',
        style: AppFonts.nunito(fontSize: 11, color: IHTheme.txtMuted(context)),
        textAlign: TextAlign.center),
      const SizedBox(height: 20),
    ]);

  Widget _buildSuccess(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF44336),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: const Color(0xFFF44336).withValues(alpha: .4), blurRadius: 20)]),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 40)),
        const SizedBox(height: 24),
        Text('تم إرسال البلاغ 🙏', style: AppFonts.lora(
          fontSize: 22, fontWeight: FontWeight.w700,
          color: IHTheme.txtPrimary(context))),
        const SizedBox(height: 10),
        Text('شكراً — بلاغك يساعد في حماية تراثنا العراقي',
          style: AppFonts.nunito(fontSize: 14, color: IHTheme.txtSecondary(context)),
          textAlign: TextAlign.center),
        const SizedBox(height: 32),
        IHButton(
          label: AppStrings.lang(_lang).backToSettings,
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context)),
      ]),
    ),
  );
}

// ── Image Button ──────────────────────────────────────────────────────────────
class _ImgButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final BuildContext ctx;
  const _ImgButton({required this.icon, required this.label, required this.onTap, required this.ctx});
  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: IHTheme.card(ctx),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: IHTheme.bdr(ctx)),
        boxShadow: IHTheme.shadow(ctx)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: IHTheme.prim(ctx), size: 26),
        const SizedBox(height: 6),
        Text(label, style: AppFonts.nunito(fontSize: 12,
          fontWeight: FontWeight.w600, color: IHTheme.txtSecondary(ctx))),
      ])));
}
