import type { Env, ChatRequest, ModelResult } from './types';
import { models } from './config';
import { callGemini } from './gemini';
import { isCoolingDown, markFailure, markSuccess } from './monitoring';
import { HttpError } from './errors';

const RETRYABLE = new Set([408, 429, 500, 502, 503, 504]);

export async function routeChat(env: Env, request: ChatRequest): Promise<ModelResult> {
  const candidates = models(env);
  if (candidates.length === 0) throw new HttpError(503, 'No AI model is configured.', 'GATEWAY_NOT_CONFIGURED');
  const errors: string[] = [];
  const statuses: number[] = [];

  for (const model of candidates) {
    if (await isCoolingDown(env, model)) continue;
    for (let attempt = 0; attempt < 2; attempt += 1) {
      try {
        const result = await callGemini(env, model, request);
        await markSuccess(env, model);
        return result;
      } catch (error) {
        const status = error instanceof HttpError ? error.status : 500;
        if (error instanceof HttpError && error.code === 'GATEWAY_NOT_CONFIGURED') throw error;
        statuses.push(status);
        errors.push(`${model}:${status}`);
        await markFailure(env, model, status);
        if (!RETRYABLE.has(status) || attempt === 1) break;
        await new Promise((resolve) => setTimeout(resolve, 250 * 2 ** attempt));
      }
    }
  }

  if (statuses.length > 0 && statuses.every((status) => status === 429)) {
    throw new HttpError(429, 'Provider quota is exhausted for configured models.', 'UPSTREAM_QUOTA_EXCEEDED');
  }
  throw new HttpError(503, `All configured AI models are temporarily unavailable. ${errors.join(', ')}`, 'ALL_MODELS_UNAVAILABLE');
}

