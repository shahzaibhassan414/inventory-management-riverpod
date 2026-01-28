# Riverpod Flutter - Inventory & Invoice Management

A professional Flutter application for managing inventory, customers, and generating invoices. Built using modern development practices with **Riverpod** for state management and **Firebase** for data persistence.

## 🚀 Features

- **Authentication**: Secure Login and Sign-up using Firebase Auth.
- **Inventory Management**: Track stock levels, add, update, and delete items.
- **Invoice Generation**: Create professional invoices for customers with real-time stock deduction.
- **Customer Management**: Save and track customer visit history. Auto-update all related invoices when a customer's name is edited.
- **Invoice History**: View past transactions and total sales analytics.
- **Dark Mode Support**: Seamless toggle between light and dark themes with persistent storage.
- **Splash Screen**: Animated entry that pre-loads essential data for a smooth user experience.
- **MVVM Architecture**: Clean and maintainable code structure separating UI, logic, and data.

## 🛠 Tech Stack

- **Framework**: Flutter
- **State Management**: [Riverpod](https://riverpod.dev/) (Notifier & StateProvider)
- **Backend**: [Firebase](https://firebase.google.com/) (Firestore, Auth)
- **Local Storage**: Shared Preferences (for Theme persistence)
- **Styling**: Google Fonts & Custom Theme Data

## 📁 Project Structure

```text
lib/
├── Constants/    # App constants and shared styles
├── Models/       # Data models (Inventory, Invoice, Customer)
├── Providers/    # Riverpod providers (ViewModel layer)
├── Services/     # Firebase and external service logic
├── Theme/        # Light and Dark theme configurations
├── Utils/        # Helper functions
├── Views/        # UI Screens (Auth, Home, Inventory, Invoice, etc.)
└── Widgets/      # Reusable UI components
```

## ⚙️ Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shahzaibhassan414/inventory-management-riverpod.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup:**
   - Create a new project on the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist`.
   - Run `flutterfire configure` to set up your `firebase_options.dart`.

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
