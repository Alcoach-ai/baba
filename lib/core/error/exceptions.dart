class CacheException implements Exception {
  final String? message;

  CacheException([this.message]);

  @override
  String toString() => message ?? 'CacheException';
}

class ServerException implements Exception {}

class NetworkException implements Exception {}
