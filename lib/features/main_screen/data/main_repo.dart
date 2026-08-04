import '../../../core/exports.dart';
import 'model/product_model.dart';

class MainRepo {
  BaseApiConsumer api;
  MainRepo(this.api);

  Future<Either<Failure, List<ProductModel>>> getProducts() async {
    try {
      final response = await api.get("https://fakestoreapi.com/products");
      final List<ProductModel> products = (response as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return Right(products);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
