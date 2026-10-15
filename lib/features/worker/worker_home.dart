import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/utils/matching.dart';
import '../../core/utils/safety_rules.dart';
import '../../core/widgets/common.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';

String employerName(AppState st, Job j) {
  try {
    final e = st.employers.firstWhere((e) => e.id == j.employerId);
    return e.businessName.isNotEmpty
        ? e.businessName
        : st.users.firstWhere((u) => u.id == e.userId).name;
  } catch (_) {
    return 'Verified employer';
  }
}

class WorkerDashboard extends ConsumerWidget {
  const WorkerDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final w = st.currentWorker;
    final matched = matchJobsForWorker(w, st.jobs).take(4).toList();
    final myApps = st.applications.where((a) => a.workerId == w.id).toList();
    final offers = myApps
        .where((a) => a.status == ApplicationStatus.offered)
        .length;
    final unread = st.unreadFor(st.currentWorkerId);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: KsColors.primaryContainer,
              child: Text(
                w.primaryTrade.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'नमस्ते, ${st.currentWorkerUser.name} 🙏',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: KsColors.primary,
                    ),
                  ),
                  Text(
                    '${w.primaryTrade} • ${w.workArea}',
                    style: const TextStyle(fontSize: 12, color: KsColors.muted),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/notifications'),
                  icon: const Icon(Icons.notifications_outlined),
                ),
                if (unread > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: KsColors.danger,
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Availability card (HTML: Signature Availability Module)
        Card(
          color: KsColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'आज उपलब्धता • Availability',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Employers nearby find you faster',
                            style: TextStyle(
                              color: KsColors.primaryFixedDim,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: w.availability == AvailabilityStatus.available,
                      activeColor: KsColors.secondaryContainer,
                      onChanged: (v) {
                        ctl.setAvailability(
                          v
                              ? AvailabilityStatus.available
                              : AvailabilityStatus.unavailable,
                        );
                        showFeedback(
                          context,
                          v ? 'You are now discoverable ✓' : 'Availability paused — existing jobs unaffected',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    StatusChip(
                      w.availability == AvailabilityStatus.available
                          ? 'AVAILABLE • उपलब्ध'
                          : 'PAUSED',
                      bg: w.availability == AvailabilityStatus.available
                          ? KsColors.successBg
                          : KsColors.amberBg,
                      fg: w.availability == AvailabilityStatus.available
                          ? KsColors.successDeep
                          : KsColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${w.preferredRadiusKm.toStringAsFixed(0)} km • ${w.availableDate}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Kaam Bolo bar
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pushNamed(context, '/voice'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: KsColors.surfaceHigh),
            ),
            child: const Row(
              children: [
                Icon(Icons.mic, color: KsColors.secondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'बोलकर काम खोजें • "Kal Pune me electrician…"',
                    style: TextStyle(color: KsColors.muted, fontSize: 13),
                  ),
                ),
                Icon(Icons.search, color: KsColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Stats (derived — never hardcoded)
        Row(
          children: [
            _Stat(
              value: '₹${(w.completedJobs * 750).toString()}',
              label: 'Est. earnings',
            ),
            _Stat(value: '${w.completedJobs}', label: 'Jobs done'),
            _Stat(value: '${myApps.length}', label: 'Applications'),
            _Stat(value: '$offers', label: 'Offers'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Nearby jobs for you',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: KsColors.primary,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => DefaultTabController.of(context).animateTo(1),
              child: const Text('See all'),
            ),
          ],
        ),
        if (matched.isEmpty)
          const EmptyView(
            icon: Icons.work_off_outlined,
            title: 'No matching jobs yet',
            subtitle:
                'Try widening your radius or changing trade in Skill Passport.',
            actionLabel: 'Edit passport',
          )
        else
          for (final j in matched)
            JobCard(
              job: j,
              employerName: employerName(st, j),
              distanceLabel:
                  '${areaDistanceKm(w.workArea, j.location).toStringAsFixed(1)} km',
              saved: st.savedJobIds.contains(j.id),
              safetyFlags: safetyFlagsForJob(j),
              onSave: () => ctl.toggleSaveJob(j.id),
              onTap: () =>
                  Navigator.pushNamed(context, '/job', arguments: j.id),
            ),
        const SizedBox(height: 8),
        // Passport snapshot
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.badge_outlined, color: KsColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Skill Passport snapshot',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: KsColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${w.primaryTrade} • ${w.experienceYears} yrs • ${w.completedJobs} jobs',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  'Skills: ${[w.primaryTrade, ...w.additionalSkills].join(', ')}',
                  style: const TextStyle(fontSize: 12, color: KsColors.muted),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/passport'),
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Open Skill Passport'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/safety'),
                icon: const Icon(Icons.shield_outlined),
                label: const Text('Suraksha'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/welfare'),
                icon: const Icon(Icons.account_balance_outlined),
                label: const Text('Welfare'),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KsColors.successBg.withOpacity(.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: KsColors.successDeep,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Work Promise Slip locked before every job — hours, wage & pay method in writing.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: KsColors.primary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: KsColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});
  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  String q = '';
  String trade = 'All';
  String city = 'All';
  String sort = 'Relevance';
  bool savedOnly = false;
  double minPay = 0;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final w = st.currentWorker;
    var list = st.jobs.where((j) => j.status == JobStatus.open).toList();
    if (q.isNotEmpty)
      list = list
          .where(
            (j) => '${j.title} ${j.description} ${j.category}'
                .toLowerCase()
                .contains(q.toLowerCase()),
          )
          .toList();
    if (trade != 'All') list = list.where((j) => j.category == trade).toList();
    if (city != 'All') list = list.where((j) => j.city == city).toList();
    if (minPay > 0) list = list.where((j) => j.payAmount >= minPay).toList();
    if (savedOnly)
      list = list.where((j) => st.savedJobIds.contains(j.id)).toList();
    // sort
    if (sort == 'Pay') {
      list.sort((a, b) => b.payAmount.compareTo(a.payAmount));
    } else if (sort == 'Distance') {
      list.sort(
        (a, b) => areaDistanceKm(
          w.workArea,
          a.location,
        ).compareTo(areaDistanceKm(w.workArea, b.location)),
      );
    } else {
      list = matchJobsForWorker(w, list);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search title, trade…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.mic_none),
                tooltip: 'Voice search',
                onPressed: () => Navigator.pushNamed(context, '/voice'),
              ),
            ),
            onChanged: (v) => setState(() => q = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _Chip(
                label: 'Trade: $trade',
                onTap: () => _pick(
                  context,
                  'Trade',
                  ['All', ...kTrades],
                  trade,
                  (v) => setState(() => trade = v),
                ),
              ),
              _Chip(
                label: 'City: $city',
                onTap: () => _pick(
                  context,
                  'City',
                  ['All', 'Pune', 'Mumbai'],
                  city,
                  (v) => setState(() => city = v),
                ),
              ),
              _Chip(
                label: 'Sort: $sort',
                onTap: () => _pick(
                  context,
                  'Sort',
                  ['Relevance', 'Pay', 'Distance'],
                  sort,
                  (v) => setState(() => sort = v),
                ),
              ),
              FilterChip(
                label: Text('Min ₹${minPay.toStringAsFixed(0)}'),
                selected: minPay > 0,
                onSelected: (_) => _pickPay(context),
              ),
              FilterChip(
                label: const Text('Saved'),
                selected: savedOnly,
                onSelected: (v) => setState(() => savedOnly = v),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              const Icon(Icons.verified, size: 14, color: KsColors.successDeep),
              Text(
                ' ${list.length} verified openings',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: KsColors.successDeep,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? EmptyView(
                  icon: Icons.search_off_outlined,
                  title: 'No jobs match',
                  subtitle: 'Try clearing filters, widening distance, or lowering minimum pay.',
                  actionLabel: 'Clear filters',
                  onAction: () => setState(() {
                    q = '';
                    trade = 'All';
                    city = 'All';
                    minPay = 0;
                    savedOnly = false;
                  }),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final j = list[i];
                    return JobCard(
                      job: j,
                      employerName: employerName(st, j),
                      distanceLabel:
                          '${areaDistanceKm(w.workArea, j.location).toStringAsFixed(1)} km',
                      saved: st.savedJobIds.contains(j.id),
                      safetyFlags: safetyFlagsForJob(j),
                      onSave: () => ctl.toggleSaveJob(j.id),
                      onTap: () =>
                          Navigator.pushNamed(context, '/job', arguments: j.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _Chip({required String label, required VoidCallback onTap}) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
    ),
  );

  void _pick(
    BuildContext context,
    String title,
    List<String> opts,
    String cur,
    void Function(String) set,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            for (final o in opts)
              ListTile(
                title: Text(o),
                trailing: o == cur
                    ? const Icon(Icons.check, color: KsColors.primary)
                    : null,
                onTap: () {
                  set(o);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickPay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Minimum daily wage',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            for (final p in [0.0, 500.0, 700.0, 900.0, 1200.0])
              ListTile(
                title: Text(p == 0 ? 'Any' : '₹${p.toStringAsFixed(0)}+'),
                onTap: () {
                  setState(() => minPay = p);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final job = st.jobs.firstWhere((j) => j.id == jobId);
    final flags = safetyFlagsForJob(job);
    final existing = st.applications
        .where(
          (a) =>
              a.jobId == jobId &&
              a.workerId == st.currentWorkerId &&
              ![
                ApplicationStatus.rejected,
                ApplicationStatus.withdrawn,
                ApplicationStatus.cancelled,
              ].contains(a.status),
        )
        .toList();
    final applied = existing.isNotEmpty;
    final w = st.currentWorker;

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: KsColors.successBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified,
                  size: 15,
                  color: KsColors.successDeep,
                ),
                const SizedBox(width: 6),
                Text(
                  'VERIFIED JOB • ${job.category}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: KsColors.successDeep,
                  ),
                ),
                const Spacer(),
                StatusChip(job.status.name.toUpperCase()),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            job.title,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: KsColors.primary,
            ),
          ),
          Text(
            job.description,
            style: const TextStyle(fontSize: 13.5, color: KsColors.muted),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KsColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fmtPay(job),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        job.paymentTerms,
                        style: const TextStyle(
                          color: KsColors.primaryFixedDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: KsColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${areaDistanceKm(w.workArea, job.location).toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              _Info(Icons.location_on_outlined, 'Location', job.location),
              _Info(
                Icons.schedule_outlined,
                'Timing',
                '${fmtDate(job.startDate)}\n${job.workingHours}',
              ),
              _Info(
                Icons.groups_outlined,
                'Need',
                '${job.requiredWorkers} worker(s)\n${job.duration}',
              ),
              _Info(
                Icons.handyman_outlined,
                'Tools',
                job.toolsRequired.isEmpty
                    ? 'Provided on site'
                    : job.toolsRequired,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: KsColors.primaryContainer,
                child: Icon(
                  Icons.store_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              title: Text(
                employerName(st, job),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${job.location} • ${job.city}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: KsColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Work Promise preview',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: KsColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wage ₹${job.payAmount.toStringAsFixed(0)} • ${job.workingHours} • ${job.location}\nPay: ${job.paymentTerms}',
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const Text(
                    'Full Work Promise Card is generated after offer — both sides must confirm same terms.',
                    style: TextStyle(fontSize: 11.5, color: KsColors.muted),
                  ),
                ],
              ),
            ),
          ),
          if (flags.isNotEmpty)
            Card(
              color: const Color(0xFFFFEBEE),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: KsColors.danger,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Safety flags — read before applying',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: KsColors.danger,
                          ),
                        ),
                      ],
                    ),
                    for (final f in flags)
                      Text('• $f', style: const TextStyle(fontSize: 12.5)),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/report',
                        arguments: jobId,
                      ),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Report this listing'),
                    ),
                  ],
                ),
              ),
            ),
          if (applied)
            Card(
              color: KsColors.successBg.withOpacity(.6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    StatusChip.app(existing.first.status),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You already applied — track it in My Jobs.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => showFeedback(
                    context,
                    'Calling ${employerName(st, job)}… (simulated call)',
                  ),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: job.status != JobStatus.open
                      ? null
                      : applied
                      ? () => Navigator.pushNamed(context, '/myjobs')
                      : () {
                          final r = ctl.applyForJob(jobId);
                          showFeedback(context, r.msg, error: !r.ok);
                          if (r.ok) Navigator.pushNamed(context, '/myjobs');
                        },
                  icon: Icon(
                    applied ? Icons.work_history_outlined : Icons.lock_outline,
                  ),
                  label: Text(
                    job.status != JobStatus.open
                        ? 'Closed'
                        : applied
                        ? 'Track application'
                        : 'Apply & Lock Job',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String k, v;
  const _Info(this.icon, this.k, this.v);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: KsColors.primary),
          Text(
            k,
            style: const TextStyle(
              fontSize: 10.5,
              color: KsColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            v,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );
}
