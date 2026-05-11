# VoltRush AI

VoltRush AI is a SwiftUI iOS learning simulator for electricians, apprentices, contractors, and students. It presents practical electrical concepts through game-style missions, wiring puzzles, fault diagnosis, quizzes, AI mentor mock chat, premium placeholders, and contractor business progression.

## Requirements

- Xcode 16 or newer recommended
- iOS 17.0 minimum deployment target
- SwiftUI, StoreKit, UserNotifications
- No external API keys required for the MVP

## Setup

1. Open `VoltRushAI.xcodeproj` in Xcode.
2. Select the `VoltRushAI` scheme.
3. Choose an iPhone simulator.
4. Build and run.

The app stores mock progress locally with `UserDefaults`. A privacy manifest is included because Apple requires declared reasons for required-reason APIs such as `UserDefaults`.

## GitHub App Store Upload

This repo includes a manual GitHub Actions workflow, `iOS App Store Upload`, that archives the app on a macOS runner and uploads the IPA to App Store Connect. Add the Apple signing/API secrets listed in `.github/APP_STORE_UPLOAD_SECRETS.md`, including an Apple Distribution `.p12` and App Store provisioning profile, then run the workflow from the GitHub Actions tab.

The workflow uses bundle ID `com.voltrushai.app`, scheme `VoltRushAI`, and increments the build number from the GitHub Actions run number.

## App Structure

- `VoltRushAI/App`: app entry, tab shell, theme
- `VoltRushAI/Models`: user, mission, fault, quiz, wiring, store, and business models
- `VoltRushAI/Services`: mock data, StoreKit-ready placeholder service, AI mentor mock responder
- `VoltRushAI/ViewModels`: MVVM state for onboarding, quiz, wiring, battle, business, and diagnosis flows
- `VoltRushAI/Views`: SwiftUI screens and reusable components
- `VoltRushAI/Resources`: asset catalog, privacy manifest, product placeholder data

## Current MVP Features

- Onboarding with role, learning path, skill level, optional notifications, and safety disclaimer
- Home dashboard with level, XP, coins, rank, streak, daily mission, badges, and quick launch
- Career progression from Apprentice to Electrical Company Owner
- Mission details, simulated job flow, rewards, and completion animation
- Fault diagnosis game with tools/actions, safety mistakes, scoring, and learning summary
- Wiring Lab with SwiftUI drag/tap wire connections and placeholder circuit puzzles
- Quiz Arena with practice, timed, and boss battle modes
- PvP-style local Fault Battle against an AI opponent
- AI Mentor chat using local mock responses
- StoreKit-ready paywall with product IDs, restore button, terms/privacy links, and transparent placeholders
- Contractor Business Mode with jobs, tools, van/team upgrades, virtual money, and reputation

## Production TODOs

- Replace placeholder App Icon with final artwork before App Store submission.
- Add a `.storekit` test configuration or App Store Connect products matching `StoreService.productIDs`.
- Replace `MockAIMentorService` with a real AI API client after adding safety-reviewed prompts, moderation, error handling, and privacy disclosures.
- Add real leaderboard backend and anti-cheat protections.
- Expand local/mock data into reviewed learning content for each jurisdiction.
- Add unit tests for scoring, mission rewards, StoreKit entitlement handling, and profile persistence.
- Add UI tests for onboarding, mission completion, quiz flow, paywall restore, and disclaimer acceptance.
- Replace placeholder Terms and Privacy URLs.

## Safety Disclaimer

VoltRush AI is for learning and simulation only. It does not replace formal electrician training, licensing, certification, manufacturer instructions, workplace procedures, site risk assessments, or qualified professional guidance. Users must follow local electrical regulations and professional safety requirements.

## App Review Notes

- Monetization is transparent: product rows show the product type and placeholder price text.
- Premium unlock is simulated until real StoreKit products are configured.
- No tracking is used in this MVP.
- No external network requests are made in the MVP.
- The app includes a required safety disclaimer during onboarding.
