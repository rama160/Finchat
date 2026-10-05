import { describe, expect, it } from 'vitest';
import { parseChatRequest } from '../src/validation';

describe('chat validation', () => {
  it('accepts a valid request', async () => {
    const request = new Request('https://gateway.test/v1/ai/chat', {
      method: 'POST',
      body: JSON.stringify({ messages: [{ role: 'user', text: 'Halo' }] }),
    });
    await expect(parseChatRequest(request, 20000)).resolves.toMatchObject({ messages: [{ role: 'user', text: 'Halo' }] });
  });

  it('rejects malformed messages', async () => {
    const request = new Request('https://gateway.test/v1/ai/chat', {
      method: 'POST',
      body: JSON.stringify({ messages: [{ role: 'system', text: '' }] }),
    });
    await expect(parseChatRequest(request, 20000)).rejects.toMatchObject({ status: 400 });
  });
});

