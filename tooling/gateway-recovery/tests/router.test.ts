import { beforeEach, describe, expect, it, vi } from 'vitest';
import { routeChat } from '../src/router';
import { callGemini } from '../src/gemini';
import { isCoolingDown } from '../src/monitoring';
import { HttpError } from '../src/errors';
import { models } from '../src/config';
import type { Env } from '../src/types';

vi.mock('../src/gemini', () => ({ callGemini: vi.fn() }));
vi.mock('../src/monitoring', () => ({ isCoolingDown: vi.fn(), markFailure: vi.fn().mockResolvedValue(undefined), markSuccess: vi.fn().mockResolvedValue(undefined) }));
const env = { MODEL_PRIMARY: 'model-a', MODEL_FALLBACK_1: 'model-b' } as Env;
const request = { messages: [{ role: 'user' as const, text: 'Hi' }] };
beforeEach(() => { vi.mocked(callGemini).mockReset(); vi.mocked(isCoolingDown).mockReset().mockResolvedValue(false); });

describe('model router', () => {
  it('falls back after transient model failure', async () => {
    vi.mocked(callGemini).mockRejectedValueOnce(new Error('temporary')).mockRejectedValueOnce(new Error('temporary')).mockResolvedValueOnce({ model: 'model-b', text: 'ok', latencyMs: 12 });
    expect((await routeChat(env, request)).model).toBe('model-b');
  });
  it('does not retry a removed model before trying fallback', async () => {
    vi.mocked(callGemini).mockRejectedValueOnce(new HttpError(404, 'Removed')).mockResolvedValueOnce({ model: 'model-b', text: 'ok', latencyMs: 12 });
    expect((await routeChat(env, request)).model).toBe('model-b');
    expect(callGemini).toHaveBeenCalledTimes(2);
  });
  it('keeps upstream quota distinguishable from unavailable models', async () => {
    vi.mocked(callGemini).mockRejectedValue(new HttpError(429, 'Quota'));
    await expect(routeChat(env, request)).rejects.toMatchObject({ status: 429, code: 'UPSTREAM_QUOTA_EXCEEDED' });
  });
  it('returns explicit missing configuration without repeated attempts', async () => {
    vi.mocked(callGemini).mockRejectedValue(new HttpError(503, 'Missing key', 'GATEWAY_NOT_CONFIGURED'));
    await expect(routeChat(env, request)).rejects.toMatchObject({ code: 'GATEWAY_NOT_CONFIGURED' });
    expect(callGemini).toHaveBeenCalledTimes(1);
  });
  it('respects cooldown and does not call unavailable models', async () => {
    vi.mocked(isCoolingDown).mockResolvedValue(true);
    await expect(routeChat(env, request)).rejects.toMatchObject({ status: 503, code: 'ALL_MODELS_UNAVAILABLE' });
    expect(callGemini).not.toHaveBeenCalled();
  });
  it('deduplicates and trims configured model names', () => {
    expect(models({ MODEL_PRIMARY: ' model-a ', MODEL_FALLBACK_1: 'model-a', MODEL_FALLBACK_2: '  ' } as Env)).toEqual(['model-a']);
  });
});
