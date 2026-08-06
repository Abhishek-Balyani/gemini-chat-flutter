import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your internet network.',
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;
        String errorMessage = 'Server returned error ($statusCode)';

        if (responseData is Map && responseData.containsKey('error')) {
          final errorObj = responseData['error'];
          if (errorObj is Map && errorObj.containsKey('message')) {
            errorMessage = errorObj['message'].toString();
          }
        }

        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          data: responseData,
        );

      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Unable to connect to Gemini servers. Check connection.',
        );

      default:
        return ApiException(
          message: dioException.message ?? 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
