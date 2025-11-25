import 'package:equatable/equatable.dart';
import 'package:gold_mobile/features/home/domain/entities/category.dart';
import 'package:gold_mobile/features/home/domain/entities/jewelry_item.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Category> categories;
  final List<JewelryItem> featuredItems;
  final List<JewelryItem> newArrivals;
  final List<JewelryItem> bestSellers;

  const HomeLoaded({
    required this.categories,
    required this.featuredItems,
    required this.newArrivals,
    required this.bestSellers,
  });

  @override
  List<Object?> get props => [categories, featuredItems, newArrivals, bestSellers];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
