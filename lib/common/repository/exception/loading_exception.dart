
class LoadingException implements Exception {
  String cause;

  LoadingException([this.cause = 'Načítám...']);

  @override
  String toString() {
    return cause;
  }
}