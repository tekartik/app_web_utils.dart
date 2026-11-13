# tekartik_app_web_build_menu

A console menu (`dart run tool/build_menu.dart`) to build, serve, clean and
deploy a plain Dart web app (compiled with `webdev`, not Flutter web), on top
of the builders of
[tekartik_app_web_build](../app_build/README.md): a local deploy folder,
Firebase hosting or surge.

VM only: the menu shells out (`webdev`, `firebase`, `surge`), so it lives in
`tool/` or `bin/`, never in the web app sources.

## Getting started

Git dependency (not on pub.dev), in the `dev_dependencies` of the web app:

```yaml
dev_dependencies:
  tekartik_app_web_build_menu:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      path: packages/app_build_menu
    version: '>=1.0.1'
  # webdev needs them in the app itself
  build_runner: ">=2.15.0"
  build_web_compilers: ">=4.4.19"
```

`tool/build_menu.dart`, one target on Firebase hosting:

```dart
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

var devBuilder = FirebaseWebAppBuilder(
  options: FirebaseWebAppOptions(
    buildOptions: WebAppBuildOptions(),
    deployOptions: FirebaseDeployOptions(
      projectId: 'my-project-dev',
      hostingId: 'my-app-dev',
      target: 'dev',
    ),
  ),
);

void main(List<String> arguments) {
  mainMenuConsole(arguments, () {
    menuCommonWebAppContent(builders: [devBuilder]);
    menuAppContent();
  });
}
```

```shell
dart run tool/build_menu.dart          # the menu, items picked by number
dart run tool/build_menu.dart 0 0 . .  # target dev, build, back, exit
```

`build` runs `webdev build`, then copies the files listed in `web/deploy.yaml`
from `build/web` to the deploy folder (`<deployDir>/public` for Firebase), see
[app_build setup](../app_build/doc/setup.md).

## What to use

- `menuCommonWebAppContent(builders: [...])`: one `target <name>` menu per
  builder (`DefaultWebAppBuilder`, `FirebaseWebAppBuilder`,
  `SurgeWebAppBuilder`) with `build`, `serve` (webdev), `clean`, `deploy`,
  `serveDeployed`, `buildAndServeDeployed`, `buildAndDeploy`.
  `menuCommonWebAppBuilderContent(builder: )` puts these items in the
  current menu.
- `menuWebAppContent(options: WebAppOptions(...))`: a `web_app_builder`
  menu without a deploy target (`build`, `serve`, `clean`, `pre-deploy`, the
  same build).
- `menuAppContent(path: '.')`: a `pub` menu (`list sub projects`, `run_ci`,
  `pub_get`, `pub_upgrade`).
- `menuFirebaseWebAppContent` / `menuFirebaseWebAppBuilderContent`: older
  names restricted to `FirebaseWebAppBuilder`.

The library re-exports `package:dev_build/menu/menu_io.dart` (`menu`, `item`,
`enter`, `write`...) and the builders of tekartik_app_web_build,
tekartik_firebase_build and tekartik_web_publish: one import is enough.

## Pitfalls

- The command line arguments are typed lines run first, then the menu waits
  for more on a terminal. `.` leaves the current menu, at the root it exits:
  `0 0 . .` builds the first target and exits.
- The declaration callback of `mainMenuConsole` and `menu` must be
  synchronous; only the item bodies may be async.
- `clean` deletes `build/` and the deploy folder (only when it is inside the
  package); the Firebase builder deletes only `<deployDir>/public`, keeping
  `firebase.json` and `.firebaserc`.
- `deploy` and `buildAndDeploy` publish for real (firebase or surge cli,
  logged in).

## wbm command

A ready made menu (`menuWebAppContent` + `menuAppContent`) for any web app
folder:

```shell
dart pub global activate -s path .     # from this package
wbm                                    # the current folder, sources in web/
wbm -s example -p 8060 ../my_app       # other sources folder, port and app
```

The first argument after the options is the app path, the next ones are
menu lines.
