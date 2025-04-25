
class ClientTimeoutException implements Exception {
  String cause;

  ClientTimeoutException([this.cause = 'Request byl přerušen kvůli timeoutu a zkusí se znovu po návratu z pozadí.']);

  @override
  String toString() {
    return cause;
  }
}