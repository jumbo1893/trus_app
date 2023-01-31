import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trus_app/features/fine/repository/fine_repository.dart';
import 'package:trus_app/models/fine_model.dart';



final fineControllerProvider = Provider((ref) {
  final fineRepository = ref.watch(fineRepositoryProvider);
  return FineController(fineRepository: fineRepository, ref: ref);
});

class FineController {
  final FineRepository fineRepository;
  final ProviderRef ref;

  FineController({
    required this.fineRepository,
    required this.ref,
  });

  Stream<List<FineModel>> fines() {
    return fineRepository.getFines();
  }

  Future<bool> addFine(
    BuildContext context,
    String name,
    int amount,
  ) async {
    bool result =
        await fineRepository.addFine(context, name, amount);
    return result;
  }

  Future<bool> editFine(
    BuildContext context,
    String name,
    int amount,
    FineModel fineModel,
  ) async {
    bool result = await fineRepository.editFine(
        context, name, amount, fineModel);
    return result;
  }

  Future<void> deleteFine(
    BuildContext context,
    FineModel fineModel,
  ) async {
    await fineRepository.deleteFine(context, fineModel);
  }
}
