# tekartik_mediapipe_js

Experimental `dart:js_interop` bindings for the
[MediaPipe Tasks Vision](https://ai.google.dev/edge/mediapipe/solutions/vision/face_landmarker/web_js)
JavaScript module, loaded at runtime from jsDelivr. Only the face landmarker
is bound.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  web: '>=1.0.0'
  tekartik_mediapipe_js:
    git:
      url: https://github.com/tekartik/app_web_utils.dart
      path: packages/mediapipe_js
```

Web only (dart2js and dart2wasm), in a browser page. Load the module, create
the landmarker once, then detect on an image (or a video frame with
`detectForVideo` in `VIDEO` mode):

```dart
import 'package:tekartik_mediapipe_js/mediapipe_js_interop.dart';
import 'package:web/web.dart' as web;

Future<FaceLandmarkerJs> createFaceLandmarker() async {
  var vision = await importMediapipeVisionModule();
  var fileset = await vision.filesetResolverProto.forVisionTasks();
  return await vision.faceLandmarkerProto.createFromOptions(
    fileset,
    FaceLandmarkerOptionsJs(
      numFaces: 1,
      baseOptions: FaceLandmarkerBaseOptionsJs(
        modelAssetPath: optionsFaceLandmarkerModelAssetPath,
        delegate: optionsDelegateGpu,
      ),
      runningMode: optionsRunningModeImage,
    ),
  );
}

FaceLandmarkerResultJs detectFaces(
  FaceLandmarkerJs landmarker,
  web.HTMLImageElement image,
) => landmarker.detect(TexImageSourceJs.fromImageElement(image));
```

## Common pitfalls

* The module, the wasm files and the model come from CDNs on first use: guard
  the setup with try/catch. `importMediapipeVisionModule(version:)` and
  `forVisionTasks(basePath:)` pin or self-host them.
* `detect` needs the `IMAGE` running mode, `detectForVideo` the `VIDEO` one,
  with a timestamp in milliseconds (`web.window.performance.now()`, not the
  video `currentTime`, which is in seconds)
  (`setOptions` switches).
* `FaceLandmarkerResultJs` has no members yet: bind what you read
  (`faceLandmarks`...) with your own extension.

Agent skill:
[skills/tekartik-mediapipe-js-vision](skills/tekartik-mediapipe-js-vision/SKILL.md).
