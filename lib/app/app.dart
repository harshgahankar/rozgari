import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/common.dart';
import '../data/models/enums.dart';
import '../state/app_state.dart';
import 'theme.dart';
import '../features/onboarding/onboarding.dart';
import '../features/worker/worker_home.dart';
import '../features/worker/worker_more.dart';
import '../features/employer/employer.dart';
import '../features/agreements/agreement.dart';

class KaamSetuApp extends StatelessWidget {
  const KaamSetuApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaamSetu',
      debugShowCheckedModeBanner: false,
      theme: kaamSetuTheme(),
      initialRoute: '/',
      onGenerateRoute: (s) {
        Widget page;
        switch (s.name) {
          case '/':
            page = const RootGate();
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
            page = const WorkerProfileFormScreen();
            break;
          case '/home':
            page = const HomeShell();
            break;
          case '/job':
            page = JobDetailScreen(jobId: s.arguments as String);
            break;
          case '/myjobs':
            page = const MyJobsScreen();
            break;
          case '/passport':
            page = const PassportScreen();
            break;
          case '/voice':
            page = const VoiceScreen();
            break;
          case '/safety':
            page = const SafetyScreen();
            break;
          case '/report':
            page = ReportScreen(jobId: s.arguments as String);
            break;
          case '/welfare':
            page = const WelfareScreen();
            break;
          case '/notifications':
            page = const NotificationsScreen();
            break;
          case '/agreement':
            page = AgreementScreen(agreementId: (s.arguments as String?) ?? '');
            break;
          case '/post':
            page = const PostJobScreen();
            break;
          case '/eapplications':
            page = EmployerApplicationsScreen(jobId: s.arguments as String);
            break;
          case '/echowk':
            page = const EmployerChowkScreen();
            break;
          case '/epassport':
            page = EmployerPassportScreen(workerId: s.arguments as String);
            break;
          case '/eagreements':
            page = const EmployerAgreementsScreen();
            break;
          default:
            page = Scaffold(
              appBar: AppBar(),
              body: EmptyView(
                icon: Icons.error_outline,
                title: 'Route not found',
                subtitle: '${s.name}',
                actionLabel: 'Home',
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

class RootGate extends ConsumerWidget {
  const RootGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(appControllerProvider);
    if (st.loading)
      return const Scaffold(body: LoadingView(label: 'Loading KaamSetu demo…'));
    if (!st.onboarded) return const LanguageScreen();
    return const HomeShell();
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'कामसेतू • KaamSetu',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    'Beyond the Waiting Line',
                    style: TextStyle(fontSize: 9.5, color: KsColors.muted),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // language switcher
            PopupMenuButton<String>(
              tooltip: 'Language',
              icon: const Icon(Icons.translate_outlined),
              onSelected: (v) {
                ctl.setLang(v);
                showFeedback(context, 'Language: $v');
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'hi', child: Text('हिंदी')),
                PopupMenuItem(value: 'mr', child: Text('मराठी')),
                PopupMenuItem(value: 'en', child: Text('English')),
              ],
            ),
            IconButton(
              tooltip: 'Demo controls',
              icon: const Icon(Icons.science_outlined),
              onPressed: () => _demoSheet(context, ref),
            ),
          ],
          bottom: TabBar(
            tabs: isWorker
                ? const [
                    Tab(icon: Icon(Icons.home_outlined), text: 'Home'),
                    Tab(icon: Icon(Icons.search), text: 'Jobs'),
                    Tab(icon: Icon(Icons.groups_outlined), text: 'Chowk'),
                  ]
                : const [
                    Tab(icon: Icon(Icons.dashboard_outlined), text: 'Home'),
                    Tab(icon: Icon(Icons.groups_outlined), text: 'Chowk'),
                    Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Work'),
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
                        ? 'Worker • ${st.currentWorker.primaryTrade}'
                        : 'Employer • ${st.currentEmployer.businessName.isEmpty ? st.currentEmployerUser.name : st.currentEmployer.businessName}',
                  ),
                ),
                const Divider(),
                if (isWorker) ...[
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Skill Passport'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/passport');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.work_history_outlined),
                    title: const Text('My Jobs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/myjobs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.mic_none),
                    title: const Text('Kaam Bolo (voice)'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/voice');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined),
                    title: const Text('Kaam Suraksha'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/safety');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: const Text('Welfare Hub'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/welfare');
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Post a job'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/post');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Agreements & payments'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/eagreements');
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text(
                    'Notifications (${st.unreadFor(isWorker ? st.currentWorkerId : st.currentEmployerId)})',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/notifications');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.refresh_outlined),
                  title: const Text('Reset demo data'),
                  subtitle: const Text('Restores Ramesh • Meera • 28 jobs'),
                  onTap: () async {
                    await ctl.resetDemo();
                    if (context.mounted) {
                      Navigator.pop(context);
                      showFeedback(context, 'Demo restored ✓');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt_outlined),
                  title: const Text('Restart onboarding'),
                  onTap: () async {
                    await ctl.setOnboarded(false);
                    if (context.mounted)
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (_) => false,
                      );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'All identities, jobs, agreements & payments are simulated and stay on this device.',
                    style: TextStyle(fontSize: 11.5, color: KsColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const DemoBanner(),
            Expanded(
              child: TabBarView(
                children: isWorker
                    ? const [WorkerDashboard(), JobsTab(), ChowkTab()]
                    : const [
                        EmployerDashboard(),
                        EmployerChowkScreen(),
                        EmployerAgreementsScreen(),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _demoSheet(BuildContext context, WidgetRef ref) {
    final st = ref.read(appControllerProvider);
    final ctl = ref.read(appControllerProvider.notifier);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Demo Mode — judge controls',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: KsColors.primary,
                ),
              ),
              const Text(
                'Same central state — actions persist across role switch & restart.',
                style: TextStyle(fontSize: 12, color: KsColors.muted),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.construction),
                title: const Text(
                  'Switch to Worker: Ramesh Patil — Electrician',
                ),
                subtitle: Text(
                  st.currentWorkerId == 'w01' ? 'active' : '',
                  style: const TextStyle(color: KsColors.successDeep),
                ),
                onTap: () async {
                  await ctl.switchWorker('w01');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store_outlined),
                title: const Text('Switch to Employer: Meera Shah'),
                subtitle: Text(
                  st.currentEmployerId == 'e01' ? 'active' : '',
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
                title: Text('Current role: ${st.role.name} — tap to toggle'),
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
                title: const Text('Reset demo data'),
                subtitle: const Text(
                  'Restores 15 workers • 5 employers • 28 jobs',
                ),
                onTap: () async {
                  await ctl.resetDemo();
                  if (context.mounted) {
                    Navigator.pop(context);
                    showFeedback(context, 'Demo restored ✓');
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
