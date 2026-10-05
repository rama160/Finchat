import { describe, expect, it } from 'vitest';
import worker from '../src/index';

describe('health', () => {
  it('returns healthy status', async () => {
    const response = await worker.fetch(new Request('https://gateway.test/health'), {} as never);
    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toMatchObject({ ok: true, service: 'finchat-ai-gateway' });
  });
});

