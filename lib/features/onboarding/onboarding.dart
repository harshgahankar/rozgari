import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/constants/meta.dart';
import '../../core/widgets/common.dart';
import '../../data/models/enums.dart';
import '../../state/app_state.dart';

const langCards = [
  (
    'hi',
    'हिंदी',
    'Hindi',
    'नमस्ते, अपनी पसंदीदा भाषा चुनें',
    'अ',
    'डिफ़ॉल्ट भाषा • Most popular',
  ),
  (
    'mr',
    'मराठी',
    'Marathi',
    'नमस्कार, कामाच्या नव्या संधी शोधा',
    'म',
    'महाराष्ट्र व गोवा विभाग',
  ),
  (
    'en',
    'English',
    'All India',
    'Find nearby skilled & daily wage work',
    'Aa',
    'Universal terms & wage slips',
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
                const Text(
                  'STEP 1 OF 3 • चरण १',
                  style: TextStyle(
                    fontSize: 11,
                    color: KsColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'अपनी भाषा चुनें',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: KsColors.primary,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Choose Your Language',
                  style: TextStyle(
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
                  child: const Text(
                    'मदद उपलब्ध',
                    style: TextStyle(
                      fontSize: 11,
                      color: KsColors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'You can change this anytime or use voice assistance for full audio support across all screens.',
              style: TextStyle(color: KsColors.muted, fontSize: 13),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'बोलकर सुनें',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Audio prompt: "अपनी भाषा चुनिए"',
                          style: TextStyle(
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
                    child: const Text(
                      'LIVE VOICE',
                      style: TextStyle(
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
            for (final l in langCards)
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
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: KsColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'कामसेतु का वादा: कोई फ़ीस नहीं, सीधा काम और पूरी पारदर्शिता.',
                      style: TextStyle(fontSize: 12.5, color: KsColors.primary),
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
                  label: const Text('आगे बढ़ें • Continue'),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'अगला कदम: अपनी भूमिका चुनें (Worker / Employer)',
                style: TextStyle(fontSize: 11, color: KsColors.muted),
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
          showFeedback(context, 'Language: $name');
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

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});
  @override
  Widget build(BuildContext context) {
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'कामसेतू',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: KsColors.primary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PUNE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: KsColors.successDeep,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'KAAMSETU • DIGITAL CHOWK',
                      style: TextStyle(fontSize: 9.5, color: KsColors.muted),
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
                  child: const Text(
                    'EN • हिंदी • मराठी',
                    style: TextStyle(
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
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 10, color: KsColors.successDeep),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '480+ Daily wage & skilled jobs live today in Pune',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: KsColors.successDeep,
                      ),
                    ),
                  ),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: KsColors.successDeep,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'BEYOND THE WAITING LINE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.4,
                color: KsColors.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              'Your Skills.\nYour Work.\nYour Tomorrow.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 30,
                height: 1.15,
                color: KsColors.primary,
              ),
            ),
            const Text(
              'काम आपकी पहचान, अवसर आपका अधिकार',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: KsColors.primary,
              ),
            ),
            const Text(
              'Connect directly with trusted local jobs in Pune & nearby. Transparent daily wages, no commission, no resume needed.',
              style: TextStyle(color: KsColors.muted, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: KsColors.successDeep,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "TODAY'S VERIFIED CHOWK",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: KsColors.successDeep,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Shivajinagar • 2 km',
                          style: TextStyle(
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
                      child: const Row(
                        children: [
                          Icon(
                            Icons.handyman,
                            size: 28,
                            color: KsColors.primary,
                          ),
                          SizedBox(width: 10),
                          Expanded(
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
                              Text(
                                '₹850',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: KsColors.successDeep,
                                ),
                              ),
                              Text(
                                'PER DAY DIRECT PAY',
                                style: TextStyle(
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
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: KsColors.primaryContainer,
                          child: Text(
                            'R',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                'Booked 4 days this week',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: KsColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '98% On-Time Pay',
                          style: TextStyle(
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
                onPressed: () => Navigator.pushNamed(context, '/role'),
                icon: const Icon(Icons.search),
                label: const Text('काम ढूँढें / Find Work — 1 min free'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/role'),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('काम करवाएं / Hire a Worker'),
              ),
            ),
            const SizedBox(height: 12),
            for (final v in [
              (
                Icons.phone_in_talk_outlined,
                'Direct Calling & Chat',
                '0% Cut',
                'Talk straight to homeowners and contractors. No agent fees.',
              ),
              (
                Icons.verified_user_outlined,
                'Work Promise Slip',
                'Written Record',
                'Digital wage slip before you start. Hours, rate and pay method locked in.',
              ),
              (
                Icons.badge_outlined,
                'Digital Skill Passport',
                'Audio Bio',
                'Showcase work photos and voice reviews. Carry your reputation anywhere.',
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
            const Text(
              'Available Trades in Pune',
              style: TextStyle(
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
              children: const [
                _Trade(
                  icon: Icons.bolt_outlined,
                  en: 'Electrician',
                  hi: 'इलेक्ट्रीशियन',
                ),
                _Trade(
                  icon: Icons.plumbing_outlined,
                  en: 'Plumber',
                  hi: 'प्लम्बर',
                ),
                _Trade(
                  icon: Icons.carpenter_outlined,
                  en: 'Carpenter',
                  hi: 'बढ़ई',
                ),
                _Trade(
                  icon: Icons.format_paint_outlined,
                  en: 'Painter',
                  hi: 'पेंटर',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KsColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.support_agent, color: KsColors.secondaryContainer),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'मदद चाहिए? Kaam Sahayak Helpline (Toll-Free)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(Icons.call, color: KsColors.secondaryContainer),
                ],
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
  final String en, hi;
  const _Trade({required this.icon, required this.en, required this.hi});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(icon, color: KsColors.primary),
          Text(
            en,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
          Text(
            hi,
            style: const TextStyle(fontSize: 9.5, color: KsColors.muted),
          ),
        ],
      ),
    ),
  );
}

class RoleScreen extends ConsumerWidget {
  const RoleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    UserRole sel = st.role;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('कदम २ / Step 2'),
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
            child: const Text(
              '🤝 KAAMSETU ONBOARDING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: KsColors.secondary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'आप KaamSetu पर क्या करना चाहते हैं?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: KsColors.primary,
            ),
          ),
          const Text(
            'What would you like to do?',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: KsColors.muted,
            ),
          ),
          const Text(
            'Choose your role to personalize your experience. No paperwork or formal résumé required.',
            style: TextStyle(color: KsColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _RoleCard(
            selected: sel == UserRole.worker,
            badge: 'लोकप्रिय • Most Popular',
            title: 'मुझे काम चाहिए',
            sub: 'I Want Work',
            desc: 'इलेक्ट्रीशियन, प्लंबर, मिस्त्री, पेंटर, बढ़ई, हेल्पर आदि',
            points: const [
              'दैनिक पारिश्रमिक • Daily wage opportunities',
              'सीधे मालिक से बात • Direct employer contact',
              'डिजिटल स्किल पासपोर्ट • Digital Skill Passport',
            ],
            icon: Icons.construction,
            onTap: () => ctl.setRole(UserRole.worker),
          ),
          _RoleCard(
            selected: sel == UserRole.employer,
            badge: 'मालिक / ठेकेदार • Hirer',
            title: 'मुझे कारीगर चाहिए',
            sub: 'I Want to Hire',
            desc:
                'घर, निर्माण कार्य या प्रोजेक्ट के लिए सत्यापित कामगार ढूंढें',
            points: const [
              'आसपास तुरंत उपलब्धता • Instant nearby availability',
              'कोई कमीशन नहीं • Zero brokerage, fair wages',
            ],
            icon: Icons.groups_outlined,
            onTap: () => ctl.setRole(UserRole.employer),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KsColors.successBg.withOpacity(.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'कामसेतु का वादा: कोई फ़ीस नहीं, सीधा संपर्क और लिखित पारिश्रमिक रिकॉर्ड।',
              style: TextStyle(fontSize: 12.5, color: KsColors.primary),
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
                  ctl.setOnboarded(true);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                sel == UserRole.worker
                    ? 'Continue as Worker'
                    : 'Continue as Employer',
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
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    if (st.loading) return const Scaffold(body: LoadingView());
    _prefill(st);
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Passport बनाएँ • Step 3')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 130),
          children: [
            const Text(
              'बिना résumé के अपनी पहचान बनाएँ',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: KsColors.primary,
              ),
            ),
            const Text(
              'No résumé needed — just your trade and area.',
              style: TextStyle(color: KsColors.muted),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'आपका नाम • Your name *',
                hintText: 'e.g. Ramesh Patil',
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Please enter your name'
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            const Text(
              'Primary trade *',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kTrades)
                  ChoiceChip(
                    label: Text(t),
                    selected: _trade == t,
                    onSelected: (_) => setState(() => _trade = t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Additional skills (optional)',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in kTrades.where((e) => e != _trade))
                  FilterChip(
                    label: Text(t),
                    selected: _skills.contains(t),
                    onSelected: (v) =>
                        setState(() => v ? _skills.add(t) : _skills.remove(t)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Experience (years) *',
                  style: TextStyle(fontWeight: FontWeight.w800),
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
              decoration: const InputDecoration(labelText: 'Work locality *'),
              items: [
                for (final a in kAreas)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setState(() => _area = v ?? _area),
            ),
            const SizedBox(height: 12),
            Text(
              'Preferred radius: ${_radius.toStringAsFixed(0)} km',
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
              'Expected pay: ₹${_pay.toStringAsFixed(0)}/day',
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
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: KsColors.successDeep),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Work photos & audio intro are optional and can be added later from Skill Passport.',
                        style: TextStyle(fontSize: 12.5),
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
                  child: const Text('Back'),
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
                        'Please fill required fields',
                        error: true,
                      );
                      return;
                    }
                    final ctl = ref.read(appControllerProvider.notifier);
                    final w = st.currentWorker;
                    await ctl.upsertWorkerProfile(
                      w.copyWith(
                        primaryTrade: _trade,
                        additionalSkills: _skills.toList(),
                        experienceYears: _exp,
                        workArea: _area,
                        preferredRadiusKm: _radius,
                        preferredPay: _pay,
                      ),
                    );
                    // update display name
                    if (_name.text.trim().isNotEmpty) {
                      await ctl.renameCurrentWorker(_name.text.trim());
                    }
                    await ctl.setOnboarded(true);
                    if (!context.mounted) return;
                    showFeedback(context, 'Skill Passport saved ✓');
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('Preview & Save Passport'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
