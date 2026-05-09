# Prani Doctor Mobile App Assets

Livestock/farm-first image pack for Prani Doctor / Animal Doctors mobile app.

## Recommended placement

- `logos/prani_doctor_primary_logo.png`: splash screen, about page, profile header, drawer/header brand.
- `app_icons/prani_doctor_app_icon.png`: source image for launcher icon generation.
- `logos/prani_doctor_horizontal_wordmark.png`: onboarding/header/marketing areas where wide logo fits.
- `logos/prani_doctor_alt_logo_earth_tone.png`: optional secondary brand mark.
- `illustrations/splash_farm_livestock.png`: splash/login background or welcome screen.
- `illustrations/onboarding_farmer_livestock.png`: onboarding slide for farmer-focused service.
- `illustrations/doctor_visit_cow_farm.png`: doctor home visit / emergency doctor pages.
- `illustrations/service_tracking_livestock_app.png`: request tracking / app workflow pages.
- `illustrations/farm_service_banner.png`: home banner, service request landing, empty states.
- `illustrations/ai_technician_cattle_service.png`: AI technician / artificial insemination service pages.
- `guidelines/prani_doctor_logo_usage_board.png`: design reference only; do not bundle in production app unless needed.

## Flutter target folder

Copy this folder into:

`D:\PraniDoctor\pranidoctor_mobilessetsrand\`

Then update `pubspec.yaml` with:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/brand/logos/
    - assets/brand/app_icons/
    - assets/brand/illustrations/
```

Do not include `assets/brand/guidelines/` in production unless you intentionally want the guideline board available inside the app.
