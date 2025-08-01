# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a React Native TurboModule library called `react-native-adhan` that provides high-performance Islamic prayer time calculations. The project is built using `create-react-native-library` with C++ TurboModule support and is designed to integrate the `adhan-cpp` library for native performance.

## Key Architecture

- **TurboModule Structure**: Uses React Native's new architecture with TurboModules for native bridge communication
- **Multi-platform**: Supports both iOS (Objective-C++) and Android (Kotlin) with shared C++ logic
- **Monorepo Setup**: Uses Yarn workspaces with an example app for testing
- **Codegen**: Configured for automatic native interface generation via React Native Codegen

## Development Commands

### Core Development
- `yarn test` - Run Jest tests
- `yarn typecheck` - Run TypeScript type checking
- `yarn lint` - Run ESLint on all TypeScript/JavaScript files
- `yarn clean` - Clean all build artifacts (Android, iOS, and lib directories)
- `yarn prepare` - Build the library using react-native-builder-bob

### Example App
- `yarn example android` - Run Android example app
- `yarn example ios` - Run iOS example app  
- `yarn example start` - Start Metro bundler for example app
- `yarn example build:android` - Build Android example with specific architecture
- `yarn example build:ios` - Build iOS example in Debug mode

### Build System
- Uses `react-native-builder-bob` for library compilation
- Turbo build system configured for both Android and iOS builds
- Git hooks via `lefthook` for pre-commit linting and type checking

## Project Structure

### Native Implementation
- `/android/src/main/java/com/adhan/` - Android Kotlin TurboModule implementation
- `/ios/` - iOS Objective-C++ TurboModule implementation  
- `/cpp/` - Planned location for C++ shared logic and adhan-cpp integration
- `/src/NativeAdhan.ts` - TurboModule interface specification
- `/src/index.tsx` - Main JavaScript exports

### Configuration Files
- `Adhan.podspec` - iOS CocoaPods specification
- `android/build.gradle` - Android Gradle build configuration
- `react-native.config.js` - React Native CLI configuration
- `turbo.json` - Turbo build pipeline configuration
- `lefthook.yml` - Git hooks for code quality

## Code Generation

The project uses React Native Codegen with configuration in `package.json`:
- `codegenConfig.name`: "AdhanSpec" 
- `codegenConfig.javaPackageName`: "com.adhan"
- Generated files go to `android/generated/` and `ios/generated/`

## Development Notes

- Currently implements a basic `multiply` function as placeholder
- Designed to integrate `adhan-cpp` library for actual prayer time calculations
- Uses TurboModule registry with module name "Adhan"
- TypeScript interfaces should match native implementations exactly
- Both iOS and Android native modules extend generated spec classes

## Build Dependencies

- Requires React Native 0.79.2+
- Uses Kotlin for Android implementation
- Requires CocoaPods for iOS dependencies
- Built with modern React Native architecture (New Architecture compatible)