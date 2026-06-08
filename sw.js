// ─────────────────────────────────────────────────────────────
//  NCL Deals Service Worker
//  HOW TO FORCE AN UPDATE: change the version number below.
//  The app will silently update itself in the background and
//  reload automatically — no action needed from students.
// ─────────────────────────────────────────────────────────────
const VERSION = "ncl-deals-20260608230646";
const ASSETS  = ["/", "/index.html", "/manifest.json"];

// ── Install: cache assets, activate immediately ──────────────
self.addEventListener("install", e => {
  self.skipWaiting();
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(ASSETS)));
});

// ── Activate: wipe old caches, take control of all tabs ──────
self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())  // take over ALL open tabs immediately
  );
});

// ── Fetch: network-first for HTML, cache-first for assets ────
self.addEventListener("fetch", e => {
  const isHTML = e.request.mode === "navigate" ||
                 e.request.url.endsWith(".html") ||
                 e.request.url.endsWith("/");

  if (isHTML) {
    e.respondWith(
      fetch(e.request)
        .then(res => {
          const clone = res.clone();
          caches.open(VERSION).then(c => c.put(e.request, clone));
          return res;
        })
        .catch(() => caches.match(e.request))
    );
  } else {
    e.respondWith(
      caches.match(e.request).then(cached => cached || fetch(e.request))
    );
  }
});

// ── Message: page can ask SW to skipWaiting and reload ───────
self.addEventListener("message", e => {
  if (e.data === "skipWaiting") self.skipWaiting();
});
