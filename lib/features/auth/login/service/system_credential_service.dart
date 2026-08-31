import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SystemCredentialService {
  static const MethodChannel _channel = MethodChannel(
    'com.jumbo.trus_app/credentials',
  );

  Future<void> finishLogin({
    required String email,
    required String password,
    required bool shouldSave,
  }) async {
    if (!shouldSave) {
      TextInput.finishAutofillContext(shouldSave: false);
      return;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod<void>('savePassword', {
          'username': email,
          'password': password,
        });
        // Credential Manager už uložení vyřešil. Autofill kontext pouze ukončíme,
        // aby se neobjevila druhá konkurenční výzva k uložení.
        TextInput.finishAutofillContext(shouldSave: false);
        return;
      } on MissingPluginException {
        // Starší sestavení aplikace: použijeme standardní Flutter Autofill.
      } on PlatformException catch (exception) {
        if (exception.code == 'CANCELLED') {
          TextInput.finishAutofillContext(shouldSave: false);
          return;
        }
        // Pokud konkrétní správce explicitní uložení nepodporuje, necháme
        // Android zkusit původní Autofill nabídku.
      }
    }

    TextInput.finishAutofillContext(shouldSave: true);
  }
}
