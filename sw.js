// Service worker: guarda la app para que abra sin señal.
// Los datos NO pasan por acá (van a Supabase / cola local).
const CACHE = 'kick-challenge-v3';
const ARCHIVOS = ['./', './index.html', './config.js', './manifest.json', './icon-192.png', './icon-512.png', './icon-180.png',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'];
const EXTERNOS = ['cdn.jsdelivr.net', 'fonts.googleapis.com', 'fonts.gstatic.com'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => Promise.allSettled(ARCHIVOS.map(u => c.add(u)))).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin && !EXTERNOS.includes(url.hostname)) return;   // Supabase: directo a la red
  // Primero la red (así siempre tenés la última versión); si no hay señal, lo guardado
  e.respondWith(
    fetch(req).then(res => {
      if (res.ok || res.type === 'opaque') { const copia = res.clone(); caches.open(CACHE).then(c => c.put(req, copia)); }
      return res;
    }).catch(() => caches.match(req).then(r => r || (req.mode === 'navigate' ? caches.match('./index.html') : undefined)))
  );
});
