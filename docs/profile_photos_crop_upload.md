# Profile photos & cover — dependencies and native setup

**Project:** Prani Doctor mobile (`pranidoctor_mobile`)  
**Scope:** “ছবি ও কভার” — pick, crop, optional client compression, local preview; **upload stub** until the API supports customer media.

## Flutter packages added (`pubspec.yaml`)

| Package | Role |
|---------|------|
| `image_picker` | Gallery / camera selection. |
| `image_cropper` | Native crop UI (uCrop on Android, TOCropViewController on iOS). |
| `flutter_image_compress` | Optional JPEG recompress after crop (client-side only; server must still validate/compress). |
| `path_provider` | Temp directory for compressed outputs. |

## Android

1. **Permissions** (`android/app/src/main/AndroidManifest.xml`):
   - `CAMERA`
   - `READ_MEDIA_IMAGES` (Android 13+)
   - `READ_EXTERNAL_STORAGE` with `maxSdkVersion="32"` for older storage access
   - Optional `uses-feature` for camera (`required="false"`).

2. **uCrop activity** (required by `image_cropper`):
   - `com.yalantis.ucrop.UCropActivity` with theme `@style/Ucrop.CropTheme`.

3. **Themes** (`android/app/src/main/res/values/styles.xml`):
   - `Ucrop.CropTheme` → `Theme.AppCompat.Light.NoActionBar`.

4. **Android 15 (API 35)** (`android/app/src/main/res/values-v35/styles.xml`):
   - Same `Ucrop.CropTheme` with `android:windowOptOutEdgeToEdgeEnforcement` per upstream `image_cropper` README (uCrop edge-to-edge workaround).

## iOS

- `ios/Runner/Info.plist`: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` (Bengali user-facing strings).

## Web

- Pick/crop flow is **disabled** on web (`kIsWeb`): UI shows a short Bengali message. Conditional imports separate `dart:io` file size checks from web stubs.

## Upload / server

- `MobileUserRepositoryLive.uploadProfilePhoto` / `uploadCoverPhoto` use **`multipart/form-data`** with field name **`file`** against:
  - `POST /api/mobile/me/profile-photo`
  - `POST /api/mobile/me/cover-photo`
- While **`kMobileProfilePhotoPostEndpointsEnabled`** is `false` (default), the client **does not** call these routes and returns a Bengali **endpoint not ready** result (no `POST /api/mobile/uploads` technician route).
- After the backend implements the two `POST` routes and returns the usual `{ ok, data }` envelope, set **`kMobileProfilePhotoPostEndpointsEnabled`** to `true` in `lib/src/features/profile/data/mobile_profile_api_contract.dart`. The UI then calls `MobileUserRepository` and refreshes `GET /api/mobile/me`.

## Model

- `MobileUser.coverPhotoUrl` is parsed from JSON keys: `coverPhotoUrl`, `coverImageUrl`, `backgroundPhotoUrl`, `bannerUrl`.
- Profile hub header shows network cover over the gradient when `coverPhotoUrl` is an `http(s)` URL.

## Temporary behaviour

- Cropped images are shown as **session-local previews** only until upload is implemented. In-app copy states this explicitly.
