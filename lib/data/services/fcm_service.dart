import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/helpers.dart';

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _channelId = 'campus_eats_channel';
  static const String _channelName = 'CampusEats Notifications';

  Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications — platform-specific settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Create notification channel (Android only)
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Order updates and alerts from CampusEats',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // iOS foreground notification presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Save notification to Firestore for in-app notification feed
  Future<void> saveNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? orderId,
  }) async {
    final notifId = Helpers.generateId();
    await _db
        .collection(ApiConstants.notificationsCollection)
        .doc(notifId)
        .set({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'orderId': orderId,
      'isRead': false,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Trigger all notifications for order status changes
  Future<void> notifyOrderPlaced({
    required String vendorUserId,
    required String orderId,
    required String studentName,
  }) async {
    await saveNotification(
      userId: vendorUserId,
      title: '🍽️ New Order!',
      body: '$studentName placed a new order',
      type: 'new_order',
      orderId: orderId,
    );
  }

  Future<void> notifyOrderAccepted({
    required String studentId,
    required String orderId,
    required String stallName,
    required int estimatedMinutes,
  }) async {
    await saveNotification(
      userId: studentId,
      title: '✅ Order Accepted!',
      body: '$stallName accepted your order. Ready in ~$estimatedMinutes min.',
      type: 'order_accepted',
      orderId: orderId,
    );
  }

  Future<void> notifyOrderReady({
    required String studentId,
    required String orderId,
    required String stallName,
  }) async {
    await saveNotification(
      userId: studentId,
      title: '🎉 Food Ready!',
      body: 'Your order from $stallName is ready for pickup! Show QR code.',
      type: 'order_ready',
      orderId: orderId,
    );
  }

  Future<void> notifyOrderRejected({
    required String studentId,
    required String orderId,
    required String stallName,
    String? reason,
  }) async {
    await saveNotification(
      userId: studentId,
      title: '❌ Order Rejected',
      body: reason != null
          ? '$stallName rejected your order: $reason'
          : '$stallName rejected your order',
      type: 'order_rejected',
      orderId: orderId,
    );
  }

  Future<void> notifyOrderCancelled({
    required String vendorUserId,
    required String orderId,
    required String studentName,
    String? reason,
  }) async {
    await saveNotification(
      userId: vendorUserId,
      title: '🚫 Order Cancelled',
      body: reason != null
          ? '$studentName cancelled their order: $reason'
          : '$studentName cancelled their order',
      type: 'order_cancelled',
      orderId: orderId,
    );
  }
}
