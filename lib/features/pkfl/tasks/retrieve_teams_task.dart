import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:trus_app/common/repository/exception/bad_format_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_team.dart';
import '../../general/repository/request_executor.dart';

class RetrieveTeamsTask extends RequestExecutor {
  final String pkflTableUrl;

  RetrieveTeamsTask(this.pkflTableUrl);

  Future<List<PkflTeam>> returnPkflTeams() async {
    Response response = await getDioClient().get(pkflTableUrl);
    List<PkflTeam> pkflTeams = [];
    validatePkflStatusCode(response.statusCode);
    try {
      var document = parse(response.data);
      var table = document.getElementById(
          "grounds");
      var trs = table!.querySelectorAll("tr");
      for (var tr in trs) {
        var tds = tr.querySelectorAll("td");
        if (tds.length > 6) {
          pkflTeams.add(_returnPkflTeams(tds));
        }
      }
      return pkflTeams;
    } on BadFormatException {
      rethrow;
    } catch (e) {
      throw BadFormatException();
    }
  }

  PkflTeam _returnPkflTeams(List<Element> tds) {
    String longName = tds[1].text.replaceAll("\n", '').replaceAll(RegExp('\\s+'), ' ').trim();
    PkflTeam pkflTeam = PkflTeam(
        int.parse(tds[0].text.trim()),
        longName,
        //longName.substring(longName.indexOf(" ")),
        int.parse(tds[2].text.trim()),
        tds[3].text.trim(),
        tds[4].text.trim(),
        tds[5].text.trim(),
    int.parse(tds[6].text.trim()));

    return pkflTeam;
  }
}
