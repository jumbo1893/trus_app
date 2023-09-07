
abstract class JsonAndHttpConverter {
  Map<String, dynamic> toJson();
  JsonAndHttpConverter.fromJson(Map<String, dynamic> json);
  ///cesta k této třídě pro server
  ///pokud bychom chtěli odeslat req na 1.1.1.1.com/{class}/add
  String httpRequestClass();
}