import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/common/utils/utils.dart';
import 'package:trus_app/features/pkfl/exception/bad_format_exception.dart';
import 'package:trus_app/features/pkfl/exception/pkfl_unavailable_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_match.dart';
import 'package:trus_app/models/pkfl/pkfl_match_detail.dart';

import '../../../models/pkfl/pkfl_match_player.dart';

class RetrieveMatchDetailTask {
  final String matchUrl;

  RetrieveMatchDetailTask(this.matchUrl);

  Future<PkflMatchDetail> returnPkflMatchDetail() async {
    http.Response response = await http.Client().get(Uri.parse(matchUrl));
    validateStatusCode(response.statusCode);
    try {
      var document = parse(response.body);
      var matches = document.getElementsByClassName(
          "matches");
      var ps = matches[0].querySelectorAll("p");
      var tables = document.getElementsByClassName("dataTable table table-striped no-footer");
      PkflMatchDetail pkflMatchDetail = PkflMatchDetail(getRefereeComment(ps), getPlayersFromMatch(getTrsFromTables(tables,isHomeMatch(ps))));
      return pkflMatchDetail;
    } on BadFormatException {
      rethrow;
    } catch (e) {
      throw BadFormatException();
    }
  }

  String getRefereeComment(List<Element> ps) {
    if (ps.length > 6 && ps[6].text.toLowerCase().contains("komentář")) {
      return ps[6].text.replaceAll("  ", "");
    }
    return "Bez komentáře rozhodčího";
  }

  bool isHomeMatch(List<Element> ps) {
    String name = ps[0].text.split("/")[1].trim().toLowerCase();
    return name != ("liščí trus");
  }

  List<PkflMatchPlayer> getPlayersFromMatch(List<Element> trs) {
    List<PkflMatchPlayer> players = [];

    for (Element tr in trs) {
      List<Element> tds = tr.querySelectorAll("td");
      if (tds.length > 6) {
        players.add(_initPlayerFromTds(tds));
      }
    }
    return players;
  }

  List<Element> getTrsFromTables(List<Element> tables, bool homeMatch) {
    if (homeMatch) {
      return tables[0].querySelectorAll("tr");
    }
    else {
      return tables[1].querySelectorAll("tr");
    }
  }

  PkflMatchPlayer _initPlayerFromTds(List<Element> tds) {

    try {
      PkflMatchPlayer pkflMatchPlayer = PkflMatchPlayer(tds[0].text.trim(), int.parse(tds[1].text.trim()), int.parse(tds[2].text.trim()), int.parse(tds[3].text.trim()),
          getNumbersFromString(tds[4].text.trim()), int.parse(tds[5].text.trim()), int.parse(tds[6].text.trim()), isBestPlayer(tds[0]));
      if (pkflMatchPlayer.yellowCards > 0) {
        pkflMatchPlayer.yellowCardComment = (returnCardComment(tds[5]));
      }
      if (pkflMatchPlayer.redCards > 0) {
        pkflMatchPlayer.redCardComment = (returnCardComment(tds[6]));
      }
      return pkflMatchPlayer;
    } catch (e) {
      throw BadFormatException();
    }

  }

  String returnCardComment(Element td) {
    try {
      String comment = td.getElementsByTagName("a") .where((e) => e.attributes.containsKey('title'))
          .map((e) => e.attributes['href']).first!;
      return comment;
    }
    catch (e) {
    return "chyba při načítání komentu";
    }

  }

  int getNumbersFromString(String number) {
    return int.parse(number.replaceAll(RegExp("[^0-9]"), ""));
  }

  bool isBestPlayer(Element tdName) {
    List<Element> elements = tdName.getElementsByClassName("best-player");
    return elements.isNotEmpty;
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
