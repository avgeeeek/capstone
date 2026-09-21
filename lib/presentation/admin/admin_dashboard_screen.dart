import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/providers/auth_provider.dart';

import 'admin_users_tab.dart';
import 'admin_orders_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                }
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pending Students'),
              Tab(text: 'All Users'),
              Tab(text: 'All Orders'),
              Tab(text: 'Create Vendor'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingStudentsTab(),
            AdminUsersTab(),
            AdminOrdersTab(),
            _CreateVendorTab(),
          ],
        ),
      ),
    );
  }
}

class _PendingStudentsTab extends StatelessWidget {
  const _PendingStudentsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(ApiConstants.usersCollection)
          .where('role', isEqualTo: ApiConstants.roleStudent)
          .where('isApproved', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No pending students', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = UserModel.fromSnapshot(docs[index]);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${user.email}\n${user.collegeId}'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () => _approveUser(context, user.id),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.usersCollection)
          .doc(uid)
          .update({'isApproved': true});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student approved'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _CreateVendorTab extends StatefulWidget {
  const _CreateVendorTab();

  @override
  State<_CreateVendorTab> createState() => _CreateVendorTabState();
}

class _CreateVendorTabState extends State<_CreateVendorTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _createVendorAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // NOTE: Creating an auth user while logged in as Admin will log the Admin out 
      // in Firebase Auth by default if using standard createUserWithEmailAndPassword.
      // For a real prod app, you'd use a Cloud Function to create accounts without 
      // affecting the client auth state. 
      // As a workaround for this MVP, we just create the user in Firestore directly
      // and tell them to use "Forgot Password" or they can be created by cloud function.
      // Let's implement the standard way and warn the admin they might need to log back in.
      
      final authService = context.read<AuthProvider>();
      await authService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: ApiConstants.roleVendor,
        collegeId: '', // vendors don't need this
      );
      
      // Because registering logs the new user in, we need to sign them out and go to login.
      await authService.signOut();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vendor created! You have been logged out.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Vendor Account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'This creates the Vendor login. They will complete stall setup when they first log in.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Vendor Name (Owner)',
              hint: 'John Doe',
              controller: _nameCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Email',
              hint: 'vendor@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Phone Number',
              hint: '9876543210',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'Temporary Password',
              hint: 'Min 6 characters',
              controller: _passwordCtrl,
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Too short' : null,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Create Vendor',
              onPressed: _isLoading ? null : _createVendorAccount,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
