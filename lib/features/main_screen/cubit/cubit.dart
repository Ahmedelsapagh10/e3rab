import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/main_repo.dart';
import 'state.dart';

class MainCubit extends Cubit<MainState> {
  final MainRepo api;

  MainCubit(this.api) : super(MainInitial());

  Future<void> getProductsList() async {
    emit(MainLoading());
    final result = await api.getProducts();
    result.fold(
      (failure) => emit(MainError("Failed to load products. Please try again.")),
      (products) => emit(MainLoaded(products)),
    );
  }
}
