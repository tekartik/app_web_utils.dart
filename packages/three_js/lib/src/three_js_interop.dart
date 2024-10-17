// ignore_for_file: public_member_api_docs
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:cv/cv.dart';
import 'package:cv/cv_json.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:web/web.dart' as web;

@JS('imports')
external JSObject? get threeJsImports;

/// Three js module
extension type ThreeModuleJs._(JSObject _) implements JSObject {}

extension type GLTFLoaderModuleJs._(JSObject _) implements JSObject {}
extension type FBXLoaderModuleJs._(JSObject _) implements JSObject {}

/// Three js module ext
extension ThreeModuleJsExt on ThreeModuleJs {
  /// WebGLRenderer
  @JS('WebGLRenderer')
  external WebGLRendererProtoJs get webGLRendererProto;

  @JS('BoxGeometry')
  external BoxGeometryProtoJs get boxGeometryProto;

  @JS('MeshBasicMaterial')
  external MeshBasicMaterialProtoJs get meshBasicMaterialProto;

  @JS('Mesh')
  external MeshProtoJs get meshProto;

  @JS('Scene')
  external SceneProtoJs get sceneProto;

  @JS('PerspectiveCamera')
  external PerspectiveCameraProtoJs get perspectiveCameraProto;
}

/// Latest version of MediaPipe
final threeJsLatestVersion = Version(0, 169, 0);

const _threeJsModuleBase =
    'https://cdn.jsdelivr.net/npm/three@{{version}}/build/three.module.js';

extension on String {
  String withVersion(Version version) =>
      replaceAll('{{version}}', version.toString());
}

ThreeModuleJs get _threeJsModule => _threeJsModuleOrNull!;
ThreeModuleJs? _threeJsModuleOrNull;

/// Import the three js module.
Future<ThreeModuleJs> importThreeJsModule(
    {Version? version, bool createImportMap = false}) async {
  if (_threeJsModuleOrNull != null) {
    return _threeJsModule;
  }
  version ??= threeJsLatestVersion;
  if (createImportMap) {
    await createThreeJsImportMap(version: version);
  }
  var module =
      await importModule(_threeJsModuleBase.withVersion(version).toJS).toDart;

  /// Create importmaps dynamically
  return _threeJsModuleOrNull = ThreeModuleJs._(module);
}

Model getThreeJsImports({Version? version}) {
  version ??= threeJsLatestVersion;
  return Model.from({'three': _threeJsModuleBase.withVersion(version)});
}

var _importMapDone = false;
Future<void> createThreeJsImportMap({Version? version}) async {
  if (_importMapDone) {
    return;
  }
  _importMapDone = true;
  var importMap = newModel();
  importMap['imports'] = newModel()
    ..addAll(getThreeJsImports(version: version));

  final completer = Completer<void>.sync();
  var script = web.HTMLScriptElement();
  script.type = 'importmap';
  script.onError.listen((e) {
    completer.completeError(Exception('importmap script not loaded'));
  });
  // ignore: unsafe_html
  script.text = jsonEncode(importMap);
  web.document.head!.appendChild(script);
  if (!completer.isCompleted) {
    completer.complete();
  }
  return completer.future;
  // No need to wait
}

const _gltfLocalerJsModuleBase =
    'https://cdn.jsdelivr.net/npm/three@{{version}}/examples/jsm/loaders/GLTFLoader.js';
const _fbxLocalerJsModuleBase =
    'https://cdn.jsdelivr.net/npm/three@{{version}}/examples/jsm/loaders/FBXLoader.js';
Future<GLTFLoaderModuleJs> importGLTFLoaderJsModule({Version? version}) async {
  version ??= threeJsLatestVersion;
  var url = _gltfLocalerJsModuleBase.withVersion(version);
  var module = await importModule(url.toJS).toDart;
  return GLTFLoaderModuleJs._(module);
}

Future<FBXLoaderModuleJs> importFBXLoaderJsModule({Version? version}) async {
  version ??= threeJsLatestVersion;
  var module =
      await importModule(_fbxLocalerJsModuleBase.withVersion(version).toJS)
          .toDart;
  return FBXLoaderModuleJs._(module);
}

/// WebGLRenderer proto
extension type WebGLRendererProtoJs._(JSObject _) implements JSObject {}

/// Extension
extension WebGLRendererProtoJsExt on WebGLRendererProtoJs {
  /// Create renderer
  WebGLRendererJs create(WebGLRendererParametersJs parameters) {
    return (this as JSFunction).callAsConstructor(parameters);
  }
}

extension type BufferGeometryJs._(JSObject _) implements JSObject {}
extension type BoxGeometryJs._(JSObject _) implements BufferGeometryJs {
  factory BoxGeometryJs(num width, num height, num depth,
          [num? widthSegments, num? heightSegments, num? depthSegments]) =>
      _threeJsModule.boxGeometryProto.create(
          width, height, depth, widthSegments, heightSegments, depthSegments);
}
extension type BoxGeometryProtoJs._(JSObject _) implements JSObject {}

extension BoxGeometryProtoJsExt on BoxGeometryProtoJs {
  /// Create renderer
  BoxGeometryJs create(num width, num height, num depth,
      [num? widthSegments, num? heightSegments, num? depthSegments]) {
    return (this as JSFunction).callAsConstructorVarArgs([
      width.toJS,
      height.toJS,
      depth.toJS,
      if (widthSegments != null) widthSegments.toJS,
      if (widthSegments != null && heightSegments != null) heightSegments.toJS,
      if (widthSegments != null &&
          heightSegments != null &&
          depthSegments != null)
        depthSegments.toJS
    ]);
  }
}

extension type MeshJs._(JSObject _) implements Object3DJs {
  factory MeshJs(BufferGeometryJs geometry, MaterialJs material) =>
      _threeJsModule.meshProto.create(geometry, material);
}
extension type MeshProtoJs._(JSObject _) implements JSObject {}

extension MeshProtoJsExt on MeshProtoJs {
  /// Create renderer
  MeshJs create(BufferGeometryJs geometry, MaterialJs material) {
    return (this as JSFunction).callAsConstructor(geometry, material);
  }
}

extension type MaterialJs._(JSObject _) implements JSObject {}
extension type MeshBasicMaterialJs._(JSObject _) implements MaterialJs {
  factory MeshBasicMaterialJs(MeshBasicMaterialParametersJs parameters) =>
      _threeJsModule.meshBasicMaterialProto.create(parameters);
}
extension type MeshBasicMaterialProtoJs._(JSObject _) implements JSObject {}

extension MeshBasicMaterialProtoJsExt on MeshBasicMaterialProtoJs {
  /// Create renderer
  MeshBasicMaterialJs create(MeshBasicMaterialParametersJs parameters) =>
      (this as JSFunction).callAsConstructor(parameters);
}

extension type MeshBasicMaterialParametersJs._(JSObject _) implements JSObject {
  /// Constructor
  external MeshBasicMaterialParametersJs({
    int color,
  });
}

extension MeshBasicMaterialParametersJsExt on MeshBasicMaterialParametersJs {
  external JSAny? /*Color|String|num*/ get color;

  external set color(JSAny? /*Color|String|num*/ v);
}
//
// Object3D
//

extension type Object3DJs._(JSObject _) implements JSObject {}

extension Object3DJsExt on Object3DJs {
  /// Adds object as child of this object.
  external void add(Object3DJs object);

  external set position(Vector3Js position);
  external Vector3Js get position;

  /// Object's local rotation (Euler angles), in radians.
  external EulerJs get rotation;
  external set rotation(EulerJs rotation);
}

// Scene

extension type SceneJs._(JSObject _) implements Object3DJs {
  factory SceneJs() => _threeJsModule.sceneProto.create();
}
extension type SceneProtoJs._(JSObject _) implements JSObject {}

extension SceneProtoJsExt on SceneProtoJs {
  /// Create renderer
  SceneJs create() => (this as JSFunction).callAsConstructor();
}

extension type SceneParametersJs._(JSObject _) implements JSObject {
  /// Constructor
  external SceneParametersJs({
    int color,
  });
}

// Camera

extension type CameraJs._(JSObject _) implements Object3DJs {}
extension type PerspectiveCameraJs._(JSObject _) implements CameraJs {
  /// .aspect : Float
  /// Camera frustum aspect ratio, usually the canvas width / canvas height. Default is 1 (square canvas).
  ///
  /// .far : Float
  /// Camera frustum far plane. Default is 2000.
  ///
  /// .fov : Float
  /// Camera frustum vertical field of view, from bottom to top of view, in degrees. Default is 50.
  ///
  /// .near : Float
  /// Camera frustum near plane. Default is 0.1.
  ///
  factory PerspectiveCameraJs(
          double fov, double aspect, double near, double far) =>
      _threeJsModule.perspectiveCameraProto.create(fov, aspect, near, far);
}
extension type PerspectiveCameraProtoJs._(JSObject _) implements JSObject {}

extension PerspectiveCameraProtoJsExt on PerspectiveCameraProtoJs {
  /// Create renderer
  PerspectiveCameraJs create(
          double fov, double aspect, double near, double far) =>
      (this as JSFunction)
          .callAsConstructor(fov.toJS, aspect.toJS, near.toJS, far.toJS);
}

extension type PerspectiveCameraParametersJs._(JSObject _) implements JSObject {
  /// Constructor
  external PerspectiveCameraParametersJs({
    int color,
  });
}

// Vector 3
extension type VectorJs._(JSObject _) implements JSObject {}
extension type Vector3Js._(JSObject _) implements JSObject {
  factory Vector3Js(num x, num y, num z) =>
      (_threeJsModule['Vector3'] as JSFunction)
          .callAsConstructor(x.toJS, y.toJS, z.toJS);
}

extension Vector3JsExt on Vector3Js {
  external num get x;

  external set x(num v);

  external num get y;

  external set y(num v);

  external num get z;

  external set z(num v);
}

// Euler

extension type EulerJs._(JSObject _) implements JSObject {
  factory EulerJs(num x, num y, num z, [String? order]) =>
      (_threeJsModule['Euler'] as JSFunction)
          .callAsConstructor(x.toJS, y.toJS, z.toJS, order?.toJS);
}

extension EulerJsExt on EulerJs {
  external num get x;

  external set x(num v);

  external num get y;

  external set y(num v);

  external num get z;

  external set z(num v);

  external String get order;

  external set order(String v);
}
// WebGL Renderer

/// WebGLRenderer parameters
/// https://threejs.org/docs/#api/en/renderers/WebGLRenderer
extension type WebGLRendererParametersJs._(JSObject _) implements JSObject {
  /// Constructor
  external WebGLRendererParametersJs(
      {web.HTMLCanvasElement canvas,
      // default false
      bool alpha,
      // default false
      bool antialias});
}

/// WebGLRenderer
extension type WebGLRendererJs._(JSObject _) implements JSObject {
  factory WebGLRendererJs(WebGLRendererParametersJs parameters) =>
      _threeJsModule.webGLRendererProto.create(parameters);
}

extension WebGLRendererJsExt on WebGLRendererJs {
  external void setSize(num width, num height, [bool updateStyle]);
  external web.HTMLElement get domElement;

  /// Set size
  external void render(SceneJs scene, CameraJs camera);
}
