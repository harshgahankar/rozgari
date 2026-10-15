import 'package:flutter_test/flutter_test.dart';
import 'package:rozgari/data/models/enums.dart';
import 'package:rozgari/state/app_state.dart';
import 'package:rozgari/data/local/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Headless validation of the 24-step judge demo flow through the real
/// AppController + real SharedPreferences persistence (mocked backend).
void main() {
  test('Worker → Employer → Agreement → Completion demo flow', () async {
    SharedPreferences.setMockInitialValues({});
    final store = LocalStore();
    final ctl = AppController(store);
    // wait for async init
    for (var i = 0; i < 50 && ctl.state.loading; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(
      ctl.state.loading,
      isFalse,
      reason: 'controller must finish loading demo data',
    );

    // 2. Worker demo as Ramesh (w01 Electrician)
    await ctl.switchWorker('w01');
    expect(ctl.state.currentWorker.primaryTrade, 'Electrician');

    // 4. Edit availability
    await ctl.setAvailability(AvailabilityStatus.available, discoverable: true);
    expect(ctl.state.currentWorker.availability, AvailabilityStatus.available);

    // 5-6. Find electrician job in Pune owned by Meera (e01)
    final job = ctl.state.jobs.firstWhere(
      (j) =>
          j.employerId == 'e01' &&
          j.category == 'Electrician' &&
          j.city == 'Pune' &&
          j.status == JobStatus.open,
    );

    // 7-8. Apply + confirm saved
    final applied = ctl.applyForJob(job.id);
    expect(applied.ok, isTrue, reason: applied.msg);
    expect(
      ctl.state.applications.any(
        (a) => a.jobId == job.id && a.workerId == 'w01',
      ),
      isTrue,
    );

    // duplicate blocked
    final dup = ctl.applyForJob(job.id);
    expect(dup.ok, isFalse);

    // 9-10. Switch to Meera, find application
    await ctl.switchEmployer('e01');
    await ctl.setRole(UserRole.employer);
    final app = ctl.state.applications.firstWhere(
      (a) => a.jobId == job.id && a.workerId == 'w01',
    );
    expect(app.status, ApplicationStatus.applied);

    // 12. Shortlist
    final s = ctl.transitionApplication(app.id, ApplicationStatus.shortlisted);
    expect(s.ok, isTrue);

    // invalid jump still blocked
    final bad = ctl.transitionApplication(app.id, ApplicationStatus.completed);
    expect(bad.ok, isFalse);

    // 13. Send offer → agreement created, worker notified
    final offerRes = await ctl.sendOffer(jobId: job.id, workerId: 'w01');
    expect(offerRes.ok, isTrue, reason: offerRes.msg);
    final offer = offerRes.offer!;
    expect(offer.employerConfirmed, isTrue);
    expect(
      ctl.state.notifications.any(
        (n) => n.userId == 'w01' && n.kind == NotificationKind.offered,
      ),
      isTrue,
    );

    // 14-16. Back to Ramesh, accept via agreement confirm (worker side)
    await ctl.switchWorker('w01');
    await ctl.setRole(UserRole.worker);
    var r = await ctl.confirmAgreement(offer.id, byWorker: true);
    expect(r.ok, isTrue);
    final g = ctl.state.agreements.firstWhere((e) => e.id == offer.id);
    expect(
      g.status,
      AgreementStatus.confirmed,
      reason: 'both sides approved same terms',
    );

    // application auto-moved to confirmed
    final app2 = ctl.state.applications.firstWhere(
      (a) => a.jobId == job.id && a.workerId == 'w01',
    );
    expect(app2.status, ApplicationStatus.confirmed);

    // 19. Start + complete simulated work
    expect(
      ctl.transitionApplication(app2.id, ApplicationStatus.inProgress).ok,
      isTrue,
    );
    expect(
      ctl.transitionApplication(app2.id, ApplicationStatus.completed).ok,
      isTrue,
    );
    await ctl.ensurePaymentFor(job.id, 'w01', job.payAmount);
    final pay = ctl.state.payments.firstWhere(
      (p) => p.jobId == job.id && p.workerId == 'w01',
    );

    // 20. Payment update (simulated)
    await ctl.setPaymentStatus(pay.id, PaymentStatus.paid);
    expect(
      ctl.state.payments.firstWhere((p) => p.id == pay.id).status,
      PaymentStatus.paid,
    );

    // 21-22. Restart persistence: new controller reads same store
    final ctl2 = AppController(store);
    for (var i = 0; i < 50 && ctl2.state.loading; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    expect(
      ctl2.state.applications
          .firstWhere((a) => a.jobId == job.id && a.workerId == 'w01')
          .status,
      ApplicationStatus.completed,
    );
    expect(
      ctl2.state.agreements.firstWhere((e) => e.id == offer.id).status,
      AgreementStatus.confirmed,
    );

    // 23-24. Reset restores initial scenario
    await ctl2.resetDemo();
    expect(
      ctl2.state.applications.any(
        (a) => a.jobId == job.id && a.workerId == 'w01',
      ),
      isFalse,
    );
    expect(ctl2.state.jobs.length, 28);
  });
}
