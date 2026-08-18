{{flutter_js}}
{{flutter_build_config}}

// Absichtlich ohne serviceWorkerSettings.
//
// Flutters Loader wuerde sonst eine bestehende Registrierung uebernehmen und
// durch flutter_service_worker.js ersetzen. Diese Datei cached seit Flutter
// 3.44 aber nichts mehr, sondern meldet sich beim Aktivieren selbst ab — sie
// raeumt nur noch Altbestaende weg. Sie wuerde damit den eigenen Worker aus
// web/sw.js mitreissen, kaum dass er sich registriert hat.
//
// Ohne Argument kehrt loadServiceWorker() sofort zurueck und ruehrt gar keine
// Registrierung an. Die Verwaltung liegt vollstaendig in web/index.html.
//
// Diese Datei ersetzt die Standardvorlage von Flutter. Weicht sie nach einem
// Flutter-Update vom Original ab, steht es in
// packages/flutter_tools/lib/src/web/bootstrap.dart.
_flutter.loader.load();
