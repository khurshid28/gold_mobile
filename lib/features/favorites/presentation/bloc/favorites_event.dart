import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final String itemId;

  const ToggleFavorite(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class RemoveFavorite extends FavoritesEvent {
  final String itemId;

  const RemoveFavorite(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
