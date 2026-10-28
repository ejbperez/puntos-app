# Puntos App

An offline-first Flutter starter for running multiple sports matches independently.

## Run

Install Flutter, then run:

```bash
flutter pub get
flutter analyze
flutter run
```

## iOS and Codemagic

The iOS project is included with bundle identifier `com.ejbperez.puntosapp`.
The `ios-release` workflow in `codemagic.yaml` builds a signed IPA using
Codemagic-managed certificates and provisioning profiles. In Codemagic, add
the App Store Connect signing certificate and provisioning profile for this
bundle identifier to the connected team before running the workflow.

The `android-release` workflow builds a signed AAB and APK. In Codemagic,
upload the production Android keystore under **Code signing identities →
Android keystores** with the reference name `puntos-app-release`. Keep an
independent backup of this keystore; it must be reused for future Google Play
updates. The Android package name is `com.ejbperez.puntos_app`.

The starter uses Hive CE for local persistence. The storage boundary is `MatchRepository`, so a relational database can be introduced later without coupling the UI to storage.

## Architecture

- `models/`: serializable domain models and sport catalog.
- `data/`: persistence boundary.
- `main.dart`: initial UI shell.

The current scoring screen is intentionally a vertical slice: create a match, assign a court, increment participant scores, and persist the state offline. Sport-specific rules, sets/games, court management, service positions, match completion, and history are the next domain-layer additions.

## Vercel web deployment

Vercel uses `vercel.sh` to install the stable Flutter SDK and build the web
release. The generated site is published from `build/web`, as configured in
`vercel.json`. No Flutter SDK or build artifacts are stored in the repository.
