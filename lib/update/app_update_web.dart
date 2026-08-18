import 'dart:js_interop';

/// The Dart side of the update bridge that `web/index.html` sets up.
///
/// The service worker registration lives in plain JavaScript rather than here
/// because it has to run before Dart does — a new version has usually been
/// found and installed by the time the app is ready to ask about it.
@JS('nomenEst')
external _UpdateBridge? get _bridge;

extension type _UpdateBridge._(JSObject _) implements JSObject {
  external bool get updateReady;
  external set onUpdateReady(JSFunction callback);
  external void applyUpdate();
}

/// Calls [onReady] once a new version has been downloaded and is waiting.
///
/// Also fires straight away if the update arrived before the app got here,
/// which is the common case: the worker installs while Flutter is still
/// starting up.
void watchForUpdate(void Function() onReady) {
  final bridge = _bridge;
  if (bridge == null) return;

  bridge.onUpdateReady = (() => onReady()).toJS;
  if (bridge.updateReady) onReady();
}

bool updateIsReady() => _bridge?.updateReady ?? false;

/// Hands over to the waiting worker, which reloads the page as it takes over.
void applyUpdate() => _bridge?.applyUpdate();
