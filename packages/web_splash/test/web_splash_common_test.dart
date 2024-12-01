library;

import 'package:tekartik_web_splash/src/splash_web.dart';
import 'package:test/test.dart';

void main() {
  test('show/hide', () async {
    webSplashReady;
    webSplashHide();
  });
}
