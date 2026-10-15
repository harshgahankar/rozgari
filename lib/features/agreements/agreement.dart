import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/i18n/strings.dart';
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
    final lang = st.lang;
    final idx = st.agreements.indexWhere((g) => g.id == widget.agreementId);
    if (idx < 0) {
      return Scaffold(
        appBar: AppBar(title: Text(tr(lang, 'workPromise'))),
        body: EmptyView(
          icon: Icons.receipt_long_outlined,
          title: tr(lang, 'agrNotFound'),
          subtitle: tr(lang, 'agrNotFoundSub'),
        ),
      );
    }
    final g = st.agreements[idx];
    String jobTitle = g.jobId,
        workerName = g.workerId,
        employerName = g.employerId;
    String jobDate = '';
    try {
      final j = st.jobs.firstWhere((j) => j.id == g.jobId);
      jobTitle = j.title;
      jobDate = fmtDate(j.startDate);
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
      appBar: AppBar(title: Text('${tr(lang, 'workPromise')} • v${g.version}')),
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
                        ? tr(lang, 'confirmedBoth')
                        : '${tr(lang, 'statusL')}: ${codeLabel(lang, g.status.name)} • ${tr(lang, 'rowWorker')} ${g.workerConfirmed ? '✓' : tr(lang, 'pendingL')} • ${tr(lang, 'rowEmployer')} ${g.employerConfirmed ? '✓' : tr(lang, 'pendingL')}',
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
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: KsColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        tr(lang, 'promiseSlip'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: KsColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    tr(lang, 'infoRecord'),
                    style: const TextStyle(fontSize: 11, color: KsColors.muted),
                  ),
                  const Divider(),
                  _Row(tr(lang, 'rowWork'), jobTitle),
                  _Row(tr(lang, 'rowWorker'), workerName),
                  _Row(tr(lang, 'rowEmployer'), employerName),
                  _Row(
                    tr(lang, 'rowWage'),
                    '₹${g.agreedPay.toStringAsFixed(0)}',
                  ),
                  if (jobDate.isNotEmpty) _Row(tr(lang, 'rowDate'), jobDate),
                  _Row(tr(lang, 'rowTiming'), g.workingHours),
                  _Row(tr(lang, 'rowLocation'), g.location),
                  _Row(
                    tr(lang, 'rowPayment'),
                    '${g.paymentTerms} ${tr(lang, 'simSelf')}',
                  ),
                  _Row(
                    tr(lang, 'rowVersion'),
                    'v${g.version} • ${g.updatedAt.day}/${g.updatedAt.month} ${g.updatedAt.hour}:${g.updatedAt.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: KsColors.successBg.withOpacity(.5),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: KsColors.successDeep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr(lang, 'dignity'),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!both && isWorker) ...[
            TextField(
              controller: _note,
              decoration: InputDecoration(
                labelText: tr(lang, 'reqChanges'),
                hintText: tr(lang, 'reqHint'),
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
                              '${tr(lang, 'workPromise')} v${g.version}: $jobTitle | $workerName | $employerName | ₹${g.agreedPay} | ${g.workingHours} | ${g.location} | ${g.paymentTerms} ${tr(lang, 'simSelf')}',
                        ),
                      );
                      showFeedback(context, tr(lang, 'slipCopied'));
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text(tr(lang, 'copyShare')),
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
                              ? tr(lang, 'acceptConfirm')
                              : tr(lang, 'confirmEmployer'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(tr(lang, 'later')),
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
                                      tr(lang, 'changeSent'),
                                    );
                                    Navigator.pop(context);
                                  }
                                : () async {
                                    await ctl.declineAgreement(g.id);
                                    if (!context.mounted) return;
                                    showFeedback(
                                      context,
                                      tr(lang, 'offerDeclined'),
                                    );
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              isWorker
                                  ? tr(lang, 'requestChanges')
                                  : tr(lang, 'declineBtn'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isWorker) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            await ctl.declineAgreement(g.id);
                            if (!context.mounted) return;
                            showFeedback(
                              context,
                              tr(lang, 'offerDeclinedByWorker'),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(tr(lang, 'declineOffer')),
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
