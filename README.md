# Event Management

A comprehensive Flutter application for managing decoration events, inventory, materials, and costs. Built with modern Flutter architecture and Riverpod state management.

## 🚀 Features

### 📱 Core Functionality
- **User Authentication & Authorization**
  - Login/Logout system
  - Role-based access control (Admin/User)
  - Secure token management

- **Event Management**
  - Create and manage decoration events
  - Event templates and year management
  - Event details with multiple tabs (Cost, Design, Material)
  - Cover image and design image uploads

- **Inventory Management**
  - Comprehensive inventory tracking
  - Add, edit, and delete inventory items
  - Image upload for inventory items
  - Stock management and tracking
  - Item issuance and return system
  - Issue history and tracking

- **Material Management**
  - Material inventory tracking
  - Material issuance system
  - Cost tracking per material

- **Cost Management**
  - Event cost tracking
  - Yearly cost breakdown
  - Cost document uploads
  - Financial reporting

- **Dashboard & Analytics**
  - Real-time statistics overview
  - Yearly cost charts
  - Event and inventory metrics
  - Visual data representation

### 🎨 UI/UX Features
- **Responsive Design**
  - Cross-platform compatibility (iOS, Android, Web)
  - Adaptive layouts for different screen sizes
  - Material Design 3 components

- **Theme System**
  - Light and dark theme support
  - Custom color schemes
  - Consistent design language

- **Modern Navigation**
  - Bottom navigation bar
  - Intuitive routing system
  - Smooth transitions and animations

## 🏗️ Architecture

### **State Management**
- **Riverpod** for state management
- **Provider pattern** for dependency injection
- **Consumer widgets** for reactive UI updates

### **Project Structure**
```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # App entry point
├── models/                 # Data models
├── providers/              # State providers
├── services/               # API and business logic services
├── themes/                 # App theming
├── utils/                  # Utility functions
├── views/                  # UI screens and widgets
│   ├── auth/              # Authentication screens
│   ├── dashboard/         # Dashboard and analytics
│   ├── event/             # Event management
│   ├── inventory/         # Inventory management
│   ├── home/              # Home screen
│   └── splash/            # Splash screen
└── routes/                 # App routing configuration
```

### **Key Technologies**
- **Flutter 3.6.2+** - Cross-platform UI framework
- **Riverpod 2.5.1** - State management
- **HTTP/Dio** - API communication
- **Image Picker** - Image selection and upload
- **Shared Preferences** - Local data storage
- **Flutter Secure Storage** - Secure credential storage

## 📋 Prerequisites

- **Flutter SDK**: 3.6.2 or higher
- **Dart SDK**: 3.0.0 or higher
- **Android Studio** / **VS Code** with Flutter extensions
- **Git** for version control

## 🛠️ Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd avd_decoration_frontend_app/Frontend
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment
Create a `.env` file in the project root (if required):
```env
API_BASE_URL=your_backend_api_url
```

### 4. Run the Application

#### Development Mode
```bash
flutter run
```

#### Production Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🔧 Configuration

### **Backend Integration**
The app is designed to work with the AVD Decoration Backend API. Ensure your backend server is running and accessible.

### **API Configuration**
Update API endpoints in `lib/services/api_service.dart` to match your backend configuration.

### **Image Storage**
Configure image upload paths and storage settings in the relevant services.

## 📱 Screens & Navigation

### **Authentication Flow**
1. **Splash Screen** - App initialization
2. **Login Screen** - User authentication
3. **Home Screen** - Main navigation hub

### **Main Application**
- **Dashboard** - Overview and statistics
- **Events** - Event management and creation
- **Inventory** - Inventory management system
- **Profile** - User settings and logout

### **Navigation Structure**
```
Splash → Login → Home
  ↓
Dashboard ← → Events ← → Inventory
  ↓
Profile/Settings
```

## 🎯 Key Features in Detail

### **Event Management**
- Create new decoration events
- Upload cover and design images
- Track event costs and materials
- Manage event templates
- Year-based organization

### **Inventory System**
- **Item Management**
  - Add new inventory items
  - Upload item images
  - Edit item details
  - Delete items (admin only)
  
- **Stock Tracking**
  - Current stock levels
  - Stock history
  - Low stock alerts
  
- **Issuance System**
  - Issue items to users
  - Track return dates
  - Issue history
  - Return management

### **Cost Management**
- Track costs per event
- Yearly cost summaries
- Cost document uploads
- Financial reporting

## 🔐 Security Features

- **JWT Token Authentication**
- **Role-based Access Control**
- **Secure Storage** for sensitive data
- **Input Validation** and sanitization
- **Session Management**

## 📊 Data Management

### **Local Storage**
- User preferences
- Authentication tokens
- Cached data

### **API Integration**
- RESTful API communication
- Real-time data synchronization
- Offline data handling

## 🧪 Testing

### **Unit Tests**
```bash
flutter test
```

### **Widget Tests**
```bash
flutter test test/widget_test.dart
```

### **Integration Tests**
```bash
flutter test integration_test/
```

## 🚀 Deployment

### **Android**
1. Build APK: `flutter build apk --release`
2. Test on device: `flutter install`
3. Distribute via Google Play Store or direct APK

### **iOS**
1. Build iOS: `flutter build ios --release`
2. Archive in Xcode
3. Upload to App Store Connect

### **Web**
1. Build web: `flutter build web --release`
2. Deploy to web server (Firebase Hosting, Netlify, etc.)

## 📈 Performance Optimization

- **Lazy Loading** for large lists
- **Image Caching** and optimization
- **Efficient State Management** with Riverpod
- **Memory Management** best practices

## 🐛 Troubleshooting

### **Common Issues**

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Dependency Issues**
   ```bash
   flutter doctor
   flutter pub deps
   ```

3. **Performance Issues**
   - Check for memory leaks
   - Optimize image sizes
   - Review state management

### **Debug Mode**
```bash
flutter run --debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the ISC License.

## 👥 Team

- **Frontend Development**: Flutter Team
- **Backend Integration**: Node.js Team
- **UI/UX Design**: Design Team

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔄 Version History

- **v1.0.0** - Initial release with core functionality
- **v1.1.0** - Enhanced inventory management
- **v1.2.0** - Improved event management and cost tracking

