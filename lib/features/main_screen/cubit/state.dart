import '../data/model/product_model.dart';

abstract class MainState {}

class MainInitial extends MainState {}

class MainLoading extends MainState {}

class MainLoaded extends MainState {
  final List<ProductModel> products;
  MainLoaded(this.products);
}

class MainError extends MainState {
  final String message;
  MainError(this.message);
}
