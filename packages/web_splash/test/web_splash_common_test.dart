library;

import 'package:tekartik_web_splash/web_splash.dart';
import 'package:test/test.dart';

void main() {
  test('show/hide', () async {
    // no op on non web
    webSplashReady;
    webSplashHide();
  });
}
