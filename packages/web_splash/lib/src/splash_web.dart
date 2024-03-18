// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

const _splashParam = 'splash';
const _appLoadingClassDefault = 'app-loading';
const _appSplashIdDefault = 'app_splash';

/// Must be initialized before flutter engine starts as it may change later.
/// Call webSplashReady() to save the current Uri
var _startUri = Uri.base;

/// In the first version the app-loading class was set on the body
/// Now we set it on the app_splash id
///
/// ```html
/// <!-- add id splash -->
/// <div id="app_splash" class="app-loading"></div>
/// ```
class Splash {
  late final String appSplashId;
  late final String appLoadingClass;
  web.Element? _appSplashElement;

  /// [appSplashId] default to 'app_splash.
  ///
  /// [appLoadingClass] default to 'app-loading
  Splash({String? appSplashId, String? appLoadingClass}) {
    this.appSplashId = appSplashId ?? _appSplashIdDefault;
    this.appLoadingClass = appLoadingClass ?? _appLoadingClassDefault;
    var loadEl = web.document.getElementById(this.appSplashId);
    if (loadEl != null) {
      _appSplashElement = loadEl;
      loadEl.onTransitionEnd.listen((_) {
        loadEl.remove();
      });
    }
  }

  void hide() {
    void doHide() {
      // Compat, still remove the class on the body (if not changed)
      if (appLoadingClass == _appLoadingClassDefault) {
        web.document.body!.classList.remove(appLoadingClass);
      }
      _appSplashElement?.classList.remove(appLoadingClass);
    }

    if (_startUri.queryParameters.containsKey(_splashParam)) {
      var delay = int.tryParse(_startUri.queryParameters[_splashParam]!);
      if (delay != null) {
        Future.delayed(Duration(milliseconds: delay)).then((_) {
          doHide();
        });
      }
      // otherwise do not hide
    } else {
      doHide();
    }
  }
}

final splash = Splash();

void webSplashHide() {
  splash.hide();
}

/// Save current Uri
void webSplashReady() {
  _startUri;
}
