# TeleForge frontend

## API configuration

All requests use `API_BASE_URL`. The production default is
`https://api.teleforge.ir`. Override it at build/run time without changing
source:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
flutter build web
flutter build apk
```

For local development, use `127.0.0.1` on the same computer, `10.0.2.2` from
the Android emulator, or the computer's LAN IP from a physical device.
`0.0.0.0` is a bind address, not a client destination. Production builds must
use HTTPS.

Flutter Web also requires the app's origin to be allowed by Django CORS
settings. The backend currently allows `https://teleforge.ir`.

## Backend endpoints used

The client uses the DRF routes in `Itzrez013/TeleForge`:

| Purpose | Request |
|---|---|
| Register | `POST /register/` (`full_name`, `email`, `password`) |
| Verify OTP | `POST /register/otp/` (`email`, numeric `code`) |
| Log in | `POST /login/` (`email`, `password`) |
| Refresh rotating JWTs | `POST /token/refresh/` |
| Log out | `POST /logout/` |
| Profile and bot list | `GET /dashboard/` |
| Add bot by Telegram token | `POST /get-token/` |
| Bot details and commands | `GET/PATCH/DELETE /bots/{bot_id}/` |
| Sync/deactivate bot | `POST /bots/{bot_id}/sync/`, `/deactivate/` |
| Create command | `POST /bots/{bot_id}/` |
| Edit/delete command | `PATCH/DELETE /bots/{bot_id}/commands/{command_id}/` |
| Create response | `POST /bots/{bot_id}/commands/{command_id}/` |
| Edit response | `PATCH /bots/{bot_id}/commands/{command_id}/responses/{response_id}/` |

Access/refresh tokens are stored using platform secure storage. Expired access
tokens are refreshed once and the rotated tokens are persisted.

## Production readiness

The frontend is configured for the production API. End-to-end use still
depends on the backend deployment and response contract:

- Bot responses need the Django primary key as `id` (separate from Telegram's
  `bot_id`) because detail routes use the database key. Include `needs_sync`
  so the UI can display the actual Telegram sync status.
- The bot model currently has no `is_active` field, and
  `UpdateBotSerializer` only accepts `name`. Add/persist a bot active-state
  field in the backend if the UI should display and update that state.
- Command and response serializers need their database primary keys as `id`.
  The frontend uses these IDs to load, edit, and delete commands and responses.
- The current dashboard serializer doesn't return bot `id`, so a user with
  bots cannot load bot details until that response is corrected.
- The API currently answers HTTPS requests such as `/dashboard/` with a
  redirect to the same URL. Configure the reverse proxy to forward
  `X-Forwarded-Proto: https` and enable the backend's `USE_X_FORWARDED_PROTO`
  setting so Django does not loop on `SECURE_SSL_REDIRECT`.

Once those backend items are deployed, the client reports API errors rather
than treating failed requests as local success. Validate production login,
email verification, bot registration, command creation, and Telegram sync
against the live service before release.
