import 'package:trus_app/models/api/interfaces/model_to_string.dart';
import 'package:trus_app/models/helper/title_and_text.dart';

class StatsSheetData {
  final TitleAndText header;
  final List<ModelToString> items;
  final bool showFineMatchTabs;

  const StatsSheetData({
    required this.header,
    required this.items,
    required this.showFineMatchTabs,
  });
}