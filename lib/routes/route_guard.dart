import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/providers/auth_provider.dart';
import '../core/constants/app_routes.dart';

class RouteGuard extends StatelessWidget {
  final Widget child;

  const RouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.status == AuthStatus.unauthenticated ||
            auth.status == AuthStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return child;
      },
    );
  }
}
