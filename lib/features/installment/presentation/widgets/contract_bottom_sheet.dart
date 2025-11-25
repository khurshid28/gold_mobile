import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class ContractBottomSheet extends StatefulWidget {
  final String productName;
  final double productPrice;
  final int selectedMonths;
  final double monthlyPayment;
  final bool isDark;
  final VoidCallback onAgree;

  const ContractBottomSheet({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.selectedMonths,
    required this.monthlyPayment,
    required this.isDark,
    required this.onAgree,
  });

  @override
  State<ContractBottomSheet> createState() => _ContractBottomSheetState();
}

class _ContractBottomSheetState extends State<ContractBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  color: AppColors.gold,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Bo\'lib to\'lash shartnomasi',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: widget.isDark ? AppColors.dividerDark : AppColors.dividerLight),
          
          // Contract content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContractSection(
                    '1. SHARTNOMA PREDMETI',
                    'Ushbu shartnoma bo\'yicha Sotuvchi Xaridorga "${widget.productName}" mahsulotini ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.productPrice)} so\'m qiymatda bo\'lib to\'lash asosida sotadi.',
                  ),
                  
                  _buildContractSection(
                    '2. TO\'LOV SHARTLARI',
                    'Umumiy summa: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.productPrice)} so\'m\n'
                    'Muddat: ${widget.selectedMonths} oy\n'
                    'Oylik to\'lov: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.monthlyPayment)} so\'m\n'
                    'Boshlang\'ich to\'lov: Yo\'q\n'
                    'Foiz stavkasi: 0%',
                  ),
                  
                  _buildContractSection(
                    '3. TOMONLARNING HUQUQ VA MAJBURIYATLARI',
                    'Sotuvchi majburiyatlari:\n'
                    '- Mahsulotni belgilangan muddatda yetkazib berish\n'
                    '- Mahsulot sifatiga kafolat berish\n'
                    '- To\'lov grafikni vaqtida yuborish\n\n'
                    'Xaridor majburiyatlari:\n'
                    '- Oylik to\'lovlarni o\'z vaqtida amalga oshirish\n'
                    '- Mahsulotga ehtiyotkorlik bilan munosabatda bo\'lish\n'
                    '- Shartnoma shartlariga rioya qilish',
                  ),
                  
                  _buildContractSection(
                    '4. TO\'LOVNI KECHIKTIRISH',
                    'Agar Xaridor oylik to\'lovni 5 kundan ortiq kechiktirsa, har bir kechiktirilgan kun uchun 0.1% miqdorida jarima to\'lanadi. 30 kundan ortiq kechiktirish shartnomani bekor qilish uchun asos bo\'ladi.',
                  ),
                  
                  _buildContractSection(
                    '5. SHARTNOMANI BEKOR QILISH',
                    'Shartnoma quyidagi hollarda bekor qilinishi mumkin:\n'
                    '- Xaridor tomonidan to\'lovlarni 30 kundan ortiq kechiktirish\n'
                    '- Mahsulotga qasddan zarar yetkazish\n'
                    '- Ikki tomonning kelishuviga ko\'ra\n\n'
                    'Shartnoma bekor qilinganda, Xaridor to\'lagan summalar qaytarilmaydi va mahsulot Sotuvchiga qaytarilishi lozim.',
                  ),
                  
                  _buildContractSection(
                    '6. NIZOLARNI HAL QILISH',
                    'Tomonlar o\'rtasida kelib chiqadigan barcha nizolar muzokaralar yo\'li bilan hal qilinadi. Kelishuvga erishilmagan taqdirda, nizolar O\'zbekiston Respublikasi qonunchiligiga muvofiq sud tartibida hal qilinadi.',
                  ),
                  
                  _buildContractSection(
                    '7. YAKUNIY QOIDALAR',
                    'Ushbu shartnoma elektron shaklda imzolangan va ikki tomonning manfaatlarini himoya qiladi. Shartnoma to\'liq to\'lovlar amalga oshirilgandan so\'ng o\'z kuchini yo\'qotadi.',
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: AppColors.gold,
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Shartnomani oxirigacha o\'qib chiqing va "Roziman" tugmasini bosing',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: widget.isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hasScrolledToBottom)
                    Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            color: AppColors.warning,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Shartnomani oxirigacha o\'qing',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Bekor qilish'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _hasScrolledToBottom ? widget.onAgree : null,
                          child: const Text('Roziman'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: widget.isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: widget.isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
