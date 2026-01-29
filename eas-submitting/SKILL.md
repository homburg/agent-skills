---
name: eas-submitting
description: Submits iOS builds to TestFlight and Android builds to Play Store using EAS Submit. Use when asked to submit, release, or publish the app.
---

# EAS Submitting

Submit app builds to App Store Connect (TestFlight) and Google Play Store.

## Submit Commands

```bash
# Submit latest build
eas submit --platform ios --latest
eas submit --platform android --latest

# Submit specific build
eas submit --platform ios --id <BUILD_ID>

# Build and submit in one step
yarn build:ios:submit  # eas build --platform ios --profile production --auto-submit
```

## Configured Credentials (eas.json)

### iOS (App Store Connect)
- Apple ID: `<apple-id>`
- Team ID: `<team-id>`
- ASC App ID: `<app-id>`

### Android (Google Play)
- Release Status: `draft`

## Pre-Submission Checklist

1. **Version/Build Number**: Increment in app.config.ts or let EAS auto-increment
2. **Code Quality**:
   ```bash
   yarn lint
   yarn test
   ```
3. **Build**: Ensure a successful production build exists
4. **Environment**: Set Apple credentials if needed:
   ```bash
   export EXPO_APPLE_PASSWORD="your-password"
   # OR for app-specific password:
   export EXPO_APPLE_APP_SPECIFIC_PASSWORD="your-app-specific-password"
   ```

## Post-Submission (iOS)

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Verify build was received
3. Complete export compliance (ITSAppUsesNonExemptEncryption is set to false)
4. Add test notes for TestFlight
5. Manage testers:
   - Internal testers: Available immediately
   - External testers: Requires Apple review

## Post-Submission (Android)

1. Log in to [Google Play Console](https://play.google.com/console)
2. Review draft release
3. Add release notes
4. Promote to testing track or production

## Troubleshooting

- Verify Apple credentials: `eas credentials --platform ios`
- Check submission status: `eas submit:status`
- Re-submit if failed: Fix issues and run submit again
