import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/utils/matching.dart';
import '../../core/utils/safety_rules.dart';
import '../../core/widgets/common.dart';
import '../../core/i18n/strings.dart';
import '../../data/local/media_store.dart';
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
    final lang = st.lang;
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
                  avail ? tr(lang, 'chowkLive') : tr(lang, 'chowkPaused'),
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
                Text(
                  tr(lang, 'myAvailability'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${tradeLabel(lang, w.primaryTrade)} • ${w.workArea} • ${w.preferredRadiusKm.toStringAsFixed(0)} km',
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
                          showFeedback(context, tr(lang, 'availableToday'));
                        },
                        child: Text(
                          avail
                              ? tr(lang, 'availableChk')
                              : tr(lang, 'goAvailable'),
                        ),
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
                          showFeedback(context, tr(lang, 'pausedExisting'));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        child: Text(
                          avail ? tr(lang, 'pause') : tr(lang, 'pausedChk'),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      tr(lang, 'employerDiscovery'),
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
                const SizedBox(height: 4),
                Text(
                  tr(lang, 'availDateL'),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (final d in const ['today', 'tomorrow'])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            d == 'today'
                                ? tr(lang, 'today')
                                : tr(lang, 'tomorrow'),
                          ),
                          selected: w.availableDate == d,
                          onSelected: (_) => ctl.upsertWorkerProfile(
                            w.copyWith(availableDate: d),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  trArgs(lang, 'radiusL', {
                    'v': w.preferredRadiusKm.toStringAsFixed(0),
                  }),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Slider(
                  value: w.preferredRadiusKm.clamp(2, 25),
                  min: 2,
                  max: 25,
                  divisions: 23,
                  activeColor: KsColors.secondaryContainer,
                  label: '${w.preferredRadiusKm.toStringAsFixed(0)} km',
                  onChanged: (v) =>
                      ctl.upsertWorkerProfile(w.copyWith(preferredRadiusKm: v)),
                ),
              ],
            ),
          ),
        ),
        Text(
          tr(lang, 'directInvites'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: KsColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        if (invites.isEmpty)
          EmptyView(
            icon: Icons.markunread_mailbox_outlined,
            title: tr(lang, 'noInvites'),
            subtitle: tr(lang, 'noInvitesSub'),
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
                            StatusChip(
                              codeLabel(lang, inv.status.name).toUpperCase(),
                            ),
                          ],
                        ),
                        Text(
                          '${employerName(st, j, lang)} • ${j.location} • ₹${j.payAmount.toStringAsFixed(0)}',
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
                                child: Text(tr(lang, 'viewJob')),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (inv.status == InvitationStatus.pending) ...[
                              Expanded(
                                child: FilledButton.tonal(
                                  onPressed: () async {
                                    final r = await ctl.respondInvitation(
                                      inv.id,
                                      InvitationStatus.accepted,
                                    );
                                    if (context.mounted) {
                                      showFeedback(
                                        context,
                                        r.msg,
                                        error: !r.ok,
                                      );
                                    }
                                  },
                                  child: Text(tr(lang, 'accept')),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final r = await ctl.respondInvitation(
                                      inv.id,
                                      InvitationStatus.declined,
                                    );
                                    if (context.mounted) {
                                      showFeedback(
                                        context,
                                        r.msg,
                                        error: !r.ok,
                                      );
                                    }
                                  },
                                  child: Text(tr(lang, 'decline')),
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
          child: Text(
            tr(lang, 'fairWage'),
            style: const TextStyle(fontSize: 12, color: KsColors.secondary),
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
    final lang = st.lang;
    final w = st.currentWorker;
    final u = st.currentWorkerUser;
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'passport'))),
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
                              '${tradeLabel(lang, w.primaryTrade)} • ${trArgs(lang, 'yrsExp', {'n': '${w.experienceYears}'})}',
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
                      _PStat('${w.completedJobs}', tr(lang, 'jobsDone')),
                      _PStat(
                        '₹${w.preferredPay.toStringAsFixed(0)}',
                        tr(lang, 'expectedDay'),
                      ),
                      _PStat(
                        codeLabel(lang, w.availability.name),
                        tr(lang, 'statusL'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const _PhotosCard(),
          const _AudioCard(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.edit_outlined),
              label: Text(tr(lang, 'editPassportBtn')),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skill Passport work photos: real gallery picks stored on-device
/// (app documents dir) and persisted with the profile. Tap × to remove.
class _PhotosCard extends ConsumerStatefulWidget {
  const _PhotosCard();
  @override
  ConsumerState<_PhotosCard> createState() => _PhotosCardState();
}

class _PhotosCardState extends ConsumerState<_PhotosCard> {
  bool _busy = false;

  Future<void> _pick() async {
    final lang = ref.read(appControllerProvider).lang;
    setState(() => _busy = true);
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 80);
      if (files.isEmpty) return;
      final paths = await persistPickedImages(files);
      final ctl = ref.read(appControllerProvider.notifier);
      final w = ref.read(appControllerProvider).currentWorker;
      await ctl.upsertWorkerProfile(
        w.copyWith(workPhotos: [...w.workPhotos, ...paths]),
      );
      if (mounted) showFeedback(context, tr(lang, 'photoSaved'));
    } catch (_) {
      if (mounted) showFeedback(context, tr(lang, 'photoFailed'), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String path) async {
    final lang = ref.read(appControllerProvider).lang;
    final ctl = ref.read(appControllerProvider.notifier);
    final w = ref.read(appControllerProvider).currentWorker;
    await ctl.upsertWorkerProfile(
      w.copyWith(
        workPhotos: w.workPhotos.where((p) => p != path).toList(),
      ),
    );
    await deleteMediaQuietly(path);
    if (mounted) showFeedback(context, tr(lang, 'photoRemoved'));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    final photos = st.currentWorker.workPhotos
        .where((p) => p.isNotEmpty)
        .toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(lang, 'workPhotos'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              tr(lang, 'workPhotosSub'),
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in photos)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(p),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 72,
                            height: 72,
                            color: KsColors.surfaceContainer,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: KsColors.muted,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: GestureDetector(
                          onTap: () => _remove(p),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (photos.length < 6)
                  GestureDetector(
                    onTap: _busy ? null : _pick,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: KsColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _busy
                          ? const Padding(
                              padding: EdgeInsets.all(22),
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Icon(
                              Icons.add_a_photo_outlined,
                              color: KsColors.muted,
                            ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pick,
              icon: const Icon(Icons.upload_outlined),
              label: Text(tr(lang, 'addPhotos')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skill Passport voice intro: record / play / delete, stored on-device.
/// Fully offline — no backend, no cloud.
class _AudioCard extends ConsumerStatefulWidget {
  const _AudioCard();
  @override
  ConsumerState<_AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends ConsumerState<_AudioCard> {
  AudioRecorder? _rec;
  AudioPlayer? _player;
  StreamSubscription<void>? _doneSub;
  bool _recording = false;
  bool _playing = false;
  int _secs = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _doneSub?.cancel();
    _rec?.dispose();
    _player?.dispose();
    super.dispose();
  }

  bool _fileOk(String p) => p.isNotEmpty && File(p).existsSync();

  String _mmss(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Future<void> _toggleRecord() async {
    if (_recording) {
      await _stopAndSave();
      return;
    }
    final lang = ref.read(appControllerProvider).lang;
    final rec = AudioRecorder();
    final ok = await rec.hasPermission();
    if (!ok) {
      if (mounted) showFeedback(context, tr(lang, 'micDenied'), error: true);
      await rec.dispose();
      return;
    }
    await _player?.stop();
    setState(() => _playing = false);
    await rec.start(const RecordConfig(), path: await nextVoicePath());
    _rec = rec;
    setState(() {
      _recording = true;
      _secs = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secs++);
    });
  }

  Future<void> _stopAndSave() async {
    final lang = ref.read(appControllerProvider).lang;
    _timer?.cancel();
    String? path;
    try {
      path = await _rec?.stop();
    } catch (_) {}
    await _rec?.dispose();
    _rec = null;
    setState(() => _recording = false);
    if (path == null || path.isEmpty) return;
    final ctl = ref.read(appControllerProvider.notifier);
    final w = ref.read(appControllerProvider).currentWorker;
    if (w.audioIntro.isNotEmpty) await deleteMediaQuietly(w.audioIntro);
    await ctl.upsertWorkerProfile(w.copyWith(audioIntro: path));
    if (mounted) showFeedback(context, tr(lang, 'audioSaved'));
  }

  Future<void> _togglePlay() async {
    final w = ref.read(appControllerProvider).currentWorker;
    if (!_fileOk(w.audioIntro) || _recording) return;
    _player ??= AudioPlayer();
    if (_playing) {
      await _player!.stop();
      setState(() => _playing = false);
      return;
    }
    _doneSub?.cancel();
    _doneSub = _player!.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
    try {
      await _player!.play(DeviceFileSource(w.audioIntro));
      setState(() => _playing = true);
    } catch (_) {
      final lang = ref.read(appControllerProvider).lang;
      if (mounted) showFeedback(context, tr(lang, 'photoFailed'), error: true);
    }
  }

  Future<void> _delete() async {
    final ctl = ref.read(appControllerProvider.notifier);
    final w = ref.read(appControllerProvider).currentWorker;
    final lang = ref.read(appControllerProvider).lang;
    await _player?.stop();
    setState(() => _playing = false);
    await deleteMediaQuietly(w.audioIntro);
    await ctl.upsertWorkerProfile(w.copyWith(audioIntro: ''));
    if (mounted) showFeedback(context, tr(lang, 'audioDeleted'));
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    final has = _fileOk(st.currentWorker.audioIntro);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _recording
                    ? const Color(0xFFFFEBEE)
                    : KsColors.successBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _recording ? Icons.fiber_manual_record : Icons.mic_none,
                color: _recording ? KsColors.danger : KsColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang, 'audioIntro'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _recording
                        ? '${tr(lang, 'recLive')} ${_mmss(_secs)}'
                        : tr(lang, 'audioIntroSub'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: KsColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (_recording)
              FilledButton.tonalIcon(
                onPressed: _toggleRecord,
                icon: const Icon(Icons.stop, size: 18),
                label: Text(tr(lang, 'recStop')),
              )
            else if (has) ...[
              IconButton(
                tooltip: tr(lang, _playing ? 'stopBtn' : 'playBtn'),
                icon: Icon(
                  _playing
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  color: KsColors.primary,
                ),
                onPressed: _togglePlay,
              ),
              IconButton(
                tooltip: tr(lang, 'deleteBtn'),
                icon: const Icon(
                  Icons.delete_outline,
                  color: KsColors.muted,
                ),
                onPressed: _delete,
              ),
            ] else
              FilledButton.tonalIcon(
                onPressed: _toggleRecord,
                icon: const Icon(Icons.mic, size: 18),
                label: Text(tr(lang, 'recIntro')),
              ),
          ],
        ),
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
  String tab = 'Applied';
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final lang = st.lang;
    String tabTr(String t) {
      switch (t) {
        case 'Shortlisted':
          return tr(lang, 'tabShortlisted');
        case 'Offers':
          return tr(lang, 'tabOffers');
        case 'Confirmed':
          return tr(lang, 'tabConfirmed');
        case 'In Progress':
          return tr(lang, 'tabInProgress');
        case 'Completed':
          return tr(lang, 'tabCompleted');
        case 'Cancelled':
          return tr(lang, 'tabCancelled');
        default:
          return tr(lang, 'tabApplications');
      }
    }

    final mine = st.applications
        .where((a) => a.workerId == st.currentWorkerId)
        .toList();
    List<JobApplication> filtered;
    if (tab == 'Shortlisted') {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.shortlisted)
          .toList();
    } else if (tab == 'Offers') {
      filtered = mine
          .where((a) => a.status == ApplicationStatus.offered)
          .toList();
    } else if (tab == 'Confirmed') {
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
      appBar: AppBar(title: Text(tr(lang, 'myJobs'))),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                for (final t in [
                  'Applied',
                  'Shortlisted',
                  'Offers',
                  'Confirmed',
                  'In Progress',
                  'Completed',
                  'Cancelled',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(tabTr(t)),
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
                    title: trArgs(lang, 'nothingIn', {'t': tabTr(tab)}),
                    subtitle: tab == 'Applied'
                        ? tr(lang, 'applyNearbySub')
                        : tr(lang, 'itemsMoveSub'),
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
                                  StatusChip.app(a.status, lang),
                                ],
                              ),
                              Text(
                                '${j.location} • ₹${j.payAmount.toStringAsFixed(0)} • ${trArgs(lang, 'appliedOn', {'d': fmtDate(a.appliedAt)})}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KsColors.muted,
                                ),
                              ),
                              if (agreement != null)
                                Text(
                                  "${tr(lang, 'workPromiseBtn')} v${agreement.version}: ${codeLabel(lang, agreement.status.name)}${agreement.workerConfirmed && agreement.employerConfirmed ? ' • ${tr(lang, 'bothConfirmed')}' : ''}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (payment != null)
                                Text(
                                  "${tr(lang, 'paymentSim')}: ${codeLabel(lang, payment.status.name)} • ₹${payment.amount.toStringAsFixed(0)}",
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
                                    child: Text(tr(lang, 'details')),
                                  ),
                                  if (agreement != null)
                                    FilledButton.tonal(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/agreement',
                                        arguments: agreement.id,
                                      ),
                                      child: Text(tr(lang, 'workPromiseBtn')),
                                    ),
                                  if (a.status == ApplicationStatus.offered &&
                                      agreement != null)
                                    FilledButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/agreement',
                                        arguments: agreement.id,
                                      ),
                                      child: Text(tr(lang, 'reviewOffer')),
                                    ),
                                  if (a.status == ApplicationStatus.offered &&
                                      agreement == null)
                                    Text(tr(lang, 'offerIncoming')),
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
                                      child: Text(tr(lang, 'withdraw')),
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
                                      child: Text(tr(lang, 'startWork')),
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
                                      child: Text(tr(lang, 'markComplete')),
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
    final lang = st.lang;
    List<Job> results = [];
    if (parsed != null) {
      final now = DateTime.now();
      final want = parsed!['date'] == 'tomorrow'
          ? DateTime(now.year, now.month, now.day + 1)
          : DateTime(now.year, now.month, now.day);
      results = st.jobs.where((j) {
        if (j.status != JobStatus.open) return false;
        if (parsed!['trade']!.isNotEmpty && j.category != parsed!['trade'])
          return false;
        if (parsed!['city']!.isNotEmpty && j.city != parsed!['city'])
          return false;
        final sd = j.startDate;
        if (sd.year != want.year ||
            sd.month != want.month ||
            sd.day != want.day) {
          return false;
        }
        return true;
      }).toList();
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'voiceTitle'))),
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
                  Text(
                    tr(lang, 'speakSearch'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    tr(lang, 'micHonest'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showModalBottomSheet(
                            context: context,
                            builder: (_) => _ListeningSheet(lang: lang),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          icon: const Icon(Icons.mic_none),
                          label: Text(tr(lang, 'tryMic')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Text(
            tr(lang, 'typeSay'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ctl,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(hintText: tr(lang, 'sayHint')),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  setState(() => parsed = parseKaamBolo(_ctl.text)),
              icon: const Icon(Icons.record_voice_over_outlined),
              label: Text(tr(lang, 'interpret')),
            ),
          ),
          if (parsed != null) ...[
            const SizedBox(height: 10),
            Text(
              tr(lang, 'interpretHead'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Wrap(
              spacing: 8,
              children: [
                _FixChip(
                  label:
                      "${tr(lang, 'tradeF')}: ${parsed!['trade']!.isEmpty ? tr(lang, 'any') : tradeLabel(lang, parsed!['trade']!)}",
                  options: ['Any', ...kTrades],
                  display: (o) =>
                      o == 'Any' ? tr(lang, 'any') : tradeLabel(lang, o),
                  onPick: (v) =>
                      setState(() => parsed!['trade'] = v == 'Any' ? '' : v),
                ),
                _FixChip(
                  label:
                      "${tr(lang, 'cityF')}: ${parsed!['city']!.isEmpty ? tr(lang, 'any') : parsed!['city']}",
                  options: const ['Any', 'Pune', 'Mumbai'],
                  display: (o) => o == 'Any' ? tr(lang, 'any') : o,
                  onPick: (v) =>
                      setState(() => parsed!['city'] = v == 'Any' ? '' : v),
                ),
                _FixChip(
                  label:
                      "${tr(lang, 'dateL')}: ${parsed!['date'] == 'today' ? tr(lang, 'today') : tr(lang, 'tomorrow')}",
                  options: const ['today', 'tomorrow'],
                  display: (o) =>
                      o == 'today' ? tr(lang, 'today') : tr(lang, 'tomorrow'),
                  onPick: (v) => setState(() => parsed!['date'] = v),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              trArgs(lang, 'matchingJobs', {'n': '${results.length}'}),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: KsColors.successDeep,
              ),
            ),
            for (final j in results.take(6))
              JobCard(
                job: j,
                lang: lang,
                employerName: employerName(st, j, lang),
                safetyFlags: safetyFlagsForJob(j),
                onTap: () =>
                    Navigator.pushNamed(context, '/job', arguments: j.id),
                onSave: () => ref
                    .read(appControllerProvider.notifier)
                    .toggleSaveJob(j.id),
                saved: st.savedJobIds.contains(j.id),
              ),
            if (results.isEmpty)
              EmptyView(
                icon: Icons.search_off_outlined,
                title: tr(lang, 'nothingMatched'),
                subtitle: tr(lang, 'nothingMatchedSub'),
              ),
          ],
        ],
      ),
    );
  }
}

/// Listening UX for "Try microphone": a pulsing mic + live bars while the
/// (simulated) engine listens, then an honest fallback — real speech
/// recognition is not bundled in this offline demo.
class _ListeningSheet extends StatefulWidget {
  final String lang;
  const _ListeningSheet({required this.lang});
  @override
  State<_ListeningSheet> createState() => _ListeningSheetState();
}

class _ListeningSheetState extends State<_ListeningSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      Navigator.pop(context);
      showFeedback(context, tr(widget.lang, 'micUnavailable'));
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.16).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: KsColors.primary,
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [
                    BoxShadow(
                      color: KsColors.primary.withOpacity(.35),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr(lang, 'listening'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tr(lang, 'speakNow'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: KsColors.muted),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, _) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 7; i++)
                    Container(
                      width: 5,
                      height:
                          10 +
                          26 *
                              (0.5 +
                                  0.5 *
                                      math.sin(
                                        _pulse.value * 6.28 + i * 0.9,
                                      )),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: KsColors.secondary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr(lang, 'cancelBtn')),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixChip extends StatelessWidget {
  final String label;
  final List<String> options;
  final void Function(String) onPick;
  final String Function(String)? display;
  const _FixChip({
    required this.label,
    required this.options,
    required this.onPick,
    this.display,
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
                title: Text(display != null ? display!(o) : o),
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
    final lang = st.lang;
    final flagged = st.jobs
        .map((j) => (j, safetyFlagsForJob(j)))
        .where(
          (e) =>
              e.$2.isNotEmpty &&
              (q.isEmpty || e.$1.title.toLowerCase().contains(q.toLowerCase())),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'safetyTitleFull'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang, 'riskHow'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: KsColors.primary,
                    ),
                  ),
                  Text(
                    tr(lang, 'riskRules'),
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: tr(lang, 'searchFlagged'),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => q = v),
          ),
          const SizedBox(height: 8),
          if (flagged.isEmpty)
            EmptyView(
              icon: Icons.shield_outlined,
              title: tr(lang, 'noFlagged'),
              subtitle: tr(lang, 'noFlaggedSub'),
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
                  e.$2.map((f) => flagLabel(lang, f)).join(' • '),
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: TextButton(
                  child: Text(tr(lang, 'review')),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/job', arguments: e.$1.id),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            tr(lang, 'safetyBasics'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: KsColors.primary,
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                tr(lang, 'safetyBasicsBody'),
                style: const TextStyle(fontSize: 13),
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
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'reportTitle'))),
      body: done
          ? EmptyView(
              icon: Icons.check_circle_outline,
              title: tr(lang, 'reportDone'),
              subtitle: tr(lang, 'reportDoneSub'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  tr(lang, 'categoryL'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final c in const [
                      ('catAdvance', 'Advance fee asked'),
                      ('catWages', 'Wrong wages'),
                      ('catUnsafe', 'Unsafe work'),
                      ('catFake', 'Fake location'),
                      ('catAbuse', 'Abuse / harassment'),
                      ('catOther', 'Other'),
                    ])
                      ChoiceChip(
                        label: Text(
                          tr(lang, c.$1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: cat == c.$2,
                        onSelected: (_) => setState(() => cat = c.$2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: tr(lang, 'whatHappened'),
                    hintText: tr(lang, 'describeHint'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (_desc.text.trim().length < 5) {
                        showFeedback(context, tr(lang, 'addDesc'), error: true);
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
                    label: Text(tr(lang, 'submitReport')),
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
    final lang = st.lang;
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
      appBar: AppBar(title: Text(tr(lang, 'welfare'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: tr(lang, 'welfareSearch'),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => q = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              tr(lang, 'curatedNote'),
              style: const TextStyle(fontSize: 12, color: KsColors.muted),
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
                              trArgs(lang, 'checklist', {'v': w.checklist}),
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
    final lang = st.lang;
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
        title: Text(tr(lang, 'notifications')),
        actions: [
          TextButton(
            onPressed: () => ctl.markAllRead(uid),
            child: Text(tr(lang, 'markAllRead')),
          ),
        ],
      ),
      body: list.isEmpty
          ? EmptyView(
              icon: Icons.notifications_none_outlined,
              title: tr(lang, 'allCaughtUp'),
              subtitle: tr(lang, 'notifSub'),
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
                      '${n.body}\n${agoLabel(lang, n.createdAt)}',
                      style: const TextStyle(fontSize: 12.5),
                    ),
                    isThreeLine: true,
                    onTap: () {
                      ctl.markRead(n.id);
                      final isWorker = st.role == UserRole.worker;
                      if (n.refId != null && n.refId!.startsWith('j')) {
                        if (isWorker) {
                          Navigator.pushNamed(
                            context,
                            '/job',
                            arguments: n.refId,
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/eapplications',
                            arguments: n.refId,
                          );
                        }
                      } else if (n.refId != null && n.refId!.startsWith('g')) {
                        Navigator.pushNamed(
                          context,
                          '/agreement',
                          arguments: n.refId,
                        );
                      } else if (isWorker) {
                        Navigator.pushNamed(context, '/myjobs');
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
