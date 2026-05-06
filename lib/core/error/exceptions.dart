class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});
}

class NetworkException implements Exception {
  const NetworkException();
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
