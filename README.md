<div align="center">

<h1>CampusEats</h1>

<p><strong>Skip the queue. Order smart.</strong></p>

<p>A cross-platform Flutter mobile app that eliminates college cafeteria queues by letting students pre-order food from campus stalls and track their orders in real time.</p>

<p>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?logo=firebase" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android" />
  <img src="https://img.shields.io/badge/State-Provider-764ABC" />
</p>

</div>

---

## Features

### For Students
- **Browse Stalls** — See all open cafeteria stalls with real-time availability
- **Browse Menu** — Filter by category (Meals, Snacks, Beverages, Desserts)
- **Smart Cart** — Add/remove items, view subtotals per stall
- **Dual Payment** — Pay via Google Pay (UPI Deep Link) or Cash at Counter
- **Live Order Tracking** — Countdown timer set by the vendor, updates in real time
- **Order History** — View all past orders and their statuses
- **Push Notifications** — Get notified when your order is accepted or ready

### For Vendors
- **Tabbed Dashboard** — Pending, Preparing, and Ready tabs for order management
- **Accept Orders** — Set a custom prep time (e.g. 10 min) when accepting
- **QR Code Pickup** — Scan student's QR code to confirm pickup and complete order
- **Menu Management** — Add, edit, and toggle availability of menu items with images
- **Analytics** — View daily revenue and order stats

### Auth
- Email & Password (Student or Vendor role selection on sign-up)
- **Google Sign-In** — One-tap login with your college Google account

---

## Architecture

```
lib/
├── core/                    # Constants, theme, utilities, widgets
│   ├── constants/           # App routes, colors, strings, API constants
│   ├── theme/               # App theme (light mode)
│   ├── utils/               # Validators, date formatters
│   └── widgets/             # Reusable widgets (CustomButton, CustomTextField, etc.)
│
├── data/                    # Data layer
│   ├── models/              # UserModel, VendorModel, MenuItemModel, OrderModel
│   ├── repositories/        # AuthRepository, MenuRepository, OrderRepository, etc.
│   └── services/            # AuthService, FirestoreService, FcmService, PaymentService
│
├── logic/                   # State management (Provider)
│   └── providers/           # AuthProvider, CartProvider, OrderProvider, VendorProvider
│
├── presentation/            # UI
│   ├── common/              # Splash, Login, Register, Profile, ForgotPassword
│   ├── student/             # Home, Menu, Cart, Checkout, OrderTracking, Notifications
│   └── vendor/              # Dashboard, MenuManagement, QRScanner, Analytics
│
└── routes/                  # AppRouter + RouteGuard
```

---

## Tech Stack

| Category | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore, Storage, Messaging) |
| State Management | Provider |
| Payment | UPI Deep Link via `url_launcher` (Google Pay) |
| QR Scanning | `mobile_scanner` |
| QR Generation | `qr_flutter` |
| Google Sign-In | `google_sign_in` v7.x |
| Notifications | `flutter_local_notifications` + FCM |

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x+)
- [Android Studio](https://developer.android.com/studio) with an Android Emulator
- A [Firebase](https://firebase.google.com/) project

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/campuseats.git
cd campuseats
```

### 2. Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Register your Android app with package name `com.campuseats.campus_eats`
3. Enable the following in Firebase Console:
   - **Authentication** → Email/Password + Google
   - **Cloud Firestore** → Create a database (start in test mode)
   - **Firebase Storage**
   - **Cloud Messaging**
4. Download `google-services.json` and place it in `android/app/`
5. Run `flutterfire configure` to generate `lib/firebase_options.dart`
6. Add your Android debug SHA-1 fingerprint to Firebase (required for Google Sign-In):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run the app
```bash
flutter run
```

---

## Environment Notes

The `google-services.json` and `lib/firebase_options.dart` files contain project-specific Firebase credentials and **are not committed to this repository** (see `.gitignore`). Each developer must set up their own Firebase project or request credentials from the project owner.

---

## Screenshots

> _Screenshots to be added after first stable release._

---

## Contributing

This is a capstone project. Contributions are welcome via pull requests. Please open an issue first to discuss major changes.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
