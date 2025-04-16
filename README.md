# 📱 Device Manager

A modern Flutter application for managing device rentals in educational institutions. This app helps administrators efficiently track device usage, manage rentals, and monitor returns.

## ✨ Features

- **QR Code Scanning**: Quick and easy device check-in/check-out using QR codes
- **Real-time Tracking**: Monitor device status (renting, late, returned) in real-time
- **Student Management**: Keep track of student information and device assignments
- **History Logs**: Comprehensive history of all device rentals and returns
- **Late Return Alerts**: Automatic notifications for late device returns
- **Modern UI**: Clean and intuitive user interface with Material Design 3

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Firebase account
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/device_manager.git
```

2. Install dependencies:
```bash
cd device_manager
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

## 🔧 Configuration

### Firebase Setup

1. Enable Authentication:
   - Google Sign-In
   - Email/Password authentication

2. Set up Firestore:
   - Create collections:
     - `students`
     - `history`
   - Set up security rules

### Environment Variables

Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
```

## 📱 Screenshots

[Add screenshots of your app here]

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI toolkit
- [Firebase](https://firebase.google.com/) - Backend services
- [QR Code Scanner Plus](https://pub.dev/packages/qr_code_scanner_plus) - QR code scanning
- [Google Fonts](https://pub.dev/packages/google_fonts) - Typography
- [Intl](https://pub.dev/packages/intl) - Internationalization

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the robust backend services
- All contributors and maintainers

## 📞 Support

For support, email support@devicemanager.com or open an issue in the repository.
