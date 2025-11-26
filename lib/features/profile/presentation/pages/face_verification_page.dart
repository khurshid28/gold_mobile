import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_icon.dart';

class FaceVerificationPage extends StatefulWidget {
  const FaceVerificationPage({super.key});

  @override
  State<FaceVerificationPage> createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _isSuccess = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Auto start face scanning after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _startFaceVerification();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startFaceVerification() async {
    setState(() => _isScanning = true);

    // Simulate face scanning
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isScanning = false;
      _isSuccess = true;
    });

    // Wait a moment to show success
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Show success and return
    _showSuccessDialog();
  }

  Future<void> _showSuccessDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Tasdiqlandi!',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Hujjatingiz va yuzingiz muvaffaqiyatli tasdiqlandi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Farhod Istamov',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop('continue');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Davom etish',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    
    if (!mounted) return;
    
    // Return with action result
    Navigator.pop(context, {
      'verified': true,
      'name': 'Farhod Istamov',
      'action': result ?? 'close', // 'continue' or 'close'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: CustomIcon(
              name: 'back',
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
        title: const Text(
          'Yuzni tasdiqlash',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Face scanning animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Animated border
                if (_isScanning && !_isSuccess)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 280.w,
                          height: 280.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold,
                              width: 4,
                            ),
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                
                // Face icon/image placeholder
                Container(
                  width: 250.w,
                  height: 250.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                    border: Border.all(
                      color: _isSuccess
                          ? Colors.green
                          : (_isScanning ? AppColors.gold : Colors.grey),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _isSuccess ? Icons.check_circle : Icons.face,
                    size: 120.sp,
                    color: _isSuccess
                        ? Colors.green
                        : (_isScanning ? AppColors.gold : Colors.grey[400]),
                  ),
                ),

                // Scanning overlay
                if (_isScanning && !_isSuccess)
                  Container(
                    width: 250.w,
                    height: 250.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.gold.withOpacity(0.3),
                          Colors.transparent,
                          AppColors.gold.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 40.h),
            
            // Status text
            Text(
              _isSuccess
                  ? 'Tasdiqlandi!'
                  : (_isScanning
                      ? 'Yuzingizni skanerlash...'
                      : 'Yuzingizni markazga qo\'ying'),
              style: TextStyle(
                color: _isSuccess ? Colors.green : Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (_isScanning && !_isSuccess) ...[
              SizedBox(height: 16.h),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
