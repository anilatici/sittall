# Localization Guide

## Overview

SitTall - Fix Your Posture uses Apple's standard `.strings` localization system via Swift Package Manager. The base language is English (`en`).

All translatable strings live in:
```
Sources/SitTall - Fix Your Posture/Resources/en.lproj/Localizable.strings
```

## Adding a New Language

1. Create a new `.lproj` directory for the language code:
   ```bash
   mkdir Sources/SitTall - Fix Your Posture/Resources/{lang}.lproj
   ```
   Examples: `tr.lproj`, `de.lproj`, `ja.lproj`, `es.lproj`

2. Copy the English strings file into it:
   ```bash
   cp Sources/SitTall - Fix Your Posture/Resources/en.lproj/Localizable.strings \
      Sources/SitTall - Fix Your Posture/Resources/{lang}.lproj/Localizable.strings
   ```

3. Translate the **values** (right side of `=`) in the new file. Do not change the keys (left side).

4. Build: `swift build`

That's it. The app will automatically use the correct language based on the user's macOS system language preference.

## File Format

Each entry is a key-value pair:
```
"English key" = "Translated value";
```

Rules:
- Keys (left side) must never be changed
- Values (right side) are what gets translated
- Every line ends with a semicolon
- Use `\"` to escape quotes inside strings
- `%lld` = integer placeholder, `%@` = string placeholder — keep these in translations
- Comments (`/* ... */` and `// ...`) are for translator context

## String Interpolation Keys

Some keys use format specifiers for dynamic values:

| Key | Placeholders | Example output |
|-----|-------------|----------------|
| `%lld° toward bad posture` | `%lld` = degrees (integer) | "12° toward bad posture" |
| `%lld° score` | `%lld` = degrees | "15° score" |
| `share.healthScore %lld` | `%lld` = percentage | "Health Score: 85%" |
| `share.slouches %lld` | `%lld` = count | "Slouches: 3" |
| `share.timeSlouched %@` | `%@` = formatted time | "Time Slouched: 12m" |
| `share.corrections %lld` | `%lld` = count | "Corrections: 2" |
| `share.monitored %@` | `%@` = formatted time | "Monitored: 1h 30m" |
| `%lldh %lldm` | hours, minutes | "2h 15m" |
| `%lldm` | minutes | "45m" |

Translators can reorder placeholders if the target language requires it.

## How It Works

- **SwiftUI views** (`Text("literal")`, `Toggle("label")`, etc.) automatically look up keys in `Localizable.strings`
- **Non-SwiftUI code** (notifications, computed properties) uses `String(localized: "key", bundle: .module)`
- macOS picks the best available language from the user's system preferences

## Adding New Strings

When adding new user-facing text to the app:

1. If it's in a SwiftUI view (e.g., `Text("New label")`), just use the literal — it auto-localizes
2. If it's in non-SwiftUI code, use `String(localized: "New label", bundle: .module)`
3. Add the key-value pair to `en.lproj/Localizable.strings`
4. Add translations to all other `.lproj/Localizable.strings` files

## Testing a Language

To test a specific language without changing system settings:
```bash
# Run with Turkish locale
swift build && .build/debug/SitTall - Fix Your Posture -AppleLanguages "(tr)"
```

## Language Codes Reference

| Language | Code | Directory |
|----------|------|-----------|
| English | en | `en.lproj/` |
| Turkish | tr | `tr.lproj/` |
| German | de | `de.lproj/` |
| French | fr | `fr.lproj/` |
| Spanish | es | `es.lproj/` |
| Japanese | ja | `ja.lproj/` |
| Chinese (Simplified) | zh-Hans | `zh-Hans.lproj/` |
| Korean | ko | `ko.lproj/` |
