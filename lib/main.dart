import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/fcm_service.dart';
import 'data/services/payment_service.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/vendor_repository.dart';
import 'data/repositories/menu_repository.dart';
import 'data/repositories/order_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/cart_provider.dart';
import 'logic/providers/order_provider.dart';
import 'logic/providers/vendor_provider.dart';
import 'routes/app_router.dart';

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

  runApp(CampusEatsApp(fcmService: fcmService));
}

class CampusEatsApp extends StatelessWidget {
  final FcmService fcmService;

  const CampusEatsApp({super.key, required this.fcmService});

  @override
  Widget build(BuildContext context) {
    // Services
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final storageService = StorageService();
    final paymentService = PaymentService();

    // Repositories
    final authRepository = AuthRepository(authService);
    final vendorRepository = VendorRepository(firestoreService);
    final menuRepository = MenuRepository();
    final orderRepository = OrderRepository();
    final notificationRepository = NotificationRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository, fcmService)..init(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(orderRepository, fcmService),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProvider(
            vendorRepository,
            orderRepository,
            fcmService,
          ),
        ),
        Provider.value(value: authService),
        Provider.value(value: firestoreService),
        Provider.value(value: fcmService),
        Provider.value(value: storageService),
        Provider.value(value: paymentService),
        Provider.value(value: authRepository),
        Provider.value(value: vendorRepository),
        Provider.value(value: menuRepository),
        Provider.value(value: orderRepository),
        Provider.value(value: notificationRepository),
      ],
      child: MaterialApp(
        title: 'CampusEats',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
