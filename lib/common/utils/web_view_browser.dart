import 'package:flutter/material.dart';
import 'package:trus_app/common/utils/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> openFootbarWebView(String url, BuildContext context, Function(String) exchangeCode ) async {
  // Vytvoř WebView controller
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted) // Pokud Footbar potřebuje JS
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Můžeš ukázat progress bar
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {
          print(error);
          showSnackBar(context: context, content:  'Chyba načítání: ${error.description}');
        },
        onNavigationRequest: (NavigationRequest request) {
          print(request.url);
          // Krok 3: Zachyť callback URL
          if (request.url.contains('footbar/callback?code')) { // Nahraď svým redirectUri
            final uri = Uri.parse(request.url);
            final String? code = uri.queryParameters['code'];

            if (code != null && code.isNotEmpty) {
              // Zavři WebView a pošli code na /exchange
              Navigator.of(context).pop(); // Zavři dialog nebo screen s WebView
              exchangeCode(code);
            } else {
              Navigator.of(context).pop();
              showSnackBar(context: context, content: 'Chyba: Code chybí v callbacku');
            }
            return NavigationDecision.prevent; // Zabraň načtení URL (zachyceno lokálně)
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(url));

  // Zobraz WebView v dialogu nebo novém screen (např. full-screen dialog)
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: WebViewWidget(controller: controller),
      ),
    ),
  );
}
