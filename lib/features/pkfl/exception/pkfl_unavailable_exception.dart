
class PkflUnavailableException implements Exception {
  String cause;

  PkflUnavailableException([this.cause = 'Web PKFL je nedostupnĂ˝']);

  @override
  String toString() {
    return cause;
  }
}