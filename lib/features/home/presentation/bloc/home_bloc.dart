import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gold_mobile/core/utils/mock_data.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_event.dart';
import 'package:gold_mobile/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    try {
      emit(HomeLoaded(
        categories: MockData.categories,
        featuredItems: MockData.featuredItems,
        newArrivals: MockData.newArrivals,
        bestSellers: MockData.bestSellers,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    try {
      emit(HomeLoaded(
        categories: MockData.categories,
        featuredItems: MockData.featuredItems,
        newArrivals: MockData.newArrivals,
        bestSellers: MockData.bestSellers,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
