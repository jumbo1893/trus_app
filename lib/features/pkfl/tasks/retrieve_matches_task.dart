import 'package:http/http.dart' as http;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import '../../general/repository/request_executor.dart';

class RetrieveMatchesTask extends RequestExecutor {
  final String pkflUrl;

  static const String baseUrl = "https://pkfl.cz";

  RetrieveMatchesTask(this.pkflUrl);

  Future<List<PkflMatch>> returnPkflMatches() async {
    http.Response response = await getClient().get(Uri.parse(pkflUrl));
    List<PkflMatch> pkflMatches = [];
    validatePkflStatusCode(response);
    try {
      var document = parse(response.body);
      var table = document.getElementsByClassName(
          "dataTable table table-bordered table-striped");
      var trs = table[0].querySelectorAll("tr");
      for (var tr in trs) {
        var tds = tr.querySelectorAll("td");
        if (tds.length > 8) {
          pkflMatches.add(_returnPkflMatch(tds));
        }
      }
      return pkflMatches;
    } on BadFormatException {
      rethrow;
    } catch (e) {
      throw BadFormatException();
    }
  }

  PkflMatch _returnPkflMatch(List<Element> tds) {
    bool homeMatch = _isHomeMatch(tds[4].text);
    PkflMatch pkflMatch = PkflMatch(
        _convertTextToDateTime(tds[0].text, tds[1].text),
        (homeMatch ? tds[5].text.trim() : tds[4].text.trim()),
        int.parse(tds[2].text.trim()),
        tds[3].text.trim(),
        tds[6].text.trim(),
        tds[7].text.trim(),
        tds[8].text.replaceAll(' ', '').replaceAll("\n", ''),
        homeMatch,
        baseUrl + tds[8].getElementsByTagName("a") .where((e) => e.attributes.containsKey('href'))
            .map((e) => e.attributes['href']).first!);
    return pkflMatch;
  }

  DateTime _convertTextToDateTime(String date, String time) {
    try {
      return DateTime.parse("${date.trim()} ${time.trim()}");
    } catch (e) {
      throw BadFormatException(
          "Nelze přečíst čas zápasu, neproběhl redesign webu?");
    }
  }

  bool _isHomeMatch(String homeTeam) {
    if (homeTeam.trim() == ("Liščí trus")) {
      return true;
    }
    return false;
  }
}
