import 'dart:js_interop';

import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:web/web.dart' as web;

/// MediaPipe Vision module
extension type MediaPipeVisionModuleJs(JSObject _) implements JSObject {}

/// Media pipe vision module ext
extension MediaPipeVisionModuleJsExt on MediaPipeVisionModuleJs {
  /// Resolves the files required for the MediaPipe Task APIs.
  @JS('FilesetResolver')
  external MpvFilesetResolverJs get filesetResolverProto;

  /// Performs face landmarks detection on images.
  @JS('FaceLandmarker')
  external FaceLandmarkerProtoJs get faceLandmarkerProto;
}

/// type TexImageSource = ImageBitmap | ImageData | HTMLImageElement | HTMLCanvasElement | HTMLVideoElement | OffscreenCanvas
extension type TexImageSourceJs._(JSObject _) implements JSObject {
  /// From an image element
  TexImageSourceJs.fromImageElement(web.HTMLImageElement imageElement)
      : this._(imageElement);

  /// From a video element
  TexImageSourceJs.fromVideoElement(web.HTMLVideoElement videoElement)
      : this._(videoElement);
}

/// https://ai.google.dev/edge/api/mediapipe/js/tasks-vision.facelandmarker
extension type FaceLandmarkerJs(JSObject _) implements JSObject {}

/// FaceLandmarker ext
extension FaceLandmarkerJsExt on FaceLandmarkerJs {
  /// Sets new options for this FaceLandmarker.
  ///
  /// Calling setOptions() with a subset of options only affects those options. You can reset an option back to its default value by explicitly setting it to undefined.
  external void setOptions(FaceLandmarkerOptionsJs options);

  /// https://ai.google.dev/edge/api/mediapipe/js/tasks-vision.facelandmarker#facelandmarkerdetect
  @JS('detect')
  external FaceLandmarkerResultJs detect(TexImageSourceJs inputImage);

  /// Performs face landmarks detection on the provided video frame and waits synchronously for the response. Only use this method when the FaceLandmarker is created with running mode video.
  @JS('detectForVideo')
  external FaceLandmarkerResultJs detectForVideo(
      TexImageSourceJs inputVideo, double timestamp);
}

/// FaceLandmarkerProtoJs
extension type FaceLandmarkerProtoJs(JSObject _) implements JSObject {}

/// FaceLandmarkerProtoJs ext
extension FaceLandmarkerProtoJsExt on FaceLandmarkerProtoJs {
  /// Initializes the Wasm runtime and creates a new FaceLandmarker from the provided options.
  @JS('createFromOptions')
  external JSPromise<FaceLandmarkerJs> _createFromOptions(
      MpvFilesetJs wasmFileset, FaceLandmarkerOptionsJs faceLandmarkerOptions);

  /// Initializes the Wasm runtime and creates a new FaceLandmarker from the provided options.
  Future<FaceLandmarkerJs> createFromOptions(MpvFilesetJs wasmFileset,
          FaceLandmarkerOptionsJs faceLandmarkerOptions) =>
      _createFromOptions(wasmFileset, faceLandmarkerOptions).toDart;
}

/// delegate to Gpu
const optionsDelegateGpu = 'GPU';

/// Running mode video
const optionsRunningModeVideo = 'VIDEO';

/// Running mode image
const optionsRunningModeImage = 'IMAGE';

/// model assets path
const optionsFaceLandmarkerModelAssetPath =
    'https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task';

/// Options for the FaceLandmarker.
extension type FaceLandmarkerOptionsJs._(JSObject _) implements JSObject {
  /// Creates a new FaceLandmarkerOptions.
  external FaceLandmarkerOptionsJs(
      {int numFaces,
      FaceLandmarkerBaseOptionsJs baseOptions,
      bool outputFaceBlendshapes,
      bool outputFacialTransformationMatrixes,
      String runningMode});
}

/// FaceLandmarkerOptionsJs ext
extension FaceLandmarkerOptionsJsExt on FaceLandmarkerOptionsJs {
  /// Running mode
  external String? get runningMode;
}

/// Base Options for the FaceLandmarker.
extension type FaceLandmarkerBaseOptionsJs._(JSObject _) implements JSObject {
  /// Creates a new FaceLandmarkerBaseOptions.
  external FaceLandmarkerBaseOptionsJs(
      {String modelAssetPath, String delegate});
}

/// Resolves the files required for the MediaPipe Task APIs.
extension type MpvFilesetResolverJs(JSObject _) implements JSObject {}

/// File resolver ext
extension MpvFilesetResolverJsExt on MpvFilesetResolverJs {
  /// Resolves the files required for the MediaPipe Task APIs.
  @JS('forVisionTasks')
  external JSPromise<MpvFilesetJs> _forVisionTasks(String basePath);

  /// Resolves the files required for the MediaPipe Task APIs.
  Future<MpvFilesetJs> forVisionTasks({String? basePath}) async {
    basePath ??= _mediaPipeVisionBaseUrl.withVersion(mediaPipeLatestVersion);
    return await _forVisionTasks(basePath).toDart;
  }
}

/// Fileset for MediaPipe Vision tasks.
extension type MpvFilesetJs(JSObject _) implements JSObject {}

extension on String {
  String withVersion(Version version) =>
      replaceAll('{{version}}', version.toString());
}

const _mediapipeModuleBase =
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@{{version}}';

/// MediaPipe Vision base URL
const _mediaPipeVisionBaseUrl =
    'https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@{{version}}/wasm';

/// Latest version of MediaPipe
final mediaPipeLatestVersion = Version(0, 10, 17);

/// Import the MediaPipe Vision module.
Future<MediaPipeVisionModuleJs> importMediapipeVisionModule(
    {Version? version}) async {
  version ??= mediaPipeLatestVersion;
  var module =
      await importModule(_mediapipeModuleBase.withVersion(version).toJS).toDart;
  return MediaPipeVisionModuleJs(module);
}

/// FaceLandmarkerResultJs
extension type FaceLandmarkerResultJs._(JSObject _) implements JSObject {}
