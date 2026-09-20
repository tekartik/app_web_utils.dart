---
name: tekartik-app-web-build-setup
description: >-
  Use when writing a build/deploy tool script for a plain Dart (webdev, not
  flutter) web app with tekartik_app_web_build: webdevBuild, webdevServe,
  webdevClean, webdevPubGet, webdevPubUpgrade, buildToDeploy, httpDeployServe,
  WebAppBuilder, WebAppBuildOptions/WebAppOptions, DefaultWebAppBuilder,
  FirebaseWebAppBuilder with FirebaseWebAppOptions and FirebaseDeployOptions,
  SurgeWebAppBuilder with SurgeWebAppOptions, CommonWebAppBuilder, WebProject,
  the deploy.yaml file list, and dhttpdReady from dhttpd.dart.
---

# Dart web app build and deploy (tekartik_app_web_build)

`tekartik_app_web_build` drives `webdev` for a plain Dart web app (no Flutter):
build `web/` to `build/web`, copy the files listed in `deploy.yaml` to a
`deploy/` folder, then serve or deploy that folder (local `dhttpd`, Firebase
Hosting or Surge). Everything here uses `dart:io` and shells out, so it belongs
in `tool/` scripts and tests, never in the web app code itself.

## Guidelines

* Git dependency (not on pub.dev), normally a `dev_dependencies` entry of the
  web app package:
  ```yaml
  dev_dependencies:
    tekartik_app_web_build:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/app_build
      version: '>=0.1.1'
    # Needed direct dependencies of the web app itself
    build_runner:
    build_web_compilers:
  ```
  `webdev` and `dhttpd` are activated globally on demand (`dart pub global
  activate`), nothing else to install.
* Imports: `package:tekartik_app_web_build/app_build.dart` is the only entry
  point you normally need. It also re-exports
  `package:tekartik_common_build/common_app_builder.dart` (`CommonAppBuilder`,
  `CommonAppBuilderExt`) and
  `package:tekartik_firebase_build/firebase_deploy.dart`
  (`FirebaseDeployOptions`, `firebaseWebAppBuildToDeploy`,
  `firebaseWebAppDeploy`, `firebaseWebAppServe`, `firebaseDefaultDeployDir`,
  `FirebaseWebAppActionController`).
  `package:tekartik_app_web_build/dhttpd.dart` only exports `dhttpdReady`.
* Low level functions, all taking the web app package dir as first argument:
  `webdevBuild(dir, folder: 'web')` runs `webdev build --output
  web:build/web`; `webdevServe(dir, folder: 'web', port: )` runs `webdev serve
  --auto refresh`; `webdevClean(dir)` deletes `build/`; `webdevPubGet(dir)` and
  `webdevPubUpgrade(dir)` run `dart pub get`/`upgrade` there.
* `buildToDeploy(dir, folder: 'web', deployDir: )` copies `build/<folder>` to
  `<dir>/deploy/<folder>` following `build/<folder>/deploy.yaml`, and throws a
  `StateError` when that file is missing. Put `deploy.yaml` in the app `web/`
  source folder so `webdev` copies it to the build output; it lists the files
  to deploy:
  ```yaml
  files:
    - index.html
    - main.dart.js
    - styles.css
  ```
* `httpDeployServe(dir, deployDir: )` activates `dhttpd` if needed and serves
  the deploy folder on `http://localhost:8080`. `dhttpdReady(force: , verbose: )`
  from `dhttpd.dart` does the activation alone (it also registers a `dhttpd`
  shell alias); testing only.
* Prefer the builder objects over the raw functions for anything reusable.
  `WebAppBuildOptions({packageTop, deployDir, srcDir, webPort})` defaults to
  `packageTop: '.'`, `deployDir: 'deploy'`, `srcDir: 'web'`, dynamic port.
  `WebAppOptions` is a deprecated typedef of `WebAppBuildOptions`.
* `WebAppBuilder(options: WebAppBuildOptions(...))` is the plain builder:
  `build()` (webdev build + copy to deploy, warns on stderr instead of throwing
  when `deploy.yaml` is missing), `serve()` (webdev dev server), `clean()`.
  It implements `CommonAppBuilder`, so `generateVersion()`,
  `generateVersionIfNeeded()` and `bumpVersion(patch: , minor: , major: )` from
  `CommonAppBuilderExt` are available on it.
* Target builders all implement `CommonWebAppBuilder` (`webAppBuilder`,
  `buildOptions`, `deployOptions`, `target`, `clean()`, `build()`, `serve()`,
  `deploy()`, `serveDeployed()`). The `buildAndServe()` and `buildAndDeploy()`
  shortcuts live on the internal mixin, so they are only callable on the
  concrete `FirebaseWebAppBuilder`/`SurgeWebAppBuilder` types, not through a
  `CommonWebAppBuilder` or `DefaultWebAppBuilder` variable (call `build()` then
  `serveDeployed()`/`deploy()` there):
  - `DefaultWebAppBuilder(buildOptions: )` for a local app: `serveDeployed()`
    uses `dhttpd`, `deploy()` just writes `No deploy` on stderr and
    `deployOptions` throws `UnimplementedError`. `target` is `'local'`.
  - `FirebaseWebAppBuilder(options: FirebaseWebAppOptions(buildOptions: ,
    deployOptions: FirebaseDeployOptions(projectId: , hostingId: , target: )))`
    for Firebase Hosting; `deploy()`/`serveDeployed()` shell out to the
    `firebase` CLI and accept an optional `FirebaseWebAppActionController`
    whose `cancel()` kills the running command.
  - `SurgeWebAppBuilder(options: SurgeWebAppOptions(buildOptions: ,
    deployOptions: SurgeWebAppDeployOptions(domain: )))` for surge.sh;
    `SurgeWebAppDeployOptions` comes from
    `package:tekartik_web_publish/surge_web_publish.dart`, which is not
    re-exported.
* `WebProject(path)` with its single `build({folder})` is legacy; use
  `WebAppBuilder` instead.
* Do not `import 'package:tekartik_app_web_build/src/...'` in application
  code: `src/webdev.dart` (`webdevReady`) and
  `src/test/generate_dart_project.dart` (`generateDartProject`) are test
  helpers of this package.
* For an interactive menu around these builders, use the sibling package
  `tekartik_app_web_build_menu` (`menuCommonWebAppContent`) rather than
  hand-writing a CLI.
* Tests calling `webdevBuild` need a real `dart pub get` plus a webdev
  compilation: give them a generous `timeout: Timeout(Duration(minutes: 5))`.

## Examples

### Minimal build, copy to deploy, serve locally

```dart
import 'package:tekartik_app_web_build/app_build.dart';

Future<void> main() async {
  var dir = '.';
  await webdevBuild(dir);
  await buildToDeploy(dir);
  await httpDeployServe(dir); // http://localhost:8080
}
```

### Development server and clean

```dart
import 'package:tekartik_app_web_build/app_build.dart';

Future<void> main(List<String> args) async {
  var dir = '.';
  if (args.contains('clean')) {
    await webdevClean(dir);
    await webdevPubGet(dir);
    return;
  }
  await webdevServe(dir, port: 8060);
}
```

### Local builder with options

```dart
import 'package:tekartik_app_web_build/app_build.dart';

var builder = DefaultWebAppBuilder(
  buildOptions: WebAppBuildOptions(
    packageTop: '.',
    srcDir: 'web',
    deployDir: 'deploy',
    webPort: 8060,
  ),
);

Future<void> main() async {
  await builder.clean();
  await builder.build();
  await builder.serveDeployed(); // dhttpd on the deploy folder
}
```

### Firebase hosting builder

```dart
import 'package:tekartik_app_web_build/app_build.dart';

var devBuilder = FirebaseWebAppBuilder(
  options: FirebaseWebAppOptions(
    buildOptions: WebAppBuildOptions(packageTop: '.'),
    deployOptions: FirebaseDeployOptions(
      projectId: 'my-project-dev',
      hostingId: 'my-app-dev',
      target: 'dev',
    ),
  ),
);

Future<void> main(List<String> args) async {
  print('deploying to ${devBuilder.target}');
  await devBuilder.build();
  if (args.contains('serve')) {
    await devBuilder.serveDeployed();
  } else {
    await devBuilder.deploy();
  }
}
```

### Surge builder

```dart
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_web_publish/surge_web_publish.dart';

var builder = SurgeWebAppBuilder(
  options: SurgeWebAppOptions(
    buildOptions: WebAppBuildOptions(),
    deployOptions: SurgeWebAppDeployOptions(domain: 'my-app.surge.sh'),
  ),
);

Future<void> main() async {
  await builder.buildAndDeploy();
}
```

### Firebase hosting without a builder, cancellable

```dart
import 'package:tekartik_app_web_build/app_build.dart';

Future<void> serveDev(String path) async {
  var options = FirebaseDeployOptions(
    projectId: 'my-project-dev',
    hostingId: 'my-app-dev',
    target: 'dev',
  );
  var controller = FirebaseWebAppActionController();
  await firebaseWebAppBuildToDeploy(path, deployDir: 'deploy');
  await firebaseWebAppServe(path, options, controller: controller);
  controller.cancel();
}
```
