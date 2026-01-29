---
name: eas-building
description: Builds iOS and Android apps using EAS Build. Use when asked to build the app, create a production build, or prepare for release.
---

# EAS Building

Build iOS and Android apps using Expo Application Services (EAS).

## Available Build Commands

```bash
# Production builds (for App Store / Play Store)
eas build --platform ios --profile production
eas build --platform android --profile production

# Local builds (uses local machine)
yarn build:ios    # eas build --platform ios --local
yarn build:android  # eas build --platform android --local

# Development builds (with dev client)
eas build --platform ios --profile development
eas build --platform android --profile development
```

## Build Profiles (from eas.json)

- **base**: Node 22.14.0, base channel
- **development**: Dev client, internal distribution, auto-increment, simulator builds for iOS
- **development-simulator**: Dev client for iOS simulator only
- **production**: Production channel, auto-increment

## Pre-Build Checklist

1. Ensure dependencies are installed: `yarn install`
2. Run linting: `yarn lint`
3. Run tests: `yarn test`
4. Check Expo compatibility: `yarn expo:check`

## Build with Auto-Submit

For iOS builds that automatically submit to TestFlight:

```bash
yarn build:ios:submit  # eas build --platform ios --profile production --auto-submit
```

## Monitoring Builds

- Check build status in terminal or at https://expo.dev
- Build logs are available in the Expo dashboard
- Project ID: `8a68086d-af78-4075-a3d4-3f504d1cdbe3`

## Troubleshooting

- Clear cache: `eas build --clear-cache --platform <platform>`
- Check credentials: `eas credentials`
- Verify config: `eas config --platform <platform>`
