import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_toast.dart';
import '../widgets/primary_button.dart';
import '../widgets/rounded_text_field.dart';
import 'home_screen.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@merchant.com');
  final _passwordController = TextEditingController(text: 'securepassword');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService.login(_emailController.text, _passwordController.text);
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          AppToast.show(
            context,
            e.toString().replaceAll('Exception: ', ''),
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Slate 200
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.heading,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 6.0),
                const Text(
                  'Sign in to access your merchant dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32.0),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RoundedTextField(
                        controller: _emailController,
                        hintText: 'email@merchant.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      RoundedTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Password is required';
                          if (value.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28.0),
                      PrimaryButton(
                        text: 'Log In',
                        isLoading: _isLoading,
                        onPressed: _handleLogin,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48.0),

                // Footer
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'v1.2.4',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        'Developed by Phalla David',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
