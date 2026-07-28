import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _collegeIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _collegeIdCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: _selectedRole,
      collegeId: _collegeIdCtrl.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        _selectedRole == 'vendor'
            ? AppRoutes.vendorDashboard
            : AppRoutes.studentHome,
        (r) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.textPrimary),
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join CampusEats 🎓',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fill in your details to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 28),

                // Role Selector
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      _roleButton('student', '🎓 Student'),
                      _roleButton('vendor', '🏪 Vendor'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameCtrl,
                  validator: Validators.validateName,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Email',
                  hint: 'your@college.edu',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Phone Number',
                  hint: '9876543210',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: _selectedRole == 'vendor' ? 'Stall Name' : 'College ID',
                  hint: _selectedRole == 'vendor' ? 'e.g. Spice Garden' : 'e.g. 2021CS001',
                  controller: _collegeIdCtrl,
                  validator: Validators.validateCollegeId,
                  prefixIcon: Icon(
                    _selectedRole == 'vendor' ? Icons.store_outlined : Icons.badge_outlined,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  controller: _passwordCtrl,
                  obscureText: true,
                  validator: Validators.validatePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordCtrl,
                  obscureText: true,
                  validator: (v) => Validators.validateConfirmPassword(v, _passwordCtrl.text),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'Create Account',
                  onPressed: auth.isLoading ? null : _register,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final success = await auth.loginWithGoogle();
                            if (!mounted) return;
                            if (success) {
                              Navigator.pushReplacementNamed(context, AppRoutes.splash);
                            } else if (auth.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.errorMessage!)),
                              );
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: AppColors.divider, width: 1.5),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/google.svg', height: 22),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign up with Google',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleButton(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
