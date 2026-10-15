import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rozgari/app/app.dart';
import 'package:rozgari/core/utils/lifecycle.dart';
import 'package:rozgari/core/utils/matching.dart';
import 'package:rozgari/core/utils/safety_rules.dart';
import 'package:rozgari/data/mock/demo_data.dart';
import 'package:rozgari/data/models/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('demo dataset has expected scale', () {
    final d = buildDemoData();
    expect(d.workers.length, 15);
    expect(d.employers.length, 5);
    expect(d.jobs.length, 28);
    expect(d.welfare.length, 5);
  });

  test('invalid application transition is blocked (applied -> completed)', () {
    expect(
      canTransition(ApplicationStatus.applied, ApplicationStatus.completed),
      isFalse,
    );
    expect(
      canTransition(ApplicationStatus.applied, ApplicationStatus.shortlisted),
      isTrue,
    );
    expect(
      canTransition(ApplicationStatus.offered, ApplicationStatus.confirmed),
      isTrue,
    );
  });

  test('matching prefers same trade + nearby area', () {
    final d = buildDemoData();
    final w = d.workers.firstWhere(
      (w) => w.id == 'w01',
    ); // Ramesh, Electrician, Kothrud
    final matched = matchJobsForWorker(w, d.jobs);
    expect(matched, isNotEmpty);
    expect(matched.first.category, 'Electrician');
  });

  test('duplicate-application guard concept: same worker+job active twice is invalid', () {
    final d = buildDemoData();
    final dup = d.applications
        .where((a) => a.jobId == 'j16' && a.workerId == 'w09')
        .toList();
    expect(dup.length, 1);
  });

  test('safety flags catch advance-fee + missing-wage listing', () {
    final d = buildDemoData();
    final bad = d.jobs.firstWhere((j) => j.id == 'j27');
    final flags = safetyFlagsForJob(bad);
    expect(flags.any((f) => f.contains('Advance fee')), isTrue);
    expect(flags.any((f) => f.contains('wage')), isTrue);
  });

  test('voice parse extracts trade/city/date', () {
    final p = parseKaamBolo('Mujhe kal Pune mein plumber ka kaam chahiye');
    expect(p['trade'], 'Plumber');
    expect(p['city'], 'Pune');
    expect(p['date'], 'tomorrow');
  });

  testWidgets('KaamSetu boots to language onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: KaamSetuApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('भाषा'), findsWidgets);
  });
}
