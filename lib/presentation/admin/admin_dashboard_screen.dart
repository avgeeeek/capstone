import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/vendor_model.dart';
import '../../../data/repositories/admin_repository.dart';
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
              tooltip: 'Sign Out',
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (r) => false);
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
              Tab(text: 'Vendors'),
              Tab(text: 'All Users'),
              Tab(text: 'All Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PendingStudentsTab(),
            _VendorsTab(),
            AdminUsersTab(),
            AdminOrdersTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Pending Students Tab ────────────────────────────────────────────────────

class _PendingStudentsTab extends StatelessWidget {
  const _PendingStudentsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(ApiConstants.usersCollection)
          .where('role', isEqualTo: ApiConstants.roleStudent)
          .where('isApproved', isEqualTo: false)
          .where('isRejected', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 64, color: AppColors.success),
                SizedBox(height: 12),
                Text(
                  'No pending student applications',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'All student accounts have been reviewed',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final user = UserModel.fromSnapshot(docs[index]);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person_rounded,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name.isEmpty ? 'Student' : user.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(user.email,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (user.collegeId.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.badge_rounded,
                              size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('ID: ${user.collegeId}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side:
                                  const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () =>
                                _rejectUser(context, user.id, user.name),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon:
                                const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () =>
                                _approveUser(context, user.id, user.name),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveUser(
      BuildContext context, String uid, String name) async {
    try {
      await context.read<AdminRepository>().activateUser(uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$name has been approved!'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rejectUser(
      BuildContext context, String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Student Application'),
        content: Text(
            'Are you sure you want to reject $name?\n\nThey will be notified: "You have been rejected. Please contact admin for more details."'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    try {
      await context.read<AdminRepository>().rejectUser(uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$name application was rejected.'),
              backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ─── Vendors Tab (List, Manage & Create) ───────────────────────────────────────

class _VendorsTab extends StatelessWidget {
  const _VendorsTab();

  void _showCreateVendorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _CreateVendorSheet(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminRepo = context.read<AdminRepository>();

    return Column(
      children: [
        // Header with Add Vendor button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Campus Stalls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Manage food vendor accounts & stalls',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showCreateVendorSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New Vendor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Vendor list
        Expanded(
          child: StreamBuilder<List<VendorModel>>(
            stream: adminRepo.getAllVendors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final vendors = snapshot.data ?? [];
              if (vendors.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.storefront_outlined, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      const Text('No vendors created yet',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateVendorSheet(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Create First Vendor'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  final vendor = vendors[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                                child: const Icon(Icons.storefront_rounded, color: AppColors.secondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          vendor.stallName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: vendor.isActive
                                                ? AppColors.success.withValues(alpha: 0.12)
                                                : AppColors.error.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            vendor.isActive ? 'Active' : 'Suspended',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: vendor.isActive ? AppColors.success : AppColors.error,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: vendor.isOpen
                                                ? Colors.blue.withValues(alpha: 0.12)
                                                : Colors.grey.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            vendor.isOpen ? 'Open Now' : 'Closed',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: vendor.isOpen ? Colors.blue : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (vendor.location.isNotEmpty)
                                      Text(
                                        'Location: ${vendor.location}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (action) async {
                                  if (action == 'toggle') {
                                    if (vendor.isActive) {
                                      await adminRepo.deactivateVendor(vendor.id, vendor.ownerId);
                                    } else {
                                      await adminRepo.activateVendor(vendor.id, vendor.ownerId);
                                    }
                                  } else if (action == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Vendor Stall'),
                                        content: Text('Delete "${vendor.stallName}" and all associated menu items?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await adminRepo.deleteVendor(vendor.id, vendor.ownerId);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Deleted "${vendor.stallName}"')),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Row(
                                      children: [
                                        Icon(
                                          vendor.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                          size: 18,
                                          color: vendor.isActive ? Colors.orange : AppColors.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(vendor.isActive ? 'Suspend Vendor' : 'Activate Vendor'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                        SizedBox(width: 8),
                                        Text('Delete Vendor', style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (vendor.cuisine.isNotEmpty)
                                for (final c in vendor.cuisine)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.divider),
                                    ),
                                    child: Text(c, style: const TextStyle(fontSize: 11)),
                                  ),
                              if (vendor.upiId.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('UPI: ${vendor.upiId}',
                                      style: const TextStyle(fontSize: 11, color: Colors.purple)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Create Vendor Sheet / Form ───────────────────────────────────────────────

class _CreateVendorSheet extends StatefulWidget {
  final ScrollController scrollController;
  const _CreateVendorSheet({required this.scrollController});

  @override
  State<_CreateVendorSheet> createState() => _CreateVendorSheetState();
}

class _CreateVendorSheetState extends State<_CreateVendorSheet> {
  final _formKey = GlobalKey<FormState>();

  // Account fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Stall fields
  final _stallNameCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _stallNameCtrl.dispose();
    _upiCtrl.dispose();
    _locationCtrl.dispose();
    _cuisineCtrl.dispose();
    super.dispose();
  }

  Future<void> _createVendor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final emailEntered = _emailCtrl.text.trim();
    final stallEntered = _stallNameCtrl.text.trim();

    try {
      final adminRepo = context.read<AdminRepository>();

      // Create auth user WITHOUT logging out admin (secondary Firebase App)
      final uid = await adminRepo.createVendorAccount(
        email: emailEntered,
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      // Create vendor stall document
      final cuisineList = _cuisineCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final vendor = VendorModel(
        id: uid,
        stallName: stallEntered,
        ownerId: uid,
        upiId: _upiCtrl.text.trim(),
        cuisine: cuisineList,
        isOpen: false,
        rating: 0.0,
        location: _locationCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        isActive: true,
      );

      await FirebaseFirestore.instance
          .collection(ApiConstants.vendorsCollection)
          .doc(uid)
          .set(vendor.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vendor "$stallEntered" created! Login: $emailEntered'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Make Firebase error messages user-friendly
        String msg = e.toString();
        if (msg.contains('email-already-in-use')) {
          msg = 'This email is already registered. '
              'Please use a different email address.';
        } else {
          msg = msg.replaceFirst('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text('Create New Vendor Stall',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Creates a vendor login and initializes their food stall in the app.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Section: Owner Account
              const _SectionHeader(
                  icon: Icons.person_rounded, title: 'Owner Account'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Owner Name',
                hint: 'e.g. Ravi Kumar',
                controller: _nameCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Vendor Email',
                hint: 'vendor@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    !v!.contains('@') ? 'Invalid email' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Phone Number',
                hint: '9876543210',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v!.length < 10 ? 'Enter valid phone number' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Temporary Password',
                hint: 'Min 6 characters',
                controller: _passwordCtrl,
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 20),

              // Section: Stall Details
              const _SectionHeader(
                  icon: Icons.store_rounded,
                  title: 'Stall Details'),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Stall Name',
                hint: 'e.g. Spice Garden',
                controller: _stallNameCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'UPI ID for Payments',
                hint: 'vendor@upi',
                controller: _upiCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Campus Location / Stall No.',
                hint: 'e.g. Block A, Food Court 1',
                controller: _locationCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Cuisine Types',
                hint: 'e.g. South Indian, Beverages, Snacks',
                controller: _cuisineCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 4),
              const Text(
                'Separate multiple cuisines with commas',
                style: TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Create Vendor Account',
                onPressed: _isLoading ? null : _createVendor,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }
}
