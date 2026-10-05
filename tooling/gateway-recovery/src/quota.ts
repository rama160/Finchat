import type { Env } from './types';
import { numberEnv } from './config';
import { HttpError } from './errors';

function dayKey(subject: string): string {
  const day = new Date().toISOString().slice(0, 10);
  return `usage:${subject}:${day}`;
}

export async function enforceFreeQuota(env: Env, subject: string): Promise<void> {
  const limit = numberEnv(env.FREE_DAILY_REQUESTS, 50);
  const key = dayKey(subject);
  const current = Number(await env.USAGE_KV.get(key) ?? '0');
  if (current >= limit) {
    throw new HttpError(429, 'Daily AI request limit reached.', 'DAILY_QUOTA_EXCEEDED');
  }
}

export async function recordUsage(env: Env, subject: string): Promise<void> {
  const key = dayKey(subject);
  const current = Number(await env.USAGE_KV.get(key) ?? '0');
  await env.USAGE_KV.put(key, String(current + 1), { expirationTtl: 172800 });
}

