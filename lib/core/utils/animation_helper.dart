import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AnimationHelper {
  AnimationHelper._();

  // Fade In Animation
  static Widget fadeIn({
    required Widget child,
    Duration? duration,
    Duration? delay,
    Curve curve = Curves.easeIn,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Slide In From Bottom Animation
  static Widget slideInFromBottom({
    required Widget child,
    Duration? duration,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50.0, end: 0.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 50),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Slide In From Left Animation
  static Widget slideInFromLeft({
    required Widget child,
    Duration? duration,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -50.0, end: 0.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: 1 - (value.abs() / 50),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Slide In From Right Animation
  static Widget slideInFromRight({
    required Widget child,
    Duration? duration,
    Curve curve = Curves.easeOutCubic,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 50.0, end: 0.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: Opacity(
            opacity: 1 - (value / 50),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Scale Animation
  static Widget scaleIn({
    required Widget child,
    Duration? duration,
    Curve curve = Curves.easeOutBack,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Staggered List Animation
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    int startDelay = 0,
    int itemDelay = 100,
    Curve curve = Curves.easeOutCubic,
  }) {
    final delay = startDelay + (index * itemDelay);
    
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0),
      builder: (context, _) {
        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: delay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Opacity(
                opacity: 0,
                child: Transform.translate(
                  offset: const Offset(0, 20),
                  child: child,
                ),
              );
            }
            
            return slideInFromBottom(
              duration: Duration(milliseconds: AppSizes.animationMedium),
              curve: curve,
              child: child,
            );
          },
        );
      },
    );
  }

  // Shimmer Effect Animation Controller
  static Animation<double> shimmerAnimation(AnimationController controller) {
    return Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  // Bouncing Animation
  static Widget bounce({
    required Widget child,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration ?? Duration(milliseconds: AppSizes.animationLong),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Rotate Animation
  static Widget rotate({
    required Widget child,
    Duration? duration,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }

  // Custom Page Route with Animation
  static PageRouteBuilder<T> customPageRoute<T>({
    required Widget page,
    Duration? duration,
    PageTransitionType type = PageTransitionType.fade,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      reverseTransitionDuration: duration ?? Duration(milliseconds: AppSizes.animationMedium),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case PageTransitionType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          case PageTransitionType.fadeSlide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
    );
  }
}

enum PageTransitionType {
  fade,
  slide,
  scale,
  fadeSlide,
}
