# AGENTS.md

Guidance for automated coding agents working in this repository.

## Project overview

- **App**: AthanTV (tvOS)
- **UI**: SwiftUI
- **Project generation**: XcodeGen (`project.yml`)
- **Prayer calculations**: Adhan-Swift (SwiftPM)

## Build / test / lint

### Generate project (required after project.yml changes)

```bash
xcodegen generate
```

### Build (tvOS Simulator)

```bash
xcodebuild -project AthanTV.xcodeproj -scheme AthanTV -destination "platform=tvOS Simulator,name=Apple TV" -configuration Debug build
```

### Clean build

```bash
xcodebuild -project AthanTV.xcodeproj -scheme AthanTV -destination "platform=tvOS Simulator,name=Apple TV" -configuration Debug clean build
```

### Tests

> **Note**: There are currently **no test targets** in the project.
> If tests are added later, use the commands below.

Run all tests (when available):

```bash
xcodebuild -project AthanTV.xcodeproj -scheme AthanTV -destination "platform=tvOS Simulator,name=Apple TV" test
```

Run a single test (when available):

```bash
xcodebuild -project AthanTV.xcodeproj -scheme AthanTV -destination "platform=tvOS Simulator,name=Apple TV" -only-testing:<TestTarget>/<TestClass>/<testMethod> test
```

### Lint / formatting

> No linting or formatting tools are configured.
> Keep formatting consistent with existing SwiftUI code.

## Code style guidelines

### Imports

- Group system imports at the top of each file.
- Prefer one blank line between import groups (if multiple frameworks).
- Avoid unused imports.

### Swift / SwiftUI conventions

- Use **SwiftUI** patterns and property wrappers (`@State`, `@StateObject`, `@EnvironmentObject`).
- Prefer value types (`struct`) for view models and models unless stateful behavior is required.
- Keep views small and focused; factor out components when they grow.
- Use `private` for helpers inside views (e.g., `private var header`).

### Naming conventions

- Types: `UpperCamelCase` (e.g., `PrayerTimeEntry`).
- Functions & variables: `lowerCamelCase` (e.g., `refreshSchedule`).
- Avoid abbreviations unless standard (`AppState`, `UI`).
- Use semantic names that reflect user intent.

### Formatting

- Follow default Swift formatting (4 spaces indent in Xcode).
- Prefer trailing closure syntax for SwiftUI views.
- Avoid horizontal scrolling; wrap long expressions.

### Error handling

- Avoid force unwraps (`!`) where possible.
- Prefer `guard` with early return for optional checks.
- Use `do/catch` where errors matter, and fail gracefully in UI.
- Current code uses silent failure for UserDefaults and notifications; keep this consistent unless changing UX.

### Concurrency

- Use `@MainActor` for UI-facing classes (e.g., `AppState`, `CitySearchService`).
- Prefer `Task {}` for async operations that update state.
- Avoid blocking the main thread.

### Persistence

- Settings are stored in `UserDefaults` via `SettingsStore`.
- If adding new settings, update `AppSettings` and migration logic if needed.

### Notifications (tvOS)

- tvOS does not support local notification presentation; scheduling is a no-op.
- Keep logic in `NotificationService` guarded by `#if os(tvOS)`.

### Location

- `LocationService` handles single-shot updates.
- `AppState` listens to location updates and stores them in settings.

### Prayer calculations

- Use `PrayerTimeService` as the sole integration point for Adhan.
- Keep calculation parameters centralized in `calculationParameters(for:)`.

### UI consistency

- `PrayerRowView` handles icon + name + time alignment.
- `TimeOfDayBackground` provides the gradient background.
- `DateFooterView` handles time + date output; avoid reformatting in views.

## Repository rules

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot rules found in `.github/copilot-instructions.md`.

## Workflow tips

- Regenerate Xcode project after `project.yml` edits.
- Run `xcodebuild -list -project AthanTV.xcodeproj` to confirm scheme names.
- Keep changes small and reversible.
- Update README/CONTRIBUTING if behavior changes.
