import 'package:flutter/material.dart';

import 'pages/un/un_entities_page.dart';
import 'pages/home_page.dart';
import 'pages/un/un_individuals_page.dart';
import 'pages/login_page.dart';
import 'pages/national/national_persons_page.dart';
import 'pages/national/national_sanctions_page.dart';
import 'pages/un/un_sanctions_page.dart';
import 'theme/app_theme.dart';
import 'widgets/header.dart';
import 'widgets/navbar.dart';

void main() {
  runApp(const NationalSanctionsApp());
}

class NationalSanctionsApp extends StatelessWidget {
  const NationalSanctionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sanctions',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
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

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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

  String get _pageTitle {
    switch (_currentIndex) {
      case 1:
        return 'United Nations Sanctions';

      case 2:
        return 'National Sanctions';

      default:
        return 'Sanctions';
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
    return Scaffold(
      appBar: Header(title: _pageTitle, showLogout: true, onLogout: _logout),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppNavbar(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}

// =============================================================
// INDIVIDUALS FULL SCREEN
// =============================================================

class _IndividualsScreen extends StatelessWidget {
  const _IndividualsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Individuals', showBackButton: true),
      body: const IndividualsPage(),
    );
  }
}

// =============================================================
// ENTITIES FULL SCREEN
// =============================================================

class _EntitiesScreen extends StatelessWidget {
  const _EntitiesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: 'Entities', showBackButton: true),
      body: const EntitiesPage(),
    );
  }
}
