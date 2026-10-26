# Puntos App

An offline-first Flutter starter for running multiple sports matches independently.

## Run

Install Flutter, then run:

```bash
flutter pub get
flutter analyze
flutter run
```

The starter uses Hive CE for local persistence. The storage boundary is `MatchRepository`, so a relational database can be introduced later without coupling the UI to storage.

## Architecture

- `models/`: serializable domain models and sport catalog.
- `data/`: persistence boundary.
- `main.dart`: initial UI shell.

The current scoring screen is intentionally a vertical slice: create a match, assign a court, increment participant scores, and persist the state offline. Sport-specific rules, sets/games, court management, service positions, match completion, and history are the next domain-layer additions.
