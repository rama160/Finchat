import type { Env } from './types';
import { authenticate } from './auth';
import { errorResponse, HttpError } from './errors';
import { models, numberEnv } from './config';
import { enforceRateLimit } from './rate_limit';
import { enforceFreeQuota, recordUsage } from './quota';
import { monitoringSnapshot } from './monitoring';
import { parseChatRequest } from './validation';
import { routeChat } from './router';

function requestId(): string { return crypto.randomUUID(); }

function json(data: unknown, status = 200, headers: Record<string, string> = {}): Response {
  return Response.json(data, { status, headers: { 'Cache-Control': 'no-store', ...headers } });
}

async function handle(request: Request, env: Env): Promise<Response> {
  const id = requestId();
  const url = new URL(request.url);

  if (request.method === 'OPTIONS') return new Response(null, { status: 204 });

  if (url.pathname === '/health' && request.method === 'GET') {
    return json({ ok: true, service: 'finchat-ai-gateway', version: '0.1.1', timestamp: new Date().toISOString() });
  }

  if (url.pathname === '/v1/monitoring' && request.method === 'GET') {
    const token = request.headers.get('X-Admin-Token');
    if (!env.ADMIN_TOKEN || token !== env.ADMIN_TOKEN) throw new HttpError(401, 'Admin authentication required.', 'ADMIN_REQUIRED');
    return json({ ok: true, models: await monitoringSnapshot(env, models(env)), timestamp: new Date().toISOString() });
  }

  if (url.pathname === '/v1/ai/chat' && request.method === 'POST') {
    const user = await authenticate(request, env);
    await enforceRateLimit(env, user.subject);
    await enforceFreeQuota(env, user.subject);
    const body = await parseChatRequest(request, numberEnv(env.MAX_REQUEST_BYTES, 20000));
    const result = await routeChat(env, body);
    await recordUsage(env, user.subject);
    return json({ requestId: id, model: result.model, text: result.text, latencyMs: result.latencyMs });
  }

  throw new HttpError(404, 'Route not found.', 'NOT_FOUND');
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    try {
      return await handle(request, env);
    } catch (error) {
      return errorResponse(error, crypto.randomUUID());
    }
  },
};

