// KaamSetu enums — stable string values for persistence.
enum UserRole { worker, employer }

enum AvailabilityStatus { available, busy, unavailable }

enum PayUnit { perDay, perHour, perJob, perMonth }

enum JobStatus { open, closed, cancelled, filled }

enum ApplicationStatus {
  applied,
  shortlisted,
  offered,
  confirmed,
  inProgress,
  completed,
  rejected,
  withdrawn,
  cancelled,
  disputed,
}

enum AgreementStatus {
  draft,
  offered,
  changesRequested,
  confirmed,
  declined,
  cancelled,
}

enum PaymentStatus { pending, partial, paid, disputed }

enum NotificationKind {
  applied,
  shortlisted,
  offered,
  accepted,
  declined,
  cancelled,
  agreementConfirmed,
  completed,
  payment,
  invitation,
  general,
}

enum InvitationStatus { pending, accepted, declined, expired }

extension EnumX on Enum {
  String get code => name;
}

T? enumFromCode<T extends Enum>(List<T> values, String? code) {
  if (code == null) return null;
  for (final v in values) {
    if (v.name == code) return v;
  }
  return null;
}
