# Contributing to react-native-adhan

We welcome contributions to react-native-adhan! This document provides guidelines for contributing to the project.

## Development Setup

### Prerequisites

- Node.js (>= 14)
- npm or yarn
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

### Getting Started

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/react-native-adhan.git
   cd react-native-adhan
   ```

2. **Install dependencies**
   ```bash
   yarn install
   ```

3. **Install iOS dependencies**
   ```bash
   cd example/ios && pod install && cd ../..
   ```

4. **Run the example app**
   ```bash
   # Start Metro bundler
   yarn example start
   
   # In another terminal - run iOS
   yarn example ios
   
   # Or run Android
   yarn example android
   ```

## Development Workflow

### Code Quality

Before submitting any code, ensure it passes all quality checks:

```bash
# Type checking
yarn typecheck

# Linting and formatting
yarn lint

# Run tests
yarn test

# Build the library
yarn prepare
```

### Pre-commit Hooks

This project uses [Lefthook](https://github.com/evilmartians/lefthook) for pre-commit hooks. The hooks automatically run:

- ESLint on staged TypeScript/JavaScript files
- TypeScript compilation check
- Commit message validation (conventional commits format)

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation if needed

3. **Test your changes**
   - Run all quality checks: `yarn typecheck && yarn lint && yarn test`
   - Test on both iOS and Android using the example app
   - Verify your changes work with different calculation methods

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new prayer calculation feature"
   ```
   
   Use [conventional commit](https://www.conventionalcommits.org/) format:
   - `feat:` - new features
   - `fix:` - bug fixes
   - `docs:` - documentation changes
   - `refactor:` - code refactoring
   - `test:` - adding tests
   - `chore:` - maintenance tasks

## Architecture Guidelines

### TurboModule Structure

This library uses React Native's New Architecture (TurboModules). When making changes:

1. **TypeScript Interface** (`src/NativeAdhan.ts`)
   - Define the TurboModule spec
   - Include comprehensive JSDoc comments
   - Use proper TypeScript types

2. **iOS Implementation** (`ios/Adhan.mm`)
   - Use Objective-C++ for React Native integration
   - Leverage the vendored Swift Core/ files
   - Follow existing pattern for parameter conversion

3. **Android Implementation** (`android/src/main/java/com/adhan/AdhanModule.kt`)
   - Use Kotlin with the adhan-kotlin library
   - Ensure identical behavior to iOS implementation
   - Handle errors gracefully

### Code Style Guidelines

#### TypeScript/JavaScript
- Use TypeScript for all new code
- Follow existing naming conventions
- Add JSDoc comments for public APIs
- Prefer explicit types over `any`

#### iOS (Objective-C++)
- Follow Apple's coding conventions
- Use proper error handling with RCTPromiseReject
- Convert parameters safely with null checks
- Use the BA-prefixed Swift wrapper classes

#### Android (Kotlin)
- Follow Kotlin coding conventions
- Use proper exception handling with promise.reject()
- Ensure thread safety for async operations
- Match method signatures exactly with the TypeScript spec

### Testing

- Add unit tests for new functionality
- Test edge cases and error conditions
- Verify cross-platform consistency
- Include integration tests in the example app

## Submitting Changes

### Pull Request Process

1. **Ensure your branch is up to date**
   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. **Push your changes**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request**
   - Use a clear, descriptive title
   - Fill out the PR template completely
   - Reference any related issues
   - Include screenshots/videos for UI changes

### Pull Request Guidelines

- **Keep PRs focused**: One feature or fix per PR
- **Write clear descriptions**: Explain what, why, and how
- **Add tests**: Ensure new code is properly tested
- **Update documentation**: Keep README and docs current
- **Follow coding standards**: Pass all linting and type checks

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Tests pass locally (`yarn test`)
- [ ] Linting passes (`yarn lint`)
- [ ] Type checking passes (`yarn typecheck`)
- [ ] Tested on iOS
- [ ] Tested on Android
- [ ] Example app works correctly

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] New and existing unit tests pass locally
```

## Code Review Process

### For Contributors
- Respond to feedback promptly
- Make requested changes in new commits (don't force push)
- Ask questions if feedback is unclear
- Be open to suggestions and improvements

### For Reviewers
- Focus on code quality, correctness, and maintainability
- Test the changes locally when possible
- Provide constructive feedback
- Approve when satisfied with the changes

## Release Process

This project uses automated releases with [release-it](https://github.com/release-it/release-it):

1. Conventional commits determine version bumps
2. Changelog is auto-generated
3. Tags and releases are created automatically
4. npm publishing happens on successful release

Only maintainers can trigger releases.

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

- **Environment details**: OS, React Native version, library version
- **Steps to reproduce**: Clear, numbered steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Code samples**: Minimal reproducible example
- **Screenshots/logs**: If applicable

### Feature Requests

For feature requests, please:

- Check if the feature already exists
- Explain the use case and benefit
- Provide examples of how it would work
- Consider if it fits the library's scope

## Getting Help

- **Documentation**: Check the [README](README.md) first
- **Issues**: Search existing issues before creating new ones
- **Discussions**: Use GitHub Discussions for questions
- **Community**: Follow conventional patterns used in the codebase

## Islamic Prayer Time Calculations

This library implements authentic Islamic prayer time calculations. When contributing:

- **Accuracy is paramount**: Prayer times must be calculated correctly
- **Follow established methods**: Use recognized calculation methods
- **Cross-platform consistency**: iOS and Android must produce identical results
- **Respect religious significance**: Handle Islamic concepts appropriately

### Calculation Methods

The library supports multiple calculation methods used by Islamic organizations worldwide:

- Muslim World League
- Egyptian General Authority
- University of Islamic Sciences, Karachi
- Umm al-Qura University, Makkah
- UAE (Dubai)
- Moonsighting Committee
- ISNA (North America)
- Kuwait, Qatar, Singapore, Turkey

When adding new methods, ensure they:
- Are based on authentic Islamic jurisprudence
- Have clear documentation and sources
- Are tested for accuracy
- Follow the same parameter structure

### Contributing to Calculations

If you're contributing to calculation logic:

1. **Understand the mathematics**: Prayer times are based on solar calculations
2. **Verify with authentic sources**: Cross-check with Islamic authorities
3. **Test extensively**: Use known correct times for validation
4. **Document sources**: Reference the Islamic jurisprudence used

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on the code and technical issues
- Respect religious and cultural sensitivities
- Follow GitHub's terms of service

## License

By contributing to react-native-adhan, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be recognized in:
- The project's README
- Release notes for significant contributions
- GitHub's contributor graph

Thank you for contributing to react-native-adhan! 🕌
