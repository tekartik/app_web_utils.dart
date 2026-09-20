---
name: tekartik-three-js-scene
description: >-
  Use when rendering a three.js scene from Dart web code with
  tekartik_three_js: importThreeJsModule, createThreeJsImportMap,
  threeJsLatestVersion, SceneJs, PerspectiveCameraJs, WebGLRendererJs with
  WebGLRendererParametersJs, BoxGeometryJs, MeshBasicMaterialJs with
  MeshBasicMaterialParametersJs, MeshJs, Object3DJs add/position/rotation,
  Vector3Js, EulerJs, importGLTFLoaderJsModule, importFBXLoaderJsModule, and
  binding three.js classes the package does not cover yet.
---

# three.js scenes from Dart (tekartik_three_js)

`tekartik_three_js` is an experimental `dart:js_interop` binding over the
three.js ES module, loaded at runtime from the jsDelivr CDN. It covers just
enough of the API for a basic scene (renderer, scene, perspective camera, box
geometry, basic material, mesh, vector and euler); anything else you bind
yourself on top of the same `JSObject` extension types.

## Guidelines

* Git dependency (not on pub.dev), alongside `web`:
  ```yaml
  dependencies:
    web: '>=1.1.0'
    tekartik_three_js:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/three_js
  ```
* Single import: `package:tekartik_three_js/three_js_interop.dart`. Web only
  (`dart:js_interop`): `web/main.dart` of a webdev app, or a
  `@TestOn('browser')` test.
* **Always `await importThreeJsModule()` first.** Every constructor
  (`SceneJs()`, `BoxGeometryJs(...)`, `WebGLRendererJs(...)`, `Vector3Js(...)`,
  `EulerJs(...)`, ...) reads a module cached by that call, and throws on a null
  check if it has not completed. The import is memoized, so calling it again is
  free and always returns the same `ThreeModuleJs`.
* `importThreeJsModule({version, createImportMap})` loads
  `https://cdn.jsdelivr.net/npm/three@<version>/build/three.module.js`.
  `version` defaults to `threeJsLatestVersion` (a `pub_semver` `Version`, from
  `package:pub_semver/pub_semver.dart`). Pass `createImportMap: true` (or call
  `createThreeJsImportMap()` before anything else) to inject a
  `<script type="importmap">` mapping the bare specifier `three` to that url:
  required for the `examples/jsm` sub modules, which `import ... from 'three'`.
  An import map must be in the document before the first module loads, so do
  this at the very top of `main()`. `getThreeJsImports({version})` returns that
  mapping as a `cv` `Model` if you want to write the import map yourself.
* Build a scene like in JavaScript: `SceneJs()`, `PerspectiveCameraJs(fov,
  aspect, near, far)` (degrees, `width / height`, 0.1, 1000 typically), a
  `WebGLRendererJs(WebGLRendererParametersJs(canvas: , alpha: , antialias: ))`,
  then `renderer.setSize(width, height)` and append `renderer.domElement` to
  the document unless you passed your own `canvas`.
* Objects: `MeshJs(geometry, material)` with `BoxGeometryJs(width, height,
  depth, [widthSegments, heightSegments, depthSegments])` and
  `MeshBasicMaterialJs(MeshBasicMaterialParametersJs(color: 0x00ff00))`. All
  of `SceneJs`, `MeshJs`, `CameraJs` are `Object3DJs`, which exposes `add()`,
  `position` (`Vector3Js`, with `x`/`y`/`z` `num` getters and setters) and
  `rotation` (`EulerJs`, `x`/`y`/`z` in radians plus `order`).
* Render with `renderer.render(scene, camera)`, and animate with
  `web.window.requestAnimationFrame(callback.toJS)` re-registering on each
  frame; there is no animation loop helper in the package.
* Unbound APIs: `GLTFLoaderModuleJs` and `FBXLoaderModuleJs`, returned by
  `importGLTFLoaderJsModule()` / `importFBXLoaderJsModule()`, are opaque; the
  loaders themselves, lights, other geometries and materials are not bound.
  Reach them with `dart:js_interop_unsafe` (`module['GLTFLoader'] as
  JSFunction` + `callAsConstructor`) or declare your own extension types, and
  keep the `...Js` suffix convention. `SceneParametersJs` and
  `PerspectiveCameraParametersJs` exist but are unused leftovers, ignore them.
* Everything is external JS: wrap the setup in a `try`/`catch` and expect a CDN
  round trip (and a WebGL context) at first render. There is no memory
  management helper, call `dispose` through interop yourself for long-lived
  apps.

## Examples

### Rotating cube (full web/main.dart)

```dart
import 'dart:js_interop';

import 'package:tekartik_three_js/three_js_interop.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  var window = web.window;
  await importThreeJsModule(createImportMap: true);

  var scene = SceneJs();
  var camera = PerspectiveCameraJs(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000,
  );
  var renderer = WebGLRendererJs(
    WebGLRendererParametersJs(alpha: true, antialias: true),
  );
  renderer.setSize(window.innerWidth, window.innerHeight);
  web.document.body!.appendChild(renderer.domElement);

  var cube = MeshJs(
    BoxGeometryJs(1, 1, 1.3),
    MeshBasicMaterialJs(MeshBasicMaterialParametersJs(color: 0x00ff00)),
  );
  scene.add(cube);
  camera.position.z = 6;

  void animate(num timestamp) {
    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;
    renderer.render(scene, camera);
    window.requestAnimationFrame(animate.toJS);
  }

  window.requestAnimationFrame(animate.toJS);
}
```

### Render into an existing canvas, once

```dart
import 'package:tekartik_three_js/three_js_interop.dart';
import 'package:web/web.dart' as web;

Future<void> renderCube(web.HTMLCanvasElement canvas) async {
  await importThreeJsModule();
  var renderer = WebGLRendererJs(
    WebGLRendererParametersJs(canvas: canvas, antialias: true),
  );
  renderer.setSize(canvas.width, canvas.height, false);

  var scene = SceneJs();
  var camera = PerspectiveCameraJs(
    50,
    canvas.width / canvas.height,
    0.1,
    2000,
  );
  camera.position.z = 5;

  var mesh = MeshJs(
    BoxGeometryJs(1, 1, 1),
    MeshBasicMaterialJs(MeshBasicMaterialParametersJs(color: 0xff0000)),
  );
  mesh.rotation = EulerJs(0.4, 0.6, 0);
  mesh.position = Vector3Js(0, 0, 0);
  scene.add(mesh);

  renderer.render(scene, camera);
}
```

### Pin a version and prepare the import map first

```dart
import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_three_js/three_js_interop.dart';

Future<void> main() async {
  var version = Version(0, 169, 0); // == threeJsLatestVersion
  // Must run before any module is imported.
  await createThreeJsImportMap(version: version);
  await importThreeJsModule(version: version);
  print(getThreeJsImports(version: version)); // {three: https://cdn...}
}
```

### Bind a class the package does not expose (GLTFLoader)

```dart
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_three_js/three_js_interop.dart';

extension type GltfLoaderJs._(JSObject _) implements JSObject {}

extension GltfLoaderJsExt on GltfLoaderJs {
  @JS('loadAsync')
  external JSPromise<JSObject> _loadAsync(String url);

  Future<JSObject> loadAsync(String url) => _loadAsync(url).toDart;
}

Future<JSObject> loadModel(String url) async {
  await importThreeJsModule(createImportMap: true);
  var module = await importGLTFLoaderJsModule();
  var loader =
      (module['GLTFLoader'] as JSFunction).callAsConstructor<GltfLoaderJs>();
  return await loader.loadAsync(url);
}
```
