import 'dart:math' as math;

import '../../core/constants/meta.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';

double areaDistanceKm(String a, String b) {
  final ca = kAreaCoords[a];
  final cb = kAreaCoords[b];
  if (ca == null || cb == null) return 999;
  if (a == b) return 0;
  // Haversine (approx, local calc only — not live GPS).
  const r = 6371.0;
  final dLat = (cb[0] - ca[0]) * math.pi / 180;
  final dLng = (cb[1] - ca[1]) * math.pi / 180;
  final s1 = math.sin(dLat / 2), s2 = math.sin(dLng / 2);
  final h =
      s1 * s1 +
      math.cos(ca[0] * math.pi / 180) *
          math.cos(cb[0] * math.pi / 180) *
          s2 *
          s2;
  return 2 * r * math.asin(math.sqrt(h));
}

int jobMatchScore({required WorkerProfile w, required Job j}) {
  var score = 0;
  if (j.category == w.primaryTrade) {
    score += 50;
  } else if (w.additionalSkills.contains(j.category)) {
    score += 30;
  } else {
    return 0; // trade mismatch → not relevant
  }
  final d = areaDistanceKm(w.workArea, j.location);
  if (d <= w.preferredRadiusKm) {
    score += 30;
  } else if (d <= w.preferredRadiusKm + 5) {
    score += 10;
  }
  if (j.status == JobStatus.open) score += 10;
  if (j.payAmount >= w.preferredPay) score += 10;
  return score;
}

List<Job> matchJobsForWorker(WorkerProfile w, List<Job> jobs) {
  final scored = <MapEntry<Job, int>>[];
  for (final j in jobs) {
    if (j.status != JobStatus.open) continue;
    final s = jobMatchScore(w: w, j: j);
    if (s > 0) scored.add(MapEntry(j, s));
  }
  scored.sort((a, b) => b.value.compareTo(a.value));
  return scored.map((e) => e.key).toList();
}

/// Employer discovery: only discoverable + available workers surface.
/// Optional filters stack: min experience, available date ('today'/'tomorrow'
/// or yyyy-MM-dd), max travel distance, free-text skill match.
List<WorkerProfile> matchWorkersForEmployer({
  required List<WorkerProfile> workers,
  required String trade,
  required String area,
  double radiusKm = 8,
  int minExp = 0,
  String date = 'Any',
  double? maxDist,
  String skillQ = '',
}) {
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final tm = now.add(const Duration(days: 1));
  final tomorrowStr =
      '${tm.year}-${tm.month.toString().padLeft(2, '0')}-${tm.day.toString().padLeft(2, '0')}';
  bool dateOk(WorkerProfile w) {
    if (date == 'Any') return true;
    if (date == 'today') {
      return w.availableDate == 'today' || w.availableDate == todayStr;
    }
    if (date == 'tomorrow') {
      return w.availableDate == 'tomorrow' || w.availableDate == tomorrowStr;
    }
    return w.availableDate == date;
  }

  final out = <WorkerProfile>[];
  for (final w in workers) {
    if (!w.discoverable) continue;
    if (w.availability != AvailabilityStatus.available) continue;
    if (w.primaryTrade != trade && !w.additionalSkills.contains(trade)) {
      continue;
    }
    if (w.experienceYears < minExp) continue;
    if (!dateOk(w)) continue;
    final d = areaDistanceKm(w.workArea, area);
    if (d > radiusKm + w.preferredRadiusKm) continue;
    if (maxDist != null && d > maxDist) continue;
    if (skillQ.trim().isNotEmpty) {
      final q = skillQ.trim().toLowerCase();
      final hay = '${w.primaryTrade} ${w.additionalSkills.join(' ')}'
          .toLowerCase();
      if (!hay.contains(q)) continue;
    }
    out.add(w);
  }
  return out;
}

/// Parses natural voice/text query: "mujhe kal Pune mein plumber ka kaam chahiye"
/// Returns {trade, city, dateOffset}.
Map<String, String> parseKaamBolo(String text) {
  final t = text.toLowerCase();
  String trade = '';
  for (final tr in kTrades) {
    if (t.contains(tr.toLowerCase())) {
      trade = tr;
      break;
    }
  }
  // Hindi transliterations.
  if (trade.isEmpty) {
    if (t.contains('bijli') || t.contains('electric')) trade = 'Electrician';
    if (t.contains('nal') || t.contains('pipe') || t.contains('plumb'))
      trade = 'Plumber';
    if (t.contains('badhai') || t.contains('carpent') || t.contains('lakdi'))
      trade = 'Carpenter';
    if (t.contains('paint') || t.contains('rang')) trade = 'Painter';
    if (t.contains('mistri') || t.contains('mason') || t.contains('raj'))
      trade = 'Mason';
  }
  var city = '';
  if (t.contains('mumbai') || t.contains('मुंबई')) {
    city = 'Mumbai';
  } else if (t.contains('pune') || t.contains('पुणे') || t.contains('पुने')) {
    city = 'Pune';
  }
  var date = 'today';
  if (t.contains('kal') || t.contains('tomorrow') || t.contains('उद्या'))
    date = 'tomorrow';
  if (t.contains('aaj') || t.contains('today') || t.contains('आज'))
    date = 'today';
  return {'trade': trade, 'city': city, 'date': date};
}
