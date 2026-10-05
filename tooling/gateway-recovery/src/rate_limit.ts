import type { Env } from './types';
import { numberEnv } from './config';
import { HttpError } from './errors';

export async function enforceRateLimit(env: Env, subject: string): Promise<void> {
  const limit = numberEnv(env.RATE_LIMIT_PER_MINUTE, 20);
  const bucket = Math.floor(Date.now() / 60_000);
  const key = `rate:${subject}:${bucket}`;
  const current = Number(await env.RATE_LIMIT_KV.get(key) ?? '0');
  if (current >= limit) {
    throw new HttpError(429, 'Rate limit exceeded. Please retry shortly.', 'RATE_LIMITED');
  }
  await env.RATE_LIMIT_KV.put(key, String(current + 1), { expirationTtl: 120 });
}

