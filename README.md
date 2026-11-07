# TeleForge frontend

## API configuration

All requests use `API_BASE_URL`. The default is `http://127.0.0.1:8000` for a
Flutter app running on the same machine as Django. Override it at build/run
time without changing source:

```powershell
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
flutter build web --dart-define=API_BASE_URL=https://api.example.com
flutter build apk --dart-define=API_BASE_URL=https://api.example.com
```

`0.0.0.0` is the address Django binds to; it is not a usable destination for a
client. Use `127.0.0.1` on the same computer, `10.0.2.2` from the Android
emulator, or the computer's LAN IP from a physical device. Release builds
should use HTTPS. Android permits cleartext HTTP only in debug builds.

Flutter Web also requires the app's origin to be allowed by Django CORS
settings. Add the exact web origin used to test/deploy the frontend to
`CORS_ALLOWED_ORIGINS`.

## Backend endpoints used

The client uses the DRF routes in `Itzrez013/TeleForge`:

| Purpose | Request |
|---|---|
| Register | `POST /register/` (`full_name`, `email`, `password`) |
| Verify OTP | `POST /register/otp/` (`email`, numeric `code`) |
| Log in | `POST /login/` (`email`, `password`) |
| Refresh rotating JWTs | `POST /token/refresh/` |
| Log out | `POST /logout/` |
| Profile and bot list | `GET /Dashboaed/` |
| Add bot by Telegram token | `POST /get-token/` |
| Bot details and commands | `GET/PATCH/DELETE /bots/{bot_id}/` |
| Sync/deactivate bot | `POST /bots/{bot_id}/sync/`, `/deactivate/` |
| Create command | `POST /bots/{bot_id}/` |
| Edit/delete command | `PATCH/DELETE /bots/{bot_id}/commands/{command_id}/` |
| Create response | `POST /bots/{bot_id}/commands/{command_id}/` |
| Edit response | `PATCH /bots/{bot_id}/commands/{command_id}/responses/{response_id}/` |

Access/refresh tokens are stored using platform secure storage. Expired access
tokens are refreshed once and the rotated tokens are persisted.

## Backend contract items to fix

The current backend source prevents the bot and command screens from working
end-to-end until its serializers/models expose the identifiers expected by
the routes:

- `TelegramBotSerializer` declares `is_acrive`, which is not a field on
  `TelegramBot`; the model also has no `is_active` although
  `UpdateBotSerializer` uses it.
- Bot responses need to include the Django primary key as `id` (distinct from
  Telegram's `bot_id`), because bot detail routes accept the database key.
  Include `is_active` and `needs_sync` as well; the model currently does not
  define `is_active`, while `needs_sync` is omitted from its serializer.
- Command and command-response serializers need to include their primary key
  as `id`; the client needs those IDs for edit/delete and response routes.
- The dashboard path is spelled `Dashboaed/` in the backend. The client uses
  that exact spelling.

The client reports API errors rather than treating failed requests as local
success. After updating the backend contract, run `flutter analyze` and
`flutter test`.
