import '../../data/models/models.dart';

/// Heuristic suspicious-listing detector (rule-based, explained to user).
List<String> safetyFlagsForJob(Job j) {
  final flags = <String>[];
  if (j.payAmount <= 0) flags.add('Missing wage information');
  if (j.description.trim().length < 20)
    flags.add('Incomplete work description');
  final d = '${j.description} ${j.paymentTerms}'.toLowerCase();
  if (d.contains('advance') &&
      (d.contains('fee') || d.contains('deposit') || d.contains('pay first'))) {
    flags.add(
      'Advance fee demand — genuine employers never ask workers to pay first',
    );
  }
  if (d.contains('otp') || d.contains('aadhaar') && d.contains('share')) {
    flags.add('Unusual personal-information request');
  }
  if (j.location.trim().isEmpty) flags.add('Missing work location');
  return flags;
}

const List<String> kReportCategories = [
  'Advance fee asked',
  'Wrong wages',
  'Unsafe work',
  'Fake location',
  'Abuse / harassment',
  'Other',
];
