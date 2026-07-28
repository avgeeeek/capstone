import 'package:flutter/material.dart';
import '../core/constants/app_routes.dart';
import '../presentation/common/splash_screen.dart';
import '../presentation/common/login_screen.dart';
import '../presentation/common/register_screen.dart';
import '../presentation/common/role_selection_screen.dart';
import '../presentation/common/forgot_password_screen.dart';
import '../presentation/common/profile_screen.dart';
import '../presentation/student/home/student_home_screen.dart';
import '../presentation/student/menu/menu_screen.dart';
import '../presentation/student/cart/cart_screen.dart';
import '../presentation/student/checkout/checkout_screen.dart';
import '../presentation/student/orders/order_tracking_screen.dart';
import '../presentation/student/orders/order_history_screen.dart';
import '../presentation/student/notifications/notifications_screen.dart';
import '../presentation/vendor/dashboard/vendor_dashboard_screen.dart';
import '../presentation/vendor/menu_management/menu_management_screen.dart';
import '../presentation/vendor/menu_management/add_item_screen.dart';
import '../presentation/vendor/menu_management/edit_item_screen.dart';
import '../presentation/vendor/qr_scanner/qr_scanner_screen.dart';
import '../presentation/vendor/analytics/analytics_screen.dart';
import '../data/models/menu_item_model.dart';
import '../data/models/vendor_model.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _build(const SplashScreen(), settings);
      case AppRoutes.login:
        return _build(const LoginScreen(), settings);
      case AppRoutes.register:
        return _build(const RegisterScreen(), settings);
      case AppRoutes.roleSelection:
        return _build(const RoleSelectionScreen(), settings);
      case AppRoutes.forgotPassword:
        return _build(const ForgotPasswordScreen(), settings);
      case AppRoutes.profile:
        return _build(const ProfileScreen(), settings);

      // Student
      case AppRoutes.studentHome:
        return _build(const StudentHomeScreen(), settings);
      case AppRoutes.stallMenu:
        final vendor = settings.arguments as VendorModel;
        return _build(MenuScreen(vendor: vendor), settings);
      case AppRoutes.cart:
        return _build(const CartScreen(), settings);
      case AppRoutes.checkout:
        return _build(const CheckoutScreen(), settings);
      case AppRoutes.orderTracking:
        final orderId = settings.arguments as String;
        return _build(OrderTrackingScreen(orderId: orderId), settings);
      case AppRoutes.orderHistory:
        return _build(const OrderHistoryScreen(), settings);
      case AppRoutes.studentNotifications:
        return _build(const NotificationsScreen(), settings);

      // Vendor
      case AppRoutes.vendorDashboard:
        return _build(const VendorDashboardScreen(), settings);
      case AppRoutes.menuManagement:
        return _build(const MenuManagementScreen(), settings);
      case AppRoutes.addMenuItem:
        return _build(const AddItemScreen(), settings);
      case AppRoutes.editMenuItem:
        final item = settings.arguments as MenuItemModel;
        return _build(EditItemScreen(item: item), settings);
      case AppRoutes.qrScanner:
        return _build(const QrScannerScreen(), settings);
      case AppRoutes.analytics:
        return _build(const AnalyticsScreen(), settings);

      default:
        return _build(
          Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
