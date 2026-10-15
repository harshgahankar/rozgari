# Rozgari — IMPLEMENTATION_PLAN.md
> Beyond the Waiting Line — Frontend UI/UX Hackathon
> Base project: `rozgari` (fresh `flutter create`, counter template). No Rozgari UI exists yet.
> Strategy: scaffold clean architecture now so incoming frontend code can drop in without rewrites. Preserve Material3 seed theme.

## 1. Baseline audit (2026-10-15)

- `pubspec.yaml`: only `cupertino_icons`, `flutter_lints`. No Riverpod / storage / speech / intl.
- `lib/main.dart`: default `MyApp` + `MyHomePage` counter. Title already renamed to `Rozgari`.
- No `app/`, `core/`, `data/`, `features/`, `state/` folders. No routing, no theme file, no widgets.
- `test/widget_test.dart`: default counter smoke test (will be replaced).
- No navigation, forms, mock data, state management, persistence, i18n.
- `flutter analyze`: clean on template. No compilation errors.
- Design to preserve: `ColorScheme.fromSeed(seedColor: Colors.deepPurple)`, Material3, responsive Scaffold defaults.

## 2. Feature matrix

| Feature | Existing screen/widget | Current | Missing | Files to touch/create | Priority | Status |
|---|---|---|---|---|---|---|
| App shell + theme + routes | `lib/main.dart` MyApp | counter only | Rozgari shell, demo entry, bottom nav, theme file | `lib/main.dart`, `lib/app/app.dart`, `lib/app/theme.dart`, `lib/app/routes.dart` | P0 | Planned |
| Data models (User, Worker, Employer, Job, Application, Agreement, Notification, Payment, Safety, Welfare, Invitation) | none | — | all strongly-typed + enums | `lib/data/models/*.dart` | P0 | Planned |
| Mock dataset (15 workers, 5 employers, 28 jobs Pune/Mumbai, apps, agreements, notifs) | none | — | realistic IN data + reset | `lib/data/mock/demo_data.dart` | P0 | Planned |
| Shared state (Riverpod) + persistence (SharedPreferences JSON) | none | — | single source of truth, survive restart | `lib/state/app_state.dart`, `lib/data/local/store.dart` | P0 | Planned |
| Worker onboarding (lang→role→profile→passport preview) | none | — | 12-step form, validation, back-preserve, edit | `lib/features/onboarding/*` | P0 | Planned |
| Worker dashboard (name/trade/availability/jobs/passport/updates) | none | — | dynamic counts, toggle, nav | `lib/features/worker/dashboard.dart` | P0 | Planned |
| Skill Passport view/edit | none | — | summary + edit | `lib/features/skill_passport/*` | P0 | Planned |
| Digital Labour Chowk (worker avail + employer discover) | none | — | deterministic match skill/date/area/avail | `lib/features/labour_chowk/*` | P0 | Planned |
| Job search/filter/sort/save + details | none | — | rule-based match, distance, empty states | `lib/features/jobs/*`, `lib/core/utils/matching.dart` | P0 | Planned |
| Voice search Kaam Bolo | none | — | mic + parse (trade/city/date) + chips + fallback demo | `lib/features/voice_search/*` | P1 | Planned |
| Application lifecycle (Applied→…→Completed, guards) | none | — | service-level transitions + notifs | `lib/state/app_state.dart` methods, `lib/core/utils/lifecycle.dart` | P0 | Planned |
| Employer dashboard + 5-step post job | none | — | post/edit/close, appears in worker list | `lib/features/employer/*` | P0 | Planned |
| Work Promise Card (offer/accept/changes/decline, dual-confirm) | none | — | agreement versions, share preview | `lib/features/agreements/*` | P0 | Planned |
| My Jobs + simulated payments (Pending/Partial/Paid/Disputed) | none | — | tabs by status, completion ack | `lib/features/my_jobs/*` | P0 | Planned |
| Safety (Kaam Suraksha heuristics + report) + Welfare Hub | none | — | suspicious-listing detect, curated dir | `lib/features/safety/*`, `lib/features/welfare/*` | P1 | Planned |
| Notifications (local, read/unread, deep-link) | none | — | event generator + badge | `lib/features/notifications/*` | P0 | Planned |
| i18n EN/HI/MR + a11y (large targets, contrast, TTS hook) | none | — | switcher, key strings, responsive | `lib/core/i18n/strings.dart` | P1 | Planned |
| Demo mode (Ramesh/Meera, switch, reset, tour) | none | — | same central state, banner | `lib/features/demo/*`, `lib/app/app.dart` | P0 | Planned |
| Tests (matching, dup apply, transitions, agreement, reset) | `test/widget_test.dart` counter | obsolete | 5 unit + 2 widget | `test/*_test.dart` | P0 | Planned |
| Docs (overview, status, demo guide, arch) | none | — | 4 md files | `*.md` | P1 | Planned |

## 3. Architecture decision (adapted to empty base)

```
lib/
 main.dart (ProviderScope + App)
 app/app.dart, theme.dart, routes.dart
 core/constants/trades.dart, areas.dart
 core/i18n/strings.dart
 core/utils/matching.dart, lifecycle.dart, safety_rules.dart, format.dart
 core/widgets/common.dart (loading/empty/error, job card, worker tile, status chip)
 data/models/enums.dart + models.dart (all entities, toJson/fromJson)
 data/mock/demo_data.dart (buildDemoData())
 data/local/store.dart (SharedPreferences load/save/clear)
 state/app_state.dart (AppState + AppController StateNotifier, Riverpod providers)
 features/onboarding, worker, employer, jobs, labour_chowk, skill_passport,
   voice_search, agreements, my_jobs, safety, welfare, notifications, demo
```

- State: `flutter_riverpod ^2.5`. Single `AppController` owns lists + session (role, currentWorkerId, currentEmployerId, lang). All screens read via providers — worker apply instantly visible to employer.
- Persist: `shared_preferences` JSON blob `kaamsetu_v1`. Reset = rebuild demo + clear.
- No Firebase/Supabase/API/auth. No ML. Deterministic rules only. No fake trust scores.
- Deps to add only: `flutter_riverpod`, `shared_preferences`, `uuid`, `intl`. `speech_to_text` deferred — real mic attempted if available, else transparent simulated demo (per spec §11: never fake success).
- Preserve design: keep seed color, Material3, reuse new common widgets everywhere so future frontend drop-in only replaces visuals.

## 4. Phased build order

1. Deps + folders + models/enums + utils (matching/lifecycle/safety)
2. Demo data (15/5/28) + store + AppController + i18n
3. Shell + demo switcher + onboarding + dashboards + passport
4. Jobs + chowk + apply/shortlist/offer + agreements + myjobs/payments + notifs
5. Voice (graceful) + safety/welfare + language polish
6. `flutter pub get`, `dart format`, `flutter analyze`, `flutter test`, manual nav/persist/role-switch check, docs

## 5. Risks / notes for incoming frontend code

- Current `lib/` will be fully replaced except `main.dart` entry pattern — frontend screens should import from `state/app_state.dart` providers and `data/models`, not duplicate logic.
- IDs stable (`w01..w15`, `e01..e05`, `j01..j28`). Dates generated relative to `DateTime.now()` so demo never goes stale.
- All payments/agreements labelled “Simulated / self-reported”.
