// NPS Clues — Service Worker
// Bump CACHE_VERSION whenever index.html (or any cached asset) changes.
// This forces old caches to be discarded on the next activate, so users
// don't get stuck on a stale offline copy after an update is deployed.
const CACHE_VERSION = 'nps-clues-v1';
const CACHE_NAME = CACHE_VERSION;

const APP_SHELL = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-192-maskable.png',
  './icons/icon-512.png',
  './icons/icon-512-maskable.png',
  './icons/icon-180.png',
  './icons/favicon.png',
  './icons/icon.svg'
];

// ── Install: pre-cache the app shell ──
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(APP_SHELL))
      .then(() => self.skipWaiting())
  );
});

// ── Activate: drop any caches from a previous version ──
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    ).then(() => self.clients.claim())
  );
});

// ── Fetch strategy ──
// index.html (and navigation requests generally): network-first, falling
// back to the cached copy when offline. This is a single self-contained
// app-shell file, so "network-first" means users on a live connection
// always get the latest deployed version, while offline/flaky-connection
// users still get a fully working cached copy instead of an error page.
//
// Everything else (icons, manifest): cache-first, since those rarely
// change and don't need to be re-fetched every load.
self.addEventListener('fetch', (event) => {
  const req = event.request;

  // Only handle GET requests; let everything else (POST, etc.) pass through
  if (req.method !== 'GET') return;

  const isNavigation = req.mode === 'navigate' ||
    (req.destination === 'document');

  if (isNavigation) {
    event.respondWith(
      fetch(req)
        .then((networkResp) => {
          // Keep the cache fresh with whatever we just fetched
          const respClone = networkResp.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put('./index.html', respClone));
          return networkResp;
        })
        .catch(() =>
          caches.match('./index.html').then((cached) => cached || caches.match(req))
        )
    );
    return;
  }

  // Static assets: cache-first, fall back to network, and opportunistically
  // update the cache with whatever the network returns.
  event.respondWith(
    caches.match(req).then((cached) => {
      if (cached) return cached;
      return fetch(req).then((networkResp) => {
        const respClone = networkResp.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(req, respClone));
        return networkResp;
      }).catch(() => cached);
    })
  );
});
