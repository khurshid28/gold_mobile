import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../cart/domain/entities/cart_item.dart';

class InstallmentSelectionPage extends StatefulWidget {
  final List<CartItem> items;
  final double totalAmount;

  const InstallmentSelectionPage({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<InstallmentSelectionPage> createState() =>
      _InstallmentSelectionPageState();
}

class _InstallmentSelectionPageState extends State<InstallmentSelectionPage> {
  int _selectedMonths = 3;

  double _calculateMonthlyPayment(int months) {
    double interestRate;
    switch (months) {
      case 3:
        interestRate = 0.10;
        break;
      case 6:
        interestRate = 0.15;
        break;
      case 9:
        interestRate = 0.20;
        break;
      case 12:
        interestRate = 0.30;
        break;
      default:
        interestRate = 0.10;
    }
    
    final totalWithInterest = widget.totalAmount * (1 + interestRate);
    return totalWithInterest / months;
  }

  double _calculateTotalWithInterest(int months) {
    double interestRate;
    switch (months) {
      case 3:
        interestRate = 0.10;
        break;
      case 6:
        interestRate = 0.15;
        break;
      case 9:
        interestRate = 0.20;
        break;
      case 12:
        interestRate = 0.30;
        break;
      default:
        interestRate = 0.10;
    }
    
    return widget.totalAmount * (1 + interestRate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Muddatli to\'lov'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardBackgroundDark
                  : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: CustomIcon(
              name: 'back',
              size: 20,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Products section
                  Container(
                    padding: EdgeInsets.all(16.w),
                    color: isDark ? Colors.grey[900] : Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanlangan mahsulotlar',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...widget.items.map((cartItem) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: cartItem.item.images.isNotEmpty
                                    ? Image.network(
                                        cartItem.item.images.first,
                                        width: 60.w,
                                        height: 60.h,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 60.w,
                                            height: 60.h,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 60.w,
                                        height: 60.h,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image),
                                      ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.item.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${cartItem.quantity} ta',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,###', 'en_US').format((cartItem.item.finalPrice * cartItem.quantity).round()).replaceAll(',', ' ')} so\'m',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        )),
                        Divider(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jami summa:',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###', 'en_US').format(widget.totalAmount.round()).replaceAll(',', ' ')} so\'m',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Installment options section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muddatni tanlang',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // Month options
                        _buildMonthOption(3),
                        SizedBox(height: 12.h),
                        _buildMonthOption(6),
                        SizedBox(height: 12.h),
                        _buildMonthOption(9),
                        SizedBox(height: 12.h),
                        _buildMonthOption(12),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          
          // Bottom summary section
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Oylik to\'lov:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###', 'en_US').format(_calculateMonthlyPayment(_selectedMonths).round()).replaceAll(',', ' ')} so\'m',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jami to\'lov:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###', 'en_US').format(_calculateTotalWithInterest(_selectedMonths).round()).replaceAll(',', ' ')} so\'m',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'months': _selectedMonths,
                          'monthlyPayment': _calculateMonthlyPayment(_selectedMonths),
                          'totalAmount': _calculateTotalWithInterest(_selectedMonths),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthOption(int months) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedMonths == months;
    final monthlyPayment = _calculateMonthlyPayment(months);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMonths = months;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withOpacity(0.1)
              : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.gold : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? AppColors.gold : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16.sp,
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$months oy',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.gold
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${NumberFormat('#,###', 'en_US').format(monthlyPayment.round()).replaceAll(',', ' ')} so\'m/oy',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
