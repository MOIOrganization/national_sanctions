import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/individuals_page.dart';
import 'theme/app_theme.dart';
import 'widgets/header.dart';
import 'widgets/navbar.dart';
import 'pages/entities_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const NationalSanctionsApp());
}

class NationalSanctionsApp extends StatelessWidget {
  const NationalSanctionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'National Sanctions',
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

  String get _pageTitle {
    switch (_currentIndex) {
      case 1:
        return 'Individuals';
      case 2:
        return 'Entities';
      case 3:
        return 'About';
      default:
        return 'National Sanctions';
    }
  }

  List<Widget> get _pages {
    return [
      HomePage(
        onOpenIndividuals: () {
          _changePage(1);
        },
        onOpenEntities: () {
          _changePage(2);
        },
      ),
      const IndividualsPage(),
      const EntitiesPage(),
      // const AboutPage(),
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
