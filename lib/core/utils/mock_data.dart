import 'package:gold_mobile/core/constants/app_strings.dart';
import 'package:gold_mobile/features/home/domain/entities/category.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';

class MockData {
  MockData._();

  // Categories
  static final List<Category> categories = [
    const Category(
      id: '1',
      name: AppStrings.rings,
      iconPath: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=400&h=400&fit=crop',
      itemCount: 45,
    ),
    const Category(
      id: '2',
      name: AppStrings.necklaces,
      iconPath: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=400&h=400&fit=crop',
      itemCount: 32,
    ),
    const Category(
      id: '3',
      name: AppStrings.earrings,
      iconPath: 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=400&h=400&fit=crop',
      itemCount: 56,
    ),
    const Category(
      id: '4',
      name: AppStrings.bracelets,
      iconPath: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=400&h=400&fit=crop',
      itemCount: 28,
    ),
    const Category(
      id: '5',
      name: AppStrings.pendants,
      iconPath: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400&h=400&fit=crop',
      itemCount: 38,
    ),
    const Category(
      id: '6',
      name: AppStrings.sets,
      iconPath: 'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=400&h=400&fit=crop',
      itemCount: 15,
    ),
  ];

  // Jewelry Items
  static final List<JewelryItem> jewelryItems = [
    const JewelryItem(
      id: '1',
      name: 'Zarhal oltin uzuk',
      description: '585 probali oltin uzukda noyob zarhal toshlar bilan bezatilgan. Klassik dizayn va yuqori sifatli ishlash. Har qanday bayramingizga ajoyib sovg\'a.',
      price: 12500000,
      category: AppStrings.rings,
      images: [
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500',
        'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500',
        'https://images.unsplash.com/photo-1602173574767-37ac01994b2a?w=500',
      ],
      material: '585 probali oltin',
      weight: 4.5,
      inStock: true,
      discount: 15,
      reviewCount: 28,
      rating: 4.8,
    ),
    const JewelryItem(
      id: '2',
      name: 'Brilyantli oltin marjon',
      description: 'Nozik brilyant toshlari bilan bezatilgan 18K oltin marjon. Klassik dizaynda tayyorlangan bu marjon har qanday kiyimga mos keladi.',
      price: 35000000,
      category: AppStrings.necklaces,
      images: [
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500',
      ],
      material: '750 probali oltin',
      weight: 12.8,
      inStock: true,
      reviewCount: 45,
      rating: 4.9,
    ),
    const JewelryItem(
      id: '3',
      name: 'Zamonaviy oltin sirg\'alar',
      description: 'Zamonaviy uslubda ishlangan oltin sirg\'alar. Har kunlik kiyish uchun juda qulay va chiroyli.',
      price: 8500000,
      category: AppStrings.earrings,
      images: [
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500',
        'https://images.unsplash.com/photo-1617038220319-276d3cfab638?w=500',
      ],
      material: '585 probali oltin',
      weight: 3.2,
      inStock: true,
      discount: 10,
      reviewCount: 34,
      rating: 4.7,
    ),
    const JewelryItem(
      id: '4',
      name: 'Naqshli oltin bilaguzuk',
      description: 'An\'anaviy o\'zbek naqshlari bilan bezatilgan oltin bilaguzuk. Noyob dizayn va yuqori sifatli ishlash.',
      price: 15500000,
      category: AppStrings.bracelets,
      images: [
        'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500',
        'https://images.unsplash.com/photo-1573408301185-9146fe634ad0?w=500',
      ],
      material: '585 probali oltin',
      weight: 8.5,
      inStock: true,
      reviewCount: 22,
      rating: 4.6,
    ),
    const JewelryItem(
      id: '5',
      name: 'Yashil zumrad uzuk',
      description: 'Tabiiy zumrad toshi bilan bezatilgan noyob oltin uzuk. Kolumbiya zumradi ishlatilgan.',
      price: 28000000,
      category: AppStrings.rings,
      images: [
        'https://images.unsplash.com/photo-1603561596112-0a132b757442?w=500',
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500',
      ],
      material: '750 probali oltin',
      weight: 5.8,
      inStock: true,
      discount: 20,
      reviewCount: 51,
      rating: 5.0,
    ),
    const JewelryItem(
      id: '6',
      name: 'Oltin to\'plam',
      description: 'Sirg\'a, uzuk va marjondan iborat to\'liq to\'plam. Bir xil dizaynda tayyorlangan.',
      price: 45000000,
      category: AppStrings.sets,
      images: [
        'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?w=500',
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
        'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?w=500',
      ],
      material: '585 probali oltin',
      weight: 18.5,
      inStock: true,
      reviewCount: 38,
      rating: 4.9,
    ),
    const JewelryItem(
      id: '7',
      name: 'Zarquyosh oqqoshiq uzuk',
      description: 'Klassik uslubda ishlangan oqqoshiq uzuk. Zarquyosh toshlar bilan bezatilgan.',
      price: 9500000,
      category: AppStrings.rings,
      images: [
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=500',
      ],
      material: '585 probali oltin',
      weight: 4.2,
      inStock: false,
      reviewCount: 18,
      rating: 4.5,
    ),
    const JewelryItem(
      id: '8',
      name: 'Brilyantli osma',
      description: 'Markazida katta brilyant toshi bo\'lgan oltin osma. Ajoyib sovg\'a.',
      price: 18500000,
      category: AppStrings.pendants,
      images: [
        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500',
        'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=500',
      ],
      material: '750 probali oltin',
      weight: 6.5,
      inStock: true,
      discount: 12,
      reviewCount: 42,
      rating: 4.8,
    ),
  ];

  // Featured items
  static List<JewelryItem> get featuredItems {
    return jewelryItems.where((item) => item.discount != null && item.discount! > 0).toList();
  }

  // New arrivals
  static List<JewelryItem> get newArrivals {
    return jewelryItems.take(4).toList();
  }

  // Best sellers
  static List<JewelryItem> get bestSellers {
    final sorted = List<JewelryItem>.from(jewelryItems);
    sorted.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(4).toList();
  }

  // Get items by category
  static List<JewelryItem> getItemsByCategory(String category) {
    return jewelryItems.where((item) => item.category == category).toList();
  }
}
