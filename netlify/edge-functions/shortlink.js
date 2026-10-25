const CHANNELS = {
  '/yt': ['youtube', 'video'],
  '/nt': ['ninjatrader', 'referral'],
  '/ig': ['instagram', 'social'],
  '/discord': ['discord', 'community'],
  '/x': ['x', 'social'],
  '/li': ['linkedin', 'social'],
};

export default function shortlink(request) {
  const url = new URL(request.url);
  const channel = CHANNELS[url.pathname];
  if (!channel) return;

  url.pathname = '/';
  url.searchParams.set('utm_source', channel[0]);
  url.searchParams.set('utm_medium', channel[1]);
  url.searchParams.set('utm_campaign', 'shortlink');
  return new Response(null, {
    status: 302,
    headers: { Location: url.href, 'Cache-Control': 'no-store' },
  });
}

export const config = { path: Object.keys(CHANNELS), method: ['GET', 'HEAD'] };
