@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_three_js/three_js_interop.dart';
import 'package:test/test.dart';

/// A three.js like vector or euler: x, y, z and a copy method.
JSObject _fakeXyz(num x, num y, num z) {
  var object = JSObject();
  object['x'] = x.toJS;
  object['y'] = y.toJS;
  object['z'] = z.toJS;
  object['copy'] = ((JSObject other) {
    for (var key in ['x', 'y', 'z']) {
      object[key] = other[key];
    }
    return object;
  }).toJS;
  return object;
}

/// A three.js like Object3D: position and rotation are read-only properties
/// (`Object.defineProperties` with a value and no `writable` in three.js).
Object3DJs _fakeObject3D() {
  var object = JSObject();
  var objectClass = globalContext['Object'] as JSObject;
  for (var name in ['position', 'rotation']) {
    var descriptor = JSObject()
      ..['value'] = _fakeXyz(0, 0, 0)
      ..['configurable'] = true.toJS
      ..['enumerable'] = true.toJS;
    objectClass.callMethod(
      'defineProperty'.toJS,
      object,
      name.toJS,
      descriptor,
    );
  }
  return object as Object3DJs;
}

void main() {
  test('set position and rotation copy into the read-only properties', () {
    var object = _fakeObject3D();
    object.position = _fakeXyz(1, 2, 3) as Vector3Js;
    object.rotation = _fakeXyz(0.4, 0.6, 0) as EulerJs;
    expect(
      [object.position.x, object.position.y, object.position.z],
      [1, 2, 3],
    );
    expect(object.rotation.x, closeTo(0.4, 1e-9));
    expect(object.rotation.y, closeTo(0.6, 1e-9));
  });
}
