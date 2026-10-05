import { afterEach, describe, expect, it, vi } from 'vitest';
import { callGemini } from '../src/gemini';
import type { Env } from '../src/types';

const env = { GEMINI_API_KEY: 'test-provider-key', REQUEST_TIMEOUT_MS: '1000' } as Env;
const request = { messages: [{ role: 'user' as const, text: 'Hi' }], maxOutputTokens: 1024, temperature: 0.1 };

afterEach(() => { vi.unstubAllGlobals(); vi.useRealTimers(); });

describe('Gemini transport', () => {
  it.each(['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite'])('uses supported minimal thinking for %s and returns only final answer', async (model) => {
    const fetcher = vi.fn().mockResolvedValue(Response.json({ candidates: [{ content: { parts: [{ text: 'internal reasoning', thought: true }, { text: 'Final answer' }] } }] }));
    vi.stubGlobal('fetch', fetcher);
    expect((await callGemini(env, model, request)).text).toBe('Final answer');
    const [url, options] = fetcher.mock.calls[0];
    expect(url).toContain(`${model}:generateContent`);
    const body = JSON.parse(options.body);
    expect(body.generationConfig).toEqual({ maxOutputTokens: 1024, thinkingConfig: { thinkingLevel: 'minimal' } });
    expect(body.contents[0].parts[0].text).toBe('Hi');
  });
  it('keeps legacy Flash compatible with budget control', async () => {
    const fetcher = vi.fn().mockResolvedValue(Response.json({ candidates: [{ content: { parts: [{ text: 'ok' }] } }] }));
    vi.stubGlobal('fetch', fetcher);
    await callGemini(env, 'gemini-2.5-flash-lite', request);
    expect(JSON.parse(fetcher.mock.calls[0][1].body).generationConfig).toEqual({ maxOutputTokens: 1024, temperature: 0.1, thinkingConfig: { thinkingBudget: 0 } });
  });
  it('reports missing provider configuration before issuing network requests', async () => {
    const fetcher = vi.fn(); vi.stubGlobal('fetch', fetcher);
    await expect(callGemini({ ...env, GEMINI_API_KEY: '' }, 'gemini-3.5-flash-lite', request)).rejects.toMatchObject({ status: 503, code: 'GATEWAY_NOT_CONFIGURED' });
    expect(fetcher).not.toHaveBeenCalled();
  });
  it('does not leak provider body or key on upstream failures', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response('test-provider-key secret diagnostics', { status: 404 })));
    await expect(callGemini(env, 'missing-model', request)).rejects.toMatchObject({ status: 404, message: 'Model missing-model returned HTTP 404.' });
  });
  it('rejects thought-only responses so routing can try another model', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(Response.json({ candidates: [{ content: { parts: [{ text: 'reasoning only', thought: true }] } }] })));
    await expect(callGemini(env, 'gemini-3.5-flash-lite', request)).rejects.toMatchObject({ status: 502, code: 'MODEL_EMPTY_RESPONSE' });
  });
  it('times out slow providers with a bounded error', async () => {
    vi.useFakeTimers();
    vi.stubGlobal('fetch', vi.fn((_url: string, options: { signal: AbortSignal }) => new Promise((_resolve, reject) => {
      options.signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError')));
    })));
    const pending = expect(callGemini(env, 'gemini-3.5-flash-lite', request)).rejects.toMatchObject({ status: 504, code: 'MODEL_TIMEOUT' });
    await vi.advanceTimersByTimeAsync(1001);
    await pending;
  });
});
