# Rozgari — Feature Status
Validated: `flutter analyze` (0 errors) • `flutter test` (8/8 pass, incl. full demo-flow test) •
`flutter build web` succeeds. Windows build unavailable here (no VS toolchain — env limit, not app bug).

| Feature | Status | Notes |
|---|---|---|
| App shell, theme (HTML palette), routes, drawer, tabs | ✅ Implemented | `lib/app/` |
| Data models + enums + JSON persistence | ✅ Implemented | `lib/data/models/`, `store.dart` |
| Demo data: 15 workers, 5 employers, 28 jobs, apps, agreements, notifs, welfare | ✅ Implemented | `demo_data.dart` |
| Shared Riverpod state + restart persistence + reset | ✅ Implemented | `app_state.dart`, proven by demo-flow test |
| Worker onboarding (lang→role→profile, validation, back-preserve, edit) | ✅ Implemented | `onboarding.dart` |
| Worker dashboard (dynamic counts, availability toggle, quick nav) | ✅ Implemented | `worker_home.dart` |
| Skill Passport view/edit | ✅ Implemented | photos/audio upload **simulated-optional** (by design) |
| Digital Labour Chowk — worker availability + invitations | ✅ Implemented | `worker_more.dart` |
| Digital Labour Chowk — employer discover + invite | ✅ Implemented | `employer.dart` |
| Job search/filter/sort/save + detail + safety flags | ✅ Implemented | rule-based matching, Haversine local calc |
| Kaam Bolo voice search | ⚠️ Partially implemented | text parse + editable chips + results **work**; real mic = honest fallback (no fake success). Needs `speech_to_text` + device mic for live recognition, TTS optional |
| Application lifecycle (10 statuses, guarded transitions) | ✅ Implemented | `lifecycle.dart`, invalid jumps blocked + tested |
| Employer post (5-step) / edit-via-close / close / applications | ⚠️ Partially implemented | post + close + applicants work; in-place job **edit** not exposed (close + repost is the path) |
| Work Promise Card (offer/accept/changes/decline, dual-confirm, versions) | ✅ Implemented | labelled informational, not legal |
| My Jobs tabs + completion + simulated payments | ✅ Implemented | payments always labelled simulated/self-reported |
| Safety flags + report flow + confirmation | ✅ Implemented | rule-based, reasons shown |
| Welfare Hub search/filter | ✅ Implemented | curated info only, no eligibility decisions |
| Notifications (event-driven, read/unread, deep-link, badge) | ✅ Implemented | local only, no push server |
| i18n HI/MR/EN + a11y (large targets, contrast, semantics on key controls) | ⚠️ Partially implemented | key nav/actions translated; full-screen translation + screen-reader audit remain |
| Demo Mode (Ramesh/Meera switch, reset, same state, banner) | ✅ Implemented | guided tour **not** built (drawer + demo sheet instead) |
| Unit + widget + flow tests | ✅ Implemented | 8 tests pass (`test/`) |
| Real backend / auth / payments / push / GPS tracking | ⛔ Not implemented | out of scope by hackathon constraints |

## What is simulated (honestly labelled in-app)
Demo identities & dataset • notifications (local) • payments (self-reported) • photo/audio upload •
microphone path (fallback disclosed) • share slip (copy-to-clipboard) • calling/employer contact.
Nothing claims server sync, legal validity, real money movement, or live GPS.
