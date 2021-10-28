// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class Splash {
  Splash() {
    var loadEl = document.getElementById('app_splash');
    if (loadEl != null) {
      loadEl.on['transitionend'].listen((_) {
        loadEl.remove();
      });
    }
  }

  void hide() {
    void _hide() {
      document.body!.classes.remove('app-loading');
    }

    if (Uri.base.queryParameters.containsKey('splash')) {
      var delay = int.tryParse(Uri.base.queryParameters['splash']!);
      if (delay != null) {
        Future.delayed(Duration(milliseconds: delay)).then((_) {
          _hide();
        });
      }
      // otherwise do not hide

    } else {
      _hide();
    }
  }
}

final splash = Splash();

void webSplashHide() {
  splash.hide();
}
