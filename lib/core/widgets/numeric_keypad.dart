import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gold_mobile/core/constants/app_colors.dart';

/// Classic 3x4 numeric keypad (1 2 3 / 4 5 6 / 7 8 9 / [left] 0 [backspace]).
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.leftAction,
    this.color,
    this.backspaceColor,
    this.onDarkBackground = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final Widget? leftAction;
  final Color? color;
  final Color? backspaceColor;
  final bool onDarkBackground;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        onDarkBackground || Theme.of(context).brightness == Brightness.dark;
    final fg = color ?? (isDark ? Colors.white : AppColors.textDark);
    final keyBg = isDark
        ? Colors.white.withOpacity(0.06)
        : AppColors.gold.withOpacity(0.07);
    final keyBorder = isDark
        ? Colors.white.withOpacity(0.10)
        : AppColors.gold.withOpacity(0.18);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row
                  .map((d) => _DigitKey(
                        digit: d,
                        color: fg,
                        bg: keyBg,
                        border: keyBorder,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onDigit(d);
                        },
                      ))
                  .toList(),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: Center(child: leftAction ?? const SizedBox.shrink()),
              ),
              _DigitKey(
                digit: '0',
                color: fg,
                bg: keyBg,
                border: keyBorder,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onDigit('0');
                },
              ),
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onBackspace();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.10),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close_rounded,
                        size: 34,
                        color: backspaceColor ?? fg,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DigitKey extends StatefulWidget {
  const _DigitKey({
    required this.digit,
    required this.color,
    required this.bg,
    required this.border,
    required this.onTap,
  });
  final String digit;
  final Color color;
  final Color bg;
  final Color border;
  final VoidCallback onTap;

  @override
  State<_DigitKey> createState() => _DigitKeyState();
}

class _DigitKeyState extends State<_DigitKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72.w,
      height: 72.w,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: _pressed ? AppColors.gold.withOpacity(0.18) : widget.bg,
              shape: BoxShape.circle,
              border: Border.all(color: widget.border, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.digit,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of [length] dots with smooth fill, glow and shake-on-error animation.
class PinDots extends StatefulWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filled,
    this.color,
    this.error = false,
  });
  final int length;
  final int filled;
  final Color? color;
  final bool error;

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  @override
  void didUpdateWidget(covariant PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error && !oldWidget.error) {
      _shake.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.color ?? (isDark ? Colors.white : AppColors.textDark);
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        // damped sine shake
        final dx = t == 0
            ? 0.0
            : 10 * (1 - t) * (t * 18).remainder(2 / 1) - 5 * (1 - t);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (i) {
          final on = i < widget.filled;
          final c = widget.error ? AppColors.error : base;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 9.w),
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: on ? c : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: c.withOpacity(on ? 1 : 0.55),
                width: 1.6,
              ),
            ),
          );
        }),
      ),
    );
  }
}
