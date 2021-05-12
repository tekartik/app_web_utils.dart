import 'dart:html';

import 'package:tekartik_web_splash/web_splash.dart';

Future<void> main() async {
  var uri = Uri.parse(window.location.href);
  print(uri);
  print(uri.queryParameters);

  if (uri.queryParameters.containsKey('splashneverends')) {
    return;
  }
  if (uri.queryParameters.containsKey('longsplash')) {
    await Future.delayed(Duration(seconds: 10));
  }

  webSplashHide();

  querySelector('#output')!.text = '''
    ${window.location.href}''';

  // Call twice for testing
  webSplashHide();
}
