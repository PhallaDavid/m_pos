import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_translations.dart';
import '../widgets/wave_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final String _selectedLanguage = 'Khmer';

  String _t(String khmerText, String englishText) {
    return AppTranslations.tr(_selectedLanguage, khmerText, englishText);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Organic Fluid Wave Header Area (matching Screen 1 in reference)
            WaveHeaderWidget(
              height: screenHeight * 0.68,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Brand Header Title
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.point_of_sale_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        const Text(
                          'mPOS Terminal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),

                    // Main Welcome Text Block
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('ប្រព័ន្ធគ្រប់គ្រងលក់\nmPOS Terminal', 'Smart Merchant\nPOS Terminal'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.25,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            _t(
                              'ប្រព័ន្ធទូទាត់ និង គ្រប់គ្រងការលក់រហ័ស សុវត្ថិភាព សម្រាប់ហាងកាហ្វេ នំប៉័ង និង ហាងលក់រាយ។',
                              'Fast, secure, and modern merchant point-of-sale solution for seamless retail transactions.',
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Area with Log In & Sign Up Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _t('ចូលប្រព័ន្ធ (Log In)', 'Log In'),
                    icon: const Icon(Icons.login_rounded, size: 20, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12.0),
                  // SecondaryButton(
                  //   text: _t('ចូលប្រព័ន្ធសាកល្បង (Explore Terminal)', 'Explore Terminal Demo'),
                  //   onPressed: () {
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const HomeScreen(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 20.0),
                  Text(
                    _t('កំណែប្រព័ន្ធ v1.2.4 • PCI DSS Compliant', 'Version 1.2.4 • PCI DSS Compliant Gateway'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
