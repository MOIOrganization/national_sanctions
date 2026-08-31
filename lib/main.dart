import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_controller.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/national/national_sanctions_page.dart';
import 'pages/un/un_entities_page.dart';
import 'pages/un/un_individuals_page.dart';
import 'pages/un/un_sanctions_page.dart';
import 'services/notification_service.dart';
import 'session/session_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/header.dart';
import 'widgets/navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await NotificationService.initialize();
  }

  runApp(const NationalSanctionsApp());
}

class NationalSanctionsApp extends StatefulWidget {
  const NationalSanctionsApp({super.key});

  @override
  State<NationalSanctionsApp> createState() => _NationalSanctionsAppState();
}

class _NationalSanctionsAppState extends State<NationalSanctionsApp> {
  final AppLocaleController _localeController = AppLocaleController();
  final SessionController _sessionController = SessionController();

  @override
  void initState() {
    super.initState();
    _localeController.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeController.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      controller: _localeController,
      child: SessionScope(
        controller: _sessionController,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sanctions',
          theme: AppTheme.lightTheme,
          locale: _localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final SessionController session = SessionScope.of(context);

    if (session.isSignedIn) {
      return const MainScreen();
    }

    return const LoginPage();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openIndividuals() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _IndividualsScreen()),
    );
  }

  void _openEntities() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _EntitiesScreen()),
    );
  }

  String _pageTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 1:
        return l10n.unSanctions;
      case 2:
        return l10n.nationalSanctions;
      default:
        return l10n.appTitle;
    }
  }

  List<Widget> get _pages {
    return [
      HomePage(
        onOpenUnitedNations: () {
          _changePage(1);
        },
        onOpenNationalSanctions: () {
          _changePage(2);
        },
      ),
      UnSanctionsPage(
        onOpenIndividuals: _openIndividuals,
        onOpenEntities: _openEntities,
      ),
      const NationalSanctionsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: Header(title: _pageTitle(l10n)),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppNavbar(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}

class _IndividualsScreen extends StatelessWidget {
  const _IndividualsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: AppLocalizations.of(context).individuals,
        showBackButton: true,
      ),
      body: const IndividualsPage(),
    );
  }
}

class _EntitiesScreen extends StatelessWidget {
  const _EntitiesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: AppLocalizations.of(context).entities,
        showBackButton: true,
      ),
      body: const EntitiesPage(),
    );
  }
}
