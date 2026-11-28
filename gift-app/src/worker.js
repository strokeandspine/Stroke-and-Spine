// Cloudflare Worker entry: API routes first, then the static app in ./public.
import { handle } from './api.js';

export default {
  async fetch(request, env, ctx) {
    const res = await handle(request, env, ctx);
    return res ?? env.ASSETS.fetch(request);
  },
};
