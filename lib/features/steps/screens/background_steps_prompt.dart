import 'dart:io';

import 'package:flutter/material.dart';

/// A separate choice after step access has been granted. The system permission
/// prompt is opened only when the user explicitly chooses background updates.
Future<bool> askForBackgroundSteps(BuildContext context) async {
  if (!Platform.isAndroid) return false;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aktualizovat kroky na pozadí?'),
          content: const Text(
            'Pokud tuto volbu zapneš, Trusí appka přibližně každých 6 hodin '
            'načte z Health Connect součty kroků za dnešek a včerejšek '
            'a uloží je k tvému účtu. Díky tomu uvidíš aktuálnější osobní '
            'historii a týmovou výzvu, i když aplikaci neotevřeš. '
            'Součty kroků uvidí také členové tvého týmu.\n\n'
            'Volba je dobrovolná. Bez ní se kroky aktualizují při používání '
            'aplikace. Automatické aktualizace můžeš vypnout na obrazovce Kroky '
            'a oprávnění odebrat v Health Connect.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Teď ne'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Povolit aktualizace'),
            ),
          ],
        ),
      ) ??
      false;
}
