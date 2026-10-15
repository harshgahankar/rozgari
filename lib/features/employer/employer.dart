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
import '../../core/i18n/strings.dart';

const _uuid = Uuid();

class EmployerDashboard extends ConsumerWidget {
  const EmployerDashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
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
            _EStat('$open', tr(lang, 'openJobs')),
            _EStat('$apps', tr(lang, 'applicationsLbl')),
            _EStat('$active', tr(lang, 'activeWork')),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/post'),
            icon: const Icon(Icons.add),
            label: Text(tr(lang, 'postJobCta')),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/echowk'),
                icon: const Icon(Icons.groups_outlined),
                label: Text(tr(lang, 'labourChowkBtn')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/eagreements'),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(tr(lang, 'agreementsBtn')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          tr(lang, 'myListings'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: KsColors.primary,
          ),
        ),
        if (myJobs.isEmpty)
          EmptyView(
            icon: Icons.post_add_outlined,
            title: tr(lang, 'noListings'),
            subtitle: tr(lang, 'noListingsSub'),
            actionLabel: tr(lang, 'postAJob'),
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
                      '${j.location} • ₹${j.payAmount.toStringAsFixed(0)} • ${trArgs(lang, 'appCount', {'n': '$count'})} • ${codeLabel(lang, j.status.name)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: StatusChip(
                      codeLabel(lang, j.status.name).toUpperCase(),
                    ),
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
/// With [jobId], edits an existing open listing instead of creating one.
class PostJobScreen extends ConsumerStatefulWidget {
  final String? jobId;
  const PostJobScreen({super.key, this.jobId});
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
  bool _init = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _hours.dispose();
    _tools.dispose();
    super.dispose();
  }

  void _prefill(AppState st) {
    if (_init) return;
    final id = widget.jobId;
    if (id == null) {
      _init = true;
      return;
    }
    Job? job;
    try {
      job = st.jobs.firstWhere((j) => j.id == id);
    } catch (_) {}
    if (job == null) {
      _init = true;
      return;
    }
    _init = true;
    cat = job.category;
    _title.text = job.title;
    _desc.text = job.description;
    loc = job.location;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sd = DateTime(
      job.startDate.year,
      job.startDate.month,
      job.startDate.day,
    );
    final diff = sd.difference(today).inDays;
    dateOff = [0, 1, 2, 5].contains(diff) ? diff : 1;
    dur = job.duration;
    _hours.text = job.workingHours;
    pay = job.payAmount;
    terms = job.paymentTerms;
    need = job.requiredWorkers;
    _tools.text = job.toolsRequired;
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    _prefill(st);
    final editing = widget.jobId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          editing
              ? tr(lang, 'editJobTitle')
              : trArgs(lang, 'postStep', {'n': '${step + 1}'}),
        ),
      ),
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
            Text(
              tr(lang, 'catDesc'),
              style: const TextStyle(
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
                    label: Text(tradeLabel(lang, t)),
                    selected: cat == t,
                    onSelected: (_) => setState(() => cat = t),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: tr(lang, 'jobTitleL')),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: tr(lang, 'descL'),
                hintText: tr(lang, 'descHint'),
              ),
            ),
          ] else if (step == 1) ...[
            Text(
              tr(lang, 'locSched'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: loc,
              decoration: InputDecoration(labelText: tr(lang, 'workLocality')),
              items: [
                for (final a in kAreas)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setState(() => loc = v ?? loc),
            ),
            const SizedBox(height: 10),
            Text(
              tr(lang, 'startDay'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final d in [0, 1, 2, 5])
                  ChoiceChip(
                    label: Text(
                      d == 0
                          ? tr(lang, 'today')
                          : d == 1
                          ? tr(lang, 'tomorrow')
                          : trArgs(lang, 'inDays', {'n': '$d'}),
                    ),
                    selected: dateOff == d,
                    onSelected: (_) => setState(() => dateOff = d),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hours,
              decoration: InputDecoration(labelText: tr(lang, 'workingHours')),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: dur,
              decoration: InputDecoration(labelText: tr(lang, 'durationL')),
              items: [
                for (final d in const [
                  ('durHalf', 'Half day'),
                  ('dur1', '1 day'),
                  ('dur2', '2 days'),
                  ('dur3', '3 days'),
                  ('dur5', '5 days'),
                  ('dur1m', '1 month'),
                ])
                  DropdownMenuItem(value: d.$2, child: Text(tr(lang, d.$1))),
              ],
              onChanged: (v) => setState(() => dur = v ?? dur),
            ),
          ] else if (step == 2) ...[
            Text(
              tr(lang, 'wageTerms'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            Text(
              trArgs(lang, 'dailyWage', {'v': pay.toStringAsFixed(0)}),
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
                for (final t in const [
                  ('payDaily', 'Daily cash after work'),
                  ('payWeekly', 'Weekly bank transfer'),
                  ('payUpi', 'After completion (UPI)'),
                ])
                  ChoiceChip(
                    label: Text(
                      tr(lang, t.$1),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: terms == t.$2,
                    onSelected: (_) => setState(() => terms = t.$2),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr(lang, 'fairHint'),
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
            ),
          ] else if (step == 3) ...[
            Text(
              tr(lang, 'workersReq'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: KsColors.primary,
              ),
            ),
            Row(
              children: [
                Text(tr(lang, 'workersNeeded')),
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
              decoration: InputDecoration(labelText: tr(lang, 'toolsOpt')),
            ),
          ] else ...[
            Text(
              tr(lang, 'reviewPublish'),
              style: const TextStyle(
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
                      '${tradeLabel(lang, cat)} • $loc • ${dateOff == 0
                          ? tr(lang, 'startsToday')
                          : dateOff == 1
                          ? tr(lang, 'startsTomorrow')
                          : trArgs(lang, 'startsIn', {'n': '$dateOff'})} • ${durLabel(lang, dur)} • ${_hours.text}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    Text(
                      '₹${pay.toStringAsFixed(0)}/day • ${trArgs(lang, 'workersLine', {'n': '$need'})} • ${payLabel(lang, terms)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              tr(lang, 'publishNote'),
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
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
                    child: Text(tr(lang, 'back')),
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
                        tr(lang, 'needTitleDesc'),
                        error: true,
                      );
                      return;
                    }
                    if (step < 4) {
                      setState(() => step++);
                      return;
                    }
                    final ctl = ref.read(appControllerProvider.notifier);
                    if (editing) {
                      final st = ref.read(appControllerProvider);
                      Job? cur;
                      try {
                        cur = st.jobs.firstWhere((j) => j.id == widget.jobId);
                      } catch (_) {}
                      if (cur == null) {
                        if (context.mounted) Navigator.pop(context);
                        return;
                      }
                      final now = DateTime.now();
                      await ctl.updateJob(
                        cur.copyWith(
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
                        ),
                      );
                      if (!context.mounted) return;
                      showFeedback(context, tr(lang, 'jobUpdated'));
                      Navigator.pop(context);
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
                    showFeedback(context, tr(lang, 'jobPublished'));
                    Navigator.pop(context);
                  },
                  child: Text(
                    step < 4
                        ? tr(lang, 'next')
                        : editing
                        ? tr(lang, 'confirm')
                        : tr(lang, 'publishJob'),
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

class EmployerApplicationsScreen extends ConsumerWidget {
  final String jobId;
  const EmployerApplicationsScreen({super.key, required this.jobId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    final ctl = ref.read(appControllerProvider.notifier);
    final job = st.jobs.firstWhere((j) => j.id == jobId);
    final apps = st.applications.where((a) => a.jobId == jobId).toList();
    String workerLabel(String wid) {
      try {
        final wp = st.workers.firstWhere((w) => w.id == wid);
        final u = st.users.firstWhere((u) => u.id == wp.userId);
        return '${u.name} • ${tradeLabel(lang, wp.primaryTrade)} • ${trArgs(lang, 'yrsExp', {'n': '${wp.experienceYears}'})} • ${trArgs(lang, 'jobsCount', {'n': '${wp.completedJobs}'})}';
      } catch (_) {
        return wid;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(trArgs(lang, 'applicantsFor', {'t': job.title})),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (job.status == JobStatus.open)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/post',
                        arguments: jobId,
                      ),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(tr(lang, 'editJobTitle')),
                    ),
                  ),
                if (job.status == JobStatus.open) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ctl.closeJob(jobId, JobStatus.closed);
                      if (context.mounted)
                        showFeedback(context, tr(lang, 'listingClosed'));
                    },
                    icon: const Icon(Icons.lock_outline),
                    label: Text(tr(lang, 'closeListing')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/echowk'),
                    icon: const Icon(Icons.person_search_outlined),
                    label: Text(tr(lang, 'findMore')),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: apps.isEmpty
                ? EmptyView(
                    icon: Icons.inbox_outlined,
                    title: tr(lang, 'noApps'),
                    subtitle: tr(lang, 'noAppsSub'),
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
                                  StatusChip.app(a.status, lang),
                                ],
                              ),
                              Text(
                                trArgs(lang, 'appliedAt', {
                                  'd': fmtDate(a.appliedAt),
                                }),
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
                                    child: Text(tr(lang, 'passport')),
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
                                      child: Text(tr(lang, 'shortlist')),
                                    ),
                                  if (a.status == ApplicationStatus.shortlisted)
                                    FilledButton(
                                      onPressed: () async {
                                        final r = await ctl.sendOffer(
                                          jobId: jobId,
                                          workerId: a.workerId,
                                        );
                                        if (context.mounted) {
                                          showFeedback(
                                            context,
                                            r.msg,
                                            error: !r.ok,
                                          );
                                        }
                                      },
                                      child: Text(tr(lang, 'offer')),
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
                                      child: Text(tr(lang, 'reject')),
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
  int minExp = 0;
  double maxDist = 25;
  String date = 'Any';
  final _skill = TextEditingController();

  @override
  void dispose() {
    _skill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    final ctl = ref.read(appControllerProvider.notifier);
    final found = matchWorkersForEmployer(
      workers: st.workers,
      trade: trade,
      area: area,
      minExp: minExp,
      date: date,
      maxDist: maxDist,
      skillQ: _skill.text,
    );
    final myJobs = st.jobs
        .where(
          (j) =>
              j.employerId == st.currentEmployer.id &&
              j.status == JobStatus.open,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'chowkFind'))),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            tr(lang, 'matchNote'),
            style: const TextStyle(fontSize: 12, color: KsColors.muted),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: trade,
            decoration: InputDecoration(labelText: tr(lang, 'tradeNeeded')),
            items: [
              for (final t in kTrades)
                DropdownMenuItem(value: t, child: Text(tradeLabel(lang, t))),
            ],
            onChanged: (v) => setState(() => trade = v ?? trade),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: area,
            decoration: InputDecoration(labelText: tr(lang, 'workLocality')),
            items: [
              for (final a in kAreas)
                DropdownMenuItem(value: a, child: Text(a)),
            ],
            onChanged: (v) => setState(() => area = v ?? area),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _skill,
            decoration: InputDecoration(
              labelText: tr(lang, 'skillSearchHint'),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: minExp,
                  decoration: InputDecoration(labelText: tr(lang, 'minExpL')),
                  items: [
                    DropdownMenuItem(value: 0, child: Text(tr(lang, 'any'))),
                    for (final e in [2, 5])
                      DropdownMenuItem(
                        value: e,
                        child: Text(trArgs(lang, 'expVal', {'n': '$e'})),
                      ),
                  ],
                  onChanged: (v) => setState(() => minExp = v ?? 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr(lang, 'dateL'),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: date,
                      isDense: true,
                      items: [
                        for (final d in ['Any', 'today', 'tomorrow'])
                          DropdownMenuItem(
                            value: d,
                            child: Text(
                              d == 'Any'
                                  ? tr(lang, 'any')
                                  : d == 'today'
                                  ? tr(lang, 'today')
                                  : tr(lang, 'tomorrow'),
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => date = v ?? 'Any'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            trArgs(lang, 'maxDistL', {'v': maxDist.toStringAsFixed(0)}),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          Slider(
            value: maxDist,
            min: 2,
            max: 25,
            divisions: 23,
            label: '${maxDist.toStringAsFixed(0)} km',
            onChanged: (v) => setState(() => maxDist = v),
          ),
          Text(
            trArgs(lang, 'availableWorkers', {'n': '${found.length}'}),
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
                                    '${tradeLabel(lang, w.primaryTrade)} • ${trArgs(lang, 'yrsExp', {'n': '${w.experienceYears}'})} • ${trArgs(lang, 'jobsCount', {'n': '${w.completedJobs}'})} • ${w.workArea}',
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
                                child: Text(tr(lang, 'passportBtn')),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: FilledButton.tonal(
                                onPressed: myJobs.isEmpty
                                    ? null
                                    : () => _invite(
                                        context,
                                        ctl,
                                        myJobs,
                                        w.id,
                                        lang,
                                      ),
                                child: Text(
                                  myJobs.isEmpty
                                      ? tr(lang, 'postFirst')
                                      : tr(lang, 'inviteToJob'),
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
            EmptyView(
              icon: Icons.person_search_outlined,
              title: tr(lang, 'nobodyAvail'),
              subtitle: tr(lang, 'nobodyAvailSub'),
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
    String lang,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                tr(lang, 'chooseJobInvite'),
                style: const TextStyle(fontWeight: FontWeight.w800),
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
                    showFeedback(context, tr(lang, 'inviteSent'));
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
    final lang = st.lang;
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
      appBar: AppBar(
        title: Text(trArgs(lang, 'workerPassportFor', {'n': u.name})),
      ),
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
                    '${tradeLabel(lang, w.primaryTrade)} • ${trArgs(lang, 'yrsExp', {'n': '${w.experienceYears}'})} • ${trArgs(lang, 'jobsDoneCount', {'n': '${w.completedJobs}'})}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${w.workArea} • ${trArgs(lang, 'expectsPay', {'v': w.preferredPay.toStringAsFixed(0)})} • ${codeLabel(lang, w.availability.name)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    trArgs(lang, 'skillsList', {
                      'v': [
                        w.primaryTrade,
                        ...w.additionalSkills,
                      ].map((t) => tradeLabel(lang, t)).join(', '),
                    }),
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          Text(
            tr(lang, 'inviteDirect'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          if (myJobs.isEmpty)
            Text(
              tr(lang, 'postOpenFirst'),
              style: const TextStyle(color: KsColors.muted),
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
                      showFeedback(context, tr(lang, 'inviteSentShort'));
                  },
                  child: Text(tr(lang, 'inviteBtn')),
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
    final lang = st.lang;
    final list = st.agreements
        .where((g) => g.employerId == st.currentEmployer.id)
        .toList()
        .reversed
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'agrTitle'))),
      body: list.isEmpty
          ? EmptyView(
              icon: Icons.receipt_long_outlined,
              title: tr(lang, 'noAgr'),
              subtitle: tr(lang, 'noAgrSub'),
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
    final ctl = ref.read(appControllerProvider.notifier);
    final lang = st.lang;
    Job? job;
    try {
      job = st.jobs.firstWhere((j) => j.id == agreement.jobId);
    } catch (_) {}
    JobApplication? app;
    for (final a in st.applications) {
      if (a.jobId == agreement.jobId && a.workerId == agreement.workerId) {
        app = a;
      }
    }
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
                StatusChip(
                  'v${agreement.version} • ${codeLabel(lang, agreement.status.name)}',
                ),
              ],
            ),
            Text(
              '₹${agreement.agreedPay.toStringAsFixed(0)} • ${agreement.workingHours} • ${agreement.location}',
              style: const TextStyle(fontSize: 12.5),
            ),
            Text(
              "${tr(lang, 'rowWorker')} ${agreement.workerConfirmed ? '✓' : '…'} • ${tr(lang, 'rowEmployer')} ${agreement.employerConfirmed ? '✓' : '…'}",
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
            ),
            if (payment != null)
              Text(
                "${tr(lang, 'paymentSim')} (${tr(lang, 'simulatedTag')}): ${codeLabel(lang, payment.status.name)} • ₹${payment.amount.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 12, color: KsColors.secondary),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/agreement',
                    arguments: agreement.id,
                  ),
                  child: Text(tr(lang, 'openPromise')),
                ),
                if (app?.status == ApplicationStatus.confirmed)
                  FilledButton(
                    onPressed: () async {
                      final r = ctl.transitionApplication(
                        app!.id,
                        ApplicationStatus.inProgress,
                      );
                      if (context.mounted) {
                        showFeedback(context, r.msg, error: !r.ok);
                      }
                    },
                    child: Text(tr(lang, 'startWork')),
                  ),
                if (app?.status == ApplicationStatus.inProgress)
                  FilledButton(
                    onPressed: () async {
                      final r = ctl.transitionApplication(
                        app!.id,
                        ApplicationStatus.completed,
                      );
                      await ctl.ensurePaymentFor(
                        agreement.jobId,
                        agreement.workerId,
                        agreement.agreedPay,
                      );
                      if (context.mounted) {
                        showFeedback(context, r.msg, error: !r.ok);
                      }
                    },
                    child: Text(tr(lang, 'markComplete')),
                  ),
                if (app?.status == ApplicationStatus.confirmed ||
                    app?.status == ApplicationStatus.inProgress)
                  TextButton(
                    onPressed: () async {
                      final r = ctl.transitionApplication(
                        app!.id,
                        ApplicationStatus.disputed,
                      );
                      if (context.mounted) {
                        showFeedback(
                          context,
                          r.ok ? tr(lang, 'disputeDone') : r.msg,
                          error: !r.ok,
                        );
                      }
                    },
                    child: Text(tr(lang, 'disputeBtn')),
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
                                title: Text(
                                  "${codeLabel(lang, s.name)} ${tr(lang, 'simulatedTag')}",
                                ),
                                onTap: () async {
                                  final pid = payment.id;
                                  await ref
                                      .read(appControllerProvider.notifier)
                                      .setPaymentStatus(pid, s);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    showFeedback(
                                      context,
                                      trArgs(lang, 'paymentTo', {
                                        's': codeLabel(lang, s.name),
                                      }),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    child: Text(tr(lang, 'updatePayment')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Employer profile view + edit. Changes surface in worker-facing
/// discovery (business name) immediately — same shared state.
class EmployerProfileScreen extends ConsumerStatefulWidget {
  const EmployerProfileScreen({super.key});
  @override
  ConsumerState<EmployerProfileScreen> createState() =>
      _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends ConsumerState<EmployerProfileScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _biz;
  late TextEditingController _contact;
  String _type = 'Homeowner';
  String _area = 'Kothrud, Pune';
  bool _init = false;

  static const _types = ['Homeowner', 'Contractor', 'Business', 'Individual'];

  String _typeLabel(String lang, String t) => switch (t) {
    'Homeowner' => tr(lang, 'typeHomeowner'),
    'Contractor' => tr(lang, 'typeContractor'),
    'Business' => tr(lang, 'typeBusiness'),
    _ => tr(lang, 'typeIndividual'),
  };

  @override
  void dispose() {
    _name.dispose();
    _biz.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _prefill(AppState st) {
    if (_init) return;
    _init = true;
    final e = st.currentEmployer;
    _name = TextEditingController(text: st.currentEmployerUser.name);
    _biz = TextEditingController(text: e.businessName);
    _contact = TextEditingController(text: e.contact);
    if (_types.contains(e.employerType)) _type = e.employerType;
    if (kAreas.contains(e.workArea)) _area = e.workArea;
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    if (st.loading) return const Scaffold(body: LoadingView());
    _prefill(st);
    final myJobs = st.jobs.where((j) => j.employerId == st.currentEmployer.id);
    final open = myJobs.where((j) => j.status == JobStatus.open).length;
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'eProfileTitle'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            Card(
              color: KsColors.primary,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name.text.isEmpty
                          ? st.currentEmployerUser.name
                          : _name.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${_typeLabel(lang, _type)} • $_area',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '$open • ${tr(lang, 'openJobs')}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: tr(lang, 'eNameL')),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? tr(lang, 'nameError')
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(labelText: tr(lang, 'eTypeL')),
              items: [
                for (final t in _types)
                  DropdownMenuItem(value: t, child: Text(_typeLabel(lang, t))),
              ],
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _biz,
              decoration: InputDecoration(labelText: tr(lang, 'eBizL')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: kAreas.contains(_area) ? _area : kAreas.first,
              decoration: InputDecoration(labelText: tr(lang, 'workLocality')),
              items: [
                for (final a in kAreas)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setState(() => _area = v ?? _area),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contact,
              decoration: InputDecoration(labelText: tr(lang, 'eContactL')),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                if (!_form.currentState!.validate()) {
                  showFeedback(context, tr(lang, 'fillRequired'), error: true);
                  return;
                }
                final ctl = ref.read(appControllerProvider.notifier);
                final e = st.currentEmployer;
                await ctl.upsertEmployerProfile(
                  EmployerProfile(
                    id: e.id,
                    userId: e.userId,
                    employerType: _type,
                    businessName: _biz.text.trim(),
                    workArea: _area,
                    contact: _contact.text.trim(),
                  ),
                );
                if (_name.text.trim().isNotEmpty) {
                  await ctl.renameCurrentEmployer(_name.text.trim());
                }
                if (!context.mounted) return;
                showFeedback(context, tr(lang, 'eSaved'));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(tr(lang, 'eSave')),
            ),
          ),
        ),
      ),
    );
  }
}
