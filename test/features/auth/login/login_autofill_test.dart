import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trus_app/features/auth/login/controller/auth_login_controller.dart';
import 'package:trus_app/features/auth/login/screens/login_screen.dart';
import 'package:trus_app/features/auth/repository/auth_repository.dart';
import 'package:trus_app/features/general/global_variables_controller.dart';
import 'package:trus_app/features/general/notifier/global_variables_notifier.dart';
import 'package:trus_app/theme/app_theme.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGlobalVariablesController implements GlobalVariablesController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthLoginController extends AuthLoginController {
  int loadLoginUserCalls = 0;

  _FakeAuthLoginController()
    : super(
        authRepository: _FakeAuthRepository(),
        globalVariablesController: _FakeGlobalVariablesController(),
        globalVariablesNotifier: GlobalVariablesNotifier(),
      );

  @override
  Future<void> setupUser() async {}

  @override
  Future<void> loadLoginUser() async {
    loadLoginUserCalls++;
    initStringFields('', emailKey());
    initStringFields('', passwordKey());
  }

  @override
  Future<LoginRedirect> sendEmailAndPassword() async => LoginRedirect.ok;
}

void main() {
  testWidgets('login uses system autofill and remembers password by default', (
    tester,
  ) async {
    final textInputCalls = <MethodCall>[];
    final credentialCalls = <MethodCall>[];
    const credentialChannel = MethodChannel('com.jumbo.trus_app/credentials');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.textInput, (call) async {
          textInputCalls.add(call);
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(credentialChannel, (call) async {
          credentialCalls.add(call);
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.textInput, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(credentialChannel, null);
    });

    final authController = _FakeAuthLoginController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authLoginControllerProvider.overrideWithValue(
            authController,
          ),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
      ),
    );
    await tester.pump();

    final autofillGroup = tester.widget<AutofillGroup>(
      find.byType(AutofillGroup),
    );
    expect(autofillGroup.onDisposeAction, AutofillContextAction.cancel);

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(2));
    expect(fields[0].autofillHints, contains(AutofillHints.username));
    expect(fields[0].keyboardType, TextInputType.emailAddress);
    expect(fields[0].decoration?.hintText, 'E-mail');
    expect(fields[1].autofillHints, contains(AutofillHints.password));
    expect(fields[1].obscureText, isTrue);
    expect(fields[1].decoration?.hintText, 'Heslo');

    await tester.enterText(find.byType(TextField).at(0), 'hrac@example.cz');
    await tester.enterText(find.byType(TextField).at(1), 'tajne-heslo');

    String fieldText(int index) => tester
        .widget<TextField>(find.byType(TextField).at(index))
        .controller!
        .text;

    CheckboxListTile rememberTile() => tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('remember_password_checkbox')),
    );

    expect(authController.loadLoginUserCalls, 1);
    expect(rememberTile().value, isTrue);

    await tester.tap(find.text('Zapamatovat heslo'));
    await tester.pump();
    expect(rememberTile().value, isFalse);
    expect(fieldText(0), 'hrac@example.cz');
    expect(fieldText(1), 'tajne-heslo');

    await tester.tap(find.text('Zapamatovat heslo'));
    await tester.pump();
    expect(rememberTile().value, isTrue);
    expect(fieldText(0), 'hrac@example.cz');
    expect(fieldText(1), 'tajne-heslo');
    expect(authController.loadLoginUserCalls, 1);

    await tester.tap(find.byKey(const ValueKey('login_button')));
    await tester.pump();
    expect(credentialCalls, hasLength(1));
    expect(credentialCalls.single.method, 'savePassword');
    expect(credentialCalls.single.arguments, {
      'username': 'hrac@example.cz',
      'password': 'tajne-heslo',
    });
    expect(_lastFinishAutofillValue(textInputCalls), isFalse);

    await tester.tap(find.text('Zapamatovat heslo'));
    await tester.pump();
    expect(rememberTile().value, isFalse);
    expect(fieldText(0), 'hrac@example.cz');
    expect(fieldText(1), 'tajne-heslo');

    await tester.tap(find.byKey(const ValueKey('login_button')));
    await tester.pump();
    expect(credentialCalls, hasLength(1));
    expect(_lastFinishAutofillValue(textInputCalls), isFalse);
  });
}

bool? _lastFinishAutofillValue(List<MethodCall> calls) {
  return calls
          .lastWhere((call) => call.method == 'TextInput.finishAutofillContext')
          .arguments
      as bool?;
}
