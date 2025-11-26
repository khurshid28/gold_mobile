import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Logo scale and opacity animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Rotation animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Fade out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Start rotation after logo appears
    await Future.delayed(const Duration(milliseconds: 800));
    _rotateController.forward();

    // Start shimmer effect
    await Future.delayed(const Duration(milliseconds: 200));
    _shimmerController.repeat();

    // Wait and navigate
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      // Check if user is already logged in
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      _fadeController.forward().then((_) {
        if (isLoggedIn) {
          // User is logged in, go to home
          context.go('/home');
        } else {
          // User is not logged in, go to login page
          context.go('/phone-login');
        }
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.backgroundDark,
                          AppColors.surfaceDark,
                          const Color(0xFF1A1A1A),
                        ]
                      : [
                          const Color(0xFFFFFBF0),
                          const Color(0xFFFFF8E1),
                          const Color(0xFFFFECB3),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background particles
                  ...List.generate(20, (index) {
                    return AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        final offset = index * 0.1;
                        final animValue =
                            (_logoController.value + offset) % 1.0;
                        return Positioned(
                          left: (index % 4) * 100.0.w + (animValue * 50.w),
                          top: (index ~/ 4) * 150.0.h + (animValue * 80.h),
                          child: Opacity(
                            opacity: (1 - animValue) * 0.3,
                            child: Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo with rotation
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _logoController,
                            _rotateController,
                          ]),
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoScale.value,
                              child: Transform.rotate(
                                angle: _rotateAnimation.value,
                                child: Opacity(
                                  opacity: _logoOpacity.value,
                                  child: Container(
                                    width: 180.w,
                                    height: 180.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.gold.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0),
                                          BlendMode.dstOver,
                                        ),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          width: 180.w,
                                          height: 180.h,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 40.h),

                        // Brand name with shimmer effect
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value,
                              child: Stack(
                                children: [
                                  // Shadow text
                                  Text(
                                    'GOLD IMPERIA',
                                    style: TextStyle(
                                      fontSize: 32.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 4,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 2
                                        ..color = AppColors.gold.withOpacity(
                                          0.5,
                                        ),
                                      shadows: [
                                        Shadow(
                                          color: AppColors.gold.withOpacity(
                                            0.5,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Main text with shimmer
                                  AnimatedBuilder(
                                    animation: _shimmerAnimation,
                                    builder: (context, child) {
                                      return ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.gold,
                                              const Color(0xFFFFE55C),
                                              AppColors.gold,
                                            ],
                                            stops: [
                                              _shimmerAnimation.value - 0.3,
                                              _shimmerAnimation.value,
                                              _shimmerAnimation.value + 0.3,
                                            ],
                                            tileMode: TileMode.mirror,
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          'GOLD IMPERIA',
                                          style: TextStyle(
                                            fontSize: 32.sp,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 4,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 12.h),

                        // Tagline
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value * 0.8,
                              child: Text(
                                'LUXURY JEWELRY',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                  color: isDark
                                      ? AppColors.textLightOnDark
                                      : AppColors.textMedium,
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 60.h),

                        // Loading indicator
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value,
                              child: LoadingWidget(
                                size: 50,
                                color: AppColors.gold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
