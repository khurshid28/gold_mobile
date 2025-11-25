import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';

class CustomIcon extends StatelessWidget {
  final String name;
  final double? size;
  final Color? color;
  
  const CustomIcon({
    super.key,
    required this.name,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = color ?? (isDark ? AppColors.textDark : AppColors.textLight);
    
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size ?? 24,
      height: size ?? 24,
      colorFilter: ColorFilter.mode(
        defaultColor,
        BlendMode.srcIn,
      ),
    );
  }
}
