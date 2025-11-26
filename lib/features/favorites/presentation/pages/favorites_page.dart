import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/mock_data.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is FavoritesLoaded) {
            if (state.favoriteIds.isEmpty) {
              return const EmptyStateWidget(
                svgPath: 'assets/images/empty_favorites.svg',
                title: 'Sevimlilar bo\'sh',
                message: 'Siz hali hech qanday mahsulotni sevimlilarga qo\'shmadingiz.\\nYoqtirgan mahsulotlaringizni saqlang!',
                actionText: 'Katalogni ko\'rish',
              );
            }
            
            // Get all items and filter favorites
            final allItems = MockData.jewelryItems;
            final favoriteItems = allItems.where((item) => 
              state.favoriteIds.contains(item.id)
            ).toList();
            
            return GridView.builder(
              padding: EdgeInsets.all(AppSizes.paddingMD.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return ProductCard(
                  item: item,
                  onTap: () {
                    context.push('/product-detail', extra: item);
                  },
                );
              },
            );
          }
          
          return const Center(child: Text('Xatolik yuz berdi'));
        },
      ),
    );
  }
}
