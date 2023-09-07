
class PkflUnavailableException implements Exception {
  String cause;

  PkflUnavailableException([this.cause = 'Web PKFL je nedostupný']);

  @override
  String toString() {
    return cause;
  }
}