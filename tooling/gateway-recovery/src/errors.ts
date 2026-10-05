export class HttpError extends Error {
  constructor(public readonly status: number, message: string, public readonly code = 'REQUEST_ERROR') {
    super(message);
  }
}

export function errorResponse(error: unknown, requestId: string): Response {
  if (error instanceof HttpError) {
    return Response.json({ error: { code: error.code, message: error.message }, requestId }, { status: error.status });
  }
  return Response.json(
    { error: { code: 'INTERNAL_ERROR', message: 'Internal gateway error.' }, requestId },
    { status: 500 },
  );
}

