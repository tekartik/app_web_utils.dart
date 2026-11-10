// Runs a generated service worker (argument) in a minimal service worker
// environment: Cache API with an exact url match (cache.match without
// ignoreSearch), fetch, install/activate/fetch events. Exit code 0 when the
// app shell is served offline after install and downloadOffline caches the
// missing resources.
const fs = require('fs');
const code = fs.readFileSync(process.argv[2], 'utf8');
const origin = 'https://example.com';
const known = ['/', '/main.dart.js', '/other.js'];
let online = true;
const fetched = [];
function toUrl(value) {
  if (value.startsWith('http')) return value;
  return origin + (value.startsWith('/') ? value : '/' + value);
}
class Request {
  constructor(input) {
    this.url = typeof input === 'string' ? toUrl(input) : input.url;
    this.method = 'GET';
  }
}
class Response {
  constructor(body, url) {
    this.body = body;
    this.url = url;
    this.ok = true;
  }
  clone() { return this; }
  async json() { return JSON.parse(this.body); }
}
async function fetch(input) {
  const request = typeof input === 'string' ? new Request(input) : input;
  fetched.push(request.url);
  if (!online) throw new TypeError('offline ' + request.url);
  const path = request.url.substring(origin.length).split('?')[0];
  if (!known.includes(path)) {
    const response = new Response('', request.url);
    response.ok = false;
    return response;
  }
  return new Response('content of ' + path, request.url);
}
class Cache {
  constructor() { this.map = new Map(); }
  async addAll(requests) {
    for (const input of requests) {
      const request = typeof input === 'string' ? new Request(input) : input;
      const response = await fetch(request);
      if (!response.ok) throw new TypeError('bad response ' + request.url);
      this.map.set(request.url, response);
    }
  }
  async put(input, response) {
    this.map.set(new Request(input).url, response);
  }
  async match(input) { return this.map.get(new Request(input).url); }
  async keys() { return [...this.map.keys()].map((url) => new Request(url)); }
  async delete(input) { return this.map.delete(new Request(input).url); }
}
const stores = {};
const caches = {
  async open(name) { return (stores[name] ??= new Cache()); },
  async delete(name) { delete stores[name]; return true; },
};
const listeners = {};
const self = {
  location: { origin },
  origin,
  addEventListener(type, listener) { listeners[type] = listener; },
  skipWaiting() {},
};
const exported = new Function(
  'self', 'caches', 'Request', 'Response', 'fetch', 'origin', 'console',
  code + '\nreturn { downloadOffline };',
)(self, caches, Request, Response, fetch, origin, console);

async function dispatch(type, fields) {
  const promises = [];
  const event = Object.assign(
    {
      waitUntil: (p) => promises.push(p),
      respondWith: (p) => promises.push(p),
    },
    fields,
  );
  listeners[type](event);
  return await Promise.all(promises);
}

(async () => {
  await dispatch('install', {});
  await dispatch('activate', {});
  const content = await caches.open('flutter-app-cache');
  const cached = [...content.map.keys()];
  console.log('cached after activate: ' + JSON.stringify(cached));
  // Offline, the precached app shell must be served from the cache.
  online = false;
  let offlineOk = true;
  for (const path of ['/main.dart.js', '/']) {
    try {
      const [response] = await dispatch('fetch', { request: new Request(path) });
      console.log('offline ' + path + ': ' + response.body);
    } catch (e) {
      offlineOk = false;
      console.log('offline ' + path + ': failed ' + e.message);
    }
  }
  online = true;
  fetched.length = 0;
  let downloadOk = true;
  try {
    await exported.downloadOffline();
  } catch (e) {
    downloadOk = false;
    console.log('downloadOffline failed: ' + e.message);
  }
  console.log('downloadOffline fetched: ' + JSON.stringify(fetched));
  const hasOther = (await content.match('other.js')) !== undefined;
  console.log('other.js cached: ' + hasOther);
  console.log(offlineOk && downloadOk && hasOther ? 'RESULT ok' : 'RESULT failed');
  process.exit(offlineOk && downloadOk && hasOther ? 0 : 1);
})();
