# USER_FLOW_AUDIT.md — Rozgari two-role flow audit

Date: 2026-10-15. Scope: `lib/` (19 Dart files) vs the 22-section flow spec.
Verdict: ~75% implemented. Worker↔Employer share one `AppController` + one
`LocalStore` blob — no disconnected second system. Gaps below, prioritized.

## 1. Existing screens (all reachable, all functional)

| Route | Screen | Role |
|---|---|---|
| `/language` | LanguageScreen (EN/HI picker, persisted) | shared |
| `/landing` | LandingScreen (welcome/marketing ≈ Welcome) | shared |
| `/role` | RoleScreen (I Want Work / I Want to Hire) | shared |
| `/profile` | WorkerProfileFormScreen (validate, back-nav safe, editable) | worker |
| `/home` | HomeShell tabs | shared |
| worker tabs | WorkerDashboard, JobsTab (search/filter/sort/save), ChowkTab | worker |
| `/job` | JobDetailScreen (apply, duplicate-blocked, closed-blocked) | worker |
| `/myjobs` | MyJobsScreen (Applications/Offers/Upcoming/In Progress/Completed/Cancelled) | worker |
| `/passport` | PassportScreen (edit, photos placeholder, history) | worker |
| `/voice` | VoiceScreen (mic honest-fallback + demo parse → results) | worker |
| `/safety`, `/report` | SafetyScreen, ReportScreen (simulated submit) | worker |
| `/welfare` | WelfareScreen (searchable info) | worker |
| `/notifications` | NotificationsScreen (role-scoped, mark read) | shared |
| `/agreement` | AgreementScreen (dual confirm, versions, changes, share preview) | shared |
| `/post` | PostJobScreen (5-step, validate, review, publish → visible both sides) | employer |
| `/eapplications` | EmployerApplicationsScreen (shortlist/reject/offer, close, find more) | employer |
| `/echowk` | EmployerChowkScreen (trade+area match, invite) | employer |
| `/epassport` | EmployerPassportScreen (invite per open job) | employer |
| `/eagreements` | EmployerAgreementsScreen + AgreementTile (open promise, payment update) | employer |
| demo sheet | role switcher (Ramesh/Meera/role toggle, reset) — data preserved | shared |

State: `AppController` (Riverpod), `LocalStore` (SharedPreferences single blob
`kaamsetu_v1`), corrupt-data fallback, `canTransition` guards, deterministic
matching, 28 seeded jobs / 15 workers / 5 employers. Tests: 8 passing.

## 2. Missing screens

- M1 Splash screen — entry is Language→Landing→Role; spec wants Splash→Welcome→Role.
- M2 Employer onboarding form (name/type/business/area/contact/review/save).
  Employer currently skips straight to home.
- M3 Employer profile view/edit.
- M4 Job edit for open listings (only close/cancel exists).
- M5 Application confirmation screen (currently snackbar + jump to My Jobs).
- M6 Skill Passport preview step in worker onboarding (saves directly).
- M7 Availability-date selector in Chowk (`availableDate` exists, no UI to change it).
- M8 Date filter in Find Work.

## 3. Broken / rule-violating behavior

- B1 `sendOffer` has no job-status guard — offers possible on closed/cancelled jobs.
- B2 `closeJob` notifies but does NOT cancel active applications/agreements (rule 11).
- B3 No positions cap — confirmations can exceed `requiredWorkers`; `JobStatus.filled`
  is never set (rule 8).
- B4 Worker has no Decline path on offers (only Request changes).
- B5 Accepting an invitation only flips the invite flag — no application record,
  no employer notification (weak second-system smell).
- B6 Employer cannot advance completion (no Start/Complete/Dispute UI; only worker can).
- B7 My Jobs tabs ≠ spec categories (Upcoming vs Confirmed; Shortlisted merged into Offers).
- B8 Work Promise Card has no Date row (job.startDate not shown).
- B9 Seed drift: Ramesh exp 8 (spec 7); Meera type `Individual` (spec Homeowner).
- B10 `Job.copyWith` covers only 4 fields — insufficient for edit-listing.
- B11 No schema version in persisted blob (fallback exists, version field missing).
- B12 Employer Chowk filters only trade+area (spec: +skills/city/date/distance/experience).
- B13 Voice parsed date is ignored when filtering results.
- B14 Availability not captured during worker onboarding (spec step 8).
- B15 No route guards — a worker could deep-link to `/post` etc. (§21).

Dead buttons: none — every button mutates state or shows an honest simulated
fallback (mic, photo upload, call). No fake success without a record.

## 4. Hardcoded values / role-transition issues

- All dashboard counters derive from state. No hardcoded statuses.
- Route transitions correct except: RoleScreen employer path skips onboarding (M2);
  no Splash (M1); no guards (B15).

## 5. Priority fixes (implementation order)

- P0 (demo-blockers): M2, B1, B2, B3, B4, B5, B6, B9, M4, B8, B7, B15, M1.
- P1 (spec compliance): M7, M8, M6, B14, B12, B11, B13, M5.
- P2 (polish): M3, audio-intro placeholder tile.
