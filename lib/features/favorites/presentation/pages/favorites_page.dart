import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For demo purposes, showing empty state
    // In real app, check if favorites exist
    const bool hasFavorites = false;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
        centerTitle: true,
      ),
      body: hasFavorites
          ? _buildFavoriteItems()
          : const EmptyStateWidget(
              svgPath: 'assets/images/empty_favorites.svg',
              title: 'Sevimlilar bo\'sh',
              message: 'Siz hali hech qanday mahsulotni sevimlilarga qo\'shmadingiz.\nYoqtirgan mahsulotlaringizni saqlang!',
              actionText: 'Katalogni ko\'rish',
            ),
    );
  }

  Widget _buildFavoriteItems() {
    return const Center(child: Text('Favorite items'));
  }
}
