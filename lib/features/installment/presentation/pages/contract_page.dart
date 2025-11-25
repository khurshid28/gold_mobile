import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';

class ContractPage extends StatefulWidget {
  final String productName;
  final double productPrice;
  final int selectedMonths;
  final double monthlyPayment;
  final VoidCallback onAgree;

  const ContractPage({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.selectedMonths,
    required this.monthlyPayment,
    required this.onAgree,
  });

  @override
  State<ContractPage> createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: CustomIcon(
              name: 'back',
              size: 20,
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
        ),
        title: const Text('Bo\'lib to\'lash shartnomasi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    isDark,
                  ),
                  
                  _buildContractSection(
                    '2. TO\'LOV SHARTLARI',
                    'Umumiy summa: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.productPrice)} so\'m\n'
                    'Muddat: ${widget.selectedMonths} oy\n'
                    'Oylik to\'lov: ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(widget.monthlyPayment)} so\'m\n'
                    'Boshlang\'ich to\'lov: Yo\'q\n'
                    'Foiz stavkasi: 0%',
                    isDark,
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
                    isDark,
                  ),
                  
                  _buildContractSection(
                    '4. TO\'LOVNI KECHIKTIRISH',
                    'Agar Xaridor oylik to\'lovni 5 kundan ortiq kechiktirsa, har bir kechiktirilgan kun uchun 0.1% miqdorida jarima to\'lanadi. 30 kundan ortiq kechiktirish shartnomani bekor qilish uchun asos bo\'ladi.',
                    isDark,
                  ),
                  
                  _buildContractSection(
                    '5. SHARTNOMANI BEKOR QILISH',
                    'Shartnoma quyidagi hollarda bekor qilinishi mumkin:\n'
                    '- Xaridor tomonidan to\'lovlarni 30 kundan ortiq kechiktirish\n'
                    '- Mahsulotga qasddan zarar yetkazish\n'
                    '- Ikki tomonning kelishuviga ko\'ra\n\n'
                    'Shartnoma bekor qilinganda, Xaridor to\'lagan summalar qaytarilmaydi va mahsulot Sotuvchiga qaytarilishi lozim.',
                    isDark,
                  ),
                  
                  _buildContractSection(
                    '6. NIZOLARNI HAL QILISH',
                    'Tomonlar o\'rtasida kelib chiqadigan barcha nizolar muzokaralar yo\'li bilan hal qilinadi. Kelishuvga erishilmagan taqdirda, nizolar O\'zbekiston Respublikasi qonunchiligiga muvofiq sud tartibida hal qilinadi.',
                    isDark,
                  ),
                  
                  _buildContractSection(
                    '7. YAKUNIY QOIDALAR',
                    'Ushbu shartnoma elektron shaklda imzolangan va ikki tomonning manfaatlarini himoya qiladi. Shartnoma to\'liq to\'lovlar amalga oshirilgandan so\'ng o\'z kuchini yo\'qotadi.',
                    isDark,
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
                        CustomIcon(
                          name: 'info',
                          color: AppColors.gold,
                          size: 24,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Shartnomani oxirigacha o\'qib chiqing va "Roziman" tugmasini bosing',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 100.h), // Space for bottom button
                ],
              ),
            ),
          ),
          
          // Bottom buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
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
                          CustomIcon(
                            name: 'info',
                            color: AppColors.warning,
                            size: 20,
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
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _hasScrolledToBottom
                          ? () {
                              Navigator.pop(context);
                              widget.onAgree();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: const Text('Roziman va davom etish'),
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

  Widget _buildContractSection(String title, String content, bool isDark) {
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
              color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: isDark ? AppColors.textMediumOnDark : AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
