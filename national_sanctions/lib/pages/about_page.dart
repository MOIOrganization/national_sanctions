import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Icon(Icons.policy, size: 75, color: AppColors.primary),
        SizedBox(height: 18),
        Text(
          'National Sanctions',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'This application provides access to individuals and entities included in official sanctions lists.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
        ),
        SizedBox(height: 28),
        Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Disclaimer\n\nThe information displayed in this application is for reference purposes. Users must verify each record against the official publishing authority before taking legal, financial or compliance action.',
              style: TextStyle(height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
