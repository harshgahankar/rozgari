# KaamSetu — Architecture

## Folder structure
```
lib/
  main.dart                        # ProviderScope + KaamSetuApp
  app/
    app.dart                       # MaterialApp, onGenerateRoute, RootGate, HomeShell (tabs/drawer/demo sheet)
    theme.dart                     # HTML-derived tokens: #00231A/#825500, canvas, stadium CTAs
  core/
    constants/meta.dart            # kTrades, kAreas, kAreaCity, kAreaCoords (approx, not GPS)
    i18n/strings.dart              # EN/HI/MR key map + tr() with EN fallback
    utils/matching.dart            # jobMatchScore, matchJobsForWorker, matchWorkersForEmployer, parseKaamBolo
    utils/lifecycle.dart           # kAllowedTransitions + canTransition (single source of truth)
    utils/safety_rules.dart        # safetyFlagsForJob heuristics + report categories
    widgets/common.dart            # DemoBanner, Loading/Empty, StatusChip, JobCard, showFeedback
  data/
    models/enums.dart              # UserRole, AvailabilityStatus, JobStatus, ApplicationStatus(10),
                                   # AgreementStatus, PaymentStatus, NotificationKind, InvitationStatus
    models/models.dart             # AppUser, WorkerProfile, EmployerProfile, Job, JobApplication,
                                   # WorkAgreement, AppNotification, PaymentRecord, SafetyReport,
                                   # JobInvitation, WelfareResource (+ toJson/fromJson)
    mock/demo_data.dart            # buildDemoData(): 15w/5e/28j + apps/agreements/notifs; dates relative to now
    local/store.dart               # SharedPreferences JSON blob `kaamsetu_v1`
  state/
    app_state.dart                 # AppState + AppController (StateNotifier) + appControllerProvider
  features/
    onboarding/onboarding.dart     # Language, Landing, Role, WorkerProfileForm (validated)
    worker/worker_home.dart        # Dashboard, JobsTab (search/filter/sort/save), JobDetail
    worker/worker_more.dart        # Chowk, Passport, MyJobs tabs, Voice, Safety, Report, Welfare, Notifications
    employer/employer.dart         # Dashboard, PostJob (5-step), Applications, Chowk, Passport view,
                                   # Agreements + simulated payments
    agreements/agreement.dart      # Work Promise Card (dual-confirm, versions, change-reset)
test/
  widget_test.dart                 # dataset scale, guards, matching, safety, voice parse, boot smoke
  demo_flow_test.dart              # full Worker→Employer→Agreement→Completion incl. persistence + reset
```

## State management
Riverpod 2 `StateNotifierProvider<AppController, AppState>`. **One** controller owns every list +
session (`role`, `currentWorkerId`, `currentEmployerId`, `lang`, `onboarded`). All screens read via
`ref.watch`; all mutations go through controller methods that `_persist()` after each change.
Worker apply → employer list updates instantly because both read the same provider.

## Local persistence
Whole state serialized to one JSON blob (`kaamsetu_v1`) in SharedPreferences after every mutation;
rehydrated on boot (`init()`), corrupt data falls back to fresh demo with a notice. **Reset** clears
the blob and rebuilds `buildDemoData()` (language kept). No server, no sync — same-device only.

## Model relationships (stable IDs)
`AppUser(id)` ← `WorkerProfile(userId)` / `EmployerProfile(userId)` •
`Job(employerId → EmployerProfile.id)` • `JobApplication(jobId, workerId)` •
`WorkAgreement(jobId, workerId, employerId, version)` • `PaymentRecord(jobId, workerId)` •
`JobInvitation(jobId, workerId, employerId)` • `AppNotification(userId, refId→job/agreement)`.
IDs: `w01..w15`, `e01..e05`, `j01..j28`; runtime rows use `uuid` prefixes (`a_`, `g_`, `n_`, `p_`, `i_`, `r_`).

## Job lifecycle
`open → closed/cancelled/filled` (employer). Application lawful path:
`applied → shortlisted → offered → confirmed → inProgress → completed`,
with `rejected/withdrawn/cancelled/disputed` exits; `canTransition` blocks jumps (e.g. applied→completed).
Agreement `offered → confirmed` requires **both** `workerConfirmed && employerConfirmed`; any term edit
resets confirmations (new version). Completion auto-ensures a `PaymentRecord` (Pending → Partial/Paid/Disputed,
always labelled simulated). Every transition emits a local notification to the affected party.
