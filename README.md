# 🛒 Grocio - Online Grocery Delivery App

**Grocio** is a full-featured iOS grocery delivery app built with SwiftUI, inspired by popular platforms like Instamart, Grofers, and Zepto. The app provides a complete shopping experience with real-time order tracking, wishlist functionality, and a modern, intuitive interface.

## 📱 Features

### 🔐 Authentication & Onboarding
- **Smooth Onboarding Flow** with animated welcome screens
- **Dummy Authentication** for testing (`testuser@grocio.com` / `123456`)
- **Guest Login** option for quick access
- **Firebase Authentication** integration (optional)

### 🏠 Home Screen
- **Animated Search Bar** with smooth appearance transitions
- **Category Carousel** with 7+ product categories
- **Featured Products Grid** with 2-column layout
- **Staggered Entrance Animations** for enhanced UX

### 🛍️ Shopping Experience
- **Product Detail Pages** with zoom animations and `matchedGeometryEffect`
- **Quantity Selector** with intuitive +/- controls
- **Real Product Images** from Unsplash for 24+ grocery items
- **Price Calculations** with discounts and original pricing
- **Smart Search** across product names, categories, and tags

### 🛒 Shopping Cart
- **Dynamic Cart Management** with add/remove/update quantities
- **Swipe-to-Delete** functionality
- **Price Breakdown** with subtotal, delivery fees, and total
- **Scroll Support** for multiple items
- **Checkout Integration** with address and payment selection

### 📦 Order Management
- **Real-time Order Tracking** with 5-stage progress
- **Animated Progress Bar** showing order status
- **Order History** with detailed information
- **Status Updates** every 30 seconds (simulated)
- **Firebase Integration** for live order data

### ❤️ Wishlist
- **Heart Animation** with scale bounce effects
- **Persistent Storage** in UserDefaults and Firebase
- **Easy Management** with toggle functionality
- **Visual Feedback** for user interactions

### 👤 User Profile
- **Profile Information** display
- **Settings Panel** with theme and notification controls
- **Order History Access**
- **Address Management**
- **Logout Functionality**

### ⚙️ Settings & Customization
- **Light/Dark Mode** toggle
- **Notification Controls**
- **Account Management**
- **App Preferences**

## 🛠️ Tech Stack

- **Framework**: SwiftUI (iOS 17.0+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Dependency Management**: Swift Package Manager
- **State Management**: `@StateObject`, `@EnvironmentObject`, `@AppStorage`
- **Image Loading**: `AsyncImage` with fallback placeholders
- **Animations**: SwiftUI native animations with `matchedGeometryEffect`
- **Local Storage**: UserDefaults, Codable

## 📁 Project Structure

```
Grocio/
├── Models/
│   ├── User.swift                 # User data model
│   ├── Product.swift              # Product & category models
│   └── Order.swift                # Order, cart item models
│
├── Views/
│   ├── Onboarding/               # Welcome & introduction screens
│   ├── Auth/                     # Login & authentication
│   ├── Main/                     # Tab bar container
│   ├── Home/                     # Home screen & search
│   ├── Categories/               # Category browsing
│   ├── Product/                  # Product detail screens
│   ├── Cart/                     # Shopping cart & management
│   ├── Checkout/                 # Checkout process
│   ├── Orders/                   # Order tracking & history
│   ├── Wishlist/                 # Favorite products
│   ├── Profile/                  # User profile & info
│   ├── Settings/                 # App settings & preferences
│   └── Components/               # Reusable UI components
│
├── Services/
│   ├── AuthService.swift         # Authentication logic
│   ├── ProductService.swift      # Product data management
│   ├── CartService.swift         # Shopping cart operations
│   ├── OrderService.swift        # Order processing & tracking
│   └── WishlistService.swift     # Wishlist management
│
├── Utils/
│   └── Extensions.swift          # Helper extensions & design system
│
├── Assets.xcassets/              # App icons & images
├── GoogleService-Info.plist      # Firebase configuration
└── GrocioApp.swift              # Main app entry point
```

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **macOS Big Sur** or later
- **Swift 5.9+**

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/grocio.git
   cd grocio
   ```

2. **Open in Xcode**
   ```bash
   open Grocio.xcodeproj
   ```

3. **Install Dependencies**
   - Xcode will automatically resolve Swift Package Manager dependencies
   - Firebase SDK will be downloaded automatically

4. **Configure Firebase (Optional)**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication and Firestore Database
   - Download your `GoogleService-Info.plist`
   - Replace the placeholder file in the project

5. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 🔧 Configuration

### Firebase Setup (Optional)
The app works without Firebase using local data and dummy authentication. To enable full Firebase features:

1. **Authentication**
   - Enable Email/Password authentication in Firebase Console
   - Configure sign-in methods

2. **Firestore Database**
   - Create database in test mode
   - Set up collections: `users`, `products`, `orders`

3. **Firebase Storage**
   - Enable storage for product images
   - Configure security rules

### Dummy Login Credentials
- **Email**: `testuser@grocio.com`
- **Password**: `123456`
- **Guest Login**: Available without credentials

## 🎯 Usage

### For Users
1. **Onboarding**: Complete the welcome flow
2. **Login**: Use dummy credentials or guest access
3. **Browse**: Explore categories and products
4. **Shop**: Add items to cart, adjust quantities
5. **Checkout**: Enter address and payment details
6. **Track**: Monitor order progress in real-time
7. **Manage**: Use wishlist and view order history

### For Developers
1. **Modify Products**: Edit `ProductService.swift` to add/remove items
2. **Customize UI**: Update design system in `Extensions.swift`
3. **Add Features**: Create new views and services following MVVM
4. **Configure Firebase**: Add your own Firebase project configuration

## 🎨 Design System

### Colors
- **Primary Green**: `#4CAF50` - Main brand color
- **Light Gray**: `#F5F5F5` - Background tint
- **Dark Gray**: `#333333` - Text primary
- **Error Red**: `#F44336` - Error states

### Typography
- **Headlines**: SF Pro Display, Bold
- **Body**: SF Pro Text, Regular
- **Captions**: SF Pro Text, Medium

### Animations
- **Gentle Bounce**: Spring animation with dampening
- **Fade Transitions**: 0.3s duration with easing
- **Scale Effects**: 1.05x on interaction
- **Matched Geometry**: For seamless transitions

## 📦 Sample Data

The app includes 24+ sample products across 7 categories:
- **Fruits & Vegetables**: Bananas, apples, tomatoes, spinach
- **Dairy & Eggs**: Milk, cheese, yogurt, eggs
- **Meat & Seafood**: Chicken, fish, prawns
- **Pantry Staples**: Rice, oil, spices
- **Snacks & Beverages**: Chips, juices, biscuits
- **Personal Care**: Shampoo, toothpaste, soap
- **Household**: Cleaning supplies, detergent

## 🔧 Development

### Adding New Features
1. Create models in `Models/` directory
2. Add service layer in `Services/` 
3. Create views following existing patterns
4. Update navigation and environment objects
5. Test with both local and Firebase modes

### Conditional Compilation
The app uses `#if canImport(Firebase...)` to work without Firebase:
- Local authentication fallback
- Dummy data when Firebase unavailable
- UserDefaults for local storage

## 🚨 Troubleshooting

### Common Issues
1. **Firebase Module Errors**
   - Ensure `GoogleService-Info.plist` is added to project
   - Check Firebase SDK installation

2. **Build Errors**
   - Clean build folder (`Cmd + Shift + K`)
   - Reset package cache if needed

3. **Simulator Issues**
   - Use iOS 17.0+ simulator
   - Enable device orientation if needed

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- **Firebase** for backend infrastructure
- **Unsplash** for high-quality product images
- **SF Symbols** for consistent iconography
- **SwiftUI** for modern iOS development

## 📞 Support

For support, email dev@grocio.com or create an issue in the repository.

---

**Made with ❤️ and SwiftUI**

*Grocio - Fresh groceries at your fingertip! 🛒* 
