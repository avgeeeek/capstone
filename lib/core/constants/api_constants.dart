class ApiConstants {
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String menuItemsCollection = 'menu_items';
  static const String ordersCollection = 'orders';
  static const String notificationsCollection = 'notifications';
  static const String reviewsCollection = 'reviews';



  // Order Status Values
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusPickedUp = 'picked_up';
  static const String statusRejected = 'rejected';
  static const String statusCancelled = 'cancelled';

  // Payment Method Values
  static const String paymentGpay = 'gpay';
  static const String paymentCash = 'cash';

  // Payment Status Values
  static const String paymentStatusPaid = 'paid';
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusFailed = 'failed';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleVendor = 'vendor';
  static const String roleAdmin = 'admin';

  // Auth Constants
  static const String collegeEmailDomain = '@vitapstudent.ac.in';

}
