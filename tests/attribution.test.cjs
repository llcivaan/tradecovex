const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');
const firstKey = 'tcx_attribution_first_v1';
const latestKey = 'tcx_attribution_latest_v1';
const now = Date.parse('2026-10-25T16:00:00Z');
const windowMs = 30 * 86400000;
const signup = 'https://app.tradecovex.com/signup';
function script() {
  if (fs.existsSync(path.join(root, 'attr.js'))) return fs.readFileSync(path.join(root, 'attr.js'), 'utf8');
  // Exercise the old capture code too, so RED failures demonstrate the actual gaps.
  return fs.readFileSync(path.join(root, 'index.html'), 'utf8')
    .match(/<script>\s*(\(function \(\) \{\s*var KEYS = \['utm_source'[\s\S]*?\}\)\(\);)\s*<\/script>/)[1];
}
function anchor(href) {
  return {
    nodeType: 1, href,
    matches: () => true,
    closest() { return this; },
    querySelectorAll: () => [],
    getAttribute() { return this.href; },
    setAttribute(_, value) { this.href = value; },
  };
}
function visit({ url = 'https://tradecovex.com/guides/copier', ref = '', storage = new Map(),
  hrefs = [signup], blocked = false, at = now } = {}) {
  const links = hrefs.map(anchor);
  const events = {};
  let observer;
  const localStorage = {
    getItem(key) { if (blocked) throw Error('blocked'); return storage.get(key) ?? null; },
    setItem(key, value) { if (blocked) throw Error('blocked'); storage.set(key, value); },
    removeItem(key) { if (blocked) throw Error('blocked'); storage.delete(key); },
  };
  const document = {
    referrer: ref, documentElement: {},
    querySelectorAll(selector) {
      return selector.includes('app.tradecovex.com/signup')
        ? links.filter(link => link.href.includes('app.tradecovex.com/signup')) : links;
    },
    addEventListener(name, callback) { events[name] = callback; },
  };
  const window = { location: new URL(url) };
  class Clock extends Date { static now() { return at; } }
  class MutationObserver {
    constructor(callback) { observer = callback; }
    observe() {}
  }
  vm.runInNewContext(script(), { document, window, localStorage, Date: Clock,
    URL, URLSearchParams, MutationObserver }, { filename: path.join(root, 'attr.js') });
  return { links, window, storage, events,
    mutate(records) { if (observer) observer(records); },
    params(index = 0) { return new URL(links[index].href).searchParams; },
  };
}

test('Google deep landing forwards both touches and the landing path', () => {
  const v = visit({ ref: 'https://www.google.com/search?q=copier' });
  assert.equal(v.params().get('referrer'), 'google.com');
  assert.equal(v.params().get('first_referrer'), 'google.com');
  assert.equal(v.params().get('first_lp'), '/guides/copier');
  assert.equal(v.params().get('utm_at'), String(now));
});
test('internal navigation keeps the original touch and landing path', () => {
  const original = visit({ ref: 'https://www.google.com/' });
  const next = visit({ storage: original.storage, ref: 'https://tradecovex.com/guides/copier',
    url: 'https://tradecovex.com/', at: now + 1000 });
  assert.equal(next.params().get('first_lp'), '/guides/copier');
  assert.equal(next.params().get('lp'), '/guides/copier');
  assert.equal(next.params().get('first_utm_at'), String(now));
});
test('a later campaign changes latest touch without replacing first touch', () => {
  const original = visit({ ref: 'https://google.com/' });
  const next = visit({ storage: original.storage, url: 'https://tradecovex.com/?utm_source=youtube&utm_medium=video&utm_campaign=shortlink', at: now + 1000 });
  assert.equal(next.params().get('first_referrer'), 'google.com');
  assert.equal(next.params().get('first_lp'), '/guides/copier');
  assert.equal(next.params().get('utm_source'), 'youtube');
});
test('pricing tier, fragment and deliberately tagged links survive', () => {
  const explicit = signup + '?utm_campaign=deliberate&tier=elite#form';
  const v = visit({ url: 'https://tradecovex.com/?utm_source=test', hrefs: [signup + '?tier=pro#form', explicit] });
  assert.equal(v.params().get('tier'), 'pro');
  assert.equal(new URL(v.links[0].href).hash, '#form');
  assert.equal(v.links[1].href, explicit);
  assert.equal(new URL(v.window.tcxSignupUrl(signup + '?tier=free')).searchParams.get('tier'), 'free');
});
test('login links receive attribution too', () => {
  const v = visit({ ref: 'https://google.com/', hrefs: ['https://app.tradecovex.com/login?tier=starter'] });
  assert.equal(v.params().get('first_referrer'), 'google.com');
  assert.equal(v.params().get('tier'), 'starter');
});
test('new links and links inside newly inserted containers are decorated', () => {
  const v = visit({ ref: 'https://google.com/', hrefs: [] });
  const link = anchor(signup + '?tier=elite');
  v.mutate([{ type: 'childList', addedNodes: [{ nodeType: 1, matches: () => false, querySelectorAll: () => [link] }] }]);
  assert.equal(new URL(link.href).searchParams.get('first_referrer'), 'google.com');
  const direct = anchor('https://app.tradecovex.com/login');
  v.mutate([{ type: 'childList', addedNodes: [direct] }]);
  assert.equal(new URL(direct.href).searchParams.get('first_referrer'), 'google.com');
});
test('href changes are decorated and repeating a mutation is idempotent', () => {
  const v = visit({ ref: 'https://google.com/' });
  v.links[0].href = signup + '?tier=starter';
  v.mutate([{ type: 'attributes', target: v.links[0] }]);
  assert.equal(v.params().get('referrer'), 'google.com');
  const decorated = v.links[0].href;
  v.mutate([{ type: 'attributes', target: v.links[0] }]);
  assert.equal(v.links[0].href, decorated);
});
test('immediate clicks and middle clicks decorate before navigation', () => {
  const v = visit({ ref: 'https://google.com/', hrefs: [] });
  for (const event of ['click', 'auxclick']) {
    const link = anchor(signup);
    if (v.events[event]) v.events[event]({ target: link });
    assert.equal(new URL(link.href).searchParams.get('referrer'), 'google.com');
  }
});
test('lookalike domains and unrelated app routes are never decorated', () => {
  const hrefs = ['https://app.tradecovex.com/signup-other',
    'https://app.tradecovex.com/signup.evil', 'https://app.tradecovex.com.evil/signup',
    'https://evil.test/?next=app.tradecovex.com/signup', 'https://app.tradecovex.com/settings'];
  const v = visit({ ref: 'https://google.com/', hrefs });
  assert.deepEqual(v.links.map(x => x.href), hrefs);
});
test('blocked storage still forwards the current visit', () => {
  const v = visit({ ref: 'https://google.com/', blocked: true });
  assert.equal(v.params().get('first_referrer'), 'google.com');
});
test('direct and self-referring visits do not invent a source', () => {
  for (const ref of ['', 'https://tradecovex.com/', 'https://app.tradecovex.com/login', 'not a URL']) {
    const v = visit({ ref });
    assert.equal(v.params().has('referrer'), false);
    assert.equal(v.params().has('utm_at'), false);
  }
});
test('expired, future and malformed stored touches are discarded', () => {
  for (const raw of ['{', 'null', JSON.stringify({ at: now - windowMs, utm_source: 'old' }),
    JSON.stringify({ at: now + 1, utm_source: 'future' }), JSON.stringify({ at: 'bad', utm_source: 'bad' })]) {
    const storage = new Map([[firstKey, raw], [latestKey, raw]]);
    assert.equal(visit({ storage }).params().has('utm_source'), false);
  }
});
test('legacy UTM storage remains latest-only', () => {
  const storage = new Map([['utm_timestamp', String(now - 1000)], ['utm_source', 'legacy']]);
  const v = visit({ storage });
  assert.equal(v.params().get('utm_source'), 'legacy');
  assert.equal(v.params().has('first_utm_source'), false);
});
test('blank tags are ignored and values are trimmed and bounded', () => {
  const v = visit({ url: 'https://tradecovex.com/?utm_source=%20%20&utm_campaign=' + 'a'.repeat(300) });
  assert.equal(v.params().has('utm_source'), false);
  assert.equal(v.params().get('utm_campaign').length, 256);
});
test('every Clarity page loads shared capture exactly once', () => {
  function pages(dir) {
    return fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry =>
      entry.isDirectory() && !entry.name.startsWith('.') ? pages(path.join(dir, entry.name)) :
        entry.isFile() && entry.name.endsWith('.html') ? [path.join(dir, entry.name)] : []);
  }
  const tracked = pages(root).filter(file => fs.readFileSync(file, 'utf8').includes('clarity.ms/tag'));
  assert.equal(tracked.length, 76);
  for (const file of tracked) {
    const html = fs.readFileSync(file, 'utf8');
    assert.equal((html.match(/<script src="\/attr\.js" defer><\/script>/g) || []).length, 1, file);
    assert.equal(html.includes("var FIRST_KEY = 'tcx_attribution_first_v1'"), false, file);
  }
});
test('six short links have tagged temporary redirects and no conflicting /nt rewrite', () => {
  const file = path.join(root, '_redirects');
  const rules = fs.existsSync(file) ? fs.readFileSync(file, 'utf8').split(/\r?\n/)
    .filter(line => line.trim() && !line.startsWith('#')).map(line => line.trim().split(/\s+/)) : [];
  for (const short of ['/yt', '/nt', '/ig', '/discord', '/x', '/li']) {
    const matches = rules.filter(rule => rule[0] === short);
    assert.equal(matches.length, 1, short);
    assert.equal(matches[0][2], '302');
    const to = new URL(matches[0][1], 'https://tradecovex.com');
    for (const key of ['utm_source', 'utm_medium', 'utm_campaign']) assert.ok(to.searchParams.get(key), key);
    assert.equal(matches[0].length, 3, 'no query matching restrictions');
  }
  assert.doesNotMatch(fs.readFileSync(path.join(root, 'netlify.toml'), 'utf8'), /from = "\/nt"/);
});

test('analytics referrer never overwrites an affiliate code', () => {
  const code = 'tcx_0123456789abcdef';
  const v = visit({ ref: 'https://google.com/', hrefs: [signup + '?ref=' + code + '&tier=pro'] });
  assert.equal(v.params().get('ref'), code);
  assert.equal(v.params().get('referrer'), 'google.com');
  assert.equal(v.params().get('first_referrer'), 'google.com');
});

test('live short-link handler keeps incoming query parameters with channel tags', async () => {
  const { pathToFileURL } = require('node:url');
  const { default: redirect, config } = await import(pathToFileURL(path.join(root, 'netlify/edge-functions/shortlink.js')).href);
  const cases = {
    '/yt': ['youtube', 'video'],
    '/nt': ['ninjatrader', 'referral'],
    '/ig': ['instagram', 'social'],
    '/discord': ['discord', 'community'],
    '/x': ['x', 'social'],
    '/li': ['linkedin', 'social'],
  };
  assert.deepEqual(config.path, Object.keys(cases));
  assert.deepEqual(config.method, ['GET'], 'Netlify rejects HEAD in edge manifests');
  for (const [short, [source, medium]] of Object.entries(cases)) {
    const response = await redirect(new Request('https://tradecovex.com' + short +
      '?probe=abc&ref=tcx_0123456789abcdef&utm_source=wrong'));
    assert.equal(response.status, 302, short);
    const to = new URL(response.headers.get('location'));
    assert.equal(to.origin + to.pathname, 'https://tradecovex.com/');
    assert.equal(to.searchParams.get('probe'), 'abc');
    assert.equal(to.searchParams.get('ref'), 'tcx_0123456789abcdef');
    assert.equal(to.searchParams.get('utm_source'), source);
    assert.equal(to.searchParams.get('utm_medium'), medium);
    assert.equal(to.searchParams.get('utm_campaign'), 'shortlink');
  }
});
