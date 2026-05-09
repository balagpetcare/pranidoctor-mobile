# Android emulator — startup and Impeller

If `flutter run` shows **Impeller** with **OpenGLES**, heavy frame skips (`Skipped N frames!`), or **Lost connection to device** during startup, try:

## Disable Impeller (software rendering path)

```powershell
cd D:\PraniDoctor\pranidoctor_mobile
flutter run -d emulator-5554 --no-enable-impeller `
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 `
  --dart-define=APP_ENV=development `
  --dart-define=ENABLE_DEV_OTP=true
```

`10.0.2.2` is the host loopback from the Android emulator (point it at your local Next.js server).

## Useful diagnostics

```powershell
adb shell pidof com.example.pranidoctor_mobile
adb logcat -d -t 500 | findstr /i "FATAL EXCEPTION AndroidRuntime Exception Error ANR pranidoctor_mobile"
```

## App-side mitigations (Prani Doctor)

- Home shell builds **only the selected tab** (no `IndexedStack` of all tabs).
- Splash shows a solid frame before decoding large PNGs.
- Home hero illustration decodes **after** the first layout frame.
- Network calls on the home path wait on **`homeNetworkDeferProvider`** (~one frame + short delay) so the first frames are not competing with Dio + JSON.
