import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_icon.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/utils/mock_data.dart';
import '../../../home/domain/entities/jewelry_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  RangeValues _priceRange = const RangeValues(0, 50000000);
  String _sortBy = 'popular'; // popular, price_asc, price_desc, newest
  List<JewelryItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  void _loadAllItems() {
    setState(() {
      _searchResults = MockData.jewelryItems;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<JewelryItem> results = List.from(MockData.jewelryItems);

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      results = results.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      final categoryName = _categoryLabels[_selectedCategory] ?? '';
      results = results.where((item) => item.category == categoryName).toList();
    }

    // Filter by price range
    results = results.where((item) {
      return item.price >= _priceRange.start && item.price <= _priceRange.end;
    }).toList();

    // Sort results
    switch (_sortBy) {
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        results.sort((a, b) => (b.id).compareTo(a.id));
        break;
      case 'popular':
      default:
        results.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    setState(() {
      _searchResults = results;
    });
  }

  final List<String> _categories = [
    'all',
    'ring',
    'necklace',
    'earring',
    'bracelet',
    'pendant',
    'set',
  ];

  final Map<String, String> _categoryLabels = {
    'all': 'Barchasi',
    'ring': 'Uzuklar',
    'necklace': 'Zanjirlar',
    'earring': 'Sirg\'alar',
    'bracelet': 'Bilakuzuklar',
    'pendant': 'Kulonlar',
    'set': 'To\'plamlar',
  };

  @override
  void dispose() {
    _searchController.dispose();
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
        title: const Text('Qidiruv'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Mahsulot qidirish...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: const CustomIcon(name: 'search', size: 20, color: AppColors.gold),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const CustomIcon(name: 'close', size: 20),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLG.r),
                  borderSide: BorderSide(color: AppColors.gold, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _applyFiltersAndSort();
                });
              },
            ),
          ),
          
          // Filters
          Container(
            padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM.h),
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
            child: Column(
              children: [
                // Category filters
                SizedBox(
                  height: 38.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD.w),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => SizedBox(width: AppSizes.paddingSM.w),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      
                      return _FilterChip(
                        label: _categoryLabels[category]!,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _applyFiltersAndSort();
                          });
                        },
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSizes.paddingSM.h),
                
                // Sort and Price filter buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showSortBottomSheet(context, isDark),
                          icon: const CustomIcon(name: 'sort', size: 18),
                          label: Text(
                            _getSortLabel(),
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.paddingSM.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showPriceFilterBottomSheet(context, isDark),
                          icon: const CustomIcon(name: 'filter', size: 18),
                          label: Text(
                            'Narx',
                            style: TextStyle(fontSize: 13.sp),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search results
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIcon(
                          name: 'search_empty',
                          size: 80,
                          color: isDark
                              ? AppColors.textMediumOnDark.withOpacity(0.4)
                              : AppColors.textMedium.withOpacity(0.4),
                        ),
                        SizedBox(height: AppSizes.paddingXL.h),
                        Text(
                          'Hech narsa topilmadi',
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
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
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

  String _getSortLabel() {
    switch (_sortBy) {
      case 'popular':
        return 'Mashhur';
      case 'price_asc':
        return 'Arzon';
      case 'price_desc':
        return 'Qimmat';
      case 'newest':
        return 'Yangi';
      default:
        return 'Saralash';
    }
  }

  void _showSortBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSizes.paddingMD.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saralash',
              style: TextStyle(
                fontSize: AppSizes.fontXL.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
              ),
            ),
            SizedBox(height: AppSizes.paddingMD.h),
            _SortOption(
              label: 'Mashhur',
              value: 'popular',
              selectedValue: _sortBy,
              onTap: () {
                setState(() {
                  _sortBy = 'popular';
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
            _SortOption(
              label: 'Arzon narxdan',
              value: 'price_asc',
              selectedValue: _sortBy,
              onTap: () {
                setState(() {
                  _sortBy = 'price_asc';
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
            _SortOption(
              label: 'Qimmat narxdan',
              value: 'price_desc',
              selectedValue: _sortBy,
              onTap: () {
                setState(() {
                  _sortBy = 'price_desc';
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
            _SortOption(
              label: 'Yangi mahsulotlar',
              value: 'newest',
              selectedValue: _sortBy,
              onTap: () {
                setState(() {
                  _sortBy = 'newest';
                  _applyFiltersAndSort();
                });
                Navigator.pop(context);
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceFilterBottomSheet(BuildContext context, bool isDark) {
    RangeValues tempRange = _priceRange;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(AppSizes.paddingMD.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Narx oralig\'i',
                style: TextStyle(
                  fontSize: AppSizes.fontXL.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkOnDark : AppColors.textDark,
                ),
              ),
              SizedBox(height: AppSizes.paddingMD.h),
              
              // Price display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tempRange.start == 0
                      ? '0'
                      : tempRange.start >= 1000000 
                        ? '${(tempRange.start / 1000000).toStringAsFixed(1)} mln'
                        : '${(tempRange.start / 1000).toStringAsFixed(0)} ming',
                    style: TextStyle(
                      fontSize: AppSizes.fontMD.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    tempRange.end >= 1000000
                      ? '${(tempRange.end / 1000000).toStringAsFixed(1)} mln'
                      : '${(tempRange.end / 1000).toStringAsFixed(0)} ming',
                    style: TextStyle(
                      fontSize: AppSizes.fontMD.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              
              // Range slider
              RangeSlider(
                values: tempRange,
                min: 0,
                max: 50000000,
                divisions: 500,
                activeColor: AppColors.gold,
                onChanged: (values) {
                  setModalState(() {
                    tempRange = values;
                  });
                },
              ),
              SizedBox(height: AppSizes.paddingMD.h),
              
              // Apply button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _priceRange = tempRange;
                      _applyFiltersAndSort();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.paddingMD.h),
                  ),
                  child: const Text('Qo\'llash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.gold 
              : (isDark ? AppColors.cardBackgroundDark : AppColors.cardBackgroundLight),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull.r),
          border: Border.all(
            color: isSelected ? AppColors.gold : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected 
                ? Colors.white 
                : (isDark ? AppColors.textDarkOnDark : AppColors.textDark),
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;
  final bool isDark;

  const _SortOption({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppSizes.paddingMD.h,
          horizontal: AppSizes.paddingSM.w,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.fontMD.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                      ? AppColors.gold 
                      : (isDark ? AppColors.textDarkOnDark : AppColors.textDark),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.gold,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
