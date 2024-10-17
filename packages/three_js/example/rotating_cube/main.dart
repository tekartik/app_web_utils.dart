// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:js_interop';

import 'package:tekartik_js_utils/js_utils_import.dart';

import 'package:tekartik_three_js/three_js_interop.dart';

import 'package:web/web.dart' as web;

Future<void> main() async {
  var window = web.window;
  await importThreeJsModule(createImportMap: true);
  print('ThreeJS loaded');
  try {
    final scene = SceneJs();
    var camera = PerspectiveCameraJs(
        75, window.innerWidth / window.innerHeight, 0.1, 1000);

    final renderer = WebGLRendererJs(
        WebGLRendererParametersJs(alpha: true, antialias: true));
    renderer.setSize(window.innerWidth, window.innerHeight);
    web.document.body!.append(renderer.domElement);

    final geometry = BoxGeometryJs(1, 1, 1.3);

    final material =
        MeshBasicMaterialJs(MeshBasicMaterialParametersJs(color: 0x00ff00));

    final cube = MeshJs(geometry, material);
    scene.add(cube);

    camera.position.z = 6;

    void draw() {
      renderer.render(scene, camera);
    }

    void animate() {
      void jsAnimate(num value) {
        cube.rotation.x += 0.01;
        cube.rotation.y += 0.01;
        draw();
        window.requestAnimationFrame(jsAnimate.toJS);
      }

      window.requestAnimationFrame(jsAnimate.toJS);
    }

    animate();
    print('DONE OK');
  } catch (e, st) {
    print('DONE ERROR');
    print(e);
    print(st);
  }
}
