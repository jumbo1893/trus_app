class InternalSnackBarException implements Exception {
  String cause;

  InternalSnackBarException([this.cause = 'Nelze provést operaci']);

  @override
  String toString() {
    return cause;
  }
}