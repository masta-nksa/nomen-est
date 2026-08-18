'use strict';

// Eigener Service Worker. Flutter liefert seit 3.44 keinen mehr, der etwas
// cached: das erzeugte flutter_service_worker.js meldet sich beim Aktivieren
// selbst wieder ab und laeuft nur noch als Aufraeumer fuer Altbestaende.
// Damit die App im Flugmodus startet und Updates bemerkbar sind, macht sie es
// hier selbst — unabhaengig davon, was Flutter kuenftig generiert.
//
// BUILD wird beim Deploy durch den Commit-Hash ersetzt. Genau daran erkennt
// der Browser eine neue Fassung: aendert sich diese Datei nicht, gilt der
// Worker als unveraendert und niemand erfaehrt je von einem Update.
const BUILD = '__BUILD_ID__';
const CACHE = `nomen-est-${BUILD}`;

// Nur was zum Starten noetig ist. CanvasKit fehlt hier mit Absicht: es gibt es
// in mehreren Varianten, und jedes Geraet laedt genau eine davon. Vorab beide
// zu holen waeren rund 12 MB, von denen die Haelfte nie gebraucht wird — zur
// Laufzeit landet die passende ohnehin im Cache.
const SHELL = [
  './',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/apple-touch-icon.png',
  'sqlite3.wasm',
  'drift_worker.js',
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    // Einzeln und fehlertolerant: eine umbenannte Datei wuerde bei
    // cache.addAll() die ganze Installation scheitern lassen und die App auf
    // dem alten Stand einfrieren. Was fehlt, kommt zur Laufzeit nach.
    await Promise.allSettled(SHELL.map((path) => cache.add(new Request(path, {cache: 'reload'}))));
  })());
  // Kein skipWaiting: der neue Worker wartet, bis die App den Wechsel
  // ausloest. Sonst tauschte sich die App waehrend einer Lektion unter der
  // laufenden Sitzung aus.
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const names = await caches.keys();
    await Promise.all(
      names.filter((name) => name.startsWith('nomen-est-') && name !== CACHE)
           .map((name) => caches.delete(name)),
    );
    await self.clients.claim();
  })());
});

self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});

/// Nur vollstaendige 200er sind cachebar: cache.put wirft bei Teilantworten
/// (206), und response.ok schliesst die nicht aus.
function store(cache, request, response) {
  if (response && response.status === 200) cache.put(request, response.clone());
}

/// Seiten immer zuerst aus dem Netz: sonst bliebe eine kaputte gecachte
/// index.html fuer immer stehen, und genau daraus entstehen die PWAs, die sich
/// nie mehr reparieren lassen.
async function networkFirst(request, cache) {
  try {
    const response = await fetch(request);
    store(cache, request, response);
    return response;
  } catch (error) {
    const cached = await cache.match(request) || await cache.match('./');
    if (cached) return cached;
    throw error;
  }
}

/// Alles Uebrige zuerst aus dem Cache. Der Cachename traegt den Build, ein
/// neuer Build beginnt also mit leerem Cache und holt sich alles frisch —
/// veraltete Dateien kann diese Strategie damit nicht ausliefern.
async function cacheFirst(request, cache) {
  const cached = await cache.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  // Bewusst ohne Pruefung auf response.type: CanvasKit wird per import()
  // geladen, und das laeuft auch bei gleicher Herkunft im CORS-Modus. Ein
  // Filter auf 'basic' liesse ausgerechnet den Renderer aussen vor — die App
  // startete dann offline nicht. Fremde Herkuenfte sind bereits vorher heraus.
  store(cache, request, response);
  return response;
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // Die Klassendaten liegen in IndexedDB bzw. OPFS, je nachdem was der
  // Browser kann. Beides laeuft nicht ueber fetch, wird hier also nie
  // angefasst und von einem Update nie beruehrt.
  const isPage = request.mode === 'navigate';
  const isEntry = url.pathname.endsWith('/flutter_bootstrap.js');

  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    return (isPage || isEntry) ? networkFirst(request, cache) : cacheFirst(request, cache);
  })());
});
