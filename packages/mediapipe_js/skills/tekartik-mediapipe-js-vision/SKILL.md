---
name: tekartik-mediapipe-js-vision
description: >-
  Use when running MediaPipe Tasks Vision face landmark detection from Dart web
  code with tekartik_mediapipe_js: importMediapipeVisionModule,
  MediaPipeVisionModuleJs, filesetResolverProto, MpvFilesetResolverJs,
  forVisionTasks, MpvFilesetJs, faceLandmarkerProto, FaceLandmarkerProtoJs,
  createFromOptions, FaceLandmarkerJs, detect, detectForVideo, setOptions,
  FaceLandmarkerOptionsJs, FaceLandmarkerBaseOptionsJs, TexImageSourceJs,
  optionsRunningModeImage/Video, optionsDelegateGpu,
  optionsFaceLandmarkerModelAssetPath, mediaPipeLatestVersion.
---

# MediaPipe vision js bindings (tekartik_mediapipe_js)

`tekartik_mediapipe_js` is a small, experimental `dart:js_interop` binding over
the `@mediapipe/tasks-vision` JavaScript module, loaded at runtime from the
jsDelivr CDN. Today it only covers the `FaceLandmarker` task; anything else in
the module has to be bound by hand.

## Guidelines

* Git dependency (not on pub.dev), alongside `web`:
  ```yaml
  dependencies:
    web: '>=1.0.0'
    tekartik_mediapipe_js:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/mediapipe_js
  ```
* Single import: `package:tekartik_mediapipe_js/mediapipe_js_interop.dart`.
  Web only (`dart:js_interop`): use it from `web/main.dart` of a webdev app or
  from a `@TestOn('browser')` test, never from VM code.
* Load the module once with `await importMediapipeVisionModule()`. It resolves
  `https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@<version>` with
  `importModule` and returns a `MediaPipeVisionModuleJs`. The default version
  is `mediaPipeLatestVersion` (a `pub_semver` `Version`); pass
  `version: Version(0, 10, 17)` to pin another one, importing `Version` from
  `package:tekartik_common_utils/version_utils.dart` (this package does not
  re-export it).
* Two members are bound on the module: `filesetResolverProto`
  (`MpvFilesetResolverJs`, the JS `FilesetResolver`) and `faceLandmarkerProto`
  (`FaceLandmarkerProtoJs`, the JS `FaceLandmarker` class object).
* Startup sequence, always in this order: `forVisionTasks()` on the fileset
  resolver (returns `Future<MpvFilesetJs>`, downloads the wasm loader; the
  default `basePath` is the `/wasm` folder of `mediaPipeLatestVersion`, pass
  `basePath:` to self-host), then
  `faceLandmarkerProto.createFromOptions(fileset, options)` which returns
  `Future<FaceLandmarkerJs>`. Keep that instance in a variable: creating it
  downloads the model and initialises the wasm runtime.
* `FaceLandmarkerOptionsJs({numFaces, baseOptions, outputFaceBlendshapes,
  outputFacialTransformationMatrixes, runningMode})`; `baseOptions` is
  `FaceLandmarkerBaseOptionsJs({modelAssetPath, delegate})`. Use the
  constants `optionsFaceLandmarkerModelAssetPath` (the hosted float16
  `face_landmarker.task`), `optionsDelegateGpu` (`'GPU'`),
  `optionsRunningModeImage` (`'IMAGE'`) and `optionsRunningModeVideo`
  (`'VIDEO'`) instead of raw strings.
* Detection must match the running mode: `detect(TexImageSourceJs)` needs
  `IMAGE`, `detectForVideo(TexImageSourceJs, double timestamp)` needs `VIDEO`
  (`timestamp` is typically `videoElement.currentTime`). Switch with
  `landmarker.setOptions(FaceLandmarkerOptionsJs(runningMode: ...))`:
  `setOptions` merges, so a partial options object only changes the fields it
  carries. Track the current mode yourself, the only readable option is the
  `runningMode` getter.
* Build the input with `TexImageSourceJs.fromImageElement(web.HTMLImageElement)`
  or `TexImageSourceJs.fromVideoElement(web.HTMLVideoElement)`; there is no
  constructor for `ImageBitmap`, `ImageData`, `HTMLCanvasElement` or
  `OffscreenCanvas` yet.
* `FaceLandmarkerResultJs` is an opaque `JSObject` extension type with no
  members. Inspect it with `jsAnyToDebugString` / `jsObjectKeys` from
  `package:tekartik_js_utils_interop/js_converter.dart` and
  `object_keys.dart` (a dependency of this package), or declare your own
  `extension on FaceLandmarkerResultJs` with `external` getters
  (`faceLandmarks`, `faceBlendshapes`, ...) for what you need.
* Everything is `external`, so failures surface as JS exceptions at runtime:
  guard `importMediapipeVisionModule` and `createFromOptions` in a
  `try`/`catch`, and expect a CDN round trip on first use.

## Examples

### Create a face landmarker

```dart
import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';

Future<FaceLandmarkerJs> createFaceLandmarker() async {
  var visionJs = await importMediapipeVisionModule();
  var fileset = await visionJs.filesetResolverProto.forVisionTasks();
  return await visionJs.faceLandmarkerProto.createFromOptions(
    fileset,
    FaceLandmarkerOptionsJs(
      numFaces: 1,
      baseOptions: FaceLandmarkerBaseOptionsJs(
        modelAssetPath: optionsFaceLandmarkerModelAssetPath,
        delegate: optionsDelegateGpu,
      ),
      outputFaceBlendshapes: true,
      outputFacialTransformationMatrixes: true,
      runningMode: optionsRunningModeImage,
    ),
  );
}
```

### Detect on an image element

```dart
import 'package:tekartik_js_utils_interop/js_converter.dart';
import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';
import 'package:web/web.dart' as web;

Future<void> detectImage(FaceLandmarkerJs landmarker) async {
  landmarker.setOptions(
    FaceLandmarkerOptionsJs(runningMode: optionsRunningModeImage),
  );
  var image = web.document.getElementById('img1') as web.HTMLImageElement;
  var result = landmarker.detect(TexImageSourceJs.fromImageElement(image));
  print(jsAnyToDebugString(result));
}
```

### Detect on the current video frame

```dart
import 'package:tekartik_js_utils_interop/object_keys.dart';
import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';
import 'package:web/web.dart' as web;

var lastRunningMode = optionsRunningModeImage;

void detectVideo(FaceLandmarkerJs landmarker, web.HTMLVideoElement video) {
  if (lastRunningMode != optionsRunningModeVideo) {
    lastRunningMode = optionsRunningModeVideo;
    landmarker.setOptions(
      FaceLandmarkerOptionsJs(runningMode: optionsRunningModeVideo),
    );
  }
  var result = landmarker.detectForVideo(
    TexImageSourceJs.fromVideoElement(video),
    video.currentTime,
  );
  print(jsObjectKeys(result));
}
```

### Pin a version and self-host the wasm files

```dart
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';

Future<MpvFilesetJs> localFileset() async {
  var visionJs = await importMediapipeVisionModule(
    version: Version(0, 10, 17), // same as mediaPipeLatestVersion
  );
  return await visionJs.filesetResolverProto.forVisionTasks(
    basePath: '/assets/mediapipe/wasm',
  );
}
```

### Read a result with your own bindings

```dart
import 'dart:js_interop';

import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';

/// Not provided by the package: bind only what you consume.
extension FaceLandmarkerResultJsExt on FaceLandmarkerResultJs {
  @JS('faceLandmarks')
  external JSArray<JSArray<JSObject>> get faceLandmarks;
}

int faceCount(FaceLandmarkerResultJs result) => result.faceLandmarks.length;
```
