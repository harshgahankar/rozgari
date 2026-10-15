import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/utils/matching.dart';
import '../../core/widgets/common.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../state/app_state.dart';

const _uuid = Uuid();

class EmployerDashboard extends ConsumerWidget {
  const EmployerDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final e = st.currentEmployer;
    final myJobs = st.jobs.where((j) => j.employerId == e.id).toList();
    final open = myJobs.where((j) => j.status == JobStatus.open).length;
    final apps = st.applications
        .where((a) => myJobs.any((j) => j.id == a.jobId))
        .length;
    final active = st.agreements
        .where(
          (g) => g.employerId == e.id && g.status == AgreementStatus.confirmed,
        )
        .length;
    final unread = st.unreadFor(st.currentEmployerId);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: KsColors.secondaryContainer,
              child: Text(
                e.businessName.isEmpty ? 'M' : e.businessName.characters.first,
                style: const TextStyle(
                  color: KsColors.primary,
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
                    e.businessName.isEmpty
                        ? st.currentEmployerUser.name
                        : e.businessName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: KsColors.primary,
                    ),
                  ),
                  Text(
                    '${e.employerType} • ${e.workArea}',
                    style: const TextStyle(fontSize: 12, color: KsColors.muted),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                IconButton(
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
        Row(
          children: [
            _EStat('$open', 'Open jobs'),
            _EStat('$apps', 'Applications'),
            _EStat('$active', 'Active work'),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/post'),
            icon: const Icon(Icons.add),
            label: const Text('Post Job • 1-min form'),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/echowk'),
                icon: const Icon(Icons.groups_outlined),
                label: const Text('Labour Chowk'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/eagreements'),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Agreements'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'My listings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: KsColors.primary,
          ),
        ),
        if (myJobs.isEmpty)
          const EmptyView(
            icon: Icons.post_add_outlined,
            title: 'No listings yet',
            subtitle: 'Post your first job — it appears in worker discovery instantly.',
            actionLabel: 'Post a job',
          )
        else
          for (final j in myJobs)
            Builder(
              builder: (_) {
                final count = st.applications
                    .where((a) => a.jobId == j.id)
                    .length;
                return Card(
                  child: ListTile(
                    title: Text(
                      j.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${j.location} • ₹${j.payAmount.toStringAsFixed(0)} • $count application(s) • ${j.status.name}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: StatusChip(j.status.name.toUpperCase()),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/eapplications',
                      arguments: j.id,
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _EStat extends StatelessWidget {
  final String v, l;
  const _EStat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              v,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: KsColors.primary,
              ),
            ),
            Text(
              l,
              style: const TextStyle(fontSize: 10.5, color: KsColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 5-step progressive job post (HTML-mapped). Appears in worker list on publish.
class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});
  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  int step = 0;
  String cat = 'Electrician';
  final _title = TextEditingController(text: 'House wiring repair — 2BHK');
  final _desc = TextEditingController(
    text: 'Repair faulty wiring, fix 3 switchboards and 2 fans. Material provided.',
  );
  String loc = 'Kothrud, Pune';
  int dateOff = 1;
  String dur = '1 day';
  final _hours = TextEditingController(text: '9am – 6pm');
  double pay = 850;
  String terms = 'Daily cash after work';
  int need = 1;
  final _tools = TextEditingController(text: 'Basic toolkit');

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _hours.dispose();
    _tools.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Job • Step ${step + 1} of 5')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
        children: [
          LinearProgressIndicator(
            value: (step + 1) / 5,
            color: KsColors.primary,
            backgroundColor: KsColors.surfaceHigh,
          ),
          const SizedBox(height: 12),
          if (step == 0) ...[
            const Text(
              'Work category & description',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kTrades)
                  ChoiceChip(
                    label: Text(t),
                    selected: cat == t,
                    onSelected: (_) => setState(() => cat = t),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Job title *'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description * (min 20 chars)',
                hintText: 'What work, how many rooms, material provided?',
              ),
            ),
          ] else if (step == 1) ...[
            const Text(
              'Location & schedule',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: loc,
              decoration: const InputDecoration(labelText: 'Work locality *'),
              items: [
                for (final a in kAreas)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setState(() => loc = v ?? loc),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start day',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final d in [0, 1, 2, 5])
                  ChoiceChip(
                    label: Text(
                      d == 0
                          ? 'Today'
                          : d == 1
                          ? 'Tomorrow'
                          : 'In $d days',
                    ),
                    selected: dateOff == d,
                    onSelected: (_) => setState(() => dateOff = d),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hours,
              decoration: const InputDecoration(labelText: 'Working hours'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: dur,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: [
                for (final d in [
                  'Half day',
                  '1 day',
                  '2 days',
                  '3 days',
                  '5 days',
                  '1 month',
                ])
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) => setState(() => dur = v ?? dur),
            ),
          ] else if (step == 2) ...[
            const Text(
              'Wages & payment terms',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            Text(
              'Daily wage: ₹${pay.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Slider(
              value: pay,
              min: 300,
              max: 2000,
              divisions: 34,
              label: '₹${pay.toStringAsFixed(0)}',
              onChanged: (v) => setState(() => pay = v),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final t in [
                  'Daily cash after work',
                  'Weekly bank transfer',
                  'After completion (UPI)',
                ])
                  ChoiceChip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    selected: terms == t,
                    onSelected: (_) => setState(() => terms = t),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Fair-wage hint: Helper ₹550 • Electrician ₹800+ (Pune, indicative). Zero wage = flagged as suspicious.',
              style: TextStyle(fontSize: 12, color: KsColors.muted),
            ),
          ] else if (step == 3) ...[
            const Text(
              'Workers & requirements',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            Row(
              children: [
                const Text('Workers needed'),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      setState(() => need = (need - 1).clamp(1, 20)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$need',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => need = (need + 1).clamp(1, 20)),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            TextField(
              controller: _tools,
              decoration: const InputDecoration(
                labelText: 'Tools required (optional)',
              ),
            ),
          ] else ...[
            const Text(
              'Review & publish',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _desc.text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KsColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$cat • $loc • Starts ${dateOff == 0
                          ? 'today'
                          : dateOff == 1
                          ? 'tomorrow'
                          : 'in $dateOff days'} • $dur • ${_hours.text}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      '₹${pay.toStringAsFixed(0)}/day • $need worker(s) • $terms',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Publishing makes this visible in worker discovery immediately (same local state).',
              style: TextStyle(fontSize: 12, color: KsColors.muted),
            ),
          ],
        ],
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SafeArea(
          child: Row(
            children: [
              if (step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => step--),
                    child: const Text('Back'),
                  ),
                ),
              if (step > 0) const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () async {
                    if (step == 0 &&
                        (_title.text.trim().isEmpty ||
                            _desc.text.trim().length < 20)) {
                      showFeedback(
                        context,
                        'Add title + description (min 20 chars)',
                        error: true,
                      );
                      return;
                    }
                    if (step < 4) {
                      setState(() => step++);
                      return;
                    }
                    final st = ref.read(appControllerProvider);
                    final now = DateTime.now();
                    final job = Job(
                      id: 'j_${_uuid.v4().substring(0, 6)}',
                      employerId: st.currentEmployer.id,
                      title: _title.text.trim(),
                      category: cat,
                      description: _desc.text.trim(),
                      location: loc,
                      city:
                          loc.contains('Mumbai') ||
                              loc.contains('Thane') ||
                              loc.contains('Vashi')
                          ? 'Mumbai'
                          : 'Pune',
                      payAmount: pay,
                      startDate: DateTime(
                        now.year,
                        now.month,
                        now.day,
                      ).add(Duration(days: dateOff)),
                      duration: dur,
                      workingHours: _hours.text,
                      requiredWorkers: need,
                      toolsRequired: _tools.text,
                      paymentTerms: terms,
                      createdAt: now,
                    );
                    await ref.read(appControllerProvider.notifier).postJob(job);
                    if (!context.mounted) return;
                    showFeedback(
                      context,
                      'Job published ✓ — visible to workers now',
                    );
                    Navigator.pop(context);
                  },
                  child: Text(step < 4 ? 'Next' : 'Publish job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmployerApplicationsScreen extends ConsumerWidget {
  final String jobId;
  const EmployerApplicationsScreen({super.key, required this.jobId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final job = st.jobs.firstWhere((j) => j.id == jobId);
    final apps = st.applications.where((a) => a.jobId == jobId).toList();
    String workerLabel(String wid) {
      try {
        final wp = st.workers.firstWhere((w) => w.id == wid);
        final u = st.users.firstWhere((u) => u.id == wp.userId);
        return '${u.name} • ${wp.primaryTrade} • ${wp.experienceYears}yrs • ${wp.completedJobs} jobs';
      } catch (_) {
        return wid;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Applicants • ${job.title}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ctl.closeJob(jobId, JobStatus.closed);
                      if (context.mounted)
                        showFeedback(
                          context,
                          'Listing closed — applicants notified',
                        );
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Close listing'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/echowk'),
                    icon: const Icon(Icons.person_search_outlined),
                    label: const Text('Find more'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: apps.isEmpty
                ? const EmptyView(
                    icon: Icons.inbox_outlined,
                    title: 'No applications yet',
                    subtitle: 'When a worker applies, they appear here instantly. Try Labour Chowk to invite workers directly.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: apps.length,
                    itemBuilder: (_, i) {
                      final a = apps[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      workerLabel(a.workerId),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                  StatusChip.app(a.status),
                                ],
                              ),
                              Text(
                                'Applied ${fmtDate(a.appliedAt)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: KsColors.muted,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/epassport',
                                      arguments: a.workerId,
                                    ),
                                    child: const Text('Skill Passport'),
                                  ),
                                  if (a.status == ApplicationStatus.applied)
                                    FilledButton.tonal(
                                      onPressed: () {
                                        final r = ctl.transitionApplication(
                                          a.id,
                                          ApplicationStatus.shortlisted,
                                        );
                                        showFeedback(
                                          context,
                                          r.msg,
                                          error: !r.ok,
                                        );
                                      },
                                      child: const Text('Shortlist'),
                                    ),
                                  if (a.status == ApplicationStatus.shortlisted)
                                    FilledButton(
                                      onPressed: () async {
                                        await ctl.sendOffer(
                                          jobId: jobId,
                                          workerId: a.workerId,
                                        );
                                        if (context.mounted)
                                          showFeedback(
                                            context,
                                            'Offer sent ✓ — worker sees Work Promise Card',
                                          );
                                      },
                                      child: const Text('Send offer'),
                                    ),
                                  if (a.status == ApplicationStatus.applied ||
                                      a.status == ApplicationStatus.shortlisted)
                                    TextButton(
                                      onPressed: () {
                                        final r = ctl.transitionApplication(
                                          a.id,
                                          ApplicationStatus.rejected,
                                        );
                                        showFeedback(
                                          context,
                                          r.msg,
                                          error: !r.ok,
                                        );
                                      },
                                      child: const Text('Reject'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class EmployerChowkScreen extends ConsumerStatefulWidget {
  const EmployerChowkScreen({super.key});
  @override
  ConsumerState<EmployerChowkScreen> createState() =>
      _EmployerChowkScreenState();
}

class _EmployerChowkScreenState extends ConsumerState<EmployerChowkScreen> {
  String trade = 'Electrician';
  String area = 'Kothrud, Pune';
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final found = matchWorkersForEmployer(
      workers: st.workers,
      trade: trade,
      area: area,
    );
    final myJobs = st.jobs
        .where(
          (j) =>
              j.employerId == st.currentEmployer.id &&
              j.status == JobStatus.open,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Labour Chowk • Find workers')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Deterministic match: skill + availability + area. No fake trust scores.',
            style: TextStyle(fontSize: 12, color: KsColors.muted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: trade,
            decoration: const InputDecoration(labelText: 'Trade needed'),
            items: [
              for (final t in kTrades)
                DropdownMenuItem(value: t, child: Text(t)),
            ],
            onChanged: (v) => setState(() => trade = v ?? trade),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: area,
            decoration: const InputDecoration(labelText: 'Work locality'),
            items: [
              for (final a in kAreas)
                DropdownMenuItem(value: a, child: Text(a)),
            ],
            onChanged: (v) => setState(() => area = v ?? area),
          ),
          const SizedBox(height: 8),
          Text(
            '${found.length} available worker(s)',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: KsColors.successDeep,
            ),
          ),
          for (final w in found)
            Builder(
              builder: (_) {
                final u = st.users.firstWhere((u) => u.id == w.userId);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: KsColors.primaryContainer,
                              child: Text(
                                u.name.characters.first,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    u.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${w.primaryTrade} • ${w.experienceYears}yrs • ${w.completedJobs} jobs • ${w.workArea}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: KsColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/epassport',
                                  arguments: w.id,
                                ),
                                child: const Text('Passport'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: FilledButton.tonal(
                                onPressed: myJobs.isEmpty
                                    ? null
                                    : () => _invite(context, ctl, myJobs, w.id),
                                child: Text(
                                  myJobs.isEmpty
                                      ? 'Post a job first'
                                      : 'Invite to job',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          if (found.isEmpty)
            const EmptyView(
              icon: Icons.person_search_outlined,
              title: 'Nobody available for this filter',
              subtitle: 'Workers who paused availability are hidden. Try another trade or nearby locality.',
            ),
        ],
      ),
    );
  }

  void _invite(
    BuildContext context,
    AppController ctl,
    List<Job> myJobs,
    String workerId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Choose job for invitation',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            for (final j in myJobs)
              ListTile(
                title: Text(j.title),
                subtitle: Text(
                  '${j.location} • ₹${j.payAmount.toStringAsFixed(0)}',
                ),
                onTap: () async {
                  await ctl.sendInvitation(jobId: j.id, workerId: workerId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    showFeedback(
                      context,
                      'Invitation sent ✓ — worker notified',
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class EmployerPassportScreen extends ConsumerWidget {
  final String workerId;
  const EmployerPassportScreen({super.key, required this.workerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final w = st.workers.firstWhere((w) => w.id == workerId);
    final u = st.users.firstWhere((u) => u.id == w.userId);
    final myJobs = st.jobs
        .where(
          (j) =>
              j.employerId == st.currentEmployer.id &&
              j.status == JobStatus.open,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text('${u.name} • Passport')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: KsColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${w.primaryTrade} • ${w.experienceYears} yrs • ${w.completedJobs} jobs done',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${w.workArea} • expects ₹${w.preferredPay.toStringAsFixed(0)}/day • ${w.availability.name}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Skills: ${[w.primaryTrade, ...w.additionalSkills].join(', ')}',
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'Invite directly (no application needed)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          if (myJobs.isEmpty)
            const Text(
              'Post an open job first, then invite.',
              style: TextStyle(color: KsColors.muted),
            ),
          for (final j in myJobs)
            Card(
              child: ListTile(
                title: Text(
                  j.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${j.location} • ₹${j.payAmount.toStringAsFixed(0)}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () async {
                    await ref
                        .read(appControllerProvider.notifier)
                        .sendInvitation(jobId: j.id, workerId: w.id);
                    if (context.mounted)
                      showFeedback(context, 'Invitation sent ✓');
                  },
                  child: const Text('Invite'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EmployerAgreementsScreen extends ConsumerWidget {
  const EmployerAgreementsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final list = st.agreements
        .where((g) => g.employerId == st.currentEmployer.id)
        .toList()
        .reversed
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Agreements & payments (simulated)')),
      body: list.isEmpty
          ? const EmptyView(
              icon: Icons.receipt_long_outlined,
              title: 'No agreements yet',
              subtitle: 'Send an offer from an application — the Work Promise Card appears here and with the worker.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) => AgreementTile(agreement: list[i]),
            ),
    );
  }
}

class AgreementTile extends ConsumerWidget {
  final WorkAgreement agreement;
  const AgreementTile({super.key, required this.agreement});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    Job? job;
    try {
      job = st.jobs.firstWhere((j) => j.id == agreement.jobId);
    } catch (_) {}
    final payment = st.payments
        .where(
          (p) => p.jobId == agreement.jobId && p.workerId == agreement.workerId,
        )
        .toList()
        .lastOrNull;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job?.title ?? agreement.jobId,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                StatusChip('v${agreement.version} • ${agreement.status.name}'),
              ],
            ),
            Text(
              '₹${agreement.agreedPay.toStringAsFixed(0)} • ${agreement.workingHours} • ${agreement.location}',
              style: const TextStyle(fontSize: 12.5),
            ),
            Text(
              'Worker ${agreement.workerConfirmed ? '✓' : '…'} • Employer ${agreement.employerConfirmed ? '✓' : '…'}',
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
            ),
            if (payment != null)
              Text(
                'Payment (simulated/self-reported): ${payment.status.name} • ₹${payment.amount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: KsColors.secondary),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/agreement',
                    arguments: agreement.id,
                  ),
                  child: const Text('Open Work Promise'),
                ),
                if (payment != null)
                  OutlinedButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final s in PaymentStatus.values)
                              ListTile(
                                title: Text('${s.name} (simulated)'),
                                onTap: () async {
                                  final pid = payment.id;
                                  await ref
                                      .read(appControllerProvider.notifier)
                                      .setPaymentStatus(pid, s);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    showFeedback(
                                      context,
                                      'Payment → ${s.name} (simulated)',
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    child: const Text('Update payment'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
