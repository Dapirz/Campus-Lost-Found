import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final wantsPasswordChange =
        _currentPasswordController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _passwordConfirmationController.text.isNotEmpty;

    final result = await context.read<AuthProvider>().updateProfile(
      name: _nameController.text.trim(),
      currentPassword: wantsPasswordChange
          ? _currentPasswordController.text
          : null,
      password: wantsPasswordChange ? _passwordController.text : null,
      passwordConfirmation: wantsPasswordChange
          ? _passwordConfirmationController.text
          : null,
    );

    if (!mounted) return;

    String snackBarMessage;
    if (result['success'] == true) {
      snackBarMessage = wantsPasswordChange
          ? 'Password berhasil diupdate'
          : (result['message'] ?? 'Profil berhasil diupdate');
    } else {
      snackBarMessage = result['message'] ?? 'Gagal memperbarui profil';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        backgroundColor: result['success'] == true
            ? AppColors.success
            : AppColors.error,
      ),
    );

    if (result['success'] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials(user?.name ?? ''),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Full Name'),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return 'Name is required';
                    if (name.length < 3)
                      return 'Name must be at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.borderDefault),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Change Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      decoration: _passwordDecoration(
                        'Current Password',
                        _obscureCurrent,
                        () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureNew,
                      decoration: _passwordDecoration(
                        'New Password',
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (value) {
                        if (_passwordFieldsEmpty) return null;
                        if (value == null || value.length < 8) {
                          return 'New password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordConfirmationController,
                      obscureText: _obscureConfirmation,
                      decoration: _passwordDecoration(
                        'Confirm New Password',
                        _obscureConfirmation,
                        () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                      ),
                      validator: (value) {
                        if (_passwordFieldsEmpty) return null;
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  onPressed: _save,
                  isLoading: auth.isLoading,
                  label: 'Save Changes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _passwordFieldsEmpty =>
      _currentPasswordController.text.isEmpty &&
      _passwordController.text.isEmpty &&
      _passwordConfirmationController.text.isEmpty;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  InputDecoration _passwordDecoration(
    String label,
    bool obscure,
    VoidCallback onToggle,
  ) {
    return _inputDecoration(label).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
        ),
        onPressed: onToggle,
      ),
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}
