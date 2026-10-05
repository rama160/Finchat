export type Env = {
  GOOGLE_SERVER_CLIENT_ID: string;
  GEMINI_API_KEY: string;
  ADMIN_TOKEN: string;
  MODEL_PRIMARY: string;
  MODEL_FALLBACK_1?: string;
  MODEL_FALLBACK_2?: string;
  RATE_LIMIT_PER_MINUTE?: string;
  FREE_DAILY_REQUESTS?: string;
  MAX_REQUEST_BYTES?: string;
  REQUEST_TIMEOUT_MS?: string;
  MODEL_COOLDOWN_SECONDS?: string;
  RATE_LIMIT_KV: KVNamespace;
  USAGE_KV: KVNamespace;
  HEALTH_KV: KVNamespace;
};

export type AuthenticatedUser = {
  subject: string;
  email?: string;
  name?: string;
};

export type ChatMessage = {
  role: 'user' | 'model';
  text: string;
};

export type ChatRequest = {
  messages: ChatMessage[];
  temperature?: number;
  maxOutputTokens?: number;
};

export type ModelResult = {
  model: string;
  text: string;
  latencyMs: number;
};

