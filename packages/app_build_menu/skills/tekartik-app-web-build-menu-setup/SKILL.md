---
name: tekartik-app-web-build-menu-setup
description: >-
  Use when writing a tool/build_menu.dart console menu that builds, serves and
  deploys a plain Dart (webdev, not flutter) web app with
  tekartik_app_web_build_menu: mainMenuConsole, menu, item, write,
  menuWebAppContent, menuCommonWebAppContent, menuCommonWebAppBuilderContent,
  menuFirebaseWebAppContent, menuFirebaseWebAppBuilderContent, menuAppContent,
  the re-exported WebAppBuilder/WebAppOptions/FirebaseWebAppBuilder/
  SurgeWebAppBuilder builders, and the wbm global command.
---

# Web app build menu (tekartik_app_web_build_menu)

`tekartik_app_web_build_menu` wraps the `tekartik_app_web_build` builders in a
`dev_build` console menu: one `tool/build_menu.dart` script gives interactive
(and scriptable) build / serve / clean / deploy items per target. It targets
plain Dart web apps compiled with `webdev`, not Flutter web.

## Guidelines

* Git dependency (not on pub.dev), in `dev_dependencies` of the web app
  package:
  ```yaml
  dev_dependencies:
    tekartik_app_web_build_menu:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/app_build_menu
      version: '>=1.0.1'
    # Needed direct dependencies of the web app itself
    build_runner:
    build_web_compilers:
  ```
* One import is enough: `package:tekartik_app_web_build_menu/app_build_menu.dart`
  re-exports `package:dev_build/menu/menu_io.dart` (`mainMenuConsole`,
  `initMenuConsole`, `menu`, `item`, `enter`, `leave`, `write`, `writeln`,
  `prompt`, `command`, `menuRun`), `package:tekartik_app_web_build/app_build.dart`
  (`WebAppBuilder`, `WebAppOptions`/`WebAppBuildOptions`,
  `DefaultWebAppBuilder`, `FirebaseWebAppBuilder`, `FirebaseWebAppOptions`,
  `FirebaseDeployOptions`, `SurgeWebAppBuilder`, `SurgeWebAppOptions`,
  `CommonWebAppBuilder`, `webdevBuild`, `webdevServe`, ...),
  `package:tekartik_firebase_build/app_build.dart` (the Flutter variants,
  `FlutterFirebaseWebAppBuilder`) and `package:tekartik_web_publish`'s
  `web_publish.dart` + `surge_web_publish.dart` (`WebAppDeployOptions`,
  `SurgeWebAppDeployOptions`, `SurgeWebAppDeployer`, `webAppBuildToDeploy`).
  Do not add these imports again next to it.
* Script shape: `void main(List<String> args) => mainMenuConsole(args, () {
  ...declare menus... });`. The declaration callback must be synchronous; only
  `item` bodies may be async. Run it with `dart run tool/build_menu.dart`;
  extra arguments select menus/items non-interactively for CI.
* `menuCommonWebAppContent(builders: [...])` is the normal entry point: it
  declares one `target <builder.target>` submenu per `CommonWebAppBuilder`
  (local, firebase or surge), each filled by
  `menuCommonWebAppBuilderContent(builder: )` with the items `build`, `serve`,
  `clean`, `deploy`, `serveDeployed`, `buildAndServeDeployed` and
  `buildAndDeploy`.
* `menuFirebaseWebAppContent(builders: )` and
  `menuFirebaseWebAppBuilderContent(builder: )` are compatibility aliases
  restricted to `FirebaseWebAppBuilder`; prefer the `Common` versions.
* `menuWebAppContent({options, builder})` declares a `web_app_builder` submenu
  (`build`, `serve`, `clean`, `pre-deploy`) around a bare `WebAppBuilder`, with
  no deploy target. Pass either an existing `builder` or `options`
  (`WebAppOptions`, i.e. `WebAppBuildOptions`); passing neither builds a
  default builder on `.` / `web` / `deploy`.
* `menuAppContent({path = '.'})` adds an unrelated `pub` submenu for the
  package at `path`: `list sub projects`, `run_ci`, `pub_get`, `pub_upgrade`
  (via `dev_build`'s `packageRunCi`). Combine it with the build menus in the
  same `mainMenuConsole` callback.
* Declare the builders as top level `var`s so other tool scripts
  (`tool/build_and_deploy_dev.dart`) can reuse the same options without the
  menu.
* The `wbm` executable is a ready-made menu for any web app directory:
  activate it with `dart pub global activate -s path .` from this package, then
  `wbm [-s|--source-dir web] [-p|--web-port 8060] [<app path> <menu args...>]`.
  It combines `menuWebAppContent` and `menuAppContent` on that directory; the
  first rest argument is the app path (default: current directory).
* Everything shells out through `dart:io`, so these scripts are VM only
  (`tool/`, `bin/`), never part of the web app sources.

## Examples

### Local dev menu for the current package

```dart
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

void main(List<String> args) {
  mainMenuConsole(args, () {
    menuWebAppContent(options: WebAppOptions(packageTop: '.', webPort: 8060));
    menuAppContent();
  });
}
```

### Firebase hosting targets (dev and prod)

```dart
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

var buildOptions = WebAppBuildOptions(packageTop: '.');

var devBuilder = FirebaseWebAppBuilder(
  options: FirebaseWebAppOptions(
    buildOptions: buildOptions,
    deployOptions: FirebaseDeployOptions(
      projectId: 'my-project-dev',
      hostingId: 'my-app-dev',
      target: 'dev',
    ),
  ),
);
var prodBuilder = FirebaseWebAppBuilder(
  options: FirebaseWebAppOptions(
    buildOptions: buildOptions,
    deployOptions: FirebaseDeployOptions(
      projectId: 'my-project',
      hostingId: 'my-app',
      target: 'prod',
    ),
  ),
);

void main(List<String> args) {
  mainMenuConsole(args, () {
    menuCommonWebAppContent(builders: [devBuilder, prodBuilder]);
  });
}
```

### Surge target

```dart
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

var appBuilder = SurgeWebAppBuilder(
  options: SurgeWebAppOptions(
    buildOptions: WebAppBuildOptions(),
    deployOptions: SurgeWebAppDeployOptions(domain: 'my_app.surge.sh'),
  ),
);

void main(List<String> args) {
  mainMenuConsole(args, () {
    menuCommonWebAppContent(builders: [appBuilder]);
  });
}
```

### Custom items next to the generated ones

```dart
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

var builder = DefaultWebAppBuilder(
  buildOptions: WebAppBuildOptions(packageTop: '.'),
);

void main(List<String> args) {
  mainMenuConsole(args, () {
    menu('web', () {
      enter(() {
        write('app: ${builder.buildOptions.packageTop}');
      });
      menuCommonWebAppBuilderContent(builder: builder);
      item('build + copy to deploy only', () async {
        await builder.build();
      });
    });
  });
}
```
