import 'package:flutter/material.dart';

import 'pages/about_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/sanctions_page.dart';
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

  String get _pageTitle {
    switch (_currentIndex) {
      case 1:
        return 'Sanctions';
      case 2:
        return 'About';
      default:
        return 'Home';
    }
  }

  List<Widget> get _pages {
    return [
      HomePage(
        onOpenSanctions: () {
          _changePage(1);
        },
      ),
      const SanctionsPage(),
      const AboutPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: _pageTitle),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppNavbar(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}
