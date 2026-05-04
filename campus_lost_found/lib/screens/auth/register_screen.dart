import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Per-field error dari API (422)
  Map<String, dynamic>? _apiErrors;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _getApiError(String field) {
    if (_apiErrors == null) return null;
    final errors = _apiErrors![field];
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    return null;
  }

  Future<void> _handleRegister() async {
    // Clear previous API errors
    setState(() => _apiErrors = null);

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful! Please sign in'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context); // Go back to LoginScreen
    } else {
      if (result['errors'] != null) {
        // Show per-field validation errors
        setState(() => _apiErrors = result['errors']);
        // Re-validate form to show API errors
        _formKey.currentState!.validate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: AppColors.textMuted),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === Hero Area (lebih kecil) ===
            Container(
              width: double.infinity,
              height: screenHeight * 0.28,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    // Icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Campus Lost & Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === Card Form ===
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Register to report lost items',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nama Field
                          const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(hint: 'Enter your full name', prefixIcon: Icons.person_outline),
                            validator: (value) {
                              final apiError = _getApiError('name');
                              if (apiError != null) return apiError;
                              if (value == null || value.trim().isEmpty) return 'Name is required';
                              if (value.trim().length < 3) return 'Name must be at least 3 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(hint: 'nama@email.com', prefixIcon: Icons.email_outlined),
                            validator: (value) {
                              final apiError = _getApiError('email');
                              if (apiError != null) return apiError;
                              if (value == null || value.trim().isEmpty) return 'Email is required';
                              if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Invalid email format';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(
                              hint: 'At least 8 characters',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (value) {
                              final apiError = _getApiError('password');
                              if (apiError != null) return apiError;
                              if (value == null || value.isEmpty) return 'Password is required';
                              if (value.length < 8) return 'Password must be at least 8 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          const Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: _inputDecoration(
                              hint: 'Re-enter your password',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please confirm your password';
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Register Button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return LoadingButton(
                                onPressed: _handleRegister,
                                isLoading: auth.isLoading,
                                label: 'Register',
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
