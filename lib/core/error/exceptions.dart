import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final String? message;

  const ServerException([this.message]);

  @override
  List<Object?> get props => [message];

  @override
  String toString() {
    return '$message';
  }
}

class FetchDataException extends ServerException {
  const FetchDataException([String? message])
    : super(message ?? "Error During Communication");
}

class BadRequestException extends ServerException {
  const BadRequestException([String? message])
    : super(message ?? "Bad Request");
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException([String? message])
    : super(message ?? "Unauthorized");
}

class NotFoundException extends ServerException {
  const NotFoundException([String? message])
    : super(message ?? "Requested Info Not Found");
}

class ConflictException extends ServerException {
  const ConflictException([String? message])
    : super(message ?? "Conflict Occurred");
}

class InternalServerErrorException extends ServerException {
  const InternalServerErrorException([String? message])
    : super(message ?? "Internal Server Error");
}

class NoInternetConnectionException extends ServerException {
  const NoInternetConnectionException([String? message])
    : super(message ?? "No Internet Connection");
}

class CacheException implements Exception {}
