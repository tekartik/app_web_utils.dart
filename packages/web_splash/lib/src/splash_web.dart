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
    // right away
    /*
    int elapsed = sw.elapsedMilliseconds;
    const int delayMin = 1500;
    if (elapsed < delayMin) {
      await sleep(delayMin - elapsed);
    }
    */
    document.body!.classes.remove('app-loading');
  }
}

final splash = Splash();
void webSplashHide() {
  splash.hide();
}
