import 'package:web/web.dart' as web;

import 'package:tekartik_web_splash/web_splash.dart';

Future<void> main() async {
  var uri = Uri.parse(web.window.location.href);
  print(uri);
  print(uri.queryParameters);

  webSplashHide();

  web.document.body!.querySelector('#output')!.textContent = '''
    ${web.window.location.href}''';

  // Call twice for testing
  webSplashHide();
}
