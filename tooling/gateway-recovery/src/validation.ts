import type { ChatRequest } from './types';
import { HttpError } from './errors';

export async function parseChatRequest(request: Request, maxBytes: number): Promise<ChatRequest> {
  const contentLength = Number(request.headers.get('content-length') ?? '0');
  if (contentLength > maxBytes) throw new HttpError(413, 'Request body is too large.', 'REQUEST_TOO_LARGE');
  let payload: unknown;
  try { payload = await request.json(); } catch { throw new HttpError(400, 'Request body must be valid JSON.', 'INVALID_JSON'); }
  if (!payload || typeof payload !== 'object') throw new HttpError(400, 'Invalid request body.', 'INVALID_REQUEST');
  const value = payload as Partial<ChatRequest>;
  if (!Array.isArray(value.messages) || value.messages.length === 0 || value.messages.length > 50) {
    throw new HttpError(400, 'messages must contain 1 to 50 items.', 'INVALID_MESSAGES');
  }
  const messages = value.messages.map((message) => {
    if (!message || typeof message !== 'object') throw new HttpError(400, 'Invalid message.', 'INVALID_MESSAGE');
    const item = message as { role?: unknown; text?: unknown };
    if ((item.role !== 'user' && item.role !== 'model') || typeof item.text !== 'string' || !item.text.trim()) {
      throw new HttpError(400, 'Each message requires role and text.', 'INVALID_MESSAGE');
    }
    if (item.text.length > 10000) throw new HttpError(413, 'Message is too large.', 'MESSAGE_TOO_LARGE');
    return { role: item.role, text: item.text.trim() } as const;
  });
  const temperature = typeof value.temperature === 'number' ? Math.min(Math.max(value.temperature, 0), 1) : undefined;
  const maxOutputTokens = typeof value.maxOutputTokens === 'number' ? Math.min(Math.max(Math.floor(value.maxOutputTokens), 64), 4096) : undefined;
  return { messages, temperature, maxOutputTokens };
}

