# Flutter Posts App — Riverpod State Management

A two-screen Flutter application demonstrating clean architecture, REST API integration, and shared state mutation using Riverpod.

---

## Features

- Fetch a list of posts from the [JSONPlaceholder API](https://jsonplaceholder.typicode.com/posts)
- Display posts with loading and error states handled gracefully
- A slim refresh indicator under the AppBar shows progress during re-fetch without blocking the list
- Navigate to a detail screen showing the full post
- Edit post title and body locally — updates reflect instantly across both screens
- Refresh the list while preserving any local edits
- Clean separation between data layer and UI layer throughout

---

## Project Structure

```
lib/
├── main.dart                          # App entry point + ThemeData
├── data/
│   ├── models/
│   │   └── post_model.dart            # Immutable Post model with fromJson & copyWith
│   ├── repositories/
│   │   └── post_repository.dart       # HTTP logic, error handling, API calls
│   └── providers/
│       └── post_provider.dart         # All Riverpod providers and PostsNotifier
└── presentation/
    ├── screens/
    │   ├── list_screen.dart           # Post list with filter chips and refresh indicator
    │   └── detail_screen.dart         # Post detail with inline edit
    └── widgets/
        └── post_list_tile.dart        # Reusable post card widget
```
---
## Screens

### List Screen
- Fetches posts on launch with a full-screen loading spinner
- Shows an error view with a retry button on failure
- Tapping a post navigates to the Detail Screen
- Refresh button re-fetches from API while preserving all local edits

### Detail Screen
- Displays the full title and body of the selected post
- Shows the userId as a chip
- Tapping the edit icon switches to edit mode with TextFields
- Save validates input, updates Riverpod state, and exits edit mode
- Cancel discards changes and exits edit mode
- Changes reflect instantly — navigating back shows the updated title in the list

---

## Key Design Decisions

**Local edits survive refresh**
A `_localEdits` map inside `PostsNotifier` tracks every user edit by post id. On refresh, fresh API data is merged with this map — edited posts keep their local values while unedited posts get the latest server data.

**No PUT/PATCH request**
Edits are intentionally local only. `updatePost()` in the notifier writes directly to Riverpod state without touching the repository or making any network call.

**Shared state across screens**
Both `ListScreen` and `DetailScreen` watch the same `postsProvider`. When `updatePost()` is called from the detail screen, the list screen rebuilds automatically on navigation back — no callbacks or arguments passed between screens.

**Two-stage loading feedback**
- **Initial load** → full-screen `CircularProgressIndicator` (no data yet)
- **Refresh** → slim 2px `LinearProgressIndicator` under the AppBar (list stays visible and scrollable)

The distinction is detected via `postsAsync.isLoading && postsAsync.asData != null` — loading is only treated as a refresh when previous data already exists.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0 <4.0.0`
- Dart SDK `>=3.0.0 <4.0.0`
- A connected device or emulator

Check your Flutter setup:
```bash
flutter doctor
```

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/flutter-riverpod-posts.git
cd flutter-riverpod-posts

# Install dependencies
flutter pub get
```

### Running the App

```bash
# Run on connected device (default)
flutter run

# Run on a specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome       # Web
flutter run -d macos        # macOS desktop
```

### Dependencies

```yaml
flutter_riverpod: ^2.5.1   # State management
http: ^1.2.1               # REST API calls
```

Full dependency list is in `pubspec.yaml`.

---

## API

**Endpoint:** `GET https://jsonplaceholder.typicode.com/posts?_limit=15`

**Response shape:**
```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "post title here",
    "body": "post body here"
  }
]
```


---




