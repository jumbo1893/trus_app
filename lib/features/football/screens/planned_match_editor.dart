import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/common/utils/calendar.dart';
import 'package:trus_app/common/widgets/rows/app_switch_field.dart';
import 'package:trus_app/common/widgets/rows/app_text_input_field.dart';
import 'package:trus_app/common/widgets/rows/form/fake_input.dart';
import 'package:trus_app/common/widgets/rows/form/form_card.dart';
import 'package:trus_app/common/widgets/rows/form/form_field_wrapper.dart';
import 'package:trus_app/features/football/repository/planned_match_api_service.dart';
import 'package:trus_app/features/football/widgets/planned_match_photo.dart';
import 'package:trus_app/features/season/repository/season_api_service.dart';
import 'package:trus_app/models/api/match/planned_match.dart';
import 'package:trus_app/models/api/season_api_model.dart';
import 'package:trus_app/theme/app_colors.dart';

final plannedSeasonOptionsProvider =
    FutureProvider.autoDispose<List<SeasonApiModel>>(
      (ref) =>
          ref.read(seasonApiServiceProvider).getSeasons(false, false, false),
    );

class PlannedMatchEditor extends ConsumerStatefulWidget {
  final PlannedMatch? match;
  final ValueChanged<PlannedMatch> onSaved;
  final VoidCallback onCancel;

  const PlannedMatchEditor({
    super.key,
    this.match,
    required this.onSaved,
    required this.onCancel,
  });

  @override
  ConsumerState<PlannedMatchEditor> createState() => _PlannedMatchEditorState();
}

class _PlannedMatchEditorState extends ConsumerState<PlannedMatchEditor> {
  late DateTime date;
  late String type;
  late bool home;
  late String status;
  late int? seasonId;
  late String opponent;
  late String description;
  Uint8List? photoBytes;
  bool removePhoto = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final match = widget.match;
    date = match?.date.toLocal() ?? DateTime.now().add(const Duration(days: 1));
    type = match?.type ?? 'LEAGUE';
    home = match?.home ?? true;
    status = match?.status ?? 'SCHEDULED';
    seasonId = match?.seasonId;
    opponent = match?.opponent ?? '';
    description = match?.description ?? '';
  }

  Future<void> _save() async {
    if (type != 'TRAINING' &&
        type != 'TEAMBUILDING' &&
        opponent.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vyplň soupeře.')));
      return;
    }
    setState(() => saving = true);
    try {
      final api = ref.read(plannedMatchApiProvider);
      var saved = widget.match == null
          ? await api.create(
              date: date,
              type: type,
              opponent: type == 'TRAINING' || type == 'TEAMBUILDING'
                  ? null
                  : opponent.trim(),
              home: type == 'TRAINING' || type == 'TEAMBUILDING' ? null : home,
              description: description.trim(),
              seasonId: seasonId,
            )
          : await api.update(
              widget.match!,
              date: date,
              type: type,
              opponent: type == 'TRAINING' || type == 'TEAMBUILDING'
                  ? null
                  : opponent.trim(),
              home: type == 'TRAINING' || type == 'TEAMBUILDING' ? null : home,
              description: description.trim(),
              seasonId: seasonId,
              status: status,
            );
      if (photoBytes != null) {
        await api.uploadPhoto(saved.id, photoBytes!);
        saved = await api.get(saved.id);
      } else if (removePhoto && widget.match?.hasPhoto == true) {
        await api.deletePhoto(saved.id);
        saved = await api.get(saved.id);
      }
      widget.onSaved(saved);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plánovaný zápas se nepodařilo uložit.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _pickDate() async {
    final day = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: date,
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (time != null && mounted) {
      setState(
        () => date = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final decoded = image_lib.decodeImage(await file.readAsBytes());
    if (decoded == null || !mounted) return;
    final resized = image_lib.copyResize(decoded, width: 1024);
    setState(() {
      photoBytes = Uint8List.fromList(
        image_lib.encodeJpg(resized, quality: 82),
      );
      removePhoto = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seasons = ref.watch(plannedSeasonOptionsProvider);
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 104),
          children: [
            FormCard(
              children: [
                FormFieldWrapper(
                  label: 'Typ události',
                  child: DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'TRAINING',
                        child: Text('Trénink'),
                      ),
                      DropdownMenuItem(
                        value: 'FRIENDLY',
                        child: Text('Přípravný zápas'),
                      ),
                      DropdownMenuItem(
                        value: 'LEAGUE',
                        child: Text('Ligový zápas'),
                      ),
                      DropdownMenuItem(value: 'CUP', child: Text('Pohár')),
                      DropdownMenuItem(
                        value: 'TEAMBUILDING',
                        child: Text('Teambuilding'),
                      ),
                    ],
                    onChanged: (value) => setState(() => type = value!),
                  ),
                ),
                if (type != 'TRAINING' && type != 'TEAMBUILDING') ...[
                  FormFieldWrapper(
                    label: 'Soupeř',
                    child: AppTextInputField(
                      value: opponent,
                      hintText: 'Zadej soupeře',
                      onChanged: (value) => opponent = value,
                    ),
                  ),
                  FormFieldWrapper(
                    label: 'Místo',
                    child: AppSwitchField(
                      text: 'Doma',
                      value: home,
                      onChanged: (value) => setState(() => home = value),
                    ),
                  ),
                ],
                FormFieldWrapper(
                  label: 'Datum a čas',
                  child: InkWell(
                    onTap: _pickDate,
                    child: FakeInput(
                      text: matchDateToString(date, includeTime: true),
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
                FormFieldWrapper(
                  label: 'Popis',
                  child: AppTextInputField(
                    value: description,
                    hintText: 'Volitelný popis',
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),
                ),
                FormFieldWrapper(
                  label: 'Fotka',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (photoBytes != null)
                        Image.memory(
                          photoBytes!,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      else if (widget.match?.hasPhoto == true && !removePhoto)
                        PlannedMatchPhoto(id: widget.match!.id, height: 120),
                      TextButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: const Text('Vybrat fotku'),
                      ),
                      if (photoBytes != null ||
                          widget.match?.hasPhoto == true && !removePhoto)
                        TextButton(
                          onPressed: () => setState(() {
                            photoBytes = null;
                            removePhoto = true;
                          }),
                          child: const Text('Odebrat fotku'),
                        ),
                    ],
                  ),
                ),
                FormFieldWrapper(
                  label: 'Sezona',
                  child: seasons.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => TextButton(
                      onPressed: () =>
                          ref.invalidate(plannedSeasonOptionsProvider),
                      child: const Text(
                        'Sezony se nepodařilo načíst. Zkusit znovu',
                      ),
                    ),
                    data: (options) => DropdownButtonFormField<int?>(
                      initialValue:
                          options.any((option) => option.id == seasonId)
                          ? seasonId
                          : null,
                      decoration: const InputDecoration(),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Automatická sezona'),
                        ),
                        ...options
                            .where((season) => season.id != null)
                            .map(
                              (season) => DropdownMenuItem<int?>(
                                value: season.id,
                                child: Text(season.name),
                              ),
                            ),
                      ],
                      onChanged: (value) => setState(() => seasonId = value),
                    ),
                  ),
                ),
                if (widget.match != null)
                  FormFieldWrapper(
                    label: 'Stav',
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(
                          value: 'SCHEDULED',
                          child: Text('Naplánováno'),
                        ),
                        DropdownMenuItem(
                          value: 'CANCELLED',
                          child: Text('Zrušeno'),
                        ),
                      ],
                      onChanged: (value) => setState(() => status = value!),
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Material(
            elevation: 8,
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving ? null : widget.onCancel,
                      child: const Text('Zrušit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: saving ? null : _save,
                      child: Text(saving ? 'Ukládám…' : 'Uložit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
