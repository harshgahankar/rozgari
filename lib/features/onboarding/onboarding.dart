import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/widgets/common.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../core/i18n/strings.dart';
import '../../state/app_state.dart';

/// Language cards built from current lang via tr() — EN/HI only.
List<(String, String, String, String, String, String)> langCards(String lang) =>
    [
      (
        'hi',
        tr(lang, 'langHiName'),
        tr(lang, 'langHiSub'),
        tr(lang, 'langHiTag'),
        tr(lang, 'langGlyphHi'),
        tr(lang, 'langHiFoot'),
      ),
      (
        'en',
        tr(lang, 'langEnName'),
        tr(lang, 'langEnSub'),
        tr(lang, 'langEnTag'),
        tr(lang, 'langGlyphEn'),
        tr(lang, 'langEnFoot'),
      ),
    ];

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appControllerProvider).lang;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          children: [
            Row(
              children: [
                Container(
                  height: 6,
                  width: 32,
                  decoration: BoxDecoration(
                    color: KsColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 6,
                  width: 10,
                  decoration: BoxDecoration(
                    color: KsColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 6,
                  width: 10,
                  decoration: BoxDecoration(
                    color: KsColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Text(
                  tr(lang, 'step1of3'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: KsColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              tr(lang, 'chooseLang'),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: KsColors.primary,
              ),
            ),
            Row(
              children: [
                Text(
                  lang == 'hi'
                      ? tr('en', 'chooseLang')
                      : tr('hi', 'chooseLang'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: KsColors.secondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KsColors.amberBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    tr(lang, 'helpAvailable'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: KsColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr(lang, 'chooseLangHint'),
              style: const TextStyle(color: KsColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KsColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: KsColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.volume_up, color: KsColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(lang, 'listenAloud'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          tr(lang, 'audioPrompt'),
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
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: KsColors.successDeep,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tr(lang, 'liveVoice'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final l in langCards(lang))
              _LangCard(
                code: l.$1,
                name: l.$2,
                sub: l.$3,
                tagline: l.$4,
                glyph: l.$5,
                foot: l.$6,
                selected: lang == l.$1,
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KsColors.successBg.withOpacity(.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: KsColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr(lang, 'promiseNoFee'),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: KsColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.96),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/landing'),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(tr(lang, 'continueBtn')),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr(lang, 'nextIsRole'),
                style: const TextStyle(fontSize: 11, color: KsColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangCard extends ConsumerWidget {
  final String code, name, sub, tagline, glyph, foot;
  final bool selected;
  const _LangCard({
    required this.code,
    required this.name,
    required this.sub,
    required this.tagline,
    required this.glyph,
    required this.foot,
    required this.selected,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appControllerProvider.select((s) => s.lang));
    return Card(
      color: selected ? const Color(0xFFF2F7F4) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? KsColors.primary : Colors.transparent,
          width: selected ? 2 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ref.read(appControllerProvider.notifier).setLang(code);
          final v = code == 'hi' ? tr(lang, 'hindi') : tr(lang, 'english');
          showFeedback(context, trArgs(lang, 'langChanged', {'v': v}));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? KsColors.primaryContainer
                          : KsColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      glyph,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: selected ? Colors.white : KsColors.primary,
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
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: KsColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($sub)',
                              style: const TextStyle(
                                color: KsColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          tagline,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: KsColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? KsColors.primary
                          : KsColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: selected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    foot,
                    style: const TextStyle(fontSize: 11, color: KsColors.muted),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.volume_down_outlined,
                    size: 18,
                    color: KsColors.muted,
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

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appControllerProvider.select((s) => s.lang));
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: KsColors.primaryContainer,
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Icon(
                    Icons.handshake,
                    color: KsColors.secondaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tr(lang, 'appName'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: KsColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr(lang, 'pune'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: KsColors.successDeep,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      tr(lang, 'digitalChowk'),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: KsColors.muted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KsColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'EN • ${tr(lang, 'hindi')}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: KsColors.successBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: KsColors.successDeep,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '480+ ${tr(lang, 'liveJobs')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: KsColors.successDeep,
                      ),
                    ),
                  ),
                  Text(
                    tr(lang, 'live'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: KsColors.successDeep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr(lang, 'beyondLine'),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                color: KsColors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${tr(lang, 'hero1')}\n${tr(lang, 'hero2')}\n${tr(lang, 'hero3')}',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 30,
                height: 1.15,
                color: KsColors.primary,
              ),
            ),
            Text(
              tr(lang, 'heroSub'),
              style: const TextStyle(color: KsColors.muted, fontSize: 13.5),
            ),
            Text(
              tr(lang, 'heroSub2'),
              style: const TextStyle(color: KsColors.muted, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 10,
                          color: KsColors.successDeep,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr(lang, 'todayChowk'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: KsColors.successDeep,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Shivajinagar • 2 km',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: KsColors.secondary,
                          ),
                        ),
                      ],
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
                          const Icon(
                            Icons.handyman,
                            size: 28,
                            color: KsColors.primary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Electrician Assistant',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Residential wiring • 8 hrs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: KsColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                '₹850',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: KsColors.successDeep,
                                ),
                              ),
                              Text(
                                tr(lang, 'perDayDirect'),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: KsColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: KsColors.primaryContainer,
                          child: Text(
                            'R',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Ramesh Patil',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: KsColors.successDeep,
                                  ),
                                ],
                              ),
                              Text(
                                tr(lang, 'bookedWeek'),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: KsColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          tr(lang, 'onTimePay'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: KsColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(appControllerProvider.notifier)
                      .setRole(UserRole.worker);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/profile');
                  }
                },
                icon: const Icon(Icons.search),
                label: Text(tr(lang, 'findWork')),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref
                      .read(appControllerProvider.notifier)
                      .setRole(UserRole.employer);
                  if (context.mounted) {
                    Navigator.pushNamed(context, '/eonboard');
                  }
                },
                icon: const Icon(Icons.person_add_outlined),
                label: Text(tr(lang, 'hireWorker')),
              ),
            ),
            const SizedBox(height: 12),
            for (final v in [
              (
                Icons.phone_in_talk_outlined,
                tr(lang, 'featDirect'),
                tr(lang, 'featDirectTag'),
                tr(lang, 'featDirectSub'),
              ),
              (
                Icons.verified_user_outlined,
                tr(lang, 'featPromise'),
                tr(lang, 'featPromiseTag'),
                tr(lang, 'featPromiseSub'),
              ),
              (
                Icons.badge_outlined,
                tr(lang, 'featPassport'),
                tr(lang, 'featPassportTag'),
                tr(lang, 'featPassportSub'),
              ),
            ])
              Card(
                child: ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: KsColors.successBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(v.$1, color: KsColors.primary),
                  ),
                  title: Text(
                    v.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(v.$4, style: const TextStyle(fontSize: 12.5)),
                  trailing: Text(
                    v.$3,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: KsColors.successDeep,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              tr(lang, 'tradesTitle'),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _Trade(
                  icon: Icons.bolt_outlined,
                  en: 'Electrician',
                  lang: lang,
                ),
                _Trade(
                  icon: Icons.plumbing_outlined,
                  en: 'Plumber',
                  lang: lang,
                ),
                _Trade(
                  icon: Icons.carpenter_outlined,
                  en: 'Carpenter',
                  lang: lang,
                ),
                _Trade(
                  icon: Icons.format_paint_outlined,
                  en: 'Painter',
                  lang: lang,
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => dialHelpline(context, lang),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KsColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      color: KsColors.secondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(lang, 'helpline'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(Icons.call, color: KsColors.secondaryContainer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Trade extends StatelessWidget {
  final IconData icon;
  final String en;
  final String lang;
  const _Trade({required this.icon, required this.en, required this.lang});
  @override
  Widget build(BuildContext context) {
    final first = tradeLabel(lang, en);
    final second = lang == 'hi' ? en : tradeLabel('hi', en);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: KsColors.primary),
            Text(
              first,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              second,
              style: const TextStyle(fontSize: 9.5, color: KsColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleScreen extends ConsumerWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    final ctl = ref.read(appControllerProvider.notifier);
    UserRole sel = st.role;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(tr(lang, 'step2')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 130),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: KsColors.amberBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              tr(lang, 'onboardingBadge'),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: KsColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(lang, 'roleTitle'),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: KsColors.primary,
            ),
          ),
          Text(
            tr(lang, 'roleSub'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: KsColors.muted,
            ),
          ),
          Text(
            tr(lang, 'roleDesc'),
            style: const TextStyle(color: KsColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            selected: sel == UserRole.worker,
            badge: tr(lang, 'wantWorkBadge'),
            title: tr(lang, 'wantWork'),
            sub: tr(lang == 'hi' ? 'en' : 'hi', 'wantWork'),
            desc: tr(lang, 'wantWorkDesc'),
            points: [
              tr(lang, 'wantWorkP1'),
              tr(lang, 'wantWorkP2'),
              tr(lang, 'wantWorkP3'),
            ],
            icon: Icons.construction,
            onTap: () => ctl.setRole(UserRole.worker),
          ),
          _RoleCard(
            selected: sel == UserRole.employer,
            badge: tr(lang, 'wantHireBadge'),
            title: tr(lang, 'wantHire'),
            sub: tr(lang == 'hi' ? 'en' : 'hi', 'wantHire'),
            desc: tr(lang, 'wantHireDesc'),
            points: [tr(lang, 'wantHireP1'), tr(lang, 'wantHireP2')],
            icon: Icons.groups_outlined,
            onTap: () => ctl.setRole(UserRole.employer),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KsColors.successBg.withOpacity(.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tr(lang, 'promiseShort'),
              style: const TextStyle(fontSize: 12.5, color: KsColors.primary),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                if (sel == UserRole.worker) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  Navigator.pushNamed(context, '/eonboard');
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                sel == UserRole.worker
                    ? tr(lang, 'continueAsWorker')
                    : tr(lang, 'continueAsEmployer'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final String badge, title, sub, desc;
  final List<String> points;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleCard({
    required this.selected,
    required this.badge,
    required this.title,
    required this.sub,
    required this.desc,
    required this.points,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? KsColors.primary : Colors.transparent,
          width: selected ? 2 : 0,
        ),
      ),
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selected
                          ? KsColors.successBg
                          : KsColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: KsColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: KsColors.secondary,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: KsColors.primary,
                          ),
                        ),
                        Text(
                          sub,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: KsColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected
                          ? KsColors.primary
                          : KsColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: selected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(fontSize: 12.5, color: KsColors.muted),
              ),
              const SizedBox(height: 8),
              for (final p in points)
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 15,
                      color: KsColors.successDeep,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(p, style: const TextStyle(fontSize: 12.5)),
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

/// Worker profile form — validates required inputs, preserves back-navigation
/// values via controllers held in stateful widget + saves to shared state.
class WorkerProfileFormScreen extends ConsumerStatefulWidget {
  const WorkerProfileFormScreen({super.key});
  @override
  ConsumerState<WorkerProfileFormScreen> createState() =>
      _WorkerProfileFormScreenState();
}

class _WorkerProfileFormScreenState
    extends ConsumerState<WorkerProfileFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name;
  String _trade = 'Electrician';
  final Set<String> _skills = {'Helper'};
  int _exp = 5;
  String _area = 'Kothrud, Pune';
  double _radius = 8;
  double _pay = 800;
  AvailabilityStatus _avail = AvailabilityStatus.available;
  String _date = 'today';
  bool _init = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _prefill(AppState st) {
    if (_init) return;
    _init = true;
    _name = TextEditingController(
      text: st.currentWorkerUser.name == 'Ramesh Patil'
          ? ''
          : st.currentWorkerUser.name,
    );
    final w = st.currentWorker;
    _trade = w.primaryTrade;
    _skills.addAll(w.additionalSkills);
    _exp = w.experienceYears;
    _area = w.workArea;
    _radius = w.preferredRadiusKm;
    _pay = w.preferredPay;
    _avail = w.availability;
    _date = w.availableDate;
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final lang = st.lang;
    if (st.loading) return const Scaffold(body: LoadingView());
    _prefill(st);
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'profileTitle'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          children: [
            Text(
              tr(lang, 'profileHead'),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KsColors.primary,
              ),
            ),
            Text(
              tr(lang, 'profileSub'),
              style: const TextStyle(color: KsColors.muted),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: tr(lang, 'nameLabel'),
                hintText: tr(lang, 'nameHint'),
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? tr(lang, 'nameError')
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Text(
              tr(lang, 'primaryTrade'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kTrades)
                  ChoiceChip(
                    label: Text(tradeLabel(lang, t)),
                    selected: _trade == t,
                    onSelected: (_) => setState(() => _trade = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tr(lang, 'addSkills'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kTrades.where((e) => e != _trade))
                  FilterChip(
                    label: Text(tradeLabel(lang, t)),
                    selected: _skills.contains(t),
                    onSelected: (v) =>
                        setState(() => v ? _skills.add(t) : _skills.remove(t)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  tr(lang, 'expYears'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      setState(() => _exp = (_exp - 1).clamp(0, 40)),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_exp',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _exp = (_exp + 1).clamp(0, 40)),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
            Text(
              trArgs(lang, 'prefRadius', {'v': _radius.toStringAsFixed(0)}),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _radius,
              min: 2,
              max: 25,
              divisions: 23,
              label: '${_radius.toStringAsFixed(0)} km',
              onChanged: (v) => setState(() => _radius = v),
            ),
            Text(
              trArgs(lang, 'expectedPay', {'v': _pay.toStringAsFixed(0)}),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _pay,
              min: 300,
              max: 2000,
              divisions: 34,
              label: '₹${_pay.toStringAsFixed(0)}',
              onChanged: (v) => setState(() => _pay = v),
            ),
            Card(
              color: KsColors.successBg.withOpacity(.5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: KsColors.successDeep),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tr(lang, 'photosNote'),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr(lang, 'availL'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(tr(lang, 'availableChk')),
                  selected: _avail == AvailabilityStatus.available,
                  onSelected: (_) =>
                      setState(() => _avail = AvailabilityStatus.available),
                ),
                ChoiceChip(
                  label: Text(tr(lang, 'pausedChk')),
                  selected: _avail != AvailabilityStatus.available,
                  onSelected: (_) =>
                      setState(() => _avail = AvailabilityStatus.unavailable),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tr(lang, 'availDateL'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(tr(lang, 'today')),
                  selected: _date == 'today',
                  onSelected: (_) => setState(() => _date = 'today'),
                ),
                ChoiceChip(
                  label: Text(tr(lang, 'tomorrow')),
                  selected: _date == 'tomorrow',
                  onSelected: (_) => setState(() => _date = 'tomorrow'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr(lang, 'back')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!_form.currentState!.validate()) {
                      showFeedback(
                        context,
                        tr(lang, 'fillRequired'),
                        error: true,
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      '/preview',
                      arguments: {
                        'name': _name.text.trim(),
                        'trade': _trade,
                        'skills': _skills.toList(),
                        'exp': _exp,
                        'area': _area,
                        'radius': _radius,
                        'pay': _pay,
                        'avail': _avail.name,
                        'date': _date,
                      },
                    );
                  },
                  icon: const Icon(Icons.badge_outlined),
                  label: Text(tr(lang, 'previewSave')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skill Passport preview — generated from the actual form data (flow step 10).
/// Save persists the profile + display name + onboarding (step 11) and opens
/// the Worker Dashboard (step 12).
class PassportPreviewScreen extends ConsumerWidget {
  const PassportPreviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final lang = st.lang;
    final args =
        (ModalRoute.of(context)?.settings.arguments as Map?) ?? const {};
    final name = (args['name'] as String?) ?? '';
    final base = st.currentWorker;
    final draft = base.copyWith(
      primaryTrade: (args['trade'] as String?) ?? base.primaryTrade,
      additionalSkills:
          ((args['skills'] as List?)?.map((e) => '$e').toList()) ??
          base.additionalSkills,
      experienceYears: (args['exp'] as int?) ?? base.experienceYears,
      workArea: (args['area'] as String?) ?? base.workArea,
      preferredRadiusKm:
          ((args['radius'] as num?)?.toDouble()) ?? base.preferredRadiusKm,
      preferredPay: ((args['pay'] as num?)?.toDouble()) ?? base.preferredPay,
      availability:
          enumFromCode(AvailabilityStatus.values, args['avail'] as String?) ??
          base.availability,
      availableDate: (args['date'] as String?) ?? base.availableDate,
    );
    final displayName = name.isNotEmpty ? name : st.currentWorkerUser.name;
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'previewTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 130),
        children: [
          Card(
            color: KsColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isEmpty ? '—' : displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    '${tradeLabel(lang, draft.primaryTrade)} • ${trArgs(lang, 'yrsExp', {'n': '${draft.experienceYears}'})}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '${draft.workArea} • ${trArgs(lang, 'radiusL', {'v': draft.preferredRadiusKm.toStringAsFixed(0)})}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    '${trArgs(lang, 'expectedPay', {'v': draft.preferredPay.toStringAsFixed(0)})} • ${codeLabel(lang, draft.availability.name)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in [
                        draft.primaryTrade,
                        ...draft.additionalSkills,
                      ])
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
                            tradeLabel(lang, s),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr(lang, 'back')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () async {
                    await ctl.upsertWorkerProfile(draft);
                    if (name.isNotEmpty) {
                      await ctl.renameCurrentWorker(name);
                    }
                    await ctl.setOnboarded(true);
                    if (!context.mounted) return;
                    showFeedback(context, tr(lang, 'passportSaved'));
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(tr(lang, 'saveProfile')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Employer onboarding: name → type → business → locality → contact →
/// review → save → Employer Dashboard. No OTP in demo.
class EmployerOnboardingScreen extends ConsumerStatefulWidget {
  const EmployerOnboardingScreen({super.key});
  @override
  ConsumerState<EmployerOnboardingScreen> createState() =>
      _EmployerOnboardingScreenState();
}

class _EmployerOnboardingScreenState
    extends ConsumerState<EmployerOnboardingScreen> {
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
    _name = TextEditingController(
      text: st.currentEmployerUser.name == 'Meera Shah'
          ? ''
          : st.currentEmployerUser.name,
    );
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
    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'eOnboardTitle'))),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          children: [
            Text(
              tr(lang, 'eOnboardHead'),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KsColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: tr(lang, 'eNameL')),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? tr(lang, 'nameError')
                  : null,
              textInputAction: TextInputAction.next,
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
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(lang, 'eReview'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_typeLabel(lang, _type)} • $_area',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (_biz.text.trim().isNotEmpty)
                      Text(
                        _biz.text.trim(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: KsColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: KsColors.surface.withOpacity(.97),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(tr(lang, 'back')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (!_form.currentState!.validate()) {
                      showFeedback(
                        context,
                        tr(lang, 'fillRequired'),
                        error: true,
                      );
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
                    await ctl.setOnboarded(true);
                    if (!context.mounted) return;
                    showFeedback(context, tr(lang, 'eSaved'));
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.store_outlined),
                  label: Text(tr(lang, 'eReview')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
