import '../../data/models/enums.dart';

/// Single source of truth for allowed application transitions.
/// Prevents invalid jumps e.g. applied → completed.
const Map<ApplicationStatus, List<ApplicationStatus>> kAllowedTransitions = {
  ApplicationStatus.applied: [
    ApplicationStatus.shortlisted,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
    ApplicationStatus.cancelled,
  ],
  ApplicationStatus.shortlisted: [
    ApplicationStatus.offered,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
    ApplicationStatus.cancelled,
  ],
  ApplicationStatus.offered: [
    ApplicationStatus.confirmed,
    ApplicationStatus.rejected,
    ApplicationStatus.withdrawn,
    ApplicationStatus.cancelled,
    ApplicationStatus.disputed,
  ],
  ApplicationStatus.confirmed: [
    ApplicationStatus.inProgress,
    ApplicationStatus.cancelled,
    ApplicationStatus.disputed,
  ],
  ApplicationStatus.inProgress: [
    ApplicationStatus.completed,
    ApplicationStatus.disputed,
    ApplicationStatus.cancelled,
  ],
  ApplicationStatus.completed: [],
  ApplicationStatus.rejected: [],
  ApplicationStatus.withdrawn: [],
  ApplicationStatus.cancelled: [],
  ApplicationStatus.disputed: [
    ApplicationStatus.confirmed,
    ApplicationStatus.cancelled,
  ],
};

bool canTransition(ApplicationStatus from, ApplicationStatus to) =>
    kAllowedTransitions[from]?.contains(to) ?? false;
