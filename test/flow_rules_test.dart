import 'package:flutter_test/flutter_test.dart';
import 'package:rozgari/core/utils/matching.dart';
import 'package:rozgari/data/models/enums.dart';
import 'package:rozgari/data/models/models.dart';
import 'package:rozgari/state/app_state.dart';
import 'package:rozgari/data/local/store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Future<AppController> _fresh() async {
  SharedPreferences.setMockInitialValues({});
  final ctl = AppController(LocalStore());
  for (var i = 0; i < 50 && ctl.state.loading; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  expect(ctl.state.loading, isFalse);
  return ctl;
}

Future<Job> _publish(AppController ctl, {int need = 1}) async {
  await ctl.switchEmployer('e01');
  await ctl.setRole(UserRole.employer);
  final now = DateTime.now();
  final job = Job(
    id: 'j_${_uuid.v4().substring(0, 6)}',
    employerId: 'e01',
    title: 'Test wiring job',
    category: 'Electrician',
    description: 'A sufficiently long test description for validation.',
    location: 'Kothrud, Pune',
    city: 'Pune',
    payAmount: 800,
    startDate: DateTime(now.year, now.month, now.day + 1),
    duration: '1 day',
    workingHours: '9am – 5pm',
    requiredWorkers: need,
    paymentTerms: 'Daily cash after work',
    createdAt: now,
  );
  await ctl.postJob(job);
  await ctl.switchWorker('w01');
  await ctl.setRole(UserRole.worker);
  return job;
}

Future<void> _confirm(AppController ctl, String jobId, String workerId) async {
  await ctl.switchWorker(workerId);
  expect(ctl.applyForJob(jobId).ok, isTrue);
  await ctl.switchEmployer('e01');
  var app = ctl.state.applications.firstWhere(
    (a) => a.jobId == jobId && a.workerId == workerId,
  );
  expect(
    ctl.transitionApplication(app.id, ApplicationStatus.shortlisted).ok,
    isTrue,
  );
  final offer = await ctl.sendOffer(jobId: jobId, workerId: workerId);
  expect(offer.ok, isTrue, reason: offer.msg);
  await ctl.switchWorker(workerId);
  final r = await ctl.confirmAgreement(offer.offer!.id, byWorker: true);
  expect(r.ok, isTrue);
}

void main() {
  test('published job is owned + visible to worker discovery', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl);
    expect(
      ctl.state.jobs.where((j) => j.employerId == 'e01').map((j) => j.id),
      contains(job.id),
    );
    final matched = matchJobsForWorker(ctl.state.currentWorker, ctl.state.jobs);
    expect(matched.map((j) => j.id), contains(job.id));
  });

  test('positions cap: second worker blocked once job is filled', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl, need: 1);
    await _confirm(ctl, job.id, 'w01');
    final filled = ctl.state.jobs.firstWhere((j) => j.id == job.id);
    expect(filled.status, JobStatus.filled);

    await ctl.switchWorker('w02');
    final r = ctl.applyForJob(job.id);
    expect(r.ok, isFalse);

    await ctl.switchEmployer('e01');
    final offer = await ctl.sendOffer(jobId: job.id, workerId: 'w02');
    expect(offer.ok, isFalse);
  });

  test('offers blocked on closed jobs', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl);
    await ctl.switchWorker('w01');
    expect(ctl.applyForJob(job.id).ok, isTrue);
    await ctl.switchEmployer('e01');
    await ctl.closeJob(job.id, JobStatus.closed);
    final offer = await ctl.sendOffer(jobId: job.id, workerId: 'w01');
    expect(offer.ok, isFalse);
  });

  test('closing a job cancels active applications + agreements', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl);
    await ctl.switchWorker('w01');
    expect(ctl.applyForJob(job.id).ok, isTrue);
    await ctl.switchEmployer('e01');
    var app = ctl.state.applications.firstWhere((a) => a.jobId == job.id);
    expect(
      ctl.transitionApplication(app.id, ApplicationStatus.shortlisted).ok,
      isTrue,
    );
    final offer = await ctl.sendOffer(jobId: job.id, workerId: 'w01');
    expect(offer.ok, isTrue);

    await ctl.closeJob(job.id, JobStatus.cancelled);
    app = ctl.state.applications.firstWhere((a) => a.jobId == job.id);
    expect(app.status, ApplicationStatus.cancelled);
    final g = ctl.state.agreements.firstWhere((e) => e.id == offer.offer!.id);
    expect(g.status, AgreementStatus.cancelled);
    // worker was notified
    expect(
      ctl.state.notifications.any(
        (n) => n.userId == 'w01' && n.kind == NotificationKind.cancelled,
      ),
      isTrue,
    );
    // no new applications after close
    await ctl.switchWorker('w01');
    expect(ctl.applyForJob(job.id).ok, isFalse);
  });

  test(
    'accepting an invitation creates an application + notifies employer',
    () async {
      final ctl = await _fresh();
      final job = await _publish(ctl);
      await ctl.switchEmployer('e01');
      await ctl.sendInvitation(jobId: job.id, workerId: 'w01');
      final inv = ctl.state.invitations.firstWhere(
        (e) => e.jobId == job.id && e.workerId == 'w01',
      );
      await ctl.switchWorker('w01');
      final r = await ctl.respondInvitation(inv.id, InvitationStatus.accepted);
      expect(r.ok, isTrue, reason: r.msg);
      expect(
        ctl.state.applications.any(
          (a) =>
              a.jobId == job.id &&
              a.workerId == 'w01' &&
              a.status == ApplicationStatus.applied,
        ),
        isTrue,
      );
      final empUser = ctl.state.employers
          .firstWhere((e) => e.id == 'e01')
          .userId;
      expect(
        ctl.state.notifications.any(
          (n) => n.userId == empUser && n.kind == NotificationKind.applied,
        ),
        isTrue,
      );
    },
  );

  test('worker can decline an offer, history preserved', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl);
    await ctl.switchWorker('w01');
    expect(ctl.applyForJob(job.id).ok, isTrue);
    await ctl.switchEmployer('e01');
    final app = ctl.state.applications.firstWhere((a) => a.jobId == job.id);
    await ctl.transitionApplication(app.id, ApplicationStatus.shortlisted);
    final offer = await ctl.sendOffer(jobId: job.id, workerId: 'w01');
    expect(offer.ok, isTrue);
    await ctl.switchWorker('w01');
    await ctl.declineAgreement(offer.offer!.id);
    final g = ctl.state.agreements.firstWhere((e) => e.id == offer.offer!.id);
    expect(g.status, AgreementStatus.declined);
    // application row still exists
    expect(ctl.state.applications.any((a) => a.jobId == job.id), isTrue);
  });

  test('discovery hides unavailable workers, date filter works', () async {
    final ctl = await _fresh();
    final found = matchWorkersForEmployer(
      workers: ctl.state.workers,
      trade: 'Electrician',
      area: 'Kothrud, Pune',
    );
    expect(found.map((w) => w.id), contains('w01'));

    await ctl.switchWorker('w01');
    await ctl.setAvailability(
      AvailabilityStatus.unavailable,
      discoverable: false,
    );
    final hidden = matchWorkersForEmployer(
      workers: ctl.state.workers,
      trade: 'Electrician',
      area: 'Kothrud, Pune',
    );
    expect(hidden.map((w) => w.id), isNot(contains('w01')));

    await ctl.setAvailability(AvailabilityStatus.available, discoverable: true);
    await ctl.upsertWorkerProfile(
      ctl.state.currentWorker.copyWith(availableDate: 'tomorrow'),
    );
    final dated = matchWorkersForEmployer(
      workers: ctl.state.workers,
      trade: 'Electrician',
      area: 'Kothrud, Pune',
      date: 'tomorrow',
    );
    expect(dated.map((w) => w.id), contains('w01'));
  });

  test('role + language persist across restart', () async {
    final store = LocalStore();
    SharedPreferences.setMockInitialValues({});
    var ctl = AppController(store);
    for (var i = 0; i < 50 && ctl.state.loading; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await ctl.switchEmployer('e01');
    await ctl.setLang('en');
    await ctl.setOnboarded(true);

    final ctl2 = AppController(store);
    for (var i = 0; i < 50 && ctl2.state.loading; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(ctl2.state.role, UserRole.employer);
    expect(ctl2.state.currentEmployerId, 'e01');
    expect(ctl2.state.lang, 'en');
    expect(ctl2.state.onboarded, isTrue);
  });

  test('edited listing updates worker-facing data', () async {
    final ctl = await _fresh();
    final job = await _publish(ctl);
    await ctl.switchEmployer('e01');
    await ctl.updateJob(
      job.copyWith(title: 'Renamed wiring job', payAmount: 950),
    );
    await ctl.switchWorker('w01');
    final seen = ctl.state.jobs.firstWhere((j) => j.id == job.id);
    expect(seen.title, 'Renamed wiring job');
    expect(seen.payAmount, 950);
  });
}
