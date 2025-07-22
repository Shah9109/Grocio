import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var orderService: OrderService
    @State private var showSettings = false
    @State private var showOrderHistory = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeaderView
                        
                        // Quick Stats
                        quickStatsView
                        
                        // Menu Items
                        menuItemsView
                        
                        // Account Actions
                        accountActionsView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authService)
        }
        .sheet(isPresented: $showOrderHistory) {
            OrderHistoryView()
                .environmentObject(orderService)
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                authService.signOut()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
    
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Profile Picture
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.primaryGreen.opacity(0.2), Color.primaryGreen.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if let profileImageURL = authService.user?.profileImageURL {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.primaryGreen)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.primaryGreen)
                }
                
                // Edit Button
                Button(action: {
                    // Edit profile photo
                }) {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.primaryGreen)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .offset(x: 35, y: 35)
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(authService.user?.name ?? "Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(authService.user?.email ?? "guest@grocio.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let phoneNumber = authService.user?.phoneNumber {
                    Text(phoneNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var quickStatsView: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "bag.fill",
                title: "Orders",
                value: "\(orderService.orders.count)",
                color: .blue
            )
            
            StatCard(
                icon: "heart.fill",
                title: "Wishlist",
                value: "12",
                color: .red
            )
            
            StatCard(
                icon: "star.fill",
                title: "Reviews",
                value: "8",
                color: .orange
            )
        }
    }
    
    private var menuItemsView: some View {
        VStack(spacing: 4) {
            MenuItemRow(
                icon: "clock.arrow.circlepath",
                title: "Order History",
                subtitle: "View all your orders",
                color: .green
            ) {
                showOrderHistory = true
            }
            
            MenuItemRow(
                icon: "location.fill",
                title: "Addresses",
                subtitle: "Manage delivery addresses",
                color: .blue
            ) {
                // Navigate to addresses
            }
            
            MenuItemRow(
                icon: "creditcard.fill",
                title: "Payment Methods",
                subtitle: "Manage payment options",
                color: .purple
            ) {
                // Navigate to payment methods
            }
            
            MenuItemRow(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Manage notification preferences",
                color: .orange
            ) {
                // Navigate to notifications
            }
            
            MenuItemRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "Get help and contact us",
                color: .teal
            ) {
                // Navigate to help
            }
            
            MenuItemRow(
                icon: "info.circle.fill",
                title: "About Grocio",
                subtitle: "App version and information",
                color: .indigo
            ) {
                // Navigate to about
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var accountActionsView: some View {
        VStack(spacing: 12) {
            Button(action: {
                showSettings = true
            }) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.gray)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("App preferences and privacy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                showLogoutAlert = true
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.red)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Logout")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Text("Sign out from your account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct MenuItemRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
        .environmentObject(OrderService())
} 