import 'package:tekartik_app_web_build/dhttpd.dart';
import 'package:test/test.dart';

void main() {
  group('dhttps', () {
    test('dhttpdReady', () async {
      await dhttpdReady(force: true, verbose: true);
      await dhttpdReady(verbose: true);
    });
  });
}
