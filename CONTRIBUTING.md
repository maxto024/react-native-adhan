# Contributing

Contributions are always welcome, no matter how large or small!

We want this community to be friendly and respectful to each other. Please follow it in all your interactions with the project. Before contributing, please read the [code of conduct](./CODE_OF_CONDUCT.md).

## Development workflow

This project is a monorepo managed using [Yarn workspaces](https://yarnpkg.com/features/workspaces). It contains the following packages:

- The library package in the root directory.
- An example app in the `example/` directory.

To get started with the project, run `yarn` in the root directory to install the required dependencies for each package:

```sh
yarn
```

> Since the project relies on Yarn workspaces, you cannot use [`npm`](https://github.com/npm/cli) for development.

The [example app](/example/) demonstrates usage of the library. You need to run it to test any changes you make.

It is configured to use the local version of the library, so any changes you make to the library's source code will be reflected in the example app. Changes to the library's JavaScript code will be reflected in the example app without a rebuild, but native code changes will require a rebuild of the example app.

If you want to use Android Studio or XCode to edit the native code, you can open the `example/android` or `example/ios` directories respectively in those editors. To edit the Objective-C or Swift files, open `example/ios/AdhanExample.xcworkspace` in XCode and find the source files at `Pods > Development Pods > react-native-adhan`.

To edit the Java or Kotlin files, open `example/android` in Android studio and find the source files at `react-native-adhan` under `Android`.

You can use various commands from the root directory to work with the project.

To start the packager:

```sh
yarn example start
```

To run the example app on Android:

```sh
yarn example android
```

To run the example app on iOS:

```sh
yarn example ios
```

To confirm that the app is running with the new architecture, you can check the Metro logs for a message like this:

```sh
Running "AdhanExample" with {"fabric":true,"initialProps":{"concurrentRoot":true},"rootTag":1}
```

Note the `"fabric":true` and `"concurrentRoot":true` properties.

Make sure your code passes TypeScript and ESLint. Run the following to verify:

```sh
yarn typecheck
yarn lint
```

To fix formatting errors, run the following:

```sh
yarn lint --fix
```

Remember to add tests for your change if possible. Run the unit tests by:

```sh
yarn test
```

### Commit message convention

We follow the [conventional commits specification](https://www.conventionalcommits.org/en) for our commit messages:

- `fix`: bug fixes, e.g. fix crash due to deprecated method.
- `feat`: new features, e.g. add new method to the module.
- `refactor`: code refactor, e.g. migrate from class components to hooks.
- `docs`: changes into documentation, e.g. add usage example for the module..
- `test`: adding or updating tests, e.g. add integration tests using detox.
- `chore`: tooling changes, e.g. change CI config.

Our pre-commit hooks verify that your commit message matches this format when committing.

### Linting and tests

[ESLint](https://eslint.org/), [Prettier](https://prettier.io/), [TypeScript](https://www.typescriptlang.org/)

We use [TypeScript](https://www.typescriptlang.org/) for type checking, [ESLint](https://eslint.org/) with [Prettier](https://prettier.io/) for linting and formatting the code, and [Jest](https://jestjs.io/) for testing.

Our pre-commit hooks verify that the linter and tests pass when committing.

### Publishing to npm

We use [release-it](https://github.com/release-it/release-it) to make it easier to publish new versions. It handles common tasks like bumping version based on semver, creating tags and releases etc.

To publish new versions, run the following:

```sh
yarn release
```

### Scripts

The `package.json` file contains various scripts for common tasks:

- `yarn`: setup project by installing dependencies.
- `yarn typecheck`: type-check files with TypeScript.
- `yarn lint`: lint files with ESLint.
- `yarn test`: run unit tests with Jest.
- `yarn example start`: start the Metro server for the example app.
- `yarn example android`: run the example app on Android.
- `yarn example ios`: run the example app on iOS.

### Testing Enhanced Features

When contributing to react-native-adhan, please ensure you test the enhanced features we've implemented:

#### 1. Calculation Method Testing
Test your changes with all 12 supported calculation methods:
```bash
# Test in the example app with different methods
# ISNA, MWL, Karachi, Egypt, UmmAlQura, Dubai, Kuwait, Qatar, Singapore, Tehran, Turkey
```

#### 2. Timezone Support Testing
```typescript
// Test timezone identifiers
const times1 = await getPrayerTimes({
  coordinates: { latitude: 40.7128, longitude: -74.0060 },
  parameters: { method: CalculationMethod.ISNA },
  timezone: 'America/New_York'
});

// Test timezone offsets
const times2 = await getPrayerTimes({
  coordinates: { latitude: 40.7128, longitude: -74.0060 },
  parameters: { method: CalculationMethod.ISNA },
  timezone: '-05:00'
});
```

#### 3. Madhab (Asr Jurisprudence) Testing
```typescript
// Test Shafi vs Hanafi differences
const shafiTimes = await getPrayerTimes({
  coordinates: { latitude: 33.6844, longitude: 73.0479 },
  parameters: { method: CalculationMethod.Karachi, madhab: Madhab.Shafi }
});

const hanafiTimes = await getPrayerTimes({
  coordinates: { latitude: 33.6844, longitude: 73.0479 },
  parameters: { method: CalculationMethod.Karachi, madhab: Madhab.Hanafi }
});

// Hanafi Asr should be later than Shafi
console.assert(new Date(hanafiTimes.asr).getTime() > new Date(shafiTimes.asr).getTime());
```

#### 4. Custom Parameters Testing
```typescript
// Test custom angles and adjustments
const customTimes = await getPrayerTimes({
  coordinates: { latitude: 40.7128, longitude: -74.0060 },
  parameters: {
    method: CalculationMethod.ISNA,
    customAngles: { fajrAngle: 16.0, ishaAngle: 14.0 },
    adjustments: { fajr: 2, isha: -1 }
  }
});
```

### Islamic Accuracy Requirements

This library serves the Muslim community worldwide, so accuracy is paramount:

- **Verify calculations** against established Islamic authorities
- **Test with known coordinates** and compare with trusted sources
- **Consider regional differences** in calculation methods
- **Ensure Madhab calculations** are mathematically correct
- **Document sources** for any calculation formulas

### Platform Consistency

Ensure both iOS and Android platforms behave identically:

- **Same calculation results** for identical inputs
- **Consistent error handling** across platforms
- **Identical API responses** and formatting
- **Performance parity** between platforms

### Performance Considerations

- **TurboModule optimization**: Ensure direct JSI communication
- **Memory efficiency**: Avoid memory leaks in native code
- **Calculation speed**: Maintain sub-millisecond performance
- **Bulk operations**: Test multi-day calculations efficiently

### Sending a pull request

> **Working on your first pull request?** You can learn how from this _free_ series: [How to Contribute to an Open Source Project on GitHub](https://app.egghead.io/playlists/how-to-contribute-to-an-open-source-project-on-github).

When you're sending a pull request:

- Prefer small pull requests focused on one change.
- Verify that linters and tests are passing.
- **Test all 12 calculation methods** if modifying calculations.
- **Test both Shafi and Hanafi madhab** if modifying Asr calculations.
- **Test timezone support** with both identifiers and offsets.
- **Verify iOS and Android parity** for any native code changes.
- Review the documentation to make sure it looks good.
- Follow the pull request template when opening a pull request.
- For pull requests that change the API or implementation, discuss with maintainers first by opening an issue.

### Areas We Need Help With

#### High Priority
- **Calculation accuracy improvements** and validation
- **Performance optimizations** for bulk calculations
- **Additional Islamic calculation methods** from regional authorities
- **Better error handling** and user feedback
- **Documentation improvements** and examples

#### Medium Priority
- **Enhanced timezone support** for edge cases
- **More comprehensive testing** across different coordinates
- **Expo plugin enhancements** and optimization
- **TypeScript improvements** and type safety

#### Islamic Expertise Welcome
- **Religious accuracy validation** by Islamic scholars
- **Regional calculation method verification**
- **Madhab calculation differences** research and validation
- **Scholarly reference documentation** and sources
