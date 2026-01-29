---
name: expo-testing
description: Runs tests and linting for Expo React Native apps. Use when asked to test, lint, or check code quality.
---

# Expo Testing

Run tests and code quality checks for the mypreffy React Native app.

## Test Commands

```bash
# Run tests
yarn test

# Run tests with coverage report
yarn test:report  # Outputs to ./coverage directory, includes jest-junit reporter
```

## Linting Commands

```bash
# Run all linting
yarn lint

# Run linting with auto-fix
yarn lint:fix

# Individual lint checks
yarn lint:rules        # ESLint rules only
yarn lint:code-format  # Prettier formatting
yarn lint:type-check   # TypeScript type checking
```

## Test Framework

- Jest with jest-expo preset
- React Native Testing Library
- Test files: `*.test.ts`, `*.test.tsx`

## Pre-Commit Hooks

Husky runs lint-staged on commit:
- JSON, Markdown, YAML files are auto-formatted with Prettier

## Continuous Integration

For CI environments:

```bash
yarn lint          # Check all lint rules
yarn test:report   # Generate coverage and JUnit reports
```

## Writing Tests

1. Place test files next to the code being tested
2. Use `@testing-library/react-native` for component tests
3. Mock external dependencies in `__mocks__/` directory
4. Follow existing test patterns in the codebase
