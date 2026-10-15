import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/enums.dart';
import '../../state/app_state.dart';

/// Work Promise Card — digital agreement summary generated from the actual
/// selected worker + job. Confirmed only after BOTH sides approve same terms.
class AgreementScreen extends ConsumerStatefulWidget {
  final String agreementId;
  const AgreementScreen({super.key, required this.agreementId});
  @override
  ConsumerState<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends ConsumerState<AgreementScreen> {
  final _note = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final idx = st.agreements.indexWhere((g) => g.id == widget.agreementId);
    if (idx < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Work Promise')),
        body: const EmptyView(
          icon: Icons.receipt_long_outlined,
          title: 'Agreement not found',
          subtitle: 'It may have been reset with demo data. Ask the employer to send a fresh offer.',
        ),
      );
    }
    final g = st.agreements[idx];
    String jobTitle = g.jobId,
        workerName = g.workerId,
        employerName = g.employerId;
    try {
      final j = st.jobs.firstWhere((j) => j.id == g.jobId);
      jobTitle = j.title;
    } catch (_) {}
    try {
      final wp = st.workers.firstWhere((w) => w.id == g.workerId);
      workerName = st.users.firstWhere((u) => u.id == wp.userId).name;
    } catch (_) {}
    try {
      final ep = st.employers.firstWhere((e) => e.id == g.employerId);
      employerName = ep.businessName.isEmpty
          ? st.users.firstWhere((u) => u.id == ep.userId).name
          : ep.businessName;
    } catch (_) {}
    final isWorker = st.role == UserRole.worker;
    final both = g.workerConfirmed && g.employerConfirmed;

    return Scaffold(
      appBar: AppBar(title: Text('Work Promise • v${g.version}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 140),
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: both ? KsColors.successBg : KsColors.amberBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  both ? Icons.verified : Icons.pending_actions_outlined,
                  color: both ? KsColors.successDeep : KsColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    both
                        ? 'CONFIRMED by both sides — keep this slip for wage proof.'
                        : 'Status: ${g.status.name} • Worker ${g.workerConfirmed ? '✓' : 'pending'} • Employer ${g.employerConfirmed ? '✓' : 'pending'}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Receipt card (HTML: Official Work Promise Slip)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: KsColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'काम का पक्का वादा • Work Promise Slip',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: KsColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Informational record — not a legally verified contract.',
                    style: TextStyle(fontSize: 11, color: KsColors.muted),
                  ),
                  const Divider(),
                  _Row('Work', jobTitle),
                  _Row('Worker', workerName),
                  _Row('Employer', employerName),
                  _Row('Wage', '₹${g.agreedPay.toStringAsFixed(0)}'),
                  _Row('Timing', g.workingHours),
                  _Row('Location', g.location),
                  _Row(
                    'Payment',
                    '${g.paymentTerms} (simulated / self-reported)',
                  ),
                  _Row(
                    'Version',
                    'v${g.version} • ${g.updatedAt.day}/${g.updatedAt.month} ${g.updatedAt.hour}:${g.updatedAt.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: KsColors.successBg.withOpacity(.5),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: KsColors.successDeep),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dignity guarantee: agreed wage, safe hours and written record. Never pay advance fees.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!both && isWorker) ...[
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Request changes (optional note)',
                hintText: 'e.g. timing 10am–5pm instead',
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SafeArea(
          child: both
              ? SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              'Work Promise v${g.version}: $jobTitle | $workerName | $employerName | ₹${g.agreedPay} | ${g.workingHours} | ${g.location} | ${g.paymentTerms} (simulated record)',
                        ),
                      );
                      showFeedback(
                        context,
                        'Slip copied — shareable preview (simulated)',
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Copy / share slip preview'),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final r = await ctl.confirmAgreement(
                            g.id,
                            byWorker: isWorker,
                          );
                          if (!context.mounted) return;
                          showFeedback(context, r.msg, error: !r.ok);
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          isWorker
                              ? 'Accept & Confirm terms'
                              : 'Confirm as employer',
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Later'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: isWorker
                                ? () async {
                                    await ctl.requestChanges(
                                      g.id,
                                      _note.text.trim(),
                                    );
                                    if (!context.mounted) return;
                                    showFeedback(
                                      context,
                                      'Change request sent — confirmations reset',
                                    );
                                    Navigator.pop(context);
                                  }
                                : () async {
                                    await ctl.declineAgreement(g.id);
                                    if (!context.mounted) return;
                                    showFeedback(context, 'Offer declined');
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              isWorker ? 'Request changes' : 'Decline',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String k, v;
  const _Row(this.k, this.v);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            k,
            style: const TextStyle(
              fontSize: 12,
              color: KsColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
