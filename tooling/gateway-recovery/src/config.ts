import type { Env } from './types';

export function numberEnv(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
}

export function models(env: Env): string[] {
  return [...new Set([env.MODEL_PRIMARY, env.MODEL_FALLBACK_1, env.MODEL_FALLBACK_2]
    .map((value) => value?.trim()).filter((value): value is string => Boolean(value)))];
}

