import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/pkfl/exception/bad_format_exception.dart';
import 'package:trus_app/features/pkfl/exception/pkfl_unavailable_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';

class RetrieveMatchesTask {
  final String pkflUrl;

  static const String baseUrl = "https://pkfl.cz";

  RetrieveMatchesTask(this.pkflUrl);

  Future<List<PkflMatch>> returnPkflMatches() async {
    http.Response response = await http.Client().get(Uri.parse(pkflUrl));
    List<PkflMatch> pkflMatches = [];
    validateStatusCode(response.statusCode);
    try {
      var document = parse(response.body);
      var table = document.getElementsByClassName(
          "dataTable table table-bordered table-striped");
      var trs = table[0].querySelectorAll("tr");
      for (var tr in trs) {
        var tds = tr.querySelectorAll("td");
        if (tds.length > 8) {
          pkflMatches.add(returnPkflMatch(tds));
        }
      }
      return pkflMatches;
    } on BadFormatException {
      rethrow;
    } catch (e) {
      throw BadFormatException();
    }
  }

  PkflMatch returnPkflMatch(List<Element> tds) {
    bool homeMatch = isHomeMatch(tds[4].text);
    PkflMatch pkflMatch = PkflMatch(
        convertTextToDateTime(tds[0].text, tds[1].text),
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

  DateTime convertTextToDateTime(String date, String time) {
    try {
      return DateTime.parse("${date.trim()} ${time.trim()}");
    } catch (e) {
      throw BadFormatException(
          "Nelze přečíst čas zápasu, neproběhl redesign webu?");
    }
  }

  bool isHomeMatch(String homeTeam) {
    if (homeTeam.trim() == ("Liščí trus")) {
      return true;
    }
    return false;
  }

  void validateStatusCode(int value) {
    if (value == 404) {
      throw PkflUnavailableException("Chybná url pkfl web stránky");
    } else if (value == 401 || value == 403) {
      throw PkflUnavailableException("Odmítnutý přístup na pkfl web");
    } else if (value != 200) {
      throw PkflUnavailableException('Web PKFL je nedostupný. Status: $value');
    }
  }
}
