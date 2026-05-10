# M00 — Full Current App Audit

## Freeze

- **Freeze name:** Baseline Frozen
- **Audit date:** 2026-05-10
- **Project path:** `D:\PraniDoctor\pranidoctor_mobile`
- **Scope:** Flutter mobile client only (`lib/`, `assets/`, `test/`, config); backend ও ওয়েব অ্যাপ এই ডকুমেন্টের বাইরে।

---

## Executive Summary

প্রাণি ডাক্তার মোবাইল অ্যাপটি **Riverpod + GoRouter + Dio** ভিত্তিক; গ্রাহক OTP লগইন, হোম শেল (৫ ট্যাব), ডাক্তার/টেকনিশিয়ান খোঁজা, সেবা অনুরোধ, প্রাণী প্রোফাইল, নলেজ হাব, নোটিফিকেশন, ও আলাদা **ডাক্তার / টেকনিশিয়ান** প্রবেশ পথ রয়েছে। ডিজাইন সিস্টেম ও ব্র্যান্ড অ্যাসেট আংশিকভাবে কেন্দ্রীভূত (`PraniAssets`, ডিজাইন টোকেন)। কিছু ফ্লোতে **প্লেসহোল্ডার UI বা স্ন্যাক** (যেমন প্রভাইডার ডিটেলে কল/বুকিং, জ্ঞানহাব সার্চ বার), এবং কনফিগযোগ্য **মক API** (`USE_MOCK_*`) আছে। **২০২৬-০৫-১০** তারিখে `flutter analyze`, `flutter test`, ও `flutter build apk --debug` এই রিপোতে **সফল** ছিল। এই বেসলাইন থেকে পরবর্তী UI/ফিচার কাজ পরিকল্পনা করা উচিত।

---

## 1. Files/Folders Inspected

| Area | Files/Folders | Notes |
|------|----------------|-------|
| Manifest | `pubspec.yaml` | SDK ^3.11.5, Dio, go_router, riverpod, secure_storage, etc. |
| Analyzer | `analysis_options.yaml` | `flutter_lints` বেস। |
| Entry | `lib/main.dart` | Zone guards, `ProviderScope`, dev API লগ। |
| App shell | `lib/src/app/` | `app.dart`, `router.dart`, `theme.dart`, `navigation_keys.dart`, এবং হেল্পার। |
| Core | `lib/src/core/` | `AppConfig`, Dio/API client, অ্যাসেট কনস্ট্যান্ট। |
| Design system | `lib/src/design_system/` | টোকেন, রং, উইজেট, `PraniBrandHero`। |
| Features | `lib/src/features/` | মডুলার ফিচার (auth, home, providers, …)। |
| Shared | `lib/src/shared/` | **ফোল্ডার নেই** (খালি/অমজুদ)। |
| Assets | `assets/` | ব্র্যান্ড লোগো, ইলাস্ট্রেশন, `images/home/`। |
| Tests | `test/` | ৩টি টেস্ট ফাইল। |
| Docs | `docs/mobile-ui/` | এই অডিট ফাইলসহ মোবাইল UI ডক। |

---

## 2. Existing Screens / Pages

`*screen.dart` নামের ফাইল **৩৬টি**; এর বাইরে `service_requests_tab_screen.dart`-এ **`ServiceRequestDetailScreen`** এম্বেডেড। নিচের স্ট্যাটাস প্রজেক্ট কোড ও ন্যাভিগেশন অনুযায়ী।

| Module | Screen/Page | File Path | Status | Notes |
|--------|----------------|-----------|--------|-------|
| Splash | Splash | `lib/src/features/splash/splash_screen.dart` | Complete | রুট `/splash`। |
| Onboarding | Onboarding | `lib/src/features/onboarding/onboarding_screen.dart` | Complete | `/onboarding`। |
| Auth | Login entry (গ্রাহক OTP) | `lib/src/features/auth/login_entry_screen.dart` | Complete | `/login`; ডাক্তার/টেক লিঙ্ক। |
| Auth | Doctor login | `lib/src/features/auth/doctor/presentation/doctor_login_screen.dart` | Partial | `/doctor/login`; ওয়েব/ডিবাগ সম্পর্কিত কপি। |
| Auth | Technician login | `lib/src/features/auth/technician/presentation/technician_login_screen.dart` | Partial | `/technician/login`; মক ফ্ল্যাগ ব্যানার। |
| Home shell | Home shell (ট্যাব বার) | `lib/src/features/home/home_shell_screen.dart` | Complete | `/home`; ৫ ট্যাব। |
| Home | Customer home | `lib/src/features/home/home_screen.dart` | Partial | সেবা টাইলে “ঔষধ ও পণ্য” শীঘ্রই যুক্ত স্ন্যাক। |
| Home | Doctor tab | `lib/src/features/home/presentation/doctor_tab_screen.dart` | Complete | ট্যাব ভিতরে। |
| Home | Doctor portal home | `lib/src/features/home/doctor/presentation/doctor_home_screen.dart` | Partial | `/doctor/home`; নলেজ হাব লিঙ্ক। |
| Providers | Doctor list | `lib/src/features/providers/presentation/doctor_list_screen.dart` | Complete | `/providers/doctors`। |
| Providers | Doctor detail | `lib/src/features/providers/presentation/doctor_detail_screen.dart` | Partial | নেস্টেড `:doctorId`; কল/বুকিং প্লেসহোল্ডার স্ন্যাক। |
| Providers | Technician list | `lib/src/features/providers/presentation/technician_list_screen.dart` | Complete | `/providers/technicians`। |
| Providers | Technician detail | `lib/src/features/providers/presentation/technician_detail_screen.dart` | Partial | নেস্টেড `:technicianId`; কল/বুকিং প্লেসহোল্ডার। |
| Service requests | Service requests tab | `lib/src/features/service_requests/presentation/service_requests_tab_screen.dart` | Complete | ট্যাব + ইনলাইন **`ServiceRequestDetailScreen`**। |
| Service requests | Service request detail | *same file* (`ServiceRequestDetailScreen`) | Complete | `/service-requests/:requestId`। |
| Service requests | Booking wizard | `lib/src/features/service_requests/presentation/booking_wizard_screen.dart` | Complete | `/booking/new`। |
| Notifications | Notifications list | `lib/src/features/notifications/presentation/notifications_list_screen.dart` | Complete | `/notifications`। |
| Profile | Profile home | `lib/src/features/profile/presentation/profile_home_screen.dart` | Complete | ট্যাব ভিতরে। |
| Profile | Edit profile | `lib/src/features/profile/presentation/edit_profile_screen.dart` | Partial | অ্যাভাটার/ফোন পরিবর্তন TODO (`PATCH /me` সীমা)। |
| Profile | Area setting | `lib/src/features/profile/presentation/area_setting_screen.dart` | Complete | `/profile/area`। |
| Profile | App settings | `lib/src/features/profile/presentation/app_settings_screen.dart` | Complete | `/profile/settings`। |
| Profile | Help & support | `lib/src/features/profile/presentation/help_support_screen.dart` | Partial | সাপোর্ট কার্ডে প্লেসহোল্ডার টেক্সট। |
| Profile | About | `lib/src/features/profile/presentation/about_screen.dart` | Complete | `/profile/about`। |
| Animals | Animal list | `lib/src/features/animals/presentation/animal_list_screen.dart` | Complete | `/animals`; রুট + প্রোফাইল মেনু। |
| Animals | Animal detail | `lib/src/features/animals/presentation/animal_detail_screen.dart` | Complete | প্রায় সবসময় **MaterialPageRoute**। |
| Animals | Animal form | `lib/src/features/animals/presentation/animal_form_screen.dart` | Complete | Material push; ফটো আপলোড প্লেসহোল্ডার। |
| Animals | Animals tab (nested Nav) | `lib/src/features/animals/presentation/animals_tab_screen.dart` | Placeholder | **কোথাও রেফারেন্স নেই** — ডেড/ফিউচার শেল। |
| Knowledge | Knowledge hub home | `lib/src/features/knowledge_hub/presentation/knowledge_hub_home_screen.dart` | Partial | সার্চ বার প্লেসহোল্ডার উইজেট। |
| Knowledge | Categories | `lib/src/features/knowledge_hub/presentation/knowledge_categories_screen.dart` | Complete | নেস্টেড। |
| Knowledge | Post list | `lib/src/features/knowledge_hub/presentation/knowledge_post_list_screen.dart` | Partial | মক ব্যানার + সার্চ প্লেসহোল্ডার। |
| Knowledge | Post detail | `lib/src/features/knowledge_hub/presentation/knowledge_post_detail_screen.dart` | Complete | নেস্টেড `:slugOrId`। |
| Technician AI | Dashboard | `lib/src/features/technician_ai/presentation/technician_dashboard_screen.dart` | Partial | `/technician/home`; মক ফ্ল্যাগ ব্যানার। |
| Technician AI | Requests | `lib/src/features/technician_ai/presentation/technician_requests_screen.dart` | Complete | `/technician/requests`। |
| Technician AI | Jobs list | `lib/src/features/technician_ai/presentation/technician_jobs_screen.dart` | Complete | `/technician/jobs`। |
| Technician AI | Job detail | `lib/src/features/technician_ai/presentation/technician_job_detail_screen.dart` | Partial | `_PlaceholderSection` কিছু স্টেটে। |
| Technician AI | AI record form | `lib/src/features/technician_ai/presentation/technician_ai_record_form_screen.dart` | Complete | চাইল্ড রুট `.../record`। |
| Technician AI | Complete job | `lib/src/features/technician_ai/presentation/technician_complete_job_screen.dart` | Complete | চাইল্ড রুট `.../complete`। |

---

## 3. Existing Routes

`lib/src/app/router.dart` — **GoRouter**। গ্রাহক সেশন: `sessionNotifierProvider`। **রিডাইরেক্ট:** লগইন পাতায় ইউজার লগড ইন থাকলে `/home`; গ্রাহক **পাবলিক** পথ `/splash`, `/onboarding`, `/login` মাত্র; `/doctor*` ও `/technician*` গ্রাহক অথ চেক থেকে **বাইপাস**; বাকি অথেন্টিকেটেড পথে আনঅথ হলে `/login`। পুরনো `/tutorials` URL → জ্ঞান পোস্ট তালিকায় ম্যাপ।

| Route Path/Name | Target Screen | File Path | Auth/Guard | Notes |
|-------------------|---------------|-----------|------------|--------|
| `/splash` — `splash` | Splash | `splash_screen.dart` | Public | ইনিশিয়াল লোকেশন। |
| `/onboarding` — `onboarding` | Onboarding | `onboarding_screen.dart` | Public | |
| `/login` — `loginEntry` | Login entry | `login_entry_screen.dart` | Public | লগড ইন হলে → `/home`। |
| `/home` — `homeShell` | Home shell | `home_shell_screen.dart` | Customer auth | |
| `/doctor/login` — `doctorLogin` | Doctor login | `doctor_login_screen.dart` | Bypass | গ্রাহক অথ বাইপাস। |
| `/technician/login` — `technicianLogin` | Technician login | `technician_login_screen.dart` | Bypass | |
| `/technician/home` — `technicianHome` | Technician dashboard | `technician_dashboard_screen.dart` | Bypass | |
| `/technician/requests` — `technicianRequests` | Technician requests | `technician_requests_screen.dart` | Bypass | |
| `/technician/jobs` — `technicianJobs` | Technician jobs | `technician_jobs_screen.dart` | Bypass | |
| `/technician/jobs/:jobId` — `technicianJobDetail` | Job detail | `technician_job_detail_screen.dart` | Bypass | |
| `.../record` — `technicianAiRecord` | AI record form | `technician_ai_record_form_screen.dart` | Bypass | চাইল্ড। |
| `.../complete` — `technicianCompleteJob` | Complete job | `technician_complete_job_screen.dart` | Bypass | চাইল্ড। |
| `/doctor/home` — `doctorHome` | Doctor home | `doctor_home_screen.dart` | Bypass | |
| `/providers/doctors` — `doctorList` | Doctor list | `doctor_list_screen.dart` | Customer auth | |
| `:doctorId` — `doctorDetail` | Doctor detail | `doctor_detail_screen.dart` | Customer auth | নেস্টেড। |
| `/providers/technicians` — `technicianList` | Technician list | `technician_list_screen.dart` | Customer auth | |
| `:technicianId` — `technicianDetail` | Technician detail | `technician_detail_screen.dart` | Customer auth | নেস্টেড। |
| `/notifications` — `notificationsList` | Notifications | `notifications_list_screen.dart` | Customer auth | |
| `/profile/edit` — `profileEdit` | Edit profile | `edit_profile_screen.dart` | Customer auth | |
| `/profile/area` — `profileArea` | Area setting | `area_setting_screen.dart` | Customer auth | |
| `/profile/settings` — `profileSettings` | App settings | `app_settings_screen.dart` | Customer auth | |
| `/profile/help` — `profileHelp` | Help | `help_support_screen.dart` | Customer auth | |
| `/profile/about` — `profileAbout` | About | `about_screen.dart` | Customer auth | |
| `/animals` — `animalsList` | Animal list | `animal_list_screen.dart` | Customer auth | |
| `/knowledge` — `knowledgeHubHome` | Knowledge hub | `knowledge_hub_home_screen.dart` | Customer auth | |
| `categories` — `knowledgeCategories` | Categories | `knowledge_categories_screen.dart` | Customer auth | চাইল্ড। |
| `posts` — `knowledgePosts` | Post list | `knowledge_post_list_screen.dart` | Customer auth | চাইল্ড। |
| `:slugOrId` — `knowledgePostDetail` | Post detail | `knowledge_post_detail_screen.dart` | Customer auth | চাইল্ড। |
| `/booking/new` — `bookingNew` | Booking wizard | `booking_wizard_screen.dart` | Customer auth | |
| `/service-requests/:requestId` — `serviceRequestDetail` | Service request detail | `service_requests_tab_screen.dart` | Customer auth | |

**GoRouter বাইরে (পুশ/রুট স্ট্যাক):** `AnimalFormScreen`, `AnimalDetailScreen` — **`MaterialPageRoute`** (`animal_list_screen.dart` থেকে)।

---

## 4. API Endpoint Usage

বেস URL: **`AppConfig.resolvedApiBaseUrl`** (ডিফল্ট `https://pranidoctor.com`)। কল **`Dio`** → বেশিরভাগ **`ApiClient`** বা সরাসরি `ref.read(dioProvider)` (হোম ফিড)। অথ: `Authorization: Bearer` ইন্টারসেপ্টর (`dio_provider.dart`)।

| Method | Endpoint/Path | Used In | Purpose | Status/Notes |
|--------|----------------|---------|---------|----------------|
| GET | `/api/mobile/health` | `mobile_api_health.dart` | কানেক্টিভিটি চেক | অপশনাল হেল্পার। |
| POST | `/api/mobile/auth/otp/request` | `mobile_otp_auth_repository.dart` | OTP পাঠানো | |
| POST | `/api/mobile/auth/otp/verify` | `mobile_otp_auth_repository.dart` | OTP যাচাই, টোকেন | ডেভ `ENABLE_DEV_OTP` ফলব্যাক। |
| GET | `/api/mobile/me` | `mobile_user_repository.dart` | প্রোফাইল | ৪০৪ → গেস্ট ফলব্যাক। |
| PATCH | `/api/mobile/me` | `mobile_user_repository.dart` | প্রোফাইল আপডেট | |
| GET | `/api/mobile/service-categories` | `home_feed_providers.dart`, `service_category_repository.dart` | হোম শর্টকাট/ক্যাটালগ | একই পথ দুই প্রদানকারী। |
| GET | `/api/mobile/app-config` | `home_feed_providers.dart` | ইমারজেন্সি ফোন ইত্যাদি | ব্যর্থ হলে খালি কনফিগ। |
| POST | `/api/mobile/service-requests` | `service_request_repository.dart` | নতুন অনুরোধ | |
| GET | `/api/mobile/service-requests` | `service_request_repository.dart` | তালিকা (query: limit, offset, status) | |
| GET | `/api/mobile/service-requests/:id` | `service_request_repository.dart` | ডিটেইল | |
| PATCH | `/api/mobile/service-requests/:id/cancel` | `service_request_repository.dart` | বাতিল | |
| GET | `/api/mobile/providers/doctors` | `provider_finder_repository.dart` | ডাক্তার খোঁজা | query প্যারাম। |
| GET | `/api/mobile/providers/technicians` | `provider_finder_repository.dart` | টেকনিশিয়ান | |
| GET | `/api/mobile/providers/doctors/:id` | `provider_finder_repository.dart` | ডাক্তার ডিটেইল | |
| GET | `/api/mobile/providers/technicians/:id` | `provider_finder_repository.dart` | টেকনিশিয়ান ডিটেইল | |
| GET | `/api/mobile/animals` | `animal_profile_repository.dart` | তালিকা | optional query। |
| GET | `/api/mobile/animals/:id` | `animal_profile_repository.dart` | ডিটেইল | |
| POST | `/api/mobile/animals` | `animal_profile_repository.dart` | তৈরি | |
| PATCH | `/api/mobile/animals/:id` | `animal_profile_repository.dart` | আপডেট | |
| PATCH | `/api/mobile/animals/:id/deactivate` | `animal_profile_repository.dart` | নিষ্ক্রিয় | |
| GET | `/api/mobile/notifications` | `notification_repository.dart` | তালিকা | query: limit, offset, unreadOnly। |
| PATCH | `/api/mobile/notifications/:id/read` | `notification_repository.dart` | পঠিত | |
| PATCH | `/api/mobile/notifications/read-all` | `notification_repository.dart` | সব পঠিত | |
| GET | `/api/mobile/content/categories` | `knowledge_repository.dart` | ক্যাটাগরি (প্রথম চেষ্টা) | ৪০৪ হলে tutorials। |
| GET | `/api/mobile/tutorials/categories` | `knowledge_repository.dart` | ফলব্যাক ক্যাটাগরি | |
| GET | `/api/mobile/content/posts` | `knowledge_repository.dart` | পোস্ট তালিকা | query: take, skip, category… |
| GET | `/api/mobile/tutorials` | `knowledge_repository.dart` | ফলব্যাক পোস্ট তালিকা | |
| GET | `/api/mobile/content/posts/:slugOrId` | `knowledge_repository.dart` | পোস্ট ডিটেইল | URI encode। |
| GET | `/api/mobile/tutorials/:slugOrId` | `knowledge_repository.dart` | ফলব্যাক ডিটেইল | |
| GET | `/api/mobile/technician/requests` | `technician_job_repository.dart` | ইনকামিং | |
| GET | `/api/mobile/technician/jobs` | `technician_job_repository.dart` | জব তালিকা | |
| GET | `/api/mobile/technician/jobs/:id` | `technician_job_repository.dart` | জব ডিটেইল | |
| PATCH | `/api/mobile/technician/jobs/:id` | `technician_job_repository.dart` | accept/reject (`action`) | |
| PATCH | `/api/mobile/technician/jobs/:id/ai-record` | `technician_job_repository.dart` | AI রেকর্ড | |
| PATCH | `/api/mobile/technician/jobs/:id/complete` | `technician_job_repository.dart` | সম্পূর্ণ | |

**মক রিপোজিটরি (HTTP বন্ধ):** `USE_MOCK_TECHNICIAN_API`, `USE_MOCK_KNOWLEDGE_API`, `USE_MOCK_PROFILE_API` — সংশ্লিষ্ট `*_mock.dart` ফাইল।

**নন-REST:** `url_launcher` — `emergency_cta_card.dart` (`tel:`)।

---

## 5. Shared Widgets / Design System Components

| Component | File Path | Used For | Notes |
|-----------|-----------|----------|-------|
| `PraniDoctorApp` | `lib/src/app/app.dart` | রুটার অ্যাপ | মেটেরিয়াল ৩, লোকেল bn। |
| `AppTheme` | `lib/src/app/theme.dart` | থিম | লাইট/ডার্ক। |
| `PraniSpacing`, টোকেন | `prani_tokens.dart`, `app_spacing.dart` | লেআউট | |
| `AppColors`, সিমান্টিক রং | `app_colors.dart`, `app_semantic_colors.dart` | রং | |
| `PraniPageInsets` / `AppPageInsets` | `prani_page_insets.dart`, `app/app_page_insets.dart` | পেজ গাটার | দ্বিতীয়টি প্রথমটির ডেলিগেট। |
| `PraniBrandHero` | `lib/src/core/assets/prani_assets.dart` | হিরো ইমেজ | `Image.asset` + ক্লিপ। |
| `PraniSafePage` | `widgets/prani_safe_page.dart` | সেফ এরিয়া স্ক্যাফোল্ড | |
| `PraniPrimaryCtaButton` | `widgets/prani_primary_cta_button.dart` | CTA | |
| `PraniPremiumCard` | `widgets/prani_premium_card.dart` | কার্ড সারফেস | |
| `PraniEmptyStateCard` | `widgets/prani_empty_state_card.dart` | খালি স্টেট | |
| `PraniAsyncListStatus` | `widgets/prani_async_list_status.dart` | অ্যাসিঙ্ক লিস্ট | |
| `PraniSectionHeader`, প্রোফাইল ভেরিয়েন্ট | `prani_section_header.dart`, `prani_profile_section_header.dart` | সেকশন হেডার | |
| `PraniAppSearchBar` | `widgets/prani_app_search_bar.dart` | সার্চ UI | |
| `PraniServiceCard` | `widgets/prani_service_card.dart` | হোম সেবা টাইল | |
| `AppIconBadge`, `SecondaryActionButton` | `app/widgets/` | ছোট UI | |
| `app_widgets.dart` | `app/widgets/app_widgets.dart` | এক্সপোর্ট বারেল | |

---

## 6. Duplicate / Problem Files

| Issue Type | File(s) | Problem | Recommendation |
|------------|---------|---------|------------------|
| রিপিটেড API পথ | `home_feed_providers.dart` + `service_category_repository.dart` | উভয়ই `GET /api/mobile/service-categories` ব্যবহার করে। | ডকুমেন্টেড রিফ্যাক্টর পর্যায়ে এক রিপোজিটরি/প্রভাইডারে একত্র করা যেতে পারে। |
| সাদৃশ্য UI হ্যান্ডলার | `doctor_detail_screen.dart`, `technician_detail_screen.dart` | `_placeholderSnack` একই ধরনের কল/বুকিং আচরণ। | ভবিষ্যতে শেয়ার্ড ছোট উইজেট বা হেল্পার (এখন ডিলিট/ডুপ্লিকেট উইজেট তৈরি নয় — শুধু নোট)। |
| থিন ফ্যাসাদ | `AppPageInsets` vs `PraniPageInsets` | একই লজিক দুই স্তরে। | ইচ্ছাকৃত API স্তর; অপসারণ জরুরি নয়। |
| ডেড কোড সন্দেহ | `animals_tab_screen.dart` | কোনো ইম্পোর্ট/রুট নেই। | ট্যাব শেল ভবিষ্যতে ব্যবহার হলে ওয়্যার করুন অথবে তখন অডিট। |
| অ্যাসেট কনস্ট্যান্ট | `PraniAssets.horizontalLogo`, `PraniAssets.altLogoEarthTone` | কোডবেজে রেফারেন্স পাওয়া যায়নি। | প্রয়োজনে UI-তে বা অপসারণ পরবর্তী অডিটে। |

---

## 7. Asset / Image Usage Audit

### 7.1 Declared Assets

`pubspec.yaml` — ডিরেক্টরি গ্লোব:

| Asset Path | Declared In | Notes |
|------------|---------------|-------|
| `assets/brand/logos/` | `pubspec.yaml` | লোগো PNG। |
| `assets/brand/app_icons/` | `pubspec.yaml` | অ্যাপ আইকন। |
| `assets/brand/illustrations/` | `pubspec.yaml` | ইলাস্ট্রেশন। |
| `assets/images/home/` | `pubspec.yaml` | হোম হিরো/ইমারজেন্সি ইত্যাদি। |

`flutter_launcher_icons:` আলাদা — `assets/brand/app_icons/prani_doctor_app_icon.png`।

### 7.2 Assets Used In Code

মূলত **`PraniAssets`** + কয়েকটি সরাসরি `Image.asset`। ব্যবহৃত পথের নমুনা:

| Asset Path | Used In | Notes |
|------------|---------|-------|
| `assets/brand/illustrations/splash_farm_livestock.png` | `splash_screen.dart` | স্প্ল্যাশ ব্যাকগ্রাউন্ড। |
| `assets/brand/logos/prani_doctor_primary_logo.png` | একাধিক | লোগো। |
| `assets/brand/illustrations/onboarding_farmer_livestock.png` | `onboarding_screen.dart` | ইলাস্ট্রেশন। |
| `assets/brand/illustrations/farm_service_banner.png` | `login_entry_screen.dart` | ব্যানার। |
| `assets/brand/illustrations/doctor_visit_cow_farm.png` | ডাক্তার লিস্ট/ডিটেইল | হিরো। |
| `assets/brand/illustrations/ai_technician_cattle_service.png` | টেক লিস্ট/ডিটেইল | হিরো। |
| `assets/brand/illustrations/service_tracking_livestock_app.png` | সেবা অনুরোধ, নোটিফিকেশন, বুকিং | ইলাস্ট্রেশন। |
| `assets/images/home/*.png` | হোম উইজেট (`hero_farm_vet`, `empty_nearby_doctors`, `emergency_vet`, `promo_vaccination`) | |

### 7.3 Missing / Risky Asset References

| Asset Path | Used In | Risk |
|------------|---------|------|
| `assets/brand/guidelines/prani_doctor_logo_usage_board.png` | *মোবাইল UI কোডে রেফ নেই* | ডিস্কে আছে কিন্তু **`pubspec`-এ গ্লোব নেই** — বান্ডেলে যাবে না; ভবিষ্যতে `Image.asset` দিলে রানটাইম ত্রুটি হতে পারে। |

### 7.4 Unused-looking Assets

| Asset Path | Reason | Recommendation |
|------------|--------|------------------|
| `assets/brand/logos/prani_doctor_horizontal_wordmark.png` | `PraniAssets.horizontalLogo` কোথাও ব্যবহৃত নয়। | ল্যান্ডিং/হেডারে ব্যবহার বা অডিটে কনস্ট্যান্ট পরিষ্কার। |
| `assets/brand/logos/prani_doctor_alt_logo_earth_tone.png` | `PraniAssets.altLogoEarthTone` আনইউজড। | একই। |
| `assets/brand/guidelines/*` | বান্ডেলে নেই; কোড রেফ নেই। | আলাদা ডিজাইন ডক হিসেবে রাখা যেতে পারে — মোবাইল রিলিজে প্রয়োজন নেই। |

---

## 8. Incomplete / Risk Areas

- **গ্রাহক ফিচার গ্যাপ:** হোমের “ঔষধ ও পণ্য কিনুন” টাইল শুধু স্ন্যাক — আসল ফ্লো নেই।
- **প্রভাইডার ডিটেইল:** কল ও বুকিং বাটন প্লেসহোল্ডার স্ন্যাক।
- **জ্ঞান হাব:** `KnowledgeSearchBarPlaceholder` — রিয়েল সার্চ নয়।
- **প্রোফাইল:** অ্যাভাটার আপলোড TODO; সাপোর্ট কার্ড স্ট্যাটিক প্লেসহোল্ডার।
- **প্রাণী:** ফটো আপলোড প্লেসহোল্ডার (`animal_photo_placeholder.dart` মন্তব্য)।
- **টেকনিশিয়ান জব ডিটেইল:** `_PlaceholderSection` কিছু বিভাগে।
- **ডুয়েল API স্কিম:** কন্টেন্ট `content` বনাম `tutorials` ফলব্যাক — ব্যাকএন্ড চুক্তি মিলিয়ে দেখা দরকার।
- **`AnimalsTabScreen`:** অনাবৃত — ট্যাব UX ভবিষ্যত ঝুঁকি।
- **বিলিং:** `USE_MOCK_BILLING_UI` গেটেড ডেমো ওভারলে — প্রোডাকশনে আচরণ যাচাই।
- **বিল্ড/CI:** এই অডিট মুহূর্তে লোকাল ভেরিফাই সবুজ; পরিবেশ ভিন্ন হলে পুনরায় চালান।

---

## 9. Verification Status

| Command | Result | Notes |
|---------|--------|--------|
| `flutter analyze` | **Pass** — `No issues found!` | ~৩.৬s। |
| `flutter test` | **Pass** — `All tests passed!` (৫ টেস্ট) | `widget_test`, `technician_ai_badge_test`, `billing_payment_summary_widget_test`। |
| `flutter build apk --debug` | **Pass** — `app-debug.apk` at `build/app/outputs/flutter-apk/` | Gradle ~১৩৪s। |
| `git status` | **Clean** (অডিট ডক যোগ করার ঠিক আগে) | ব্রাঞ্চ `feature/premium-ui-profile-polish`। এই ফাইল যোগ হওয়ার পর `docs/mobile-ui/` আনট্র্যাকড দেখাবে যতক্ষণ না কমিট করা হয়। |

---

## 10. Baseline Freeze Decision

**Baseline Frozen** মানে এই মুহূর্তের অ্যাপের কাঠামো, রুট, API ব্যবহার, অ্যাসেট, ও পরিচিত গ্যাপগুলো এই ডকুমেন্টে ধরা আছে। পরবর্তী মোবাইল UI বা ফিচার কাজ **অনুমান না করে** এই বেসলাইন থেকে শুরু করা উচিত; নতুন পরিবর্তন হলে পরবর্তী অডিট বা চেঞ্জলগ আপডেট করা যেতে পারে।

---

## 11. Next Phase Recommendation

- **M01:** গ্রাহক জার্নি ম্যাট্রিক্স (হোম → বুকিং → সেবা অনুরোধ) ও প্লেসহোল্ডার ফ্লোর প্রোডাক্ট সিদ্ধান্ত।
- **M02:** জ্ঞান হাব সার্চ/কন্টেন্ট চুক্তি (`content` vs `tutorials`) ও ব্যাকএন্ডের সাথে অ্যালাইনমেন্ট।
- **M03:** প্রভাইডার ডিটেইল অ্যাকশন (কল, বুকিং) রিয়েল ইন্টিগ্রেশন বা ডিপ লিঙ্ক।
- **M04:** অ্যাসেট ও ন্যাভিগেশন পরিষ্কার (`horizontalLogo`, `AnimalsTabScreen`, guidelines ফোল্ডার নীতি)।

---

*এই ফাইল `docs/mobile-ui/M00_AUDIT_BASELINE.md` — ম্যানুয়াল রিভিউ সুপারিশ।*
