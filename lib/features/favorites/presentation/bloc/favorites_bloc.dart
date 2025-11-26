import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final SharedPreferences prefs;
  static const String _favoritesKey = 'favorite_items';

  FavoritesBloc(this.prefs) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);

    // Auto-load favorites on init
    add(LoadFavorites());
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favoritesJson = prefs.getString(_favoritesKey) ?? '[]';
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      final favoriteIds = Set<String>.from(favoritesList);
      
      emit(FavoritesLoaded(favoriteIds));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites: $e'));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentFavorites = Set<String>.from((state as FavoritesLoaded).favoriteIds);
      
      if (currentFavorites.contains(event.itemId)) {
        currentFavorites.remove(event.itemId);
      } else {
        currentFavorites.add(event.itemId);
      }

      // Save to SharedPreferences
      await prefs.setString(_favoritesKey, jsonEncode(currentFavorites.toList()));
      
      emit(FavoritesLoaded(currentFavorites));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentFavorites = Set<String>.from((state as FavoritesLoaded).favoriteIds);
      currentFavorites.remove(event.itemId);

      // Save to SharedPreferences
      await prefs.setString(_favoritesKey, jsonEncode(currentFavorites.toList()));
      
      emit(FavoritesLoaded(currentFavorites));
    }
  }
}
