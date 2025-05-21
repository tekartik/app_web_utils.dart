@TestOn('browser')
library;

import 'package:tekartik_web_splash/src/splash_web.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('show/hide', () async {
    var body = web.document.body!;
    var element =
        web.HTMLDivElement()
          ..id = 'app_splash'
          ..className = 'app-loading';
    body.appendChild(element);
    expect(body.contains(element), isTrue);
    element = web.document.getElementById('app_splash') as web.HTMLDivElement;
    expect(element.className, 'app-loading');
    webSplashHide();
    element = web.document.getElementById('app_splash') as web.HTMLDivElement;
    expect(element.className, '');
    expect(body.contains(element), isTrue);
    // not working in unit test?
    //await Future<void>.delayed(Duration(milliseconds: 1000));
    //expect(body.contains(element), isFalse);
  });
}
