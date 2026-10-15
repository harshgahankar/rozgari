import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/i18n/strings.dart';
import '../core/widgets/common.dart';
import '../data/models/enums.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'splash.dart';
import '../features/onboarding/onboarding.dart';
import '../features/worker/worker_home.dart';
import '../features/worker/worker_more.dart';
import '../features/employer/employer.dart';
import '../features/agreements/agreement.dart';

/// Demo-role navigation guard (§21): worker screens never run employer
/// actions and vice versa. Offers a one-tap identity switch instead.
class RoleGuard extends ConsumerWidget {
  final UserRole role;
  final Widget child;
  const RoleGuard({super.key, required this.role, required this.child});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    if (st.role == role) return child;
    final wantWorker = role == UserRole.worker;
    return Scaffold(
      appBar: AppBar(),
      body: EmptyView(
        icon: Icons.lock_outline,
        title: tr(st.lang, 'wrongRole'),
        subtitle: tr(st.lang, wantWorker ? 'roleWorker' : 'roleEmployer'),
        actionLabel: tr(
          st.lang,
          wantWorker ? 'switchToWorker' : 'switchToEmployer',
        ),
        onAction: () async {
          final ctl = ref.read(appControllerProvider.notifier);
          if (wantWorker) {
            await ctl.switchWorker(st.currentWorkerId);
          } else {
            await ctl.switchEmployer(st.currentEmployerId);
          }
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
          }
        },
      ),
    );
  }
}

class RozgariApp extends ConsumerWidget {
  const RozgariApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Offline language: whole app rebuilds in EN or HI on switch.
    final lang = ref.watch(appControllerProvider.select((s) => s.lang));
    return MaterialApp(
      title: tr(lang, 'appName'),
      debugShowCheckedModeBanner: false,
      theme: rozgariTheme(),
      locale: Locale(lang),
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (s) {
        final notFoundTitle = tr(lang, 'routeNotFound');
        final homeLabel = tr(lang, 'homeBtn');
        Widget page;
        switch (s.name) {
          case '/':
            page = const SplashScreen();
            break;
          case '/language':
            page = const LanguageScreen();
            break;
          case '/landing':
            page = const LandingScreen();
            break;
          case '/role':
            page = const RoleScreen();
            break;
          case '/profile':
            page = const RoleGuard(
              role: UserRole.worker,
              child: WorkerProfileFormScreen(),
            );
            break;
          case '/preview':
            page = const RoleGuard(
              role: UserRole.worker,
              child: PassportPreviewScreen(),
            );
            break;
          case '/eonboard':
            page = const RoleGuard(
              role: UserRole.employer,
              child: EmployerOnboardingScreen(),
            );
            break;
          case '/home':
            page = const HomeShell();
            break;
          case '/job':
            page = RoleGuard(
              role: UserRole.worker,
              child: JobDetailScreen(jobId: s.arguments as String),
            );
            break;
          case '/myjobs':
            page = const RoleGuard(
              role: UserRole.worker,
              child: MyJobsScreen(),
            );
            break;
          case '/passport':
            page = const RoleGuard(
              role: UserRole.worker,
              child: PassportScreen(),
            );
            break;
          case '/voice':
            page = const RoleGuard(role: UserRole.worker, child: VoiceScreen());
            break;
          case '/safety':
            page = const RoleGuard(
              role: UserRole.worker,
              child: SafetyScreen(),
            );
            break;
          case '/report':
            page = RoleGuard(
              role: UserRole.worker,
              child: ReportScreen(jobId: s.arguments as String),
            );
            break;
          case '/welfare':
            page = const RoleGuard(
              role: UserRole.worker,
              child: WelfareScreen(),
            );
            break;
          case '/notifications':
            page = const NotificationsScreen();
            break;
          case '/agreement':
            page = AgreementScreen(agreementId: (s.arguments as String?) ?? '');
            break;
          case '/post':
            page = RoleGuard(
              role: UserRole.employer,
              child: PostJobScreen(jobId: s.arguments as String?),
            );
            break;
          case '/eapplications':
            page = RoleGuard(
              role: UserRole.employer,
              child: EmployerApplicationsScreen(jobId: s.arguments as String),
            );
            break;
          case '/echowk':
            page = const RoleGuard(
              role: UserRole.employer,
              child: EmployerChowkScreen(),
            );
            break;
          case '/epassport':
            page = RoleGuard(
              role: UserRole.employer,
              child: EmployerPassportScreen(workerId: s.arguments as String),
            );
            break;
          case '/eprofile':
            page = const RoleGuard(
              role: UserRole.employer,
              child: EmployerProfileScreen(),
            );
            break;
          case '/eagreements':
            page = const RoleGuard(
              role: UserRole.employer,
              child: EmployerAgreementsScreen(),
            );
            break;
          default:
            page = Scaffold(
              appBar: AppBar(),
              body: EmptyView(
                icon: Icons.error_outline,
                title: notFoundTitle,
                subtitle: '${s.name}',
                actionLabel: homeLabel,
                onAction: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (_) => false,
                ),
              ),
            );
        }
        return MaterialPageRoute(builder: (_) => page, settings: s);
      },
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final lang = st.lang;
    final isWorker = st.role == UserRole.worker;
    return DefaultTabController(
      length: isWorker ? 3 : 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KsColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.handshake,
                  color: KsColors.secondaryContainer,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(lang, 'appName'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    tr(lang, 'tagline'),
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: KsColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // language switcher — EN/HI only, offline, whole-app switch
            PopupMenuButton<String>(
              tooltip: tr(lang, 'language'),
              icon: const Icon(Icons.translate_outlined),
              onSelected: (v) {
                ctl.setLang(v);
                if (context.mounted) {
                  showFeedback(context, trArgs(lang, 'langChanged', {'v': v}));
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'hi', child: Text(tr(lang, 'hindi'))),
                PopupMenuItem(value: 'en', child: Text(tr(lang, 'english'))),
              ],
            ),
            IconButton(
              tooltip: tr(lang, 'demoControls'),
              icon: const Icon(Icons.science_outlined),
              onPressed: () => _demoSheet(context, ref),
            ),
          ],
          bottom: TabBar(
            tabs: isWorker
                ? [
                    Tab(
                      icon: const Icon(Icons.home_outlined),
                      text: tr(lang, 'home'),
                    ),
                    Tab(
                      icon: const Icon(Icons.search),
                      text: tr(lang, 'jobsTab'),
                    ),
                    Tab(
                      icon: const Icon(Icons.groups_outlined),
                      text: tr(lang, 'chowkTab'),
                    ),
                  ]
                : [
                    Tab(
                      icon: const Icon(Icons.dashboard_outlined),
                      text: tr(lang, 'home'),
                    ),
                    Tab(
                      icon: const Icon(Icons.groups_outlined),
                      text: tr(lang, 'chowkTab'),
                    ),
                    Tab(
                      icon: const Icon(Icons.receipt_long_outlined),
                      text: tr(lang, 'workTab'),
                    ),
                  ],
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                ListTile(
                  title: Text(
                    st.role == UserRole.worker
                        ? st.currentWorkerUser.name
                        : st.currentEmployerUser.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    isWorker
                        ? '${tr(lang, 'worker')} • ${st.currentWorker.primaryTrade}'
                        : '${tr(lang, 'employer')} • ${st.currentEmployer.businessName.isEmpty ? st.currentEmployerUser.name : st.currentEmployer.businessName}',
                  ),
                ),
                const Divider(),
                if (isWorker) ...[
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(tr(lang, 'passport')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/passport');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_history_outlined),
                    title: Text(tr(lang, 'myJobs')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/myjobs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.mic_none),
                    title: Text(tr(lang, 'voiceFull')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/voice');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(tr(lang, 'safety')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/safety');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: Text(tr(lang, 'welfare')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/welfare');
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(tr(lang, 'postAJob')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/post');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.store_outlined),
                    title: Text(tr(lang, 'eProfileTitle')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/eprofile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(tr(lang, 'agreementsPayments')),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/eagreements');
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(
                    '${tr(lang, 'notifications')} (${st.unreadFor(isWorker ? st.currentWorkerId : st.currentEmployerId)})',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh_outlined),
                  title: Text(tr(lang, 'resetDemo')),
                  subtitle: Text(tr(lang, 'resetDemoSub1')),
                  onTap: () async {
                    await ctl.resetDemo();
                    if (context.mounted) {
                      Navigator.pop(context);
                      showFeedback(context, tr(lang, 'demoRestored'));
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt_outlined),
                  title: Text(tr(lang, 'restartOnboarding')),
                  onTap: () async {
                    await ctl.setOnboarded(false);
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (_) => false,
                      );
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    tr(lang, 'simNote'),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: KsColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: isWorker
              ? const [WorkerDashboard(), JobsTab(), ChowkTab()]
              : const [
                  EmployerDashboard(),
                  EmployerChowkScreen(),
                  EmployerAgreementsScreen(),
                ],
        ),
      ),
    );
  }

  void _demoSheet(BuildContext context, WidgetRef ref) {
    final st = ref.read(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    final lang = st.lang;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr(lang, 'demoControls'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: KsColors.primary,
                ),
              ),
              Text(
                tr(lang, 'demoControlsSub'),
                style: const TextStyle(fontSize: 12, color: KsColors.muted),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.construction),
                title: Text(tr(lang, 'switchWorker')),
                subtitle: Text(
                  st.currentWorkerId == 'w01' ? tr(lang, 'active') : '',
                  style: const TextStyle(color: KsColors.successDeep),
                ),
                onTap: () async {
                  await ctl.switchWorker('w01');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store_outlined),
                title: Text(tr(lang, 'switchEmployer')),
                subtitle: Text(
                  st.currentEmployerId == 'e01' ? tr(lang, 'active') : '',
                  style: const TextStyle(color: KsColors.successDeep),
                ),
                onTap: () async {
                  await ctl.switchEmployer('e01');
                  await ctl.setRole(UserRole.employer);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz_outlined),
                title: Text(
                  trArgs(lang, 'currentRole', {
                    'r': codeLabel(lang, st.role.name),
                  }),
                ),
                onTap: () async {
                  await ctl.setRole(
                    st.role == UserRole.worker
                        ? UserRole.employer
                        : UserRole.worker,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_outlined),
                title: Text(tr(lang, 'resetDemo')),
                subtitle: Text(tr(lang, 'resetDemoSub2')),
                onTap: () async {
                  await ctl.resetDemo();
                  if (context.mounted) {
                    Navigator.pop(context);
                    showFeedback(context, tr(lang, 'demoRestored'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
