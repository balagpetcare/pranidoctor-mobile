# pranidoctor_mobile

Prani Doctor (প্রাণি ডাক্তার) — customer and professional mobile app.

## Local development

Flutter reads configuration from `--dart-define` at compile time (not from `.env` at runtime). See [.env.example](.env.example) for recommended values and copy them into your run configuration.

**Release / production APK defaults** (no defines needed): `API_BASE_URL=https://pranidoctor.com`, `APP_ENV=production`, `ENABLE_DEV_OTP=false`.

**Android emulator** talking to an API on your PC usually needs `http://10.0.2.2:3000` instead of `localhost`.

**Dev OTP** (when the API is unreachable): set `APP_ENV=development` and `ENABLE_DEV_OTP=true`. The app uses test OTP `123456`, logs a non-sensitive dev fallback line to the debug console (OTP is not logged), and issues a local dev-only access token on verify. Do **not** ship a production build with these flags.

## Getting Started

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
