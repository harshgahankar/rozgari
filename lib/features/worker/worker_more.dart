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
import 'worker_home.dart' show employerName;

class ChowkTab extends ConsumerWidget {
  const ChowkTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final w = st.currentWorker;
    final invites = st.invitations
        .where((i) => i.workerId == w.id)
        .toList()
        .reversed
        .toList();
    final avail = w.availability == AvailabilityStatus.available;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: KsColors.successBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 10, color: KsColors.successDeep),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  avail
                      ? 'CHOWK LIVE • You are visible to employers today'
                      : 'CHOWK PAUSED • Employers cannot invite you',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: KsColors.successDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          color: KsColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'मेरी आज की उपलब्धता • My availability',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${w.primaryTrade} • ${w.workArea} • ${w.preferredRadiusKm.toStringAsFixed(0)} km',
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          ctl.setAvailability(
                            AvailabilityStatus.available,
                            discoverable: true,
                          );
                          showFeedback(
                            context,
                            'Available today ✓ — employers can invite you',
                          );
                        },
                        child: Text(avail ? 'Available ✓' : 'Go Available'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ctl.setAvailability(
                            AvailabilityStatus.unavailable,
                            discoverable: false,
                          );
                          showFeedback(
                            context,
                            'Paused — existing confirmed jobs unaffected',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: Text(avail ? 'Pause' : 'Paused'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Employer discovery',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    Switch(
                      value: w.discoverable,
                      activeColor: KsColors.secondaryContainer,
                      onChanged: (v) =>
                          ctl.setAvailability(w.availability, discoverable: v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Text(
          'Direct invitations from employers',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: KsColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        if (invites.isEmpty)
          const EmptyView(
            icon: Icons.markunread_mailbox_outlined,
            title: 'No invitations yet',
            subtitle: 'When an employer invites you from Labour Chowk, it appears here with the job details.',
          )
        else
          for (final inv in invites)
            Builder(
              builder: (_) {
                Job? job;
                try {
                  job = st.jobs.firstWhere((j) => j.id == inv.jobId);
                } catch (_) {}
                if (job == null) return const SizedBox.shrink();
                final j = job;
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
                                j.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            StatusChip(inv.status.name.toUpperCase()),
                          ],
                        ),
                        Text(
                          '${employerName(st, j)} • ${j.location} • ₹${j.payAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: KsColors.muted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/job',
                                  arguments: j.id,
                                ),
                                child: const Text('View job'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (inv.status == InvitationStatus.pending) ...[
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: () {
                                    ctl.respondInvitation(
                                      inv.id,
                                      InvitationStatus.accepted,
                                    );
                                    showFeedback(
                                      context,
                                      'Invitation accepted ✓',
                                    );
                                  },
                                  child: const Text('Accept'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    ctl.respondInvitation(
                                      inv.id,
                                      InvitationStatus.declined,
                                    );
                                    showFeedback(
                                      context,
                                      'Invitation declined',
                                    );
                                  },
                                  child: const Text('Decline'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: KsColors.amberBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Fair-wage benchmark: Helper ₹550 • Electrician ₹800 • Mason ₹900 per day (Pune, indicative). Never pay any advance fee.',
            style: TextStyle(fontSize: 12, color: KsColors.secondary),
          ),
        ),
      ],
    );
  }
}

class PassportScreen extends ConsumerWidget {
  const PassportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final w = st.currentWorker;
    final u = st.currentWorkerUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Passport')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Card(
            color: KsColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: KsColors.secondaryContainer,
                        child: Text(
                          u.name.isEmpty ? '?' : u.name.characters.first,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: KsColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  u.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: KsColors.secondaryContainer,
                                ),
                              ],
                            ),
                            Text(
                              '${w.primaryTrade} • ${w.experienceYears} yrs experience',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${w.workArea} • ${w.preferredRadiusKm.toStringAsFixed(0)} km radius',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final s in [w.primaryTrade, ...w.additionalSkills])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PStat('${w.completedJobs}', 'Jobs done'),
                      _PStat(
                        '₹${w.preferredPay.toStringAsFixed(0)}',
                        'Expected/day',
                      ),
                      _PStat(w.availability.name, 'Status'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Work photos (optional)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Text(
                    'Add site photos later — employers trust visible work.',
                    style: TextStyle(fontSize: 12, color: KsColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: KsColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: KsColors.muted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () => showFeedback(
                      context,
                      'Photo upload is simulated in demo — kept optional by design',
                    ),
                    icon: const Icon(Icons.upload_outlined),
                    label: const Text('Add photos (optional)'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Skill Passport'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PStat extends StatelessWidget {
  final String v, l;
  const _PStat(this.v, this.l);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          v,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    ),
  );
}

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});
  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  String tab = 'Applications';
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final mine = st.applications
        .where((a) => a.workerId == st.currentWorkerId)
        .toList();
    List<JobApplication> filtered;
    if (tab == 'Offers') {
      filtered = mine
          .where(
            (a) =>
                a.status == ApplicationStatus.offered ||
                a.status == ApplicationStatus.shortlisted,
          )
          .toList();
    } else if (tab == 'Upcoming') {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.confirmed)
          .toList();
    } else if (tab == 'In Progress') {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.inProgress)
          .toList();
    } else if (tab == 'Completed') {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.completed)
          .toList();
    } else if (tab == 'Cancelled') {
      filtered = mine
          .where(
            (a) => [
              ApplicationStatus.rejected,
              ApplicationStatus.withdrawn,
              ApplicationStatus.cancelled,
              ApplicationStatus.disputed,
            ].contains(a.status),
          )
          .toList();
    } else {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.applied)
          .toList();
    }
    Job jobOf(JobApplication a) => st.jobs.firstWhere((j) => j.id == a.jobId);

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                for (final t in [
                  'Applications',
                  'Offers',
                  'Upcoming',
                  'In Progress',
                  'Completed',
                  'Cancelled',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(t),
                      selected: tab == t,
                      onSelected: (_) => setState(() => tab = t),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyView(
                    icon: Icons.work_history_outlined,
                    title: 'Nothing in $tab',
                    subtitle: tab == 'Applications'
                        ? 'Apply for a nearby job — it appears here and with the employer instantly.'
                        : 'Items move here automatically as statuses change.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      Job? job;
                      try {
                        job = jobOf(a);
                      } catch (_) {
                        return const SizedBox.shrink();
                      }
                      final j = job;
                      final agreement = st.agreements
                          .where(
                            (g) =>
                                g.jobId == a.jobId && g.workerId == a.workerId,
                          )
                          .toList()
                          .lastOrNull;
                      final payment = st.payments
                          .where(
                            (p) =>
                                p.jobId == a.jobId && p.workerId == a.workerId,
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
                                      j.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  StatusChip.app(a.status),
                                ],
                              ),
                              Text(
                                '${j.location} • ₹${j.payAmount.toStringAsFixed(0)} • Applied ${fmtDate(a.appliedAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KsColors.muted,
                                ),
                              ),
                              if (agreement != null)
                                Text(
                                  'Work Promise v${agreement.version}: ${agreement.status.name}${agreement.workerConfirmed && agreement.employerConfirmed ? ' • both confirmed' : ''}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (payment != null)
                                Text(
                                  'Payment (simulated): ${payment.status.name} • ₹${payment.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: KsColors.secondary,
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
                                      '/job',
                                      arguments: j.id,
                                    ),
                                    child: const Text('Details'),
                                  ),
                                  if (agreement != null)
                                    FilledButton.tonal(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/agreement',
                                        arguments: agreement.id,
                                      ),
                                      child: const Text('Work Promise'),
                                    ),
                                  if (a.status == ApplicationStatus.offered &&
                                      agreement != null)
                                    FilledButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/agreement',
                                        arguments: agreement.id,
                                      ),
                                      child: const Text('Review offer'),
                                    ),
                                  if (a.status == ApplicationStatus.offered &&
                                      agreement == null)
                                    const Text(
                                      'Offer incoming — Work Promise generates shortly.',
                                    ),
                                  if (a.status == ApplicationStatus.applied)
                                    TextButton(
                                      onPressed: () {
                                        final r = ctl.transitionApplication(
                                          a.id,
                                          ApplicationStatus.withdrawn,
                                        );
                                        showFeedback(
                                          context,
                                          r.msg,
                                          error: !r.ok,
                                        );
                                      },
                                      child: const Text('Withdraw'),
                                    ),
                                  if (a.status == ApplicationStatus.confirmed)
                                    FilledButton.tonal(
                                      onPressed: () {
                                        final r = ctl.transitionApplication(
                                          a.id,
                                          ApplicationStatus.inProgress,
                                        );
                                        showFeedback(
                                          context,
                                          r.msg,
                                          error: !r.ok,
                                        );
                                      },
                                      child: const Text('Start work'),
                                    ),
                                  if (a.status == ApplicationStatus.inProgress)
                                    FilledButton(
                                      onPressed: () async {
                                        final r = ctl.transitionApplication(
                                          a.id,
                                          ApplicationStatus.completed,
                                        );
                                        await ctl.ensurePaymentFor(
                                          a.jobId,
                                          a.workerId,
                                          j.payAmount,
                                        );
                                        if (!context.mounted) return;
                                        showFeedback(
                                          context,
                                          r.msg,
                                          error: !r.ok,
                                        );
                                      },
                                      child: const Text(
                                        'Mark complete (simulated)',
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
          ),
        ],
      ),
    );
  }
}

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});
  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _ctl = TextEditingController(
    text: 'Mujhe kal Pune mein electrician ka kaam chahiye',
  );
  Map<String, String>? parsed;
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    List<Job> results = [];
    if (parsed != null) {
      results = st.jobs.where((j) {
        if (j.status != JobStatus.open) return false;
        if (parsed!['trade']!.isNotEmpty && j.category != parsed!['trade'])
          return false;
        if (parsed!['city']!.isNotEmpty && j.city != parsed!['city'])
          return false;
        return true;
      }).toList();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Kaam Bolo • Voice Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: KsColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.mic,
                    color: KsColors.secondaryContainer,
                    size: 44,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'बोलकर खोजें — real mic where supported',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Microphone uses the device speech engine if available. Otherwise use the transparent demo parse below — never faked as real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showFeedback(
                            context,
                            'Microphone not available on this device build — use demo parse below (honest fallback)',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.mic_none),
                          label: const Text('Try microphone'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'Type or paste what you would say *',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctl,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'e.g. Mujhe kal Pune mein plumber ka kaam chahiye',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  setState(() => parsed = parseKaamBolo(_ctl.text)),
              icon: const Icon(Icons.record_voice_over_outlined),
              label: const Text('Interpret (demo parse)'),
            ),
          ),
          if (parsed != null) ...[
            const SizedBox(height: 10),
            const Text(
              'Interpretation — tap to correct',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Wrap(
              spacing: 8,
              children: [
                _FixChip(
                  label:
                      'Trade: ${parsed!['trade']!.isEmpty ? 'any' : parsed!['trade']}',
                  options: ['Any', ...kTrades],
                  onPick: (v) =>
                      setState(() => parsed!['trade'] = v == 'Any' ? '' : v),
                ),
                _FixChip(
                  label:
                      'City: ${parsed!['city']!.isEmpty ? 'any' : parsed!['city']}',
                  options: const ['Any', 'Pune', 'Mumbai'],
                  onPick: (v) =>
                      setState(() => parsed!['city'] = v == 'Any' ? '' : v),
                ),
                _FixChip(
                  label: 'Date: ${parsed!['date']}',
                  options: const ['today', 'tomorrow'],
                  onPick: (v) => setState(() => parsed!['date'] = v),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${results.length} matching jobs',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: KsColors.successDeep,
              ),
            ),
            for (final j in results.take(6))
              JobCard(
                job: j,
                employerName: employerName(st, j),
                safetyFlags: safetyFlagsForJob(j),
                onTap: () =>
                    Navigator.pushNamed(context, '/job', arguments: j.id),
                onSave: () => ref
                    .read(appControllerProvider.notifier)
                    .toggleSaveJob(j.id),
                saved: st.savedJobIds.contains(j.id),
              ),
            if (results.isEmpty)
              const EmptyView(
                icon: Icons.search_off_outlined,
                title: 'Nothing matched',
                subtitle: 'Correct a chip above or clear the trade filter.',
              ),
          ],
        ],
      ),
    );
  }
}

class _FixChip extends StatelessWidget {
  final String label;
  final List<String> options;
  final void Function(String) onPick;
  const _FixChip({
    required this.label,
    required this.options,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label),
    avatar: const Icon(Icons.edit, size: 15),
    onPressed: () => showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in options)
              ListTile(
                title: Text(o),
                onTap: () {
                  onPick(o);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});
  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final flagged = st.jobs
        .map((j) => (j, safetyFlagsForJob(j)))
        .where(
          (e) =>
              e.$2.isNotEmpty &&
              (q.isEmpty || e.$1.title.toLowerCase().contains(q.toLowerCase())),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Kaam Suraksha • Safety')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How we flag risk (rule-based, explained)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: KsColors.primary,
                    ),
                  ),
                  Text(
                    '• Missing wage  • Advance-fee demand  • Incomplete description  • OTP/Aadhaar request  • Missing location',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search flagged listings…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => q = v),
          ),
          const SizedBox(height: 8),
          if (flagged.isEmpty)
            const EmptyView(
              icon: Icons.shield_outlined,
              title: 'No flagged listings',
              subtitle: 'All current listings pass the rule checks. Reporting still available on every job detail screen.',
            ),
          for (final e in flagged)
            Card(
              color: const Color(0xFFFFF7F7),
              child: ListTile(
                leading: const Icon(
                  Icons.warning_amber_rounded,
                  color: KsColors.danger,
                ),
                title: Text(
                  e.$1.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  e.$2.join(' • '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  child: const Text('Review'),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/job', arguments: e.$1.id),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Site safety basics',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: KsColors.primary,
            ),
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Helmet • Gloves • Harness for height • Clean water • First-aid box. Stop work and report if safety gear is missing.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportScreen extends ConsumerStatefulWidget {
  final String jobId;
  const ReportScreen({super.key, required this.jobId});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String cat = 'Advance fee asked';
  final _desc = TextEditingController();
  bool done = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report listing')),
      body: done
          ? const EmptyView(
              icon: Icons.check_circle_outline,
              title: 'Report submitted (simulated)',
              subtitle: 'Thank you. Our demo moderation queue received it. No real enforcement action is taken in this prototype.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Category *',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in [
                      'Advance fee asked',
                      'Wrong wages',
                      'Unsafe work',
                      'Fake location',
                      'Abuse / harassment',
                      'Other',
                    ])
                      ChoiceChip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        selected: cat == c,
                        onSelected: (_) => setState(() => cat = c),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What happened? *',
                    hintText: 'Describe briefly…',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (_desc.text.trim().length < 5) {
                        showFeedback(
                          context,
                          'Please add a short description',
                          error: true,
                        );
                        return;
                      }
                      await ref
                          .read(appControllerProvider.notifier)
                          .submitReport(
                            jobId: widget.jobId,
                            category: cat,
                            description: _desc.text.trim(),
                          );
                      setState(() => done = true);
                    },
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Submit simulated report'),
                  ),
                ),
              ],
            ),
    );
  }
}

class WelfareScreen extends ConsumerStatefulWidget {
  const WelfareScreen({super.key});
  @override
  ConsumerState<WelfareScreen> createState() => _WelfareScreenState();
}

class _WelfareScreenState extends ConsumerState<WelfareScreen> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final list = st.welfare
        .where(
          (w) =>
              q.isEmpty ||
              '${w.title} ${w.category} ${w.summary}'.toLowerCase().contains(
                q.toLowerCase(),
              ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Welfare Hub')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search schemes, documents…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Curated information only — we never decide eligibility. Verify at official centres.',
              style: TextStyle(fontSize: 12, color: KsColors.muted),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final w = list[i];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.account_balance_outlined,
                      color: KsColors.primary,
                    ),
                    title: Text(
                      w.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(w.category),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.summary,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Checklist: ${w.checklist}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (w.link.isNotEmpty)
                              Text(
                                w.link,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final uid = st.role == UserRole.worker
        ? st.currentWorkerId
        : st.currentEmployerId;
    final list = st.notifications
        .where((n) => n.userId == uid)
        .toList()
        .reversed
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ctl.markAllRead(uid),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: list.isEmpty
          ? const EmptyView(
              icon: Icons.notifications_none_outlined,
              title: 'All caught up',
              subtitle: 'Applications, offers, agreements and payments notify you here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final n = list[i];
                return Card(
                  color: n.read ? Colors.white : const Color(0xFFF2F7F4),
                  child: ListTile(
                    leading: Icon(
                      n.read ? Icons.mail_outline : Icons.markunread,
                      color: n.read ? KsColors.muted : KsColors.primary,
                    ),
                    title: Text(
                      n.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${n.body}\n${_ago(n.createdAt)}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      ctl.markRead(n.id);
                      if (n.refId != null && n.refId!.startsWith('j'))
                        Navigator.pushNamed(
                          context,
                          '/job',
                          arguments: n.refId,
                        );
                      else if (n.refId != null && n.refId!.startsWith('g'))
                        Navigator.pushNamed(
                          context,
                          '/agreement',
                          arguments: n.refId,
                        );
                      else if (st.role == UserRole.worker)
                        Navigator.pushNamed(context, '/myjobs');
                    },
                  ),
                );
              },
            ),
    );
  }
}

String _ago(DateTime d) {
  final m = DateTime.now().difference(d).inMinutes;
  if (m < 60) return '$m min ago';
  final h = m ~/ 60;
  if (h < 24) return '$h hr ago';
  return '${h ~/ 24} days ago';
}
