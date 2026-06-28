import 'package:flutter/material.dart';
import '../theme/app_fonts.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  IH IMAGE  ── صور محلية بالكامل من assets، بدون أي اعتماد على الإنترنت
// ══════════════════════════════════════════════════════════════════════════════
class IHImage extends StatelessWidget {
  final String url;
  final double? height, width;
  final BoxFit fit;

  const IHImage({super.key, required this.url,
    this.height, this.width, this.fit = BoxFit.cover});

  // نوع الصورة من المسار
  _ImgType get _type {
    if (url.contains('characters')) return _ImgType.character;
    if (url.contains('eras'))       return _ImgType.era;
    if (url.contains('landmarks'))  return _ImgType.landmark;
    return _ImgType.general;
  }

  // يجرب كل الامتدادات تلقائياً
  static const _exts = ['.jpg', '.jpeg', '.png', '.webp'];

  String get _baseUrl {
    for (final ext in _exts) {
      if (url.endsWith(ext)) return url.substring(0, url.length - ext.length);
    }
    return url;
  }

  String get _urlNoExt => _baseUrl;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder(context);

    // كل صور التطبيق محلية (assets) — يجرب jpg ثم png ثم webp
    return _AssetImageWithFallback(
      basePath: _urlNoExt,
      extensions: _exts,
      height: height, width: width, fit: fit,
      placeholder: _placeholder(context));
  }

  Widget _placeholder(BuildContext context) {
    final data = _placeholderData(_type);
    return Container(
      height: height, width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: data.colors)),
      child: Stack(children: [
        // نمط خلفية
        Positioned.fill(child: CustomPaint(
          painter: _PlaceholderPatternPainter(data.colors.last))),
        // أيقونة + نص
        Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: (width ?? 80) * .38,
              height: (width ?? 80) * .38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .15)),
              child: Icon(data.icon,
                color: Colors.white.withValues(alpha: .8),
                size: (width ?? 80) * .22)),
            if ((height ?? 0) > 60) ...[
              const SizedBox(height: 6),
              Text(data.label,
                style: AppFonts.nunito(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: .7))),
            ]
          ],
        )),
      ]),
    );
  }


  static _PlaceholderData _placeholderData(_ImgType t) {
    switch (t) {
      case _ImgType.character:
        return _PlaceholderData(
          icon: Icons.person_outline_rounded,
          label: 'شخصية تاريخية',
          colors: [const Color(0xFF6B4A2A), const Color(0xFF3D2510)]);
      case _ImgType.era:
        return _PlaceholderData(
          icon: Icons.history_edu_rounded,
          label: 'حقبة زمنية',
          colors: [const Color(0xFF4A6B3A), const Color(0xFF253D18)]);
      case _ImgType.landmark:
        return _PlaceholderData(
          icon: Icons.account_balance_rounded,
          label: 'موقع أثري',
          colors: [const Color(0xFF4A5B6B), const Color(0xFF1E2E3D)]);
      case _ImgType.general:
        return _PlaceholderData(
          icon: Icons.image_rounded,
          label: '',
          colors: [const Color(0xFF6B5A4A), const Color(0xFF3D3020)]);
    }
  }
}

enum _ImgType { character, era, landmark, general }

class _PlaceholderData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  const _PlaceholderData({required this.icon, required this.label, required this.colors});
}

// يجرب امتدادات متعددة تلقائياً (.jpg .png .webp ...)
class _AssetImageWithFallback extends StatefulWidget {
  final String basePath;
  final List<String> extensions;
  final double? height, width;
  final BoxFit fit;
  final Widget placeholder;
  const _AssetImageWithFallback({
    required this.basePath, required this.extensions,
    this.height, this.width, this.fit = BoxFit.cover,
    required this.placeholder});
  @override State<_AssetImageWithFallback> createState() => _AssetImageWithFallbackState();
}

class _AssetImageWithFallbackState extends State<_AssetImageWithFallback> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    if (_idx >= widget.extensions.length) return widget.placeholder;
    final path = widget.basePath + widget.extensions[_idx];
    return Image.asset(path,
      height: widget.height, width: widget.width, fit: widget.fit,
      errorBuilder: (_, __, ___) {
        // جرب الامتداد الجاي
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _idx++);
        });
        return widget.placeholder;
      });
  }
}

// نمط هندسي خفيف للـ placeholder
class _PlaceholderPatternPainter extends CustomPainter {
  final Color color;
  _PlaceholderPatternPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .12)
      ..strokeWidth = .8
      ..style = PaintingStyle.stroke;
    const step = 18.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }
  @override bool shouldRepaint(_PlaceholderPatternPainter o) => o.color != color;
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH PRIMARY BUTTON
// ══════════════════════════════════════════════════════════════════════════════
class IHButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final double height;
  final bool outlined;
  const IHButton({super.key, required this.label, required this.onTap,
    this.icon, this.height = 52, this.outlined = false});
  @override State<IHButton> createState() => _IHButtonState();
}

class _IHButtonState extends State<IHButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? .96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.outlined ? null : IHTheme.primaryGradient,
          color: widget.outlined ? IHTheme.card(context) : null,
          borderRadius: BorderRadius.circular(14),
          border: widget.outlined
            ? Border.all(color: IHTheme.prim(context), width: 1.2) : null,
          boxShadow: _p || widget.outlined ? [] : IHTheme.primaryShadow),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (widget.icon != null) ...[
            Icon(widget.icon,
              color: widget.outlined ? IHTheme.prim(context) : Colors.white,
              size: 18),
            const SizedBox(width: 8)],
          Text(widget.label, style: AppFonts.lora(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: widget.outlined ? IHTheme.prim(context) : Colors.white)),
        ]),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH CARD
// ══════════════════════════════════════════════════════════════════════════════
class IHCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final BorderRadius? radius;
  const IHCard({super.key, required this.child, this.onTap,
    this.padding, this.radius});
  @override State<IHCard> createState() => _IHCardState();
}

class _IHCardState extends State<IHCard> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: widget.onTap != null ? (_) => setState(() => _p = true) : null,
    onTapUp: widget.onTap != null ? (_) {
      setState(() => _p = false); widget.onTap!(); } : null,
    onTapCancel: widget.onTap != null
      ? () => setState(() => _p = false) : null,
    child: AnimatedScale(scale: _p ? .97 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: IHTheme.card(context),
          borderRadius: widget.radius ?? BorderRadius.circular(16),
          border: Border.all(
            color: _p ? IHTheme.prim(context) : IHTheme.bdrLight(context),
            width: _p ? 1 : .8),
          boxShadow: _p ? IHTheme.primaryShadow : IHTheme.shadow(context)),
        child: widget.child),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH APP BAR
// ══════════════════════════════════════════════════════════════════════════════
class IHAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final bool light;
  const IHAppBar({super.key, required this.title,
    this.showBack = false, this.actions, this.light = false});

  @override Size get preferredSize => const Size.fromHeight(62);

  @override
  Widget build(BuildContext context) {
    final dark = IHTheme.isDark(context);
    final bgColor = light
      ? IHTheme.bg(context)
      : (dark ? IHTheme.darkBgCard : IHTheme.primary);
    final fgColor = light
      ? IHTheme.txtPrimary(context)
      : (dark ? IHTheme.darkTextPrimary : Colors.white);
    return AppBar(
      backgroundColor: bgColor,
      elevation: light ? 0 : 2,
      automaticallyImplyLeading: false,
      title: Row(children: [
        if (showBack) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_rounded,
              color: fgColor, size: 20)),
          const SizedBox(width: 8),
        ],
        Expanded(child: Text(title, textAlign: TextAlign.center,
          style: AppFonts.lora(fontSize: 20, fontWeight: FontWeight.w600,
            color: fgColor))),
      ]),
      actions: actions,
      bottom: light ? PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.transparent,
              IHTheme.primLight(context),
              IHTheme.prim(context),
              IHTheme.primLight(context),
              Colors.transparent])))) : null,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH CHIP
// ══════════════════════════════════════════════════════════════════════════════
class IHChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const IHChip({super.key, required this.label,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: selected ? IHTheme.primaryGradient : null,
        color: selected ? null : IHTheme.card(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? Colors.transparent : IHTheme.bdr(context)),
        boxShadow: selected ? IHTheme.primaryShadow : IHTheme.shadow(context)),
      child: Text(label, style: AppFonts.nunito(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : IHTheme.txtSecondary(context))),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════
class IHSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const IHSectionHeader({super.key, required this.title,
    this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(children: [
      Container(width: 4, height: 20,
        decoration: BoxDecoration(
          gradient: IHTheme.primaryGradient,
          borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: AppFonts.lora(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context)))),
      if (action != null)
        GestureDetector(onTap: onAction,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(action!, style: AppFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: IHTheme.prim(context))),
            const SizedBox(width: 2),
            Icon(Icons.arrow_forward_ios_rounded,
              size: 11, color: IHTheme.prim(context)),
          ])),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH DIVIDER
// ══════════════════════════════════════════════════════════════════════════════
class IHDivider extends StatelessWidget {
  const IHDivider({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 1, margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.transparent,
        IHTheme.primLight(context),
        IHTheme.prim(context),
        IHTheme.primLight(context),
        Colors.transparent])));
}

// ══════════════════════════════════════════════════════════════════════════════
//  IH STAT ITEM
// ══════════════════════════════════════════════════════════════════════════════
class IHStat extends StatelessWidget {
  final IconData icon; final String label, value;
  const IHStat({super.key, required this.icon,
    required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: IHTheme.card(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: IHTheme.bdrLight(context), width: .8),
      boxShadow: IHTheme.shadow(context)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: IHTheme.prim(context), size: 22),
      const SizedBox(height: 5),
      Text(value, style: AppFonts.lora(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: IHTheme.txtPrimary(context))),
      Text(label, style: AppFonts.nunito(
        fontSize: 9, color: IHTheme.txtMuted(context))),
    ]),
  );
}
