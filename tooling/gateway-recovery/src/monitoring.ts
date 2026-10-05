import type { Env } from './types';
import { numberEnv } from './config';

export type ModelHealth = {
  failures: number;
  successes: number;
  consecutiveFailures?: number;
  lastFailureStatus?: number;
  lastFailureAt?: string;
  cooldownUntil?: number;
};

function key(model: string): string { return `model-health:${model}`; }

export async function getHealth(env: Env, model: string): Promise<ModelHealth> {
  return await env.HEALTH_KV.get<ModelHealth>(key(model), 'json') ?? { failures: 0, successes: 0 };
}

export async function markSuccess(env: Env, model: string): Promise<void> {
  const current = await getHealth(env, model);
  await env.HEALTH_KV.put(key(model), JSON.stringify({
    failures: current.failures,
    successes: current.successes + 1,
    consecutiveFailures: 0,
  }), { expirationTtl: 86400 });
}

export async function markFailure(env: Env, model: string, status?: number): Promise<void> {
  const current = await getHealth(env, model);
  const failures = current.failures + 1;
  const consecutiveFailures = (current.consecutiveFailures ?? 0) + 1;
  const cooldown = consecutiveFailures >= 2 ? Date.now() + numberEnv(env.MODEL_COOLDOWN_SECONDS, 60) * 1000 : undefined;
  await env.HEALTH_KV.put(key(model), JSON.stringify({
    failures,
    consecutiveFailures,
    lastFailureStatus: status,
    successes: current.successes,
    lastFailureAt: new Date().toISOString(),
    cooldownUntil: cooldown,
  }), { expirationTtl: 86400 });
}

export async function isCoolingDown(env: Env, model: string): Promise<boolean> {
  const health = await getHealth(env, model);
  return Boolean(health.cooldownUntil && health.cooldownUntil > Date.now());
}

export async function monitoringSnapshot(env: Env, models: string[]): Promise<Record<string, ModelHealth>> {
  const result: Record<string, ModelHealth> = {};
  for (const model of models) result[model] = await getHealth(env, model);
  return result;
}

