# FinChat AI Gateway Integration

FinChat's AI provider sends requests to the configured Cloudflare Worker endpoint `/v1/ai/chat`, using the currently signed-in Google account's ID token as a Bearer token. The request uses `messages: [{role: user, text: ...}]`; the response text is read from the Gateway JSON `text` field.

The Gemini API key, model selection, retry, fallback, cooldown, rate limit, quota, timeout and monitoring are server responsibilities. Do not add a Gemini API key, provider endpoint editor, or model selector to the APK. Local transaction parsing/intelligence remains the first path; Gateway AI remains a remote fallback where the app already invokes its AI provider.

For Android CI, configure the GitHub Actions secret `FINCHAT_GOOGLE_SERVER_CLIENT_ID` with the OAuth server/web client ID matching the token audience. This is an OAuth client identifier, not a secret API key. The Worker separately requires `GOOGLE_SERVER_CLIENT_ID` as a Cloudflare secret and it must match that audience. Test a real Google login and authenticated Gateway request; a successful `/health` response alone does not validate authentication or Gemini access.
