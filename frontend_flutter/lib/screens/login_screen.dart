import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_styles.dart';
import '../widgets/booking_form_ui.dart';

/// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BookingFormUi.authHero(
              title: 'Welcome Back',
              subtitle: 'Sign in to book, track cleanings, and manage your home.',
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Email field
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                _buildPasswordField(),
                const SizedBox(height: 24),
                // Login button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleLogin(context),
                        style: BookingFormUi.primaryButtonStyle(),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Google Sign In button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleGoogleSignIn(context),
                        icon: const Icon(Icons.account_circle),
                        label: const Text('Sign in with Google'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.error != null) {
                      return Container(
                        padding:
                            const EdgeInsets.all(AppStyles.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppStyles.radiusMedium),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          authProvider.error!,
                          style: AppStyles.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                // Sign up link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppStyles.bodyMedium
                            .copyWith(color: AppColors.darkGray),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed('/register'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: BookingFormUi.fieldDecoration(label, icon),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_showPassword,
          decoration: BookingFormUi.fieldDecoration('Password', Icons.lock_outline).copyWith(
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _showPassword = !_showPassword),
              child: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.loginWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
