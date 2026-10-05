import { afterEach, expect, it, vi } from 'vitest';
import { getHealth, isCoolingDown, markFailure, markSuccess } from '../src/monitoring';
import type { Env } from '../src/types';

function environment(): Env {
  const values = new Map<string, string>();
  return { MODEL_COOLDOWN_SECONDS: '120', HEALTH_KV: {
    get: async (key: string) => values.has(key) ? JSON.parse(values.get(key)!) : null,
    put: async (key: string, value: string) => { values.set(key, value); },
  } } as unknown as Env;
}
afterEach(() => vi.useRealTimers());
it('uses configured cooldown and resets consecutive failures after success', async () => {
  vi.useFakeTimers(); vi.setSystemTime(new Date('2026-10-05T00:00:00Z'));
  const env = environment();
  await markFailure(env, 'model', 503);
  expect(await isCoolingDown(env, 'model')).toBe(false);
  await markFailure(env, 'model', 429);
  expect(await isCoolingDown(env, 'model')).toBe(true);
  expect((await getHealth(env, 'model')).lastFailureStatus).toBe(429);
  await vi.advanceTimersByTimeAsync(120001);
  expect(await isCoolingDown(env, 'model')).toBe(false);
  await markSuccess(env, 'model');
  await markFailure(env, 'model', 503);
  expect(await isCoolingDown(env, 'model')).toBe(false);
  expect(await getHealth(env, 'model')).toMatchObject({ failures: 3, successes: 1, consecutiveFailures: 1 });
});
