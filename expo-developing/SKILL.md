---
name: expo-developing
description: Runs Expo development server and device builds. Use when starting dev server, running on simulator/device, or debugging the app.
---

# Expo Developing

Run and debug the Expo React Native app during development.

## Start Development Server

```bash
yarn start       # expo start - Metro bundler only
yarn dev         # expo start --dev-client - with development client
```

## Run on Devices/Simulators

```bash
# iOS
yarn ios              # expo run:ios - build and run on iOS simulator
yarn ios:device       # expo run:ios --device - run on physical iOS device

# Android
yarn android          # expo run:android - build and run on Android emulator
yarn android:device   # expo run:android --device - run on physical Android device
```

## Development Workflow

1. Start Metro bundler: `yarn dev`
2. Run on device/simulator (first time requires native build)
3. Hot reload is enabled by default
4. Shake device or press `m` in terminal for dev menu

## Expo Doctor

Check project health and compatibility:

```bash
yarn expo:check  # npx expo install --check && npx expo-doctor
```

## GraphQL Codegen

Generate TypeScript types from GraphQL schema:

```bash
yarn codegen        # One-time generation
yarn codegen:watch  # Watch mode
```

## Environment

- Node: v22.14.0 (via mise)
- Package Manager: Yarn 4.8.1
- Expo SDK: 54

## Common Issues

- **Metro cache**: Clear with `yarn start --clear`
- **Native rebuild needed**: Run `yarn ios` or `yarn android` after native dependency changes
- **Pods out of sync**: `cd ios && pod install`
