# The Baker's Archive Mobile Companion

The Baker's Archive Mobile Companion is a Flutter app targeting Android, web and Windows. It provides a fast, read-only browsing experience for recipes published on an Odoo-based Baker's Archive site, plus offline favourites and a distraction-free Kitchen Mode for timed, large-text baking steps.

It talks directly to The Baker's Archive's public REST API — no server component of its own.

## Features

- **One Flutter codebase, three targets:** Android (APK/AAB), web and Windows (MSIX).
- **Explore feed:** all recipes across every archive, with archive chips, Instant Search and a responsive one/two-column layout.
- **Recipe detail:** full ingredient lists with baker's math, scale multipliers, checklists and per-step timers.
- **Saved recipes:** account-free favourites cached offline on the device.
- **Kitchen Mode:** large-text single-step baking with per-step countdown.
- **Settings and appearance:** server URL, test connection, optional Odoo sign-in, theme (`Warm Crust`, `Dark Toast`, `System Default`) and offline cache management.
- **Design system:** hand-tuned Artisan Crust tokens, Playfair Display / Inter typefaces and Material 3.

The full technical reference is published for The Baking Journal under `docs/baking-journal/`.

## Installation & Running

### 1. Requirements

- Flutter SDK stable channel with Dart `>=3.3.0 <4.0.0`
- Android SDK (recent build-tools) and JDK 17
- Visual Studio Desktop C++ workload for Windows builds
- `git`; `jj` if you contribute in the same style as this repository

### 2. Clone

```bash
git clone https://github.com/All-Things-Toasty-Software-Ltd/bakers-archive-mobile-companion.git
cd bakers-archive-mobile-companion
```

### 3. Install dependencies

```bash
flutter pub get
flutter run
```

### 4. Point it at your archive

Open **Settings** → **Odoo Server & Deployment**, set your host and test the connection. The default remains `https://austinatts.co.uk`.

### 5. Build release artifacts

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
```

Windows MSIX packaging is handled by the `msix` package; see **Build & Release** in the documentation tree and the Toasty Deployer pipeline.

## Documentation

See `docs/baking-journal/the-bakers-archive-mobile-companion/` for the full Baking Journal import.

## Licensing & Copyright

Copyright (c) All Things Toasty Software Ltd.

No LICENSE file is currently included in this repository — check with All Things Toasty Software Ltd before reusing or redistributing this code or its icons.
