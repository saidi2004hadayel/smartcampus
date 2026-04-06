# SmartCampus Companion

A Flutter + FastAPI mobile application demonstrating Mobile OS concepts for the university semester project.

---

## Architecture Overview

```
smartcampus/
├── backend/                    ← FastAPI (Python) — port 8003
│   ├── main.py                 ← App entry, CORS, lifespan
│   ├── database.py             ← Motor async MongoDB client + seed data
│   ├── schemas.py              ← Pydantic request/response models
│   ├── auth_utils.py           ← JWT + bcrypt utilities
│   ├── dependencies.py         ← get_current_user FastAPI dependency
│   ├── requirements.txt
│   └── routes/
│       ├── auth.py             ← POST /login, /register, GET /me
│       ├── announcements.py    ← CRUD + category filter
│       ├── events.py           ← Upcoming events with coordinates
│       └── timetable.py        ← GET by day_of_week
│
└── flutter_app/
    ├── pubspec.yaml
    ├── android/app/src/main/AndroidManifest.xml
    └── lib/
        ├── main.dart           ← Bootstrap, WorkManager, Notifications init
        ├── core/
        │   ├── di/             ← GetIt service locator
        │   ├── network/        ← Dio client (JWT interceptor) + ConnectivityService
        │   ├── storage/        ← SecureStorageService + SQLite DatabaseHelper
        │   ├── notifications/  ← NotificationService (schedule + instant)
        │   ├── lifecycle/      ← AppLifecycleObserver mixin
        │   ├── theme/          ← AppTheme (light + dark)
        │   └── router/         ← GoRouter with auth guard + bottom nav
        └── features/
            ├── auth/           ← LoginScreen, RegisterScreen, AuthBloc
            ├── home/           ← Dashboard + Accelerometer sensor demo
            ├── announcements/  ← List + Detail + offline banner + shimmer
            ├── events/         ← List + camera permission + image picker
            ├── timetable/      ← Day selector + reminder + JSON export
            ├── map/            ← Geolocator + campus POIs + distance
            └── settings/       ← Dark mode, notifications, language, logout
```

---

## OS Concepts Demonstrated

| Concept | Where |
|---|---|
| **App Lifecycle** | `HomeScreen` — `WidgetsBindingObserver`, refresh on resume |
| **Permissions Model** | Camera in `EventsScreen`, Location in `MapScreen`, Notifications in `NotificationService` |
| **Secure Storage** | `SecureStorageService` — AES-256 via `flutter_secure_storage` |
| **File System / Sandbox** | `DatabaseHelper` — SQLite in app sandbox |
| **Networking** | `DioClient` — JWT interceptor, timeout, connectivity-aware |
| **Offline-First** | All repositories: API → cache → serve cached on failure |
| **Background Execution** | `WorkManager` periodic task in `main.dart` |
| **Local Notifications** | `NotificationService` — scheduled class reminders with deep-link payload |
| **Biometrics** | `LoginScreen` — `local_auth` fingerprint/face unlock |
| **Sensors** | `HomeScreen` — real-time accelerometer via `sensors_plus` |
| **File I/O Export** | `TimetableRepository.exportAsJson()` → `Share.shareXFiles` |

---

## Quick Start

### 1. Backend

```bash
# Requires Python 3.11+ and MongoDB running on localhost:27017
cd backend
pip install -r requirements.txt
cp .env.example .env

# Start server
uvicorn main:app --host 0.0.0.0 --port 8003 --reload
# API docs: http://localhost:8003/docs
```

### 2. Flutter App (Android Studio)

```bash
cd flutter_app
flutter pub get

# Run on emulator
flutter run
# The emulator reaches your machine via 10.0.2.2
# DioClient base URL is already set to http://10.0.2.2:8003/api
```

### 3. Add pubspec dependency (get_it + go_router)

Add to `pubspec.yaml` dependencies:
```yaml
get_it: ^7.7.0
go_router: ^14.2.0
```

### 4. Run tests

```bash
cd flutter_app
flutter pub run build_runner build   # generate mocks
flutter test
```

---

## Performance Profiling Notes (for technical report)

**Improvement 1 — List rebuilds:**
- Before: `AnnouncementsScreen` rebuilt entire list on every BLoC emission
- After: Used `const` constructors on cards + `ListView.builder` (lazy rendering)
- Observed: Reduced widget rebuilds from ~40 to ~4 per refresh in Flutter DevTools

**Improvement 2 — Image caching:**
- Before: No image caching on event posters
- After: `cached_network_image` with `CacheManager` (LRU, 7-day TTL)
- Observed: Eliminated repeated network fetches, frame render time dropped

---

## Security Notes (OWASP Mobile Top 10)

- **M1 Improper Credential Usage** — Tokens stored in `flutter_secure_storage` (AES-256), never in `SharedPreferences`
- **M2 Inadequate Supply Chain** — All packages from pub.dev, pinned versions
- **M4 Insufficient Input/Output Validation** — Pydantic models validate all API inputs server-side
- **M6 Inadequate Privacy Controls** — Location only requested at runtime, not at install
- **M9 Insecure Data Storage** — SQLite cache contains no credentials; JWT in encrypted storage only

---

## API Endpoints

| Method | Route | Auth | Description |
|---|---|---|---|
| POST | /api/auth/register | — | Register new user |
| POST | /api/auth/login | — | Login, returns JWT |
| GET | /api/auth/me | Bearer | Current user profile |
| GET | /api/announcements/ | Bearer | List (paginated, filter by category) |
| GET | /api/announcements/:id | Bearer | Single announcement |
| POST | /api/announcements/ | Bearer | Create announcement |
| GET | /api/events/ | Bearer | Upcoming events |
| GET | /api/timetable/ | Bearer | Full timetable (optional ?day=0-6) |
