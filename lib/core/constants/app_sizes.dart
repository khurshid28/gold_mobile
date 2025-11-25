import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSizes {
  AppSizes._();

  // Padding & Margin
  static double get paddingXS => 4.w;
  static double get paddingSM => 8.w;
  static double get paddingMD => 16.w;
  static double get paddingLG => 24.w;
  static double get paddingXL => 32.w;
  static double get paddingXXL => 48.w;

  // Border Radius
  static double get radiusXS => 4.r;
  static double get radiusSM => 8.r;
  static double get radiusMD => 12.r;
  static double get radiusLG => 16.r;
  static double get radiusXL => 20.r;
  static double get radiusXXL => 24.r;
  static double get radiusFull => 999.r;

  // Icon Sizes
  static double get iconXS => 16.sp;
  static double get iconSM => 20.sp;
  static double get iconMD => 24.sp;
  static double get iconLG => 32.sp;
  static double get iconXL => 48.sp;
  static double get iconXXL => 64.sp;

  // Font Sizes
  static double get fontXS => 10.sp;
  static double get fontSM => 12.sp;
  static double get fontMD => 14.sp;
  static double get fontLG => 16.sp;
  static double get fontXL => 18.sp;
  static double get fontXXL => 20.sp;
  static double get font3XL => 24.sp;
  static double get font4XL => 28.sp;
  static double get font5XL => 32.sp;
  static double get font6XL => 36.sp;

  // Component Sizes
  static double get buttonHeight => 50.h;
  static double get buttonHeightSM => 40.h;
  static double get buttonHeightLG => 56.h;
  
  static double get inputHeight => 50.h;
  static double get appBarHeight => 56.h;
  static double get bottomNavHeight => 70.h;
  
  static double get imageSmall => 80.w;
  static double get imageMedium => 120.w;
  static double get imageLarge => 200.w;
  static double get imageXLarge => 300.w;

  // Elevation
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;

  // Spacing
  static double get spaceXS => 4.w;
  static double get spaceSM => 8.w;
  static double get spaceMD => 16.w;
  static double get spaceLG => 24.w;
  static double get spaceXL => 32.w;
  static double get spaceXXL => 48.w;
  
  // Height Spacing
  static double get heightXS => 4.h;
  static double get heightSM => 8.h;
  static double get heightMD => 16.h;
  static double get heightLG => 24.h;
  static double get heightXL => 32.h;
  static double get heightXXL => 48.h;

  // Grid
  static double get gridSpacing => 16.w;
  static const int gridColumnCount = 2;

  // Animation Duration (in milliseconds)
  static const int animationFast = 150;
  static const int animationShort = 200;
  static const int animationMedium = 300;
  static const int animationLong = 500;
  static const int animationXLong = 800;
}
