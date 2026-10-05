import type { Env, ChatRequest, ModelResult } from './types';
import { HttpError } from './errors';
import { numberEnv } from './config';

function toContents(messages: ChatRequest['messages']) {
  return messages.map((message) => ({
    role: message.role === 'model' ? 'model' : 'user',
    parts: [{ text: message.text }],
  }));
}

export async function callGemini(env: Env, model: string, request: ChatRequest): Promise<ModelResult> {
  if (!env.GEMINI_API_KEY?.trim()) throw new HttpError(503, 'Gateway provider key is not configured.', 'GATEWAY_NOT_CONFIGURED');
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), numberEnv(env.REQUEST_TIMEOUT_MS, 10000));
  const started = Date.now();
  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(env.GEMINI_API_KEY)}`;
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: toContents(request.messages),
        generationConfig: {
          maxOutputTokens: request.maxOutputTokens ?? 1024,
          ...(model.startsWith('gemini-3.')
            ? { thinkingConfig: { thinkingLevel: model.includes('flash-lite') ? 'minimal' : 'low' } }
            : { temperature: request.temperature ?? 0.2,
                ...(model.startsWith('gemini-2.5-flash') ? { thinkingConfig: { thinkingBudget: 0 } } : {}) }),
        },
      }),
      signal: controller.signal,
    });

    const bodyText = await response.text();
    if (!response.ok) {
      const error = new HttpError(response.status, `Model ${model} returned HTTP ${response.status}.`, 'MODEL_HTTP_ERROR');
      throw error;
    }
    if (bodyText.length > 100_000) throw new HttpError(502, 'Model response is too large.', 'MODEL_RESPONSE_TOO_LARGE');

    const body = JSON.parse(bodyText) as {
      candidates?: Array<{ content?: { parts?: Array<{ text?: string; thought?: boolean }> } }>;
    };
    const text = body.candidates?.[0]?.content?.parts?.filter((part) => !part.thought).map((part) => part.text ?? '').join('').trim();
    if (!text) throw new HttpError(502, 'Model returned no usable text.', 'MODEL_EMPTY_RESPONSE');
    return { model, text, latencyMs: Date.now() - started };
  } catch (error) {
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new HttpError(504, `Model ${model} timed out.`, 'MODEL_TIMEOUT');
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

