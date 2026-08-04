// abstract class ApiResult<L, R> {
//   const ApiResult();

//   factory ApiResult.failure(L value) = Failure<L, R>;
//   factory ApiResult.success(R value) = Success<L, R>;

//   T fold<T>(T Function(L) onFailure, T Function(R) onSuccess);
// }

// class Failure<L, R> extends ApiResult<L, R> {
//   final L value;
//   const Failure(this.value);

//   @override
//   T fold<T>(T Function(L) onFailure, T Function(R) onSuccess) =>
//       onFailure(value);
// }

// class Success<L, R> extends ApiResult<L, R> {
//   final R value;
//   const Success(this.value);

//   @override
//   T fold<T>(T Function(L) onFailure, T Function(R) onSuccess) =>
//       onSuccess(value);
// }
