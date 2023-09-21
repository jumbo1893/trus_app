class LoginExpiredException implements Exception {
  String cause;

  LoginExpiredException([this.cause = 'Vypršela session, znovu přihlašuji...']);

  @override
  String toString() {
    return cause;
  }
}