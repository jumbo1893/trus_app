
class JsonDecodeException implements Exception {
  String cause;

  JsonDecodeException([this.cause = 'Chyba při odesílání požadavku']);

  @override
  String toString() {
    return cause;
  }
}