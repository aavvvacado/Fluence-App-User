// Custom exceptions for handling errors in the Data Layer

/// Generic exception for server-related issues (e.g., 404, 500 status codes).
class ServerException implements Exception {
  final String message;

  const ServerException({this.message = 'A server error occurred.'});

  @override
  String toString() => 'ServerException: $message';
}

/// Generic exception for local cache or storage issues.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'A cache error occurred.'});

  @override
  String toString() => 'CacheException: $message';
}
