import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:trus_app/features/pkfl/exception/bad_format_exception.dart';
import 'package:trus_app/features/pkfl/exception/pkfl_unavailable_exception.dart';
import 'package:trus_app/models/pkfl/pkfl_season.dart';

class RetrieveSeasonUrlTask {
  final String pkflUrl;
  final bool currentSeason;
  static const String baseUrl = "https://pkfl.cz";

  RetrieveSeasonUrlTask(this.pkflUrl, this.currentSeason);

  Future<List<PkflSeason>> returnPkflSeasons() async {
    http.Response response = await http.Client().get(Uri.parse(pkflUrl));
    List<PkflSeason> pkflSeasons = [];
    validateStatusCode(response.statusCode);
    try {
      var document = parse(response.body);
      var matchesSpinnerDiv = document.getElementsByClassName(
          "dropdown-content")[0];
      var spinnerSeasons = matchesSpinnerDiv.querySelectorAll("a[href]");
      if(currentSeason) {
        for (var spinnerButton in spinnerSeasons) {
          var seasonButton = document.getElementsByClassName("dropbtn")[0];
          if(spinnerButton.text.contains(_getCurrentSeason(seasonButton))) {
            pkflSeasons.add(_returnPkflSeason(spinnerButton));
          }
        }
      }
      else {
        for (Element spinnerButton in spinnerSeasons) {
          pkflSeasons.add(_returnPkflSeason(spinnerButton));
        }
      }
      return pkflSeasons;
    } on BadFormatException {
      rethrow;
    } catch (e, stacktrace) {
      print(stacktrace);
      throw BadFormatException();
    }
  }

  String _getCurrentSeason(Element button) {
    return button.text.split(" ")[0].trim().toLowerCase();
  }

  PkflSeason _returnPkflSeason(Element spinnerButton) {
      return PkflSeason(baseUrl + spinnerButton.attributes['href'].toString(), spinnerButton.text);
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
