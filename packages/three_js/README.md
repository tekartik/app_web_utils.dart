# tekartik_three_js

Experimental `dart:js_interop` bindings for [three.js](https://threejs.org),
loaded at runtime from jsDelivr: renderer, scene, perspective camera, box
geometry, basic material, mesh, vector and euler, enough for a first scene.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  web: '>=1.1.0'
  tekartik_three_js:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      path: packages/three_js
```

Web only (dart2js and dart2wasm). Import the module first, then build the scene
as in JavaScript:

```dart
import 'dart:js_interop';

import 'package:tekartik_three_js/three_js_interop.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  await importThreeJsModule(createImportMap: true);
  var window = web.window;
  var scene = SceneJs();
  var camera = PerspectiveCameraJs(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000,
  );
  var renderer = WebGLRendererJs(WebGLRendererParametersJs(antialias: true));
  renderer.setSize(window.innerWidth, window.innerHeight);
  web.document.body!.appendChild(renderer.domElement);

  var cube = MeshJs(
    BoxGeometryJs(1, 1, 1),
    MeshBasicMaterialJs(MeshBasicMaterialParametersJs(color: 0x00ff00)),
  );
  scene.add(cube);
  camera.position.z = 5;

  void animate(num time) {
    cube.rotation.y += 0.01;
    renderer.render(scene, camera);
    window.requestAnimationFrame(animate.toJS);
  }

  window.requestAnimationFrame(animate.toJS);
}
```

A complete page: [example/rotating_cube](example/rotating_cube/main.dart)
(`dart run build_runner serve example:8080`, then open
`http://localhost:8080/rotating_cube/`).

## Common pitfalls

* `await importThreeJsModule()` before any constructor: they throw otherwise.
  The first call wins, a later `version:` is ignored.
* `createImportMap: true` (or `createThreeJsImportMap()`) maps `three` for the
  `examples/jsm` modules (`importGLTFLoaderJsModule()`...); do it before they
  are imported.
* `object.position = ...` and `object.rotation = ...` copy into the existing
  objects (they are read-only in three.js); `object.position.x = 1` works too.
* Not bound (lights, other geometries and materials, loaders): bind them with
  your own extension types, see the skill.

Agent skill:
[skills/tekartik-three-js-scene](skills/tekartik-three-js-scene/SKILL.md).
