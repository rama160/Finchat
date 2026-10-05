import { createRemoteJWKSet, jwtVerify } from 'jose';
import type { Env, AuthenticatedUser } from './types';
import { HttpError } from './errors';

const googleKeys = createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));

export async function authenticate(request: Request, env: Env): Promise<AuthenticatedUser> {
  const header = request.headers.get('Authorization');
  if (!header?.startsWith('Bearer ')) {
    throw new HttpError(401, 'Missing Google ID token.', 'AUTH_REQUIRED');
  }

  const token = header.slice('Bearer '.length).trim();
  if (!token) {
    throw new HttpError(401, 'Missing Google ID token.', 'AUTH_REQUIRED');
  }

  try {
    const result = await jwtVerify(token, googleKeys, {
      issuer: ['https://accounts.google.com', 'accounts.google.com'],
      audience: env.GOOGLE_SERVER_CLIENT_ID,
    });
    const subject = typeof result.payload.sub === 'string' ? result.payload.sub : '';
    if (!subject) throw new Error('Missing subject');
    return {
      subject,
      email: typeof result.payload.email === 'string' ? result.payload.email : undefined,
      name: typeof result.payload.name === 'string' ? result.payload.name : undefined,
    };
  } catch {
    throw new HttpError(401, 'Invalid Google ID token.', 'AUTH_INVALID');
  }
}

