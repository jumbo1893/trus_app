
class ServerException implements Exception {
  String cause;

  ServerException([this.cause = 'Nelze načíst data z důvodu chyby na straně serveru']);

  @override
  String toString() {
    return cause;
  }
}