import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/config.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/features/general/repository/request_executor.dart';

class RecapSummary {
  final int id;
  final String seasonName, from, to;
  final bool opened;
  const RecapSummary(this.id, this.seasonName, this.from, this.to, this.opened);
  factory RecapSummary.fromJson(Map<String, dynamic> json) => RecapSummary(
    (json['id'] as num).toInt(),
    json['seasonName'] as String,
    json['from'] as String,
    json['to'] as String,
    json['opened'] == true,
  );
}

class SeasonRecap {
  final String seasonName, from, to;
  final List<RecapPage> pages;
  const SeasonRecap(this.seasonName, this.from, this.to, this.pages);
  factory SeasonRecap.fromJson(Map<String, dynamic> json) => SeasonRecap(
    json['seasonName'] as String,
    json['from'] as String,
    json['to'] as String,
    (json['pages'] as List).map((p) => RecapPage.fromJson(p)).toList(),
  );
}

class RecapPage {
  final String kind, title, text;
  final List<RecapMetric> metrics;
  final List<RecapBoard> boards;
  const RecapPage(this.kind, this.title, this.text, this.metrics, this.boards);
  factory RecapPage.fromJson(Map<String, dynamic> json) => RecapPage(
    json['kind'] as String,
    json['title'] as String,
    json['text'] as String,
    (json['metrics'] as List)
        .map((m) => RecapMetric(m['label'], m['value']))
        .toList(),
    (json['boards'] as List).map((b) => RecapBoard.fromJson(b)).toList(),
  );
}

class RecapMetric {
  final String label, value;
  const RecapMetric(this.label, this.value);
}

class RecapBoard {
  final String title, unit;
  final List<RecapStanding> rows;
  const RecapBoard(this.title, this.unit, this.rows);
  factory RecapBoard.fromJson(Map<String, dynamic> json) => RecapBoard(
    json['title'],
    json['unit'],
    (json['rows'] as List)
        .map(
          (r) => RecapStanding(
            r['name'],
            (r['rank'] as num).toInt(),
            r['value'] as num,
            r['mine'] == true,
          ),
        )
        .toList(),
  );
}

class RecapStanding {
  final String name;
  final int rank;
  final num value;
  final bool mine;
  const RecapStanding(this.name, this.rank, this.value, this.mine);
}

class SeasonRecapApi {
  final RequestExecutor executor;
  final void Function()? onOpened;
  SeasonRecapApi(this.executor, {this.onOpened});
  Future<List<RecapSummary>> list() => executor.executeGetRequest(
    Uri.parse('$serverUrl/season-recap'),
    (json) => (json as List).map((r) => RecapSummary.fromJson(r)).toList(),
    null,
  );
  Future<SeasonRecap> detail(int id) => executor.executeGetRequest(
    Uri.parse('$serverUrl/season-recap/$id'),
    (json) => SeasonRecap.fromJson(json),
    null,
  );
  Future<void> opened(int id) async {
    await executor.executePostRequest<void>(
      Uri.parse('$serverUrl/season-recap/$id/opened'),
      (_) {},
      '{}',
      queueOnFailure: false,
    );
    // Also refresh when the user closed the sheet before this request finished.
    onOpened?.call();
  }
}

// Independent change signal: the API must not invalidate a provider that
// depends on that same API (Riverpod reports a circular dependency in debug).
final _seasonRecapRevisionProvider = StateProvider<int>((ref) => 0);

final Provider<SeasonRecapApi> seasonRecapApiProvider =
    Provider<SeasonRecapApi>(
      (ref) => SeasonRecapApi(
        ref.watch(requestExecutorProvider),
        onOpened: () {
          final revision = ref.read(_seasonRecapRevisionProvider.notifier);
          revision.state++;
        },
      ),
    );
final seasonRecapsProvider = FutureProvider.autoDispose<List<RecapSummary>>((
  ref,
) {
  ref.watch(_seasonRecapRevisionProvider);
  final team = ref.watch(globalVariablesProvider.select((s) => s.appTeam?.id));
  if (team == null) return [];
  return ref.watch(seasonRecapApiProvider).list();
});

// Consumed by HomeScreen's sheet queue; never opens a second modal on top of a notice.
final pendingSeasonRecapProvider = StateProvider<int?>((ref) => null);
