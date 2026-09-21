import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/fcm_service.dart';
import 'data/services/payment_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/vendor_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/search_repository.dart';
import 'data/repositories/admin_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/vendor_provider.dart';
import 'logic/providers/cart_provider.dart';
import 'logic/providers/order_provider.dart';
import 'logic/providers/review_provider.dart';
import 'routes/app_router.dart';

// Services & repos created once in main() — not recreated on rebuild
late final AuthService _authService;
late final AuthRepository _authRepository;
late final VendorRepository _vendorRepo;
late final MenuRepository _menuRepo;
late final OrderRepository _orderRepo;
late final ReviewRepository _reviewRepo;
late final SearchRepository _searchRepo;
late final AdminRepository _adminRepo;
late final NotificationRepository _notifRepo;
late final PaymentService _paymentService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In (required for google_sign_in v7.x)
  await GoogleSignIn.instance.initialize(
    serverClientId: '66391236956-e38muk5m0t4ajfpidnmoaogev6tjla68.apps.googleusercontent.com',
  );

  // Initialize FCM
  final fcmService = FcmService();
  await fcmService.initialize();

  // Instantiate services & repos once
  _authService = AuthService();
  _paymentService = PaymentService();
  _authRepository = AuthRepository(_authService);
  _vendorRepo = VendorRepository();
  _menuRepo = MenuRepository();
  _orderRepo = OrderRepository();
  _reviewRepo = ReviewRepository();
  _searchRepo = SearchRepository();
  _adminRepo = AdminRepository();
  _notifRepo = NotificationRepository();

  runApp(CampusEatsApp(fcmService: fcmService));
}

class CampusEatsApp extends StatelessWidget {
  final FcmService fcmService;

  const CampusEatsApp({super.key, required this.fcmService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<VendorRepository>.value(value: _vendorRepo),
        Provider<MenuRepository>.value(value: _menuRepo),
        Provider<OrderRepository>.value(value: _orderRepo),
        Provider<ReviewRepository>.value(value: _reviewRepo),
        Provider<SearchRepository>.value(value: _searchRepo),
        Provider<AdminRepository>.value(value: _adminRepo),
        Provider<NotificationRepository>.value(value: _notifRepo),

        // Services
        Provider<FcmService>.value(value: fcmService),
        Provider<PaymentService>.value(value: _paymentService),
        Provider<AuthService>.value(value: _authService),

        // State providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(_authRepository, fcmService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProvider(_vendorRepo, _orderRepo, fcmService),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(_orderRepo, fcmService),
        ),
        ChangeNotifierProvider(create: (_) => ReviewProvider(_reviewRepo)),
      ],
      child: MaterialApp(
        title: 'GrabNgo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
