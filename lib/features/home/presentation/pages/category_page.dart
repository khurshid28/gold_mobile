import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gold_mobile/core/constants/app_colors.dart';
import 'package:gold_mobile/core/widgets/custom_icon.dart';
import 'package:gold_mobile/core/widgets/product_card.dart';
import 'package:gold_mobile/features/home/domain/entities/category.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';
import 'package:gold_mobile/core/utils/mock_data.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<JewelryItem> _items = [];
  String _sortBy = 'featured';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    // Filter items by category
    final allItems = MockData.jewelryItems;
    setState(() {
      _items = allItems
          .where((item) => item.category == widget.category.name)
          .toList();
      _sortItems();
    });
  }

  void _sortItems() {
    setState(() {
      switch (_sortBy) {
        case 'price_low':
          _items.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _items.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name':
          _items.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'featured':
        default:
          _items.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saralash',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16.h),
              _SortOption(
                label: 'Tavsiya etilgan',
                value: 'featured',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortItems();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Narx: Arzon',
                value: 'price_low',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortItems();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Narx: Qimmat',
                value: 'price_high',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortItems();
                  });
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Nomi bo\'yicha',
                value: 'name',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _sortItems();
                  });
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
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
        title: Text(widget.category.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const CustomIcon(name: 'search', size: 24),
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category header with image
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(width: 20.w),
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.category.iconPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark
                              ? AppColors.cardBackgroundDark
                              : AppColors.cardBackgroundLight,
                          child: const Icon(
                            Icons.image_rounded,
                            color: AppColors.gold,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textDarkOnDark
                              : AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${_items.length} mahsulot',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.textLightOnDark
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w),
              ],
            ),
          ),

          // Filter and sort bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_items.length} ta mahsulot topildi',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textDarkOnDark
                          : AppColors.textDark,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort_rounded, size: 20),
                  label: const Text('Saralash'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.gold),
                ),
              ],
            ),
          ),

          // Products grid
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64.sp,
                          color: isDark
                              ? AppColors.textLightOnDark
                              : AppColors.textLight,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Mahsulot topilmadi',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: isDark
                                ? AppColors.textMediumOnDark
                                : AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ProductCard(
                        item: item,
                        onTap: () {
                          context.push('/product-detail', extra: item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SortOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.gold,
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.gold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
