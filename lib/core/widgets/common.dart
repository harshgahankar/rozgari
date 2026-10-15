import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';
import '../i18n/strings.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';

String fmtDate(DateTime d) => DateFormat('d MMM').format(d);
String fmtPay(Job j) {
  final unit = switch (j.payUnit) {
    PayUnit.perDay => '/day',
    PayUnit.perHour => '/hr',
    PayUnit.perJob => '/job',
    PayUnit.perMonth => '/mo',
  };
  return '₹${j.payAmount.toStringAsFixed(0)}$unit';
}

class LoadingView extends StatelessWidget {
  final String label;
  const LoadingView({super.key, this.label = 'Loading…'});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10),
        Text(label),
      ],
    ),
  );
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: KsColors.surfaceContainer,
              child: Icon(icon, size: 30, color: KsColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: KsColors.muted),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color? bg;
  final Color? fg;
  const StatusChip(this.label, {super.key, this.bg, this.fg});
  factory StatusChip.app(ApplicationStatus s, [String lang = 'en']) {
    final map = {
      ApplicationStatus.applied: (
        const Color(0xFFE3F2FD),
        const Color(0xFF1565C0),
      ),
      ApplicationStatus.shortlisted: (
        const Color(0xFFFFF3E0),
        KsColors.secondary,
      ),
      ApplicationStatus.offered: (
        const Color(0xFFF3E5F5),
        const Color(0xFF6A1B9A),
      ),
      ApplicationStatus.confirmed: (KsColors.successBg, KsColors.successDeep),
      ApplicationStatus.inProgress: (
        const Color(0xFFE0F2F1),
        const Color(0xFF00695C),
      ),
      ApplicationStatus.completed: (KsColors.successBg, KsColors.successDeep),
      ApplicationStatus.rejected: (const Color(0xFFFFEBEE), KsColors.danger),
      ApplicationStatus.withdrawn: (KsColors.surfaceHigh, KsColors.muted),
      ApplicationStatus.cancelled: (KsColors.surfaceHigh, KsColors.muted),
      ApplicationStatus.disputed: (const Color(0xFFFFEBEE), KsColors.danger),
    };
    final c = map[s]!;
    return StatusChip(codeLabel(lang, s.name), bg: c.$1, fg: c.$2);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg ?? KsColors.successBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg ?? KsColors.successDeep,
        ),
      ),
    );
  }
}

/// Localized status chip: pass app [lang] so codes render in EN/HI.
class LStatusChip extends StatelessWidget {
  final String code;
  final Color? bg;
  final Color? fg;
  const LStatusChip(this.code, {super.key, this.bg, this.fg});
  @override
  Widget build(BuildContext context) {
    // Caller localizes before constructing; kept simple via StatusChip.
    return StatusChip(code, bg: bg, fg: fg);
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final String employerName;
  final String? distanceLabel;
  final bool saved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final List<String> safetyFlags;
  final String lang;
  const JobCard({
    super.key,
    required this.job,
    required this.employerName,
    this.distanceLabel,
    this.saved = false,
    this.onTap,
    this.onSave,
    this.safetyFlags = const [],
    this.lang = 'en',
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: KsColors.successBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tradeLabel(lang, job.category).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: KsColors.successDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (distanceLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KsColors.amberBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        distanceLabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: KsColors.secondary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Semantics(
                    label: saved ? 'Unsave job' : 'Save job',
                    child: IconButton(
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                        color: saved ? KsColors.secondary : KsColors.muted,
                      ),
                      onPressed: onSave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                job.title,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: KsColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: KsColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: KsColors.canvas,
                  borderRadius: BorderRadius.circular(10),
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
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: KsColors.successDeep,
                            ),
                          ),
                          Text(
                            tr(lang, 'directPayNoComm'),
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: KsColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: KsColors.muted,
                            ),
                            Text(
                              job.location,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                          ],
                        ),
                        Text(
                          trArgs(lang, 'starts', {
                            'd': fmtDate(job.startDate),
                            'dur': job.duration,
                          }),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: KsColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.verified,
                    size: 15,
                    color: KsColors.successDeep,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      employerName,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.groups_outlined,
                    size: 15,
                    color: KsColors.muted,
                  ),
                  Text(
                    ' ${job.requiredWorkers}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              if (safetyFlags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: KsColors.danger,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trArgs(lang, 'caution', {
                            'f': flagLabel(lang, safetyFlags.first),
                          }),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: KsColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showFeedback(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: error ? KsColors.danger : KsColors.primary,
    ),
  );
}

/// Kaam Sahayak helpline: opens the phone dial pad with 8850611287
/// pre-filled (ACTION_DIAL — no call permission needed). Falls back to
/// showing the number when no dialer is available (e.g. desktop/test).
Future<void> dialHelpline(BuildContext context, String lang) async {
  final uri = Uri(scheme: 'tel', path: '8850611287');
  try {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      showFeedback(context, tr(lang, 'helplineNumber'), error: true);
    }
  } catch (_) {
    if (context.mounted) {
      showFeedback(context, tr(lang, 'helplineNumber'), error: true);
    }
  }
}
