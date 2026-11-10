# tekartik_sw_build

Build time (`dart:io`) helpers to generate the `sw.js` caching service worker
of a built web app: `generateServiceWorker(resources, coreBundle)` returns
the worker source (a port of the Flutter web worker, url to content hash
map), `generateWebAppServiceWorker(dir)` prints the md5 of every file of a
folder. Register the worker from the page with
[tekartik_sw_utils](../sw_utils).

## Getting started

```yaml
dev_dependencies:
  tekartik_sw_build:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      path: packages/sw_build
```

```dart
import 'dart:io';

import 'package:tekartik_sw_build/sw_build.dart';

Future<void> main() async {
  // url relative to the site root -> content hash ('/' is index.html).
  var resources = {'/': 'a1b2', 'main.dart.js': 'c3d4'};
  await File('build/web/sw.js').writeAsString(
    generateServiceWorker(resources, ['/', 'main.dart.js']),
  );
}
```

The package skill (`skills/tekartik-sw-build-setup`) shows how to hash a
whole build folder.
