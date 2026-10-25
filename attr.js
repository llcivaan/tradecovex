(function () {
  var KEYS = ['utm_source', 'utm_medium', 'utm_campaign'];
  var ALL = KEYS.concat(['ref', 'lp']);
  var WINDOW_MS = 30 * 24 * 60 * 60 * 1000;
  var FIRST_KEY = 'tcx_attribution_first_v1';
  var LATEST_KEY = 'tcx_attribution_latest_v1';
  var now = Date.now();

  // Our own hostnames are not a traffic source.
  function externalRef() {
    try {
      if (!document.referrer) return null;
      var host = new URL(document.referrer).hostname.replace(/^www\./, '').toLowerCase();
      if (!host || /(^|\.)tradecovex\.com$/.test(host)) return null;
      return host.slice(0, 256);
    } catch (_) { return null; }
  }

  function valid(record) {
    if (!record || !Number.isFinite(record.at) ||
        record.at > now || now - record.at >= WINDOW_MS) return null;
    var clean = { at: record.at };
    ALL.forEach(function (key) {
      if (typeof record[key] === 'string' && record[key].trim()) {
        clean[key] = record[key].trim().slice(0, 256);
      }
    });
    // A touch counts when it carries a tag OR a real referring site.
    return (KEYS.some(function (key) { return clean[key]; }) || clean.ref) ? clean : null;
  }
  function read(key) {
    try { return valid(JSON.parse(localStorage.getItem(key))); }
    catch (_) { return null; }
  }
  function write(key, value) {
    try { localStorage.setItem(key, JSON.stringify(value)); } catch (_) {}
  }

  var params = new URLSearchParams(window.location.search);
  var fresh = { at: now };
  KEYS.forEach(function (key) {
    var value = params.get(key);
    if (value && value.trim()) fresh[key] = value.trim().slice(0, 256);
  });
  var ref = externalRef();
  if (ref) fresh.ref = ref;
  fresh.lp = (window.location.pathname || '/').slice(0, 256);
  fresh = valid(fresh);
  var first = read(FIRST_KEY);
  var latest = read(LATEST_KEY);

  // Legacy tags identify a latest touch, not a verified first touch.
  if (!latest) {
    try {
      var legacy = { at: Number(localStorage.getItem('utm_timestamp')) };
      KEYS.forEach(function (key) { legacy[key] = localStorage.getItem(key); });
      latest = valid(legacy);
    } catch (_) {}
  }
  if (fresh) {
    if (!first) first = fresh;
    latest = fresh;
    write(FIRST_KEY, first);
    write(LATEST_KEY, latest);
    try {
      KEYS.forEach(function (key) {
        if (latest[key]) localStorage.setItem(key, latest[key]);
        else localStorage.removeItem(key);
      });
      localStorage.setItem('utm_timestamp', String(latest.at));
    } catch (_) {}
  }

  function withUTM(base) {
    var url = new URL(base, window.location.href);
    // Preserve tags deliberately placed on a specific signup link.
    if (KEYS.some(function (key) { return url.searchParams.get(key); })) {
      return base;
    }
    var current = Date.now();
    [ [latest, ''], [first, 'first_'] ].forEach(function (entry) {
      var touch = entry[0], prefix = entry[1];
      if (!touch || current < touch.at || current - touch.at >= WINDOW_MS) return;
      ALL.forEach(function (key) {
        if (touch[key]) url.searchParams.set(prefix + key, touch[key]);
      });
      url.searchParams.set(prefix + 'utm_at', String(touch.at));
    });
    return url.toString();
  }
  function decorate(link) {
    var base = link.getAttribute('href');
    if (!base) return;
    try {
      var url = new URL(base, window.location.href);
      if (url.origin !== 'https://app.tradecovex.com' ||
          !/^\/(signup|login)\/?$/.test(url.pathname)) return;
      var decorated = withUTM(base);
      if (decorated !== base) link.setAttribute('href', decorated);
    } catch (_) {}
  }
  function decorateLinks(root) {
    if (root.nodeType === 1 && root.matches('a[href]')) decorate(root);
    if (root.querySelectorAll) root.querySelectorAll('a[href]').forEach(decorate);
  }
  decorateLinks(document);
  // Pricing/widgets can insert links or change their destinations after page load.
  new MutationObserver(function (changes) {
    changes.forEach(function (change) {
      if (change.type === 'attributes') decorate(change.target);
      else change.addedNodes.forEach(decorateLinks);
    });
  }).observe(document.documentElement, {
    childList: true, subtree: true, attributes: true, attributeFilter: ['href']
  });
  // Cover a link inserted and clicked before the observer's next microtask.
  function decorateClick(event) {
    var target = event.target;
    var link = target && target.closest ? target.closest('a[href]') : null;
    if (link) decorate(link);
  }
  document.addEventListener('click', decorateClick, true);
  document.addEventListener('auxclick', decorateClick, true);
  window.tcxSignupUrl = function (base) {
    return withUTM(base || 'https://app.tradecovex.com/signup');
  };
})();
