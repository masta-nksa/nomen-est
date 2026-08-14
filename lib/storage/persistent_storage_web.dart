import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Asks the browser not to evict the class sets when storage runs low.
///
/// Chrome/Edge/Firefox honour this; Safari does not document it, which is why
/// the app also tells iOS users to install it to the home screen first.
void requestPersistentStorage() {
  web.window.navigator.storage.persist().toDart.catchError((Object _) => false.toJS);
}
