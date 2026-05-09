# pranidoctor_mobile

Prani Doctor (প্রাণি ডাক্তার) — customer and professional mobile app.

## Local development

Flutter reads configuration from `--dart-define` at compile time (not from `.env` at runtime). See [.env.example](.env.example) for recommended values and copy them into your run configuration.

**Android emulator** talking to an API on your PC usually needs `http://10.0.2.2:3000` instead of `localhost`.

**Dev OTP** (when the API is unreachable): set `APP_ENV=development` and `ENABLE_DEV_OTP=true`. The app uses test OTP `123456`, logs `[PraniDoctor][DEV OTP] phone=… otp=…` to the debug console, and issues a local dev-only access token on verify. Do **not** ship a production build with these flags.

## Getting Started

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
