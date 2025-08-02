# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a React Native TurboModule library for Islamic prayer times and Qibla direction calculations. The project uses the New Architecture (Fabric + TurboModules) and supports both iOS and Android platforms.

## Essential Development Commands

### Build and Development
- `yarn` - Install dependencies (required first step)
- `yarn typecheck` - Run TypeScript type checking
- `yarn lint` - Run ESLint with Prettier formatting
- `yarn lint --fix` - Auto-fix linting and formatting issues
- `yarn test` - Run Jest unit tests
- `yarn clean` - Clean all build artifacts
- `yarn prepare` - Build the library using react-native-builder-bob

### Example App Commands
- `yarn example start` - Start Metro bundler for example app
- `yarn example android` - Run example app on Android
- `yarn example ios` - Run example app on iOS

### Turbo Commands (for native builds)
- `turbo build:android` - Build Android native code
- `turbo build:ios` - Build iOS native code

## Architecture Overview

### TurboModule Structure
- **TypeScript Interface**: `src/NativeAdhan.ts` defines the TurboModule spec
- **JavaScript Entry**: `src/index.tsx` exports the public API
- **iOS Implementation**: `ios/Adhan.h` and `ios/Adhan.mm` (Objective-C++)
- **Android Implementation**: `android/src/main/java/com/adhan/` (Kotlin)

### Key Files
- `Adhan.podspec` - iOS CocoaPods specification
- `android/build.gradle` - Android build configuration
- `react-native.config.js` - React Native CLI configuration
- `turbo.json` - Turborepo build pipeline configuration

### Code Generation
The project uses React Native's New Architecture codegen:
- `codegenConfig` in package.json defines spec generation
- Native specs are auto-generated from TypeScript interfaces
- Generated files follow the pattern `NativeAdhanSpec`

## Development Workflow

### Pre-commit Hooks (Lefthook)
The repository uses Lefthook for pre-commit hooks:
- ESLint runs on staged TypeScript/JavaScript files
- TypeScript compilation check runs on commits
- Commit messages must follow conventional commits format

### Testing and Quality Assurance
- Always run `yarn typecheck` and `yarn lint` before committing
- Tests use Jest with React Native preset
- Example app at `example/` demonstrates library usage
- Use `yarn example android/ios` to test native implementations

### New Architecture Features
- TurboModules for high-performance native method calls
- Fabric renderer support
- JSI (JavaScript Interface) for direct C++ integration
- Codegen for type-safe native interfaces

## Native Development

### iOS
- Open `example/ios/AdhanExample.xcworkspace` in Xcode
- Native source files located in `Pods > Development Pods > react-native-adhan`
- Uses Objective-C++ for React Native integration

### Android
- Open `example/android` in Android Studio
- Native source files under `react-native-adhan` module
- Uses Kotlin with TurboModule base classes

## Release Process
- Uses `release-it` with conventional changelog
- Run `yarn release` to publish new versions
- Follows semantic versioning with conventional commits