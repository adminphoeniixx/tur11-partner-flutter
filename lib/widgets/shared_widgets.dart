import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class Turf11PartnerLogo extends StatelessWidget {
  final bool light;
  final bool showMark;
  final bool showText;
  final double markSize;
  final double textSize;
  final MainAxisSize mainAxisSize;

  const Turf11PartnerLogo({
    super.key,
    this.light = false,
    this.showMark = true,
    this.showText = true,
    this.markSize = 48,
    this.textSize = 22,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = light ? Colors.white : AppColors.dark;
    final secondaryText =
        light ? Colors.white.withOpacity(0.62) : AppColors.muted;

    return Row(
      mainAxisSize: mainAxisSize,
      children: [
        if (showMark) ...[
          Container(
            width: markSize,
            height: markSize,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(markSize * 0.3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(light ? 0.35 : 0.18),
                  blurRadius: markSize * 0.32,
                  offset: Offset(0, markSize * 0.12),
                ),
              ],
            ),
            child: Icon(
              Icons.sports_cricket,
              size: markSize * 0.48,
              color: Colors.white,
            ),
          ),
          if (showText) SizedBox(width: markSize * 0.22),
        ],
        if (showText)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  'Turf',
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w800,
                    color: primaryText,
                  ),
                ),
                Text(
                  '11',
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w800,
                    color: light ? AppColors.greenBright : AppColors.green,
                  ),
                ),
              ]),
              Text(
                'Partner',
                style: TextStyle(
                  fontSize: textSize * 0.42,
                  fontWeight: FontWeight.w800,
                  color: secondaryText,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ── STATUS BADGE ──
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  const StatusBadge({super.key, required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (type) {
      case StatusType.active:
        bg = AppColors.greenLt;
        fg = AppColors.green;
      case StatusType.pending:
        bg = AppColors.amberLt;
        fg = AppColors.amber;
      case StatusType.cancelled:
        bg = AppColors.redLt;
        fg = AppColors.red;
      case StatusType.completed:
        bg = AppColors.blueLt;
        fg = AppColors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

enum StatusType { active, pending, cancelled, completed }

// ── BADGE (colored tag) ──
class AppBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const AppBadge(
      {super.key, required this.label, required this.bg, required this.fg});

  factory AppBadge.green(String label) =>
      AppBadge(label: label, bg: AppColors.greenLt, fg: AppColors.green);
  factory AppBadge.red(String label) =>
      AppBadge(label: label, bg: AppColors.redLt, fg: AppColors.red);
  factory AppBadge.amber(String label) =>
      AppBadge(label: label, bg: AppColors.amberLt, fg: AppColors.amber);
  factory AppBadge.blue(String label) =>
      AppBadge(label: label, bg: AppColors.blueLt, fg: AppColors.blue);
  factory AppBadge.dark(String label) =>
      AppBadge(label: label, bg: AppColors.dark, fg: Colors.white);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── STAT CARD ──
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isUp;
  final Color? changeColor;
  final Widget? icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
    this.isUp = true,
    this.changeColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cc = changeColor ?? (isUp ? AppColors.green : AppColors.red);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 120 || constraints.maxWidth < 160;
        final veryCompact =
            constraints.maxHeight < 105 || constraints.maxWidth < 145;
        final padding = veryCompact ? 8.0 : (compact ? 12.0 : 14.0);
        final iconSize = veryCompact ? 22.0 : (compact ? 28.0 : 34.0);
        final labelStyle = TextStyle(
          fontSize: veryCompact ? 9 : (compact ? 10 : 10),
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
          letterSpacing: 0.5,
        );
        final valueStyle = TextStyle(
          fontSize: veryCompact ? 16 : (compact ? 20 : 24),
          fontWeight: FontWeight.w800,
          color: AppColors.dark,
        );
        final changeStyle = TextStyle(
          fontSize: veryCompact ? 9 : (compact ? 10 : 11),
          fontWeight: FontWeight.w600,
          color: cc,
        );

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 2))
            ],
          ),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              return SizedBox(
                width: innerConstraints.maxWidth,
                height: innerConstraints.maxHeight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: innerConstraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              child: icon!,
                            ),
                          ),
                          SizedBox(
                              height: veryCompact ? 4 : (compact ? 8 : 10)),
                        ],
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                        SizedBox(height: veryCompact ? 2 : (compact ? 4 : 6)),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: valueStyle,
                        ),
                        SizedBox(height: veryCompact ? 2 : (compact ? 2 : 4)),
                        Row(
                          children: [
                            if (isUp)
                              Icon(Icons.arrow_upward,
                                  size: veryCompact ? 9 : (compact ? 10 : 12),
                                  color: cc)
                            else
                              Icon(Icons.arrow_downward,
                                  size: veryCompact ? 9 : (compact ? 10 : 12),
                                  color: cc),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                change,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: changeStyle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── PRIMARY BUTTON (full width, pill shape with arrow) ──
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color bgColor;
  final bool compact;

  const PrimaryButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.bgColor = AppColors.dark,
      this.compact = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16, vertical: compact ? 8 : 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: compact ? 12 : 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── PILL BUTTON ──
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color fgColor;
  final IconData? icon;
  final bool outlined;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.bgColor = AppColors.dark,
    this.fgColor = Colors.white,
    this.icon,
    this.outlined = false,
  });

  factory PillButton.green(String label,
          {VoidCallback? onPressed, IconData? icon}) =>
      PillButton(
          label: label,
          onPressed: onPressed,
          bgColor: AppColors.green,
          icon: icon);

  factory PillButton.ghost(String label,
          {VoidCallback? onPressed, IconData? icon}) =>
      PillButton(
          label: label,
          onPressed: onPressed,
          bgColor: AppColors.white,
          fgColor: AppColors.dark,
          icon: icon,
          outlined: true);

  factory PillButton.red(String label,
          {VoidCallback? onPressed, IconData? icon}) =>
      PillButton(
          label: label,
          onPressed: onPressed,
          bgColor: AppColors.red,
          icon: icon);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border, width: 1.5))
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: fgColor),
                const SizedBox(width: 4)
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: fgColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SMALL BUTTON ──
class SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color fgColor;
  final IconData? icon;
  final bool outlined;

  const SmallButton({
    super.key,
    required this.label,
    this.onPressed,
    this.bgColor = AppColors.dark,
    this.fgColor = Colors.white,
    this.icon,
    this.outlined = false,
  });

  factory SmallButton.ghost(String label,
          {VoidCallback? onPressed, IconData? icon}) =>
      SmallButton(
          label: label,
          onPressed: onPressed,
          bgColor: AppColors.white,
          fgColor: AppColors.dark,
          icon: icon,
          outlined: true);

  factory SmallButton.red(String label,
          {VoidCallback? onPressed, IconData? icon}) =>
      SmallButton(
          label: label,
          onPressed: onPressed,
          bgColor: AppColors.red,
          icon: icon);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: outlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border))
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: fgColor),
                const SizedBox(width: 4)
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: fgColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CHIP SELECTOR ──
class ChipSelector extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  const ChipSelector(
      {super.key,
      required this.options,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isOn = i == selected;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: isOn ? AppColors.dark : AppColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: isOn ? AppColors.dark : AppColors.border, width: 1.5),
            ),
            child: Text(
              options[i],
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isOn ? Colors.white : AppColors.muted),
            ),
          ),
        );
      }),
    );
  }
}

// ── TOGGLE SWITCH ──
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 24,
        decoration: BoxDecoration(
          color: value ? AppColors.green : AppColors.border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── TOGGLE ROW ──
class ToggleRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleRow(
      {super.key,
      required this.label,
      this.subtitle,
      required this.value,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ── SECTION LABEL ──
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.9),
      ),
    );
  }
}

// ── INPUT FIELD LABEL ──
class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.6),
      ),
    );
  }
}

// ── APP CARD ──
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }
}

// ── PREFIX INPUT ──
class PrefixInput extends StatelessWidget {
  final String prefix;
  final String hint;
  final TextInputType? keyboardType;

  const PrefixInput(
      {super.key, required this.prefix, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.bg2,
              border: Border(
                  right: BorderSide(color: AppColors.border, width: 1.5)),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12)),
            ),
            child: Text(prefix,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark2)),
          ),
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── UPLOAD ZONE ──
class UploadZone extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;

  const UploadZone(
      {super.key,
      required this.label,
      this.subtitle,
      this.icon = Icons.cloud_upload_outlined});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.border,
              width: 2,
              strokeAlign: BorderSide.strokeAlignCenter),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.muted2),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted2)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── PROGRESS BAR ──
class AppProgressBar extends StatelessWidget {
  final double value; // 0 to 1
  final Color color;
  final double height;

  const AppProgressBar(
      {super.key,
      required this.value,
      this.color = AppColors.green,
      this.height = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: AppColors.border, borderRadius: BorderRadius.circular(3)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0, 1),
        child: Container(
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
      ),
    );
  }
}

// ── AVATAR ──
class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color bg;
  final Color fg;

  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.bg = AppColors.green,
    this.fg = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.35, fontWeight: FontWeight.w800, color: fg)),
    );
  }
}

// ── STAR RATING ──
class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.floor()
              ? Icons.star
              : (i < rating ? Icons.star_half : Icons.star_border),
          size: size,
          color: i < rating ? AppColors.green : AppColors.border,
        );
      }),
    );
  }
}
