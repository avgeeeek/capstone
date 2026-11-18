import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(_emailCtrl.text.trim());
    setState(() {
      _loading = false;
      _sent = success;
    });
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to send reset email'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🔐', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 20),
          const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your email and we'll send you a reset link.",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Email',
            hint: 'your@college.edu',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send Reset Link',
            onPressed: _loading ? null : _sendReset,
            isLoading: _loading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✉️', style: TextStyle(fontSize: 72)),
        const SizedBox(height: 24),
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to ${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
