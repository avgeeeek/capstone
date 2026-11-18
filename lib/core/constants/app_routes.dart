class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String pendingApproval = '/pending-approval';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';

  // Student Routes
  static const String studentHome = '/student/home';
  static const String stallMenu = '/student/menu';
  static const String cart = '/student/cart';
  static const String checkout = '/student/checkout';
  static const String orderTracking = '/student/order-tracking';
  static const String orderHistory = '/student/order-history';
  static const String studentNotifications = '/student/notifications';
  static const String search = '/student/search';
  static const String reviews = '/student/reviews';

  // Vendor Routes
  static const String vendorDashboard = '/vendor/dashboard';
  static const String vendorOnboarding = '/vendor/onboarding';
  static const String menuManagement = '/vendor/menu-management';
  static const String addMenuItem = '/vendor/add-menu-item';
  static const String editMenuItem = '/vendor/edit-menu-item';
  static const String qrScanner = '/vendor/qr-scanner';
  static const String analytics = '/vendor/analytics';
  static const String vendorProfile = '/vendor/profile';
}
