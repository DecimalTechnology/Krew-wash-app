# App Store Publishing Guide – Krew Carwash

Use this checklist to publish **Krew Carwash** to the Apple App Store. Your bundle ID is **`com.decimaltechnology.krewwash`**.

---

## 1. Apple Developer Account

- [ ] **Enroll in Apple Developer Program** (if not already): https://developer.apple.com/programs/
  - Cost: $99 USD/year
  - Approval can take 24–48 hours
- [ ] **Sign in** to [App Store Connect](https://appstoreconnect.apple.com) with your Apple ID

---

## 2. Register the App ID (Bundle ID) in Developer Portal

**The bundle ID only appears in App Store Connect after you register it as an App ID.** Do this first.

- [ ] Go to [Apple Developer Portal](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles**
- [ ] In the sidebar, click **Identifiers** → **+** (Add)
- [ ] Select **App IDs** → **Continue**
- [ ] Select **App** → **Continue**
- [ ] Fill in:
  - **Description:** e.g. `Krew Carwash`
  - **Bundle ID:** choose **Explicit** and enter: `com.decimaltechnology.krewwash`
- [ ] Under **Capabilities**, enable:

  | Capability | Why |
  |------------|-----|
  | **Sign in with Apple** | **Required by Apple** — Your app uses Google Sign-In (`google_sign_in`). Apple’s guideline 4.8 requires that if you offer any third-party sign-in (e.g. Google), you must also offer Sign in with Apple. Enable this now; you can add the Apple sign-in button/flow in the app before or during review. |
  | **Push Notifications** | Your app uses **Firebase Cloud Messaging** (`firebase_messaging`) and **flutter_local_notifications** for notifications. Enable this so the app can receive remote push notifications. |

  You can leave other capabilities (e.g. Associated Domains, In-App Purchase) **unchecked** unless you use them. Capabilities can be changed later in the Developer Portal and in Xcode.

- [ ] Click **Continue** → **Register**
- [ ] After registration, the bundle ID will appear in App Store Connect when you create a new app (it can take a few minutes to sync).

---

## 3. Create the App in App Store Connect

- [ ] In App Store Connect → **My Apps** → **+** → **New App**
- [ ] Fill in:
  - **Platforms:** iOS
  - **Name:** Krew Carwash (or as you want it to appear on the store)
  - **Primary Language:** Your main language
  - **Bundle ID:** Select **com.decimaltechnology.krewwash** from the dropdown (it appears only after you register it in step 2)
  - **SKU:** e.g. `krewwash-001` (internal reference, not shown to users)
  - **User Access:** Full Access (or limit if needed)
- [ ] Click **Create**

---

## 4. App Icons & Launch Screen

- [ ] **App icon:** Ensure you have a 1024×1024 px PNG (no transparency, no rounded corners).
  - Add to `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with required sizes, or use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) to generate from one image.
- [ ] **Launch screen:** Your `LaunchScreen.storyboard` is already set; test that it looks good on different devices.

---

## 5. Version & Build in Xcode/Flutter

- [ ] Set **version** in `pubspec.yaml`: e.g. `version: 1.0.1+2` (1.0.1 = user-facing, 2 = build number).
- [ ] For each new submission, **increase** at least the build number (e.g. `1.0.1+3`).

---

## 6. Signing & Certificates (Xcode)

- [ ] Open the iOS project in Xcode:
  ```bash
  open ios/Runner.xcworkspace
  ```
- [ ] Select **Runner** → **Signing & Capabilities**.
- [ ] Check **Automatically manage signing** and select your **Team** (Apple Developer account).
- [ ] Confirm **Bundle Identifier** is `com.decimaltechnology.krewwash`.
- [ ] Fix any signing or provisioning errors (Xcode can create profiles for you).

---

## 7. Build the IPA

**Option A – Xcode (recommended first time)**

- [ ] In Xcode menu: **Product** → **Archive**.
- [ ] When the Organizer opens, click **Distribute App** → **App Store Connect** → **Upload**.
- [ ] Follow the prompts (e.g. automatic signing, upload).

**Option B – Command line (Flutter)**

- [ ] From project root:
  ```bash
  flutter build ipa
  ```
- [ ] IPA path: `build/ios/ipa/` (upload via **Transporter** app or Xcode Organizer).

---

## 8. App Store Listing in App Store Connect

In your app’s page in App Store Connect, fill in:

- [ ] **App Information**
  - Subtitle (optional), Category (e.g. Lifestyle or Utilities), etc.
- [ ] **Pricing and Availability**
  - Free or paid; countries/regions.
- [ ] **App Privacy**
  - Link to your **Privacy Policy URL** (must be a live webpage).
  - Answer the **App Privacy** questionnaire (data collection, tracking, etc.). You have `PRIVACY_POLICY.md` in the repo—publish it online and use that URL here.
- [ ] **Screenshots**
  - **6.7" (iPhone 15 Pro Max):** 1290×2796 px
  - **6.5" (e.g. iPhone 14 Plus):** 1284×2778 px
  - **5.5" (e.g. iPhone 8 Plus):** 1242×2208 px  
  - Optional: iPad Pro 12.9" if you support iPad.
- [ ] **App Preview (optional)**  
  - Short video(s) showing the app in use.
- [ ] **Description**  
  - Clear description of Krew Carwash and what it does.
- [ ] **Keywords**  
  - Comma-separated, no spaces (e.g. `car wash,booking,krew`).
- [ ] **Support URL**  
  - Web page for support (e.g. contact form or email).
- [ ] **Age Rating**  
  - Complete the questionnaire (likely 4+ for this app).
- [ ] **Build**
  - After uploading the IPA, select the new build in the version’s **Build** field.

---

## 9. Submit for Review

- [ ] In the app version page, click **Add for Review** (or **Submit for Review**).
- [ ] Answer **Export Compliance**, **Advertising Identifier**, **Content Rights**, etc., as needed.
- [ ] Submit. Review usually takes 24–48 hours (sometimes longer).

---

## 10. After Approval

- [ ] App goes **Ready for Sale** (or on the date you set).
- [ ] Monitor **App Store Connect** for crashes, ratings, and reviews.
- [ ] For updates: bump version/build → archive/upload new build → create new version in App Store Connect → submit.

---

## Quick Reference

| Item              | Value                          |
|-------------------|---------------------------------|
| Bundle ID         | com.decimaltechnology.krewwash |
| App name (store)  | Krew Carwash                   |
| Privacy policy    | Publish PRIVACY_POLICY.md and add URL in App Privacy |

---

## Useful Links

- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter: iOS deployment](https://docs.flutter.dev/deployment/ios)
- [Human Interface Guidelines – App Icons](https://developer.apple.com/design/human-interface-guidelines/app-icons)
