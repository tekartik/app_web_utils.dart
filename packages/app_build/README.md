# tekartik_app_web_build

Build, serve and deploy a plain Dart web app (`webdev`, not Flutter) from
`tool/` scripts: `webdev build` of `web/` to `build/web`, a copy of the
build to a deploy folder (the files listed in `deploy.yaml`), then a local
server (`dhttpd`), Firebase Hosting or surge.sh.

For a Flutter web app use `tekartik_flutter_build` / `tekartik_firebase_build`
(package `tekartik/app_build.dart`) instead.

## Getting started

Git dependency (not on pub.dev), in the web app package:

```yaml
dev_dependencies:
  tekartik_app_web_build:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      path: packages/app_build
  # Needed by webdev in the web app itself
  build_runner:
  build_web_compilers:
```

Dart VM only (`dart:io`, shells out): use it in `tool/` scripts and tests,
never in the web app code. `webdev` and `dhttpd` are activated globally on
demand (`dart pub global activate`); the Firebase builder needs the
`firebase` cli, logged in.

Put a `deploy.yaml` in `web/` (webdev copies it to `build/web`) listing the
files to deploy:

```yaml
files:
  - index.html
  - main.dart.js
  - styles.css
```

`tool/build.dart`:

```dart
import 'package:tekartik_app_web_build/app_build.dart';

Future<void> main() async {
  var builder = WebAppBuilder(options: WebAppBuildOptions(packageTop: '.'));
  // webdev build, then build/web copied to deploy/ following deploy.yaml.
  await builder.build();
  // http://localhost:8080 serving deploy/ (httpDeployServe alone serves
  // deploy/web, where buildToDeploy copies).
  await httpDeployServe('.', deployDir: builder.options.deployDir);
}
```

## When to use what

- `WebAppBuilder`: build (`webdev build` + copy to `deployDir`), `serve()`
  (the webdev dev server), `clean()` (`build/` and the deploy folder).
- `FirebaseWebAppBuilder(options: FirebaseWebAppOptions(...))`: `deployDir`
  is the hosting folder (`firebase.json`, `.firebaserc`); `build()` copies
  the build to `<deployDir>/public` (following `deploy.yaml` when present)
  and keeps the hosting configuration, `deploy()` / `serveDeployed()` run
  the `firebase` cli there.
- `SurgeWebAppBuilder`, `DefaultWebAppBuilder` (local only, no deploy).
- `menuCommonWebAppContent` of the sibling package
  `tekartik_app_web_build_menu` for a console menu over these builders.

The [package skill](skills/tekartik-app-web-build-setup/SKILL.md) has more
examples.

## Pitfalls

- A copy to a deploy folder empties that folder first: never point a plain
  `WebAppBuilder` or `buildToDeploy` at a folder holding other files.
  `FirebaseWebAppBuilder.build()` only empties `<deployDir>/public` (before
  2026-11-12 it emptied the hosting folder too, `firebase.json` included,
  when the build had a `deploy.yaml`).
- `webdevReady()` / `dhttpdReady()` replace the global process_run
  `shellEnvironment` (to add their alias): set your own environment after
  them.
- Tests running `webdevBuild` do a real `dart pub get` and compilation: give
  them a `timeout:` of a few minutes.
