# GrabNgo / CampusEats — Project Overview

## App Summary
A **Flutter** campus food-ordering app called **GrabNgo** (package name: `campus_eats`). Students browse food stalls, place orders, and pay via UPI/cash. Vendors manage their stall, accept/reject orders, and scan QR codes on pickup. Admins approve student accounts and manage vendors.

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material 3) |
| State | Provider (`ChangeNotifier`) |
| Backend | Firebase — Auth, Firestore, FCM |
| Notifications | `flutter_local_notifications` + FCM (client-side saves to Firestore) |
| Payments | UPI deep-link (`gpay://` → `upi://` fallback) |
| QR | `qr_flutter` (display) + `mobile_scanner` (scan) |
| Auth | Email/Password + Google Sign-In v7 |
| Cloud Functions | Node.js v2 — `deleteAuthUser` callable |

---

## Architecture: Clean-ish Layered

```
lib/
  core/
    constants/   api_constants.dart, app_colors.dart, app_routes.dart, app_strings.dart
    theme/       app_theme.dart, text_styles.dart
    utils/       date_formatter.dart, extensions.dart, helpers.dart, validators.dart
    widgets/     custom_button, custom_textfield, empty_state, error_widget, loading_indicator, order_status_badge
  data/
    models/      UserModel, VendorModel, MenuItemModel, OrderModel, OrderItemModel, ReviewModel, NotificationModel
    repositories/ auth, vendor, menu, order, review, search, admin, notification
    services/    AuthService, FcmService, FirestoreService, PaymentService, StorageService, firebase_service
  logic/
    providers/   AuthProvider, VendorProvider, CartProvider, OrderProvider, ReviewProvider
  presentation/
    common/      splash, login, register, role_selection, forgot_password, profile, pending_approval
    student/     home, menu, cart, checkout, orders, notifications, search, reviews
    vendor/      onboarding, dashboard, menu_management, order_actions, qr_scanner, analytics
    admin/       admin_dashboard_screen, admin_users_tab, admin_orders_tab
  routes/        app_router.dart, route_guard.dart
```

---

## User Roles & Flows

### Student
1. Register → pending approval (non-college email) or auto-approved (`@vitapstudent.ac.in`)
2. Home → browse open stalls → menu → add to cart
3. Checkout → UPI (GPay deep-link) or Cash → order placed
4. Order tracking (real-time stream) → countdown timer → QR code on pickup
5. History, notifications, reviews, profile

### Vendor
1. Admin creates vendor account (secondary Firebase App trick — admin stays logged in)
2. Vendor logs in → onboarding → dashboard
3. Dashboard: incoming → preparing → ready tabs
4. Accept (sets estimated time), mark ready, scan QR to confirm pickup
5. Menu management (add/edit/toggle items), analytics screen

### Admin
1. Approve/reject pending students
2. Manage vendors (create, suspend, delete)
3. All users tab, all orders tab
4. Cloud Function: `deleteAuthUser` to delete Firebase Auth accounts

---

## Key Data Models

### `OrderModel` — statuses
`pending → preparing → ready → picked_up` (or `rejected` / `cancelled`)

### `UserModel` — roles
`student`, `vendor`, `admin` — `isApproved` + `isRejected` flags

### `VendorModel`
`isOpen` (vendor-controlled toggle), `isActive` (admin-controlled)

### `CartProvider`
Single-vendor constraint — shows dialog if switching vendor. Cart cleared on checkout.

---

## Important Constants
- **College email domain**: `@vitapstudent.ac.in`
- **Firestore collections**: `users`, `vendors`, `menu_items`, `orders`, `notifications`, `reviews`
- **QR format**: `campuseats://order/{orderId}`
- **Primary color**: `#6C63FF` (indigo-purple)

---

## Notification System
FcmService saves notifications to Firestore `notifications` collection (client-side). No actual FCM push token sending — just Firestore records read by `NotificationRepository`.

---

## Known Areas / Potential TODOs
- Storage service is mostly a stub (image upload not fully wired in all flows)
- `firebase_service.dart` is 161 bytes (essentially empty)
- `StallListScreen` is a stub (671 bytes — not used in routing)
- Analytics screen may need real aggregation queries
- `route_guard.dart` exists but may not be fully integrated
