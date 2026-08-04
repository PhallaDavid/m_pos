import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_translations.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedLanguage = 'Khmer';

  String _t(String khmerText, String englishText) {
    return AppTranslations.tr(_selectedLanguage, khmerText, englishText);
  }

  void _toggleLanguage() {
    setState(() {
      _selectedLanguage = _selectedLanguage == 'Khmer' ? 'English' : 'Khmer';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Language Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Logo & Name
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Text(
                        'mPOS Terminal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  // Language Toggle Switcher Pill
                  GestureDetector(
                    onTap: _toggleLanguage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            size: 15,
                            color: AppColors.heading,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _selectedLanguage == 'Khmer' ? 'ខ្មែរ' : 'ENG',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Middle Hero Illustration & Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Terminal Hero Icon Graphic Container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF5FB),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight, width: 1.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Feature Title
                    Text(
                      _t('ប្រព័ន្ធគ្រប់គ្រងលក់\nmPOS Terminal', 'Smart Merchant\nPOS Terminal'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.heading,
                        height: 1.25,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 14.0),

                    // Feature Subtitle
                    Text(
                      _t(
                        'ប្រព័ន្ធទូទាត់ និង គ្រប់គ្រងការលក់រហ័ស សុវត្ថិភាព សម្រាប់ហាងកាហ្វេ នំប៉័ង និង ហាងលក់រាយ។',
                        'Fast, secure, and modern merchant point-of-sale solution for seamless retail transactions.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Trust Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge(Icons.shield_outlined, _t('សុវត្ថិភាព 100%', 'Secure PCI-DSS')),
                        const SizedBox(width: 12),
                        _buildBadge(Icons.bolt_rounded, _t('រហ័សទាន់ចិត្ត', 'Real-time Sync')),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
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
                  const SizedBox(height: 16.0),
                  Text(
                    _t('កំណែប្រព័ន្ធ v1.2.4 • PCI DSS Compliant', 'Version 1.2.4 • PCI DSS Compliant Gateway'),
                    style: const TextStyle(
                      fontSize: 12,
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

  Widget _buildBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}
