import 'enums.dart';

Map<String, dynamic> _sd(DateTime d) => {'v': d.toIso8601String()};
DateTime _pd(dynamic v) =>
    v is Map ? DateTime.parse(v['v'] as String) : DateTime.parse(v as String);

class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String preferredLanguage;
  final String avatar;
  final String contact;
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    this.preferredLanguage = 'en',
    this.avatar = '',
    this.contact = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.code,
    'lang': preferredLanguage,
    'avatar': avatar,
    'contact': contact,
  };
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    name: j['name'] as String,
    role: enumFromCode(UserRole.values, j['role'] as String) ?? UserRole.worker,
    preferredLanguage: (j['lang'] ?? 'en') as String,
    avatar: (j['avatar'] ?? '') as String,
    contact: (j['contact'] ?? '') as String,
  );
}

class WorkerProfile {
  final String id;
  final String userId;
  final String primaryTrade;
  final List<String> additionalSkills;
  final int experienceYears;
  final String workArea;
  final double preferredRadiusKm;
  final AvailabilityStatus availability;
  final bool discoverable;
  final List<String> workPhotos;
  final String audioIntro;
  final double preferredPay;
  final int completedJobs;
  final String availableDate; // yyyy-MM-dd or 'today'
  const WorkerProfile({
    required this.id,
    required this.userId,
    required this.primaryTrade,
    this.additionalSkills = const [],
    this.experienceYears = 1,
    required this.workArea,
    this.preferredRadiusKm = 5,
    this.availability = AvailabilityStatus.available,
    this.discoverable = true,
    this.workPhotos = const [],
    this.audioIntro = '',
    this.preferredPay = 600,
    this.completedJobs = 0,
    this.availableDate = 'today',
  });
  WorkerProfile copyWith({
    String? primaryTrade,
    List<String>? additionalSkills,
    int? experienceYears,
    String? workArea,
    double? preferredRadiusKm,
    AvailabilityStatus? availability,
    bool? discoverable,
    List<String>? workPhotos,
    String? audioIntro,
    double? preferredPay,
    int? completedJobs,
    String? availableDate,
  }) => WorkerProfile(
    id: id,
    userId: userId,
    primaryTrade: primaryTrade ?? this.primaryTrade,
    additionalSkills: additionalSkills ?? this.additionalSkills,
    experienceYears: experienceYears ?? this.experienceYears,
    workArea: workArea ?? this.workArea,
    preferredRadiusKm: preferredRadiusKm ?? this.preferredRadiusKm,
    availability: availability ?? this.availability,
    discoverable: discoverable ?? this.discoverable,
    workPhotos: workPhotos ?? this.workPhotos,
    audioIntro: audioIntro ?? this.audioIntro,
    preferredPay: preferredPay ?? this.preferredPay,
    completedJobs: completedJobs ?? this.completedJobs,
    availableDate: availableDate ?? this.availableDate,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'trade': primaryTrade,
    'skills': additionalSkills,
    'exp': experienceYears,
    'area': workArea,
    'radius': preferredRadiusKm,
    'avail': availability.code,
    'discover': discoverable,
    'photos': workPhotos,
    'audio': audioIntro,
    'pay': preferredPay,
    'done': completedJobs,
    'date': availableDate,
  };
  factory WorkerProfile.fromJson(Map<String, dynamic> j) => WorkerProfile(
    id: j['id'] as String,
    userId: j['userId'] as String,
    primaryTrade: j['trade'] as String,
    additionalSkills: List<String>.from((j['skills'] ?? []) as List),
    experienceYears: (j['exp'] ?? 1) as int,
    workArea: j['area'] as String,
    preferredRadiusKm: ((j['radius'] ?? 5) as num).toDouble(),
    availability:
        enumFromCode(AvailabilityStatus.values, j['avail'] as String?) ??
        AvailabilityStatus.available,
    discoverable: (j['discover'] ?? true) as bool,
    workPhotos: List<String>.from((j['photos'] ?? []) as List),
    audioIntro: (j['audio'] ?? '') as String,
    preferredPay: ((j['pay'] ?? 600) as num).toDouble(),
    completedJobs: (j['done'] ?? 0) as int,
    availableDate: (j['date'] ?? 'today') as String,
  );
}

class EmployerProfile {
  final String id;
  final String userId;
  final String employerType;
  final String businessName;
  final String workArea;
  final String contact;
  const EmployerProfile({
    required this.id,
    required this.userId,
    this.employerType = 'Individual',
    this.businessName = '',
    required this.workArea,
    this.contact = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': employerType,
    'biz': businessName,
    'area': workArea,
    'contact': contact,
  };
  factory EmployerProfile.fromJson(Map<String, dynamic> j) => EmployerProfile(
    id: j['id'] as String,
    userId: j['userId'] as String,
    employerType: (j['type'] ?? 'Individual') as String,
    businessName: (j['biz'] ?? '') as String,
    workArea: j['area'] as String,
    contact: (j['contact'] ?? '') as String,
  );
}

class Job {
  final String id;
  final String employerId;
  final String title;
  final String category;
  final String description;
  final String location;
  final String city;
  final double lat;
  final double lng;
  final double payAmount;
  final PayUnit payUnit;
  final String paymentTerms;
  final DateTime startDate;
  final String duration;
  final String workingHours;
  final int requiredWorkers;
  final String toolsRequired;
  final JobStatus status;
  final DateTime createdAt;
  const Job({
    required this.id,
    required this.employerId,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.city,
    this.lat = 0,
    this.lng = 0,
    required this.payAmount,
    this.payUnit = PayUnit.perDay,
    this.paymentTerms = 'Daily cash after work',
    required this.startDate,
    this.duration = '1 day',
    this.workingHours = '9am – 6pm',
    this.requiredWorkers = 1,
    this.toolsRequired = '',
    this.status = JobStatus.open,
    required this.createdAt,
  });
  Job copyWith({
    JobStatus? status,
    String? title,
    String? category,
    String? description,
    String? location,
    String? city,
    double? payAmount,
    PayUnit? payUnit,
    String? paymentTerms,
    DateTime? startDate,
    String? duration,
    String? workingHours,
    int? requiredWorkers,
    String? toolsRequired,
  }) => Job(
    id: id,
    employerId: employerId,
    title: title ?? this.title,
    category: category ?? this.category,
    description: description ?? this.description,
    location: location ?? this.location,
    city: city ?? this.city,
    lat: lat,
    lng: lng,
    payAmount: payAmount ?? this.payAmount,
    payUnit: payUnit ?? this.payUnit,
    paymentTerms: paymentTerms ?? this.paymentTerms,
    startDate: startDate ?? this.startDate,
    duration: duration ?? this.duration,
    workingHours: workingHours ?? this.workingHours,
    requiredWorkers: requiredWorkers ?? this.requiredWorkers,
    toolsRequired: toolsRequired ?? this.toolsRequired,
    status: status ?? this.status,
    createdAt: createdAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'eid': employerId,
    'title': title,
    'cat': category,
    'desc': description,
    'loc': location,
    'city': city,
    'lat': lat,
    'lng': lng,
    'pay': payAmount,
    'unit': payUnit.code,
    'terms': paymentTerms,
    'start': _sd(startDate),
    'dur': duration,
    'hours': workingHours,
    'need': requiredWorkers,
    'tools': toolsRequired,
    'status': status.code,
    'created': _sd(createdAt),
  };
  factory Job.fromJson(Map<String, dynamic> j) => Job(
    id: j['id'] as String,
    employerId: j['eid'] as String,
    title: j['title'] as String,
    category: j['cat'] as String,
    description: j['desc'] as String,
    location: j['loc'] as String,
    city: j['city'] as String,
    lat: ((j['lat'] ?? 0) as num).toDouble(),
    lng: ((j['lng'] ?? 0) as num).toDouble(),
    payAmount: ((j['pay'] ?? 0) as num).toDouble(),
    payUnit:
        enumFromCode(PayUnit.values, j['unit'] as String?) ?? PayUnit.perDay,
    paymentTerms: (j['terms'] ?? '') as String,
    startDate: _pd(j['start']),
    duration: (j['dur'] ?? '1 day') as String,
    workingHours: (j['hours'] ?? '') as String,
    requiredWorkers: (j['need'] ?? 1) as int,
    toolsRequired: (j['tools'] ?? '') as String,
    status:
        enumFromCode(JobStatus.values, j['status'] as String?) ??
        JobStatus.open,
    createdAt: _pd(j['created']),
  );
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    this.status = ApplicationStatus.applied,
    required this.appliedAt,
    required this.updatedAt,
  });
  JobApplication copyWith({ApplicationStatus? status, DateTime? updatedAt}) =>
      JobApplication(
        id: id,
        jobId: jobId,
        workerId: workerId,
        status: status ?? this.status,
        appliedAt: appliedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'job': jobId,
    'w': workerId,
    'st': status.code,
    'at': _sd(appliedAt),
    'up': _sd(updatedAt),
  };
  factory JobApplication.fromJson(Map<String, dynamic> j) => JobApplication(
    id: j['id'] as String,
    jobId: j['job'] as String,
    workerId: j['w'] as String,
    status:
        enumFromCode(ApplicationStatus.values, j['st'] as String?) ??
        ApplicationStatus.applied,
    appliedAt: _pd(j['at']),
    updatedAt: _pd(j['up']),
  );
}

class WorkAgreement {
  final String id;
  final String jobId;
  final String workerId;
  final String employerId;
  final double agreedPay;
  final String workingHours;
  final String location;
  final String paymentTerms;
  final bool workerConfirmed;
  final bool employerConfirmed;
  final AgreementStatus status;
  final DateTime updatedAt;
  final int version;
  const WorkAgreement({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.employerId,
    required this.agreedPay,
    required this.workingHours,
    required this.location,
    required this.paymentTerms,
    this.workerConfirmed = false,
    this.employerConfirmed = false,
    this.status = AgreementStatus.offered,
    required this.updatedAt,
    this.version = 1,
  });
  WorkAgreement copyWith({
    double? agreedPay,
    String? workingHours,
    String? location,
    String? paymentTerms,
    bool? workerConfirmed,
    bool? employerConfirmed,
    AgreementStatus? status,
    DateTime? updatedAt,
    int? version,
  }) => WorkAgreement(
    id: id,
    jobId: jobId,
    workerId: workerId,
    employerId: employerId,
    agreedPay: agreedPay ?? this.agreedPay,
    workingHours: workingHours ?? this.workingHours,
    location: location ?? this.location,
    paymentTerms: paymentTerms ?? this.paymentTerms,
    workerConfirmed: workerConfirmed ?? this.workerConfirmed,
    employerConfirmed: employerConfirmed ?? this.employerConfirmed,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'job': jobId,
    'w': workerId,
    'e': employerId,
    'pay': agreedPay,
    'hours': workingHours,
    'loc': location,
    'terms': paymentTerms,
    'wc': workerConfirmed,
    'ec': employerConfirmed,
    'st': status.code,
    'up': _sd(updatedAt),
    'v': version,
  };
  factory WorkAgreement.fromJson(Map<String, dynamic> j) => WorkAgreement(
    id: j['id'] as String,
    jobId: j['job'] as String,
    workerId: j['w'] as String,
    employerId: j['e'] as String,
    agreedPay: ((j['pay'] ?? 0) as num).toDouble(),
    workingHours: (j['hours'] ?? '') as String,
    location: (j['loc'] ?? '') as String,
    paymentTerms: (j['terms'] ?? '') as String,
    workerConfirmed: (j['wc'] ?? false) as bool,
    employerConfirmed: (j['ec'] ?? false) as bool,
    status:
        enumFromCode(AgreementStatus.values, j['st'] as String?) ??
        AgreementStatus.offered,
    updatedAt: _pd(j['up']),
    version: (j['v'] ?? 1) as int,
  );
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationKind kind;
  final String title;
  final String body;
  final String? refId;
  final bool read;
  final DateTime createdAt;
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.body,
    this.refId,
    this.read = false,
    required this.createdAt,
  });
  AppNotification markRead() => AppNotification(
    id: id,
    userId: userId,
    kind: kind,
    title: title,
    body: body,
    refId: refId,
    read: true,
    createdAt: createdAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'u': userId,
    'k': kind.code,
    't': title,
    'b': body,
    'r': refId,
    'read': read,
    'at': _sd(createdAt),
  };
  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'] as String,
    userId: j['u'] as String,
    kind:
        enumFromCode(NotificationKind.values, j['k'] as String?) ??
        NotificationKind.general,
    title: j['t'] as String,
    body: j['b'] as String,
    refId: j['r'] as String?,
    read: (j['read'] ?? false) as bool,
    createdAt: _pd(j['at']),
  );
}

class PaymentRecord {
  final String id;
  final String jobId;
  final String workerId;
  final double amount;
  final PaymentStatus status;
  final String note;
  final DateTime updatedAt;
  const PaymentRecord({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.amount,
    this.status = PaymentStatus.pending,
    this.note = 'Simulated / self-reported',
    required this.updatedAt,
  });
  PaymentRecord copyWith({PaymentStatus? status, double? amount}) =>
      PaymentRecord(
        id: id,
        jobId: jobId,
        workerId: workerId,
        amount: amount ?? this.amount,
        status: status ?? this.status,
        note: note,
        updatedAt: DateTime.now(),
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'job': jobId,
    'w': workerId,
    'amt': amount,
    'st': status.code,
    'note': note,
    'up': _sd(updatedAt),
  };
  factory PaymentRecord.fromJson(Map<String, dynamic> j) => PaymentRecord(
    id: j['id'] as String,
    jobId: j['job'] as String,
    workerId: j['w'] as String,
    amount: ((j['amt'] ?? 0) as num).toDouble(),
    status:
        enumFromCode(PaymentStatus.values, j['st'] as String?) ??
        PaymentStatus.pending,
    note: (j['note'] ?? '') as String,
    updatedAt: _pd(j['up']),
  );
}

class SafetyReport {
  final String id;
  final String jobId;
  final String reporterId;
  final String category;
  final String description;
  final DateTime createdAt;
  const SafetyReport({
    required this.id,
    required this.jobId,
    required this.reporterId,
    required this.category,
    required this.description,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'job': jobId,
    'rep': reporterId,
    'cat': category,
    'desc': description,
    'at': _sd(createdAt),
  };
  factory SafetyReport.fromJson(Map<String, dynamic> j) => SafetyReport(
    id: j['id'] as String,
    jobId: j['job'] as String,
    reporterId: j['rep'] as String,
    category: j['cat'] as String,
    description: j['desc'] as String,
    createdAt: _pd(j['at']),
  );
}

class JobInvitation {
  final String id;
  final String jobId;
  final String workerId;
  final String employerId;
  final InvitationStatus status;
  final DateTime createdAt;
  const JobInvitation({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.employerId,
    this.status = InvitationStatus.pending,
    required this.createdAt,
  });
  JobInvitation copyWith({InvitationStatus? status}) => JobInvitation(
    id: id,
    jobId: jobId,
    workerId: workerId,
    employerId: employerId,
    status: status ?? this.status,
    createdAt: createdAt,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'job': jobId,
    'w': workerId,
    'e': employerId,
    'st': status.code,
    'at': _sd(createdAt),
  };
  factory JobInvitation.fromJson(Map<String, dynamic> j) => JobInvitation(
    id: j['id'] as String,
    jobId: j['job'] as String,
    workerId: j['w'] as String,
    employerId: j['e'] as String,
    status:
        enumFromCode(InvitationStatus.values, j['st'] as String?) ??
        InvitationStatus.pending,
    createdAt: _pd(j['at']),
  );
}

class WelfareResource {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String checklist;
  final String link;
  const WelfareResource({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.checklist,
    this.link = '',
  });
}
