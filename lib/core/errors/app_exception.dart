class AppException implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final Map<String, String>? fieldErrors;

  @override
  String toString() => 'AppException($statusCode): $message';
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.fieldErrors})
      : super(statusCode: 400);
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class ConflictException extends AppException {
  const ConflictException({required super.message}) : super(statusCode: 409);
}

class ForbiddenException extends AppException {
  const ForbiddenException({required super.message}) : super(statusCode: 403);
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}
