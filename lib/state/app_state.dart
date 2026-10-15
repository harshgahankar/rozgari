import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/lifecycle.dart';
import '../data/local/store.dart';
import '../data/mock/demo_data.dart';
import '../data/models/enums.dart';
import '../data/models/models.dart';

const _uuid = Uuid();

class AppState {
  final List<AppUser> users;
  final List<WorkerProfile> workers;
  final List<EmployerProfile> employers;
  final List<Job> jobs;
  final List<JobApplication> applications;
  final List<WorkAgreement> agreements;
  final List<AppNotification> notifications;
  final List<PaymentRecord> payments;
  final List<JobInvitation> invitations;
  final List<SafetyReport> reports;
  final List<WelfareResource> welfare;
  final List<String> savedJobIds;
  // session
  final UserRole role;
  final String currentWorkerId;
  final String currentEmployerId;
  final String lang;
  final bool onboarded;
  final bool loading;
  final String? error;

  const AppState({
    this.users = const [],
    this.workers = const [],
    this.employers = const [],
    this.jobs = const [],
    this.applications = const [],
    this.agreements = const [],
    this.notifications = const [],
    this.payments = const [],
    this.invitations = const [],
    this.reports = const [],
    this.welfare = const [],
    this.savedJobIds = const [],
    this.role = UserRole.worker,
    this.currentWorkerId = 'w01',
    this.currentEmployerId = 'e01',
    this.lang = 'hi',
    this.onboarded = false,
    this.loading = true,
    this.error,
  });

  AppUser get currentWorkerUser => users.firstWhere(
    (u) => u.id == currentWorkerId,
    orElse: () => users.firstWhere((u) => u.role == UserRole.worker),
  );
  AppUser get currentEmployerUser => users.firstWhere(
    (u) => u.id == currentEmployerId,
    orElse: () => users.firstWhere((u) => u.role == UserRole.employer),
  );
  WorkerProfile get currentWorker => workers.firstWhere(
    (w) => w.id == currentWorkerId,
    orElse: () => workers.first,
  );
  EmployerProfile get currentEmployer => employers.firstWhere(
    (e) => e.id == currentEmployerId,
    orElse: () => employers.first,
  );

  int unreadFor(String userId) =>
      notifications.where((n) => n.userId == userId && !n.read).length;

  Map<String, dynamic> toJson() => {
    'users': users.map((e) => e.toJson()).toList(),
    'workers': workers.map((e) => e.toJson()).toList(),
    'employers': employers.map((e) => e.toJson()).toList(),
    'jobs': jobs.map((e) => e.toJson()).toList(),
    'apps': applications.map((e) => e.toJson()).toList(),
    'agreements': agreements.map((e) => e.toJson()).toList(),
    'notifs': notifications.map((e) => e.toJson()).toList(),
    'payments': payments.map((e) => e.toJson()).toList(),
    'invites': invitations.map((e) => e.toJson()).toList(),
    'reports': reports.map((e) => e.toJson()).toList(),
    'saved': savedJobIds,
    'role': role.code,
    'cwid': currentWorkerId,
    'ceid': currentEmployerId,
    'lang': lang,
    'onboarded': onboarded,
  };

  AppState copyWith({
    List<AppUser>? users,
    List<WorkerProfile>? workers,
    List<EmployerProfile>? employers,
    List<Job>? jobs,
    List<JobApplication>? applications,
    List<WorkAgreement>? agreements,
    List<AppNotification>? notifications,
    List<PaymentRecord>? payments,
    List<JobInvitation>? invitations,
    List<SafetyReport>? reports,
    List<String>? savedJobIds,
    UserRole? role,
    String? currentWorkerId,
    String? currentEmployerId,
    String? lang,
    bool? onboarded,
    bool? loading,
    String? error,
  }) => AppState(
    users: users ?? this.users,
    workers: workers ?? this.workers,
    employers: employers ?? this.employers,
    jobs: jobs ?? this.jobs,
    applications: applications ?? this.applications,
    agreements: agreements ?? this.agreements,
    notifications: notifications ?? this.notifications,
    payments: payments ?? this.payments,
    invitations: invitations ?? this.invitations,
    reports: reports ?? this.reports,
    welfare: welfare,
    savedJobIds: savedJobIds ?? this.savedJobIds,
    role: role ?? this.role,
    currentWorkerId: currentWorkerId ?? this.currentWorkerId,
    currentEmployerId: currentEmployerId ?? this.currentEmployerId,
    lang: lang ?? this.lang,
    onboarded: onboarded ?? this.onboarded,
    loading: loading ?? this.loading,
    error: error,
  );
}

class AppController extends StateNotifier<AppState> {
  final LocalStore _store;
  AppController(this._store) : super(const AppState()) {
    init();
  }

  Future<void> init() async {
    final saved = await _store.load();
    if (saved == null) {
      final d = buildDemoData();
      state = state.copyWith(
        users: d.users,
        workers: d.workers,
        employers: d.employers,
        jobs: d.jobs,
        applications: d.applications,
        agreements: d.agreements,
        notifications: d.notifications,
        payments: d.payments,
        invitations: d.invitations,
        reports: d.reports,
        loading: false,
      );
      await _persist();
    } else {
      try {
        _fromJson(saved);
      } catch (e) {
        final d = buildDemoData();
        state = state.copyWith(
          users: d.users,
          workers: d.workers,
          employers: d.employers,
          jobs: d.jobs,
          applications: d.applications,
          agreements: d.agreements,
          notifications: d.notifications,
          payments: d.payments,
          invitations: d.invitations,
          reports: d.reports,
          loading: false,
          error: 'Saved data was corrupt — demo restored.',
        );
      }
    }
  }

  void _fromJson(Map<String, dynamic> j) {
    final d = buildDemoData();
    List<T> list<T>(String k, T Function(Map<String, dynamic>) f) {
      final raw = (j[k] ?? []) as List;
      return raw.map((e) => f(Map<String, dynamic>.from(e as Map))).toList();
    }

    state = AppState(
      users:
          (j['users'] as List?)
              ?.map(
                (e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          d.users,
      workers: list('workers', WorkerProfile.fromJson),
      employers: list('employers', EmployerProfile.fromJson),
      jobs: list('jobs', Job.fromJson),
      applications: list('apps', JobApplication.fromJson),
      agreements: list('agreements', WorkAgreement.fromJson),
      notifications: list('notifs', AppNotification.fromJson),
      payments: list('payments', PaymentRecord.fromJson),
      invitations: list('invites', JobInvitation.fromJson),
      reports: list('reports', SafetyReport.fromJson),
      welfare: d.welfare,
      savedJobIds: List<String>.from((j['saved'] ?? []) as List),
      role:
          enumFromCode(UserRole.values, j['role'] as String?) ??
          UserRole.worker,
      currentWorkerId: (j['cwid'] ?? 'w01') as String,
      currentEmployerId: (j['ceid'] ?? 'e01') as String,
      lang: (j['lang'] ?? 'hi') as String,
      onboarded: (j['onboarded'] ?? false) as bool,
      loading: false,
    );
  }

  Future<void> _persist() => _store.save(state.toJson());

  // ---------- session ----------
  Future<void> setLang(String v) async {
    state = state.copyWith(lang: v);
    await _persist();
  }

  Future<void> setRole(UserRole r) async {
    state = state.copyWith(role: r);
    await _persist();
  }

  Future<void> switchWorker(String id) async {
    state = state.copyWith(currentWorkerId: id, role: UserRole.worker);
    await _persist();
  }

  Future<void> switchEmployer(String id) async {
    state = state.copyWith(currentEmployerId: id, role: UserRole.employer);
    await _persist();
  }

  Future<void> setOnboarded(bool v) async {
    state = state.copyWith(onboarded: v);
    await _persist();
  }

  Future<void> resetDemo() async {
    await _store.clear();
    final d = buildDemoData();
    final keepLang = state.lang;
    state = AppState(
      users: d.users,
      workers: d.workers,
      employers: d.employers,
      jobs: d.jobs,
      applications: d.applications,
      agreements: d.agreements,
      notifications: d.notifications,
      payments: d.payments,
      invitations: d.invitations,
      reports: d.reports,
      welfare: d.welfare,
      lang: keepLang,
      loading: false,
    );
    await _persist();
  }

  // ---------- worker ----------
  Future<void> upsertWorkerProfile(WorkerProfile w) async {
    final list = [...state.workers];
    final i = list.indexWhere((e) => e.id == w.id);
    if (i >= 0) {
      list[i] = w;
    } else {
      list.add(w);
    }
    state = state.copyWith(workers: list);
    await _persist();
  }

  Future<void> setAvailability(
    AvailabilityStatus v, {
    bool? discoverable,
  }) async {
    final w = state.currentWorker;
    await upsertWorkerProfile(
      w.copyWith(availability: v, discoverable: discoverable ?? w.discoverable),
    );
  }

  Future<void> toggleSaveJob(String jobId) async {
    final s = [...state.savedJobIds];
    if (s.contains(jobId)) {
      s.remove(jobId);
    } else {
      s.add(jobId);
    }
    state = state.copyWith(savedJobIds: s);
    await _persist();
  }

  ({bool ok, String msg}) applyForJob(String jobId) {
    final job = state.jobs.firstWhere((j) => j.id == jobId);
    if (job.status != JobStatus.open)
      return (ok: false, msg: 'Job is no longer open');
    final dup = state.applications.any(
      (a) =>
          a.jobId == jobId &&
          a.workerId == state.currentWorkerId &&
          ![
            ApplicationStatus.rejected,
            ApplicationStatus.withdrawn,
            ApplicationStatus.cancelled,
          ].contains(a.status),
    );
    if (dup) return (ok: false, msg: 'Already applied — check My Jobs');
    final now = DateTime.now();
    final app = JobApplication(
      id: 'a_${_uuid.v4().substring(0, 6)}',
      jobId: jobId,
      workerId: state.currentWorkerId,
      status: ApplicationStatus.applied,
      appliedAt: now,
      updatedAt: now,
    );
    final empUserId = _employerUserIdForJob(job);
    state = state.copyWith(
      applications: [...state.applications, app],
      notifications: [
        ...state.notifications,
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: empUserId,
          kind: NotificationKind.applied,
          title: 'New application',
          body: '${state.currentWorkerUser.name} applied for ${job.title}.',
          refId: jobId,
          createdAt: now,
        ),
      ],
    );
    _persist();
    return (ok: true, msg: 'Application saved — employer notified');
  }

  String _employerUserIdForJob(Job job) {
    final emp = state.employers.firstWhere(
      (e) => e.id == job.employerId,
      orElse: () => state.employers.first,
    );
    return emp.userId;
  }

  ({bool ok, String msg}) transitionApplication(
    String appId,
    ApplicationStatus to,
  ) {
    final i = state.applications.indexWhere((a) => a.id == appId);
    if (i < 0) return (ok: false, msg: 'Application not found');
    final app = state.applications[i];
    if (!canTransition(app.status, to)) {
      return (
        ok: false,
        msg: 'Invalid status: ${app.status.name} → ${to.name}',
      );
    }
    final list = [...state.applications];
    list[i] = app.copyWith(status: to, updatedAt: DateTime.now());
    final job = state.jobs.firstWhere((j) => j.id == app.jobId);
    final notifs = [...state.notifications];
    final now = DateTime.now();
    void notify(String uid, NotificationKind k, String t, String b) =>
        notifs.add(
          AppNotification(
            id: 'n_${_uuid.v4().substring(0, 6)}',
            userId: uid,
            kind: k,
            title: t,
            body: b,
            refId: app.jobId,
            createdAt: now,
          ),
        );
    switch (to) {
      case ApplicationStatus.shortlisted:
        notify(
          app.workerId,
          NotificationKind.shortlisted,
          'You were shortlisted',
          'Good news — you were shortlisted for ${job.title}.',
        );
      case ApplicationStatus.offered:
        notify(
          app.workerId,
          NotificationKind.offered,
          'Work offer received',
          'Review the Work Promise Card for ${job.title}.',
        );
      case ApplicationStatus.confirmed:
        notify(
          app.workerId,
          NotificationKind.agreementConfirmed,
          'Agreement confirmed',
          'Work Promise confirmed for ${job.title}.',
        );
        notify(
          _employerUserIdForJob(job),
          NotificationKind.agreementConfirmed,
          'Worker confirmed',
          '${_workerName(app.workerId)} confirmed ${job.title}.',
        );
      case ApplicationStatus.inProgress:
        notify(
          _employerUserIdForJob(job),
          NotificationKind.general,
          'Work started',
          '${_workerName(app.workerId)} started ${job.title}.',
        );
      case ApplicationStatus.completed:
        notify(
          _employerUserIdForJob(job),
          NotificationKind.completed,
          'Work completed (simulated)',
          '${_workerName(app.workerId)} marked ${job.title} complete.',
        );
        notify(
          app.workerId,
          NotificationKind.completed,
          'Completion recorded',
          'Completion recorded for ${job.title}.',
        );
      case ApplicationStatus.rejected:
        notify(
          app.workerId,
          NotificationKind.declined,
          'Application update',
          'Your application for ${job.title} was not selected.',
        );
      case ApplicationStatus.withdrawn:
        notify(
          _employerUserIdForJob(job),
          NotificationKind.declined,
          'Application withdrawn',
          '${_workerName(app.workerId)} withdrew from ${job.title}.',
        );
      case ApplicationStatus.cancelled:
        notify(
          app.workerId,
          NotificationKind.cancelled,
          'Job cancelled',
          '${job.title} was cancelled.',
        );
      case ApplicationStatus.disputed:
        notify(
          _employerUserIdForJob(job),
          NotificationKind.payment,
          'Issue raised',
          'An issue was raised on ${job.title}.',
        );
      default:
        break;
    }
    state = state.copyWith(applications: list, notifications: notifs);
    _persist();
    return (ok: true, msg: 'Status → ${to.name}');
  }

  String _workerName(String workerProfileId) {
    try {
      final wid = state.workers
          .firstWhere((w) => w.id == workerProfileId)
          .userId;
      return state.users.firstWhere((u) => u.id == wid).name;
    } catch (_) {
      return 'Worker';
    }
  }

  // ---------- employer: jobs ----------
  Future<String> postJob(Job draft) async {
    state = state.copyWith(jobs: [...state.jobs, draft]);
    await _persist();
    return draft.id;
  }

  Future<void> updateJob(Job updated) async {
    final list = [...state.jobs];
    final i = list.indexWhere((j) => j.id == updated.id);
    if (i >= 0) list[i] = updated;
    state = state.copyWith(jobs: list);
    await _persist();
  }

  Future<void> closeJob(String jobId, JobStatus to) async {
    final list = [...state.jobs];
    final i = list.indexWhere((j) => j.id == jobId);
    if (i < 0) return;
    list[i] = list[i].copyWith(status: to);
    // notify active applicants
    final notifs = [...state.notifications];
    for (final a in state.applications.where(
      (a) =>
          a.jobId == jobId &&
          ![
            ApplicationStatus.completed,
            ApplicationStatus.rejected,
            ApplicationStatus.cancelled,
          ].contains(a.status),
    )) {
      notifs.add(
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: a.workerId,
          kind: NotificationKind.cancelled,
          title: 'Job ${to.name}',
          body: '${list[i].title} was ${to.name}.',
          refId: jobId,
          createdAt: DateTime.now(),
        ),
      );
    }
    state = state.copyWith(jobs: list, notifications: notifs);
    await _persist();
  }

  // ---------- agreements ----------
  Future<WorkAgreement> sendOffer({
    required String jobId,
    required String workerId,
    double? payOverride,
  }) async {
    final job = state.jobs.firstWhere((j) => j.id == jobId);
    final existing = state.agreements
        .where((g) => g.jobId == jobId && g.workerId == workerId)
        .toList();
    final now = DateTime.now();
    final g = WorkAgreement(
      id: 'g_${_uuid.v4().substring(0, 6)}',
      jobId: jobId,
      workerId: workerId,
      employerId: job.employerId,
      agreedPay: payOverride ?? job.payAmount,
      workingHours: job.workingHours,
      location: job.location,
      paymentTerms: job.paymentTerms,
      workerConfirmed: false,
      employerConfirmed: true,
      status: AgreementStatus.offered,
      updatedAt: now,
      version: existing.isEmpty
          ? 1
          : existing.map((e) => e.version).reduce((a, b) => a > b ? a : b) + 1,
    );
    transitionApplicationFor(
      jobId,
      workerId,
      ApplicationStatus.offered,
      silent: true,
    );
    state = state.copyWith(
      agreements: [...state.agreements, g],
      notifications: [
        ...state.notifications,
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: workerId,
          kind: NotificationKind.offered,
          title: 'Work offer received',
          body:
              'Review the Work Promise Card for ${job.title} (₹${g.agreedPay.toStringAsFixed(0)}).',
          refId: g.id,
          createdAt: now,
        ),
      ],
    );
    await _persist();
    return g;
  }

  void transitionApplicationFor(
    String jobId,
    String workerId,
    ApplicationStatus to, {
    bool silent = false,
  }) {
    final idx = state.applications.indexWhere(
      (a) =>
          a.jobId == jobId &&
          a.workerId == workerId &&
          ![
            ApplicationStatus.rejected,
            ApplicationStatus.withdrawn,
            ApplicationStatus.cancelled,
            ApplicationStatus.completed,
          ].contains(a.status),
    );
    if (idx < 0) {
      // auto-create path offer→confirmed needs an application row
      if (to == ApplicationStatus.offered) {
        final now = DateTime.now();
        final app = JobApplication(
          id: 'a_${_uuid.v4().substring(0, 6)}',
          jobId: jobId,
          workerId: workerId,
          status: ApplicationStatus.offered,
          appliedAt: now,
          updatedAt: now,
        );
        state = state.copyWith(applications: [...state.applications, app]);
      }
      return;
    }
    final app = state.applications[idx];
    // walk through intermediate states if needed (shortlist before offer)
    ApplicationStatus cur = app.status;
    final list = [...state.applications];
    List<ApplicationStatus> path(
      ApplicationStatus from,
      ApplicationStatus target,
    ) {
      if (from == ApplicationStatus.applied &&
          target == ApplicationStatus.offered) {
        return [ApplicationStatus.shortlisted, ApplicationStatus.offered];
      }
      return [target];
    }

    for (final step in path(cur, to)) {
      if (!canTransition(cur, step)) break;
      final i2 = list.indexWhere((a) => a.id == app.id);
      list[i2] = list[i2].copyWith(status: step, updatedAt: DateTime.now());
      cur = step;
    }
    state = state.copyWith(applications: list);
    if (!silent) _persist();
  }

  Future<({bool ok, String msg})> confirmAgreement(
    String agreementId, {
    required bool byWorker,
  }) async {
    final i = state.agreements.indexWhere((g) => g.id == agreementId);
    if (i < 0) return (ok: false, msg: 'Agreement not found');
    final g = state.agreements[i];
    final upd = g.copyWith(
      workerConfirmed: byWorker ? true : g.workerConfirmed,
      employerConfirmed: byWorker ? g.employerConfirmed : true,
      updatedAt: DateTime.now(),
    );
    final both = upd.workerConfirmed && upd.employerConfirmed;
    final list = [...state.agreements];
    list[i] = upd.copyWith(
      status: both ? AgreementStatus.confirmed : AgreementStatus.offered,
    );
    state = state.copyWith(agreements: list);
    if (both) {
      // confirmed → move application to confirmed
      final ai = state.applications.indexWhere(
        (a) =>
            a.jobId == g.jobId &&
            a.workerId == g.workerId &&
            ![
              ApplicationStatus.completed,
              ApplicationStatus.cancelled,
              ApplicationStatus.rejected,
            ].contains(a.status),
      );
      if (ai >= 0) {
        // walk offered→confirmed (allowed), or shortlisted→offered→confirmed
        var cur = state.applications[ai].status;
        final alist = [...state.applications];
        for (final step in [
          ApplicationStatus.offered,
          ApplicationStatus.confirmed,
        ]) {
          if (cur == step) continue;
          if (canTransition(cur, step)) {
            alist[ai] = alist[ai].copyWith(
              status: step,
              updatedAt: DateTime.now(),
            );
            cur = step;
          }
        }
        state = state.copyWith(applications: alist);
      }
      state = state.copyWith(
        notifications: [
          ...state.notifications,
          AppNotification(
            id: 'n_${_uuid.v4().substring(0, 6)}',
            userId: byWorker ? g.employerId : g.workerId,
            kind: NotificationKind.agreementConfirmed,
            title: 'Agreement confirmed',
            body: 'Work Promise confirmed (v${upd.version}).',
            refId: g.id,
            createdAt: DateTime.now(),
          ),
        ],
      );
    }
    await _persist();
    return (
      ok: true,
      msg: both
          ? 'Agreement confirmed by both sides'
          : 'Your confirmation saved — waiting for other side',
    );
  }

  Future<void> requestChanges(String agreementId, String note) async {
    final i = state.agreements.indexWhere((g) => g.id == agreementId);
    if (i < 0) return;
    final g = state.agreements[i];
    final list = [...state.agreements];
    list[i] = g.copyWith(
      status: AgreementStatus.changesRequested,
      workerConfirmed: false,
      employerConfirmed: false,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      agreements: list,
      notifications: [
        ...state.notifications,
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: g.employerId,
          kind: NotificationKind.general,
          title: 'Changes requested',
          body: note.isEmpty
              ? 'Worker requested changes to the Work Promise.'
              : note,
          refId: g.id,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await _persist();
  }

  Future<void> declineAgreement(String agreementId) async {
    final i = state.agreements.indexWhere((g) => g.id == agreementId);
    if (i < 0) return;
    final list = [...state.agreements];
    list[i] = list[i].copyWith(
      status: AgreementStatus.declined,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(agreements: list);
    await _persist();
  }

  Future<void> renameCurrentWorker(String name) async {
    final users = [...state.users];
    final ui = users.indexWhere((u) => u.id == state.currentWorkerId);
    if (ui < 0) return;
    final old = users[ui];
    users[ui] = AppUser(
      id: old.id,
      name: name,
      role: old.role,
      preferredLanguage: old.preferredLanguage,
      contact: old.contact,
    );
    state = state.copyWith(users: users);
    await _persist();
  }

  // ---------- payments ----------
  Future<void> setPaymentStatus(String paymentId, PaymentStatus s) async {
    final list = [...state.payments];
    final i = list.indexWhere((p) => p.id == paymentId);
    if (i < 0) return;
    list[i] = list[i].copyWith(status: s);
    final p = list[i];
    state = state.copyWith(
      payments: list,
      notifications: [
        ...state.notifications,
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: p.workerId,
          kind: NotificationKind.payment,
          title: 'Payment update (simulated)',
          body:
              'Payment for job marked ${s.name}. Self-reported, not a real transfer.',
          refId: p.jobId,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await _persist();
  }

  Future<void> ensurePaymentFor(
    String jobId,
    String workerId,
    double amount,
  ) async {
    if (state.payments.any((p) => p.jobId == jobId && p.workerId == workerId))
      return;
    state = state.copyWith(
      payments: [
        ...state.payments,
        PaymentRecord(
          id: 'p_${_uuid.v4().substring(0, 6)}',
          jobId: jobId,
          workerId: workerId,
          amount: amount,
          updatedAt: DateTime.now(),
        ),
      ],
    );
    await _persist();
  }

  // ---------- invitations / safety / notifs ----------
  Future<void> sendInvitation({
    required String jobId,
    required String workerId,
  }) async {
    final job = state.jobs.firstWhere((j) => j.id == jobId);
    state = state.copyWith(
      invitations: [
        ...state.invitations,
        JobInvitation(
          id: 'i_${_uuid.v4().substring(0, 6)}',
          jobId: jobId,
          workerId: workerId,
          employerId: job.employerId,
          createdAt: DateTime.now(),
        ),
      ],
      notifications: [
        ...state.notifications,
        AppNotification(
          id: 'n_${_uuid.v4().substring(0, 6)}',
          userId: workerId,
          kind: NotificationKind.invitation,
          title: 'Direct invitation',
          body:
              'You were invited for ${job.title} (₹${job.payAmount.toStringAsFixed(0)}).',
          refId: jobId,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await _persist();
  }

  Future<void> respondInvitation(String id, InvitationStatus s) async {
    final list = [...state.invitations];
    final i = list.indexWhere((e) => e.id == id);
    if (i < 0) return;
    list[i] = list[i].copyWith(status: s);
    state = state.copyWith(invitations: list);
    await _persist();
  }

  Future<void> submitReport({
    required String jobId,
    required String category,
    required String description,
  }) async {
    state = state.copyWith(
      reports: [
        ...state.reports,
        SafetyReport(
          id: 'r_${_uuid.v4().substring(0, 6)}',
          jobId: jobId,
          reporterId: state.currentWorkerId,
          category: category,
          description: description,
          createdAt: DateTime.now(),
        ),
      ],
    );
    await _persist();
  }

  Future<void> markRead(String notifId) async {
    final list = state.notifications
        .map((n) => n.id == notifId ? n.markRead() : n)
        .toList();
    state = state.copyWith(notifications: list);
    await _persist();
  }

  Future<void> markAllRead(String userId) async {
    final list = state.notifications
        .map((n) => n.userId == userId ? n.markRead() : n)
        .toList();
    state = state.copyWith(notifications: list);
    await _persist();
  }
}

final appControllerProvider = StateNotifierProvider<AppController, AppState>(
  (ref) => AppController(LocalStore()),
);
