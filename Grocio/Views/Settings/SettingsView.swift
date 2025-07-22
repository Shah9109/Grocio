import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("enablePushNotifications") private var enablePushNotifications = true
    @AppStorage("enableEmailNotifications") private var enableEmailNotifications = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("enableFaceID") private var enableFaceID = false
    @AppStorage("autoOrder") private var autoOrder = false
    
    @State private var showDeleteAccountAlert = false
    @State private var showClearCacheAlert = false
    @State private var cacheSize = "45.2 MB"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Notifications Section
                        notificationsSection
                        
                        // Appearance Section
                        appearanceSection
                        
                        // Security Section
                        securitySection
                        
                        // Shopping Preferences
                        shoppingPreferencesSection
                        
                        // Storage Section
                        storageSection
                        
                        // Account Actions
                        accountActionsSection
                        
                        // App Information
                        appInfoSection
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .alert("Clear Cache", isPresented: $showClearCacheAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("This will clear \(cacheSize) of cached data. This action cannot be undone.")
        }
    }
    
    private var notificationsSection: some View {
        SettingsSection(title: "Notifications", icon: "bell.fill", color: .orange) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Enable Notifications",
                    subtitle: "Receive order updates and offers",
                    isOn: $enableNotifications
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsToggleRow(
                    title: "Push Notifications",
                    subtitle: "Real-time order status updates",
                    isOn: $enablePushNotifications
                )
                .disabled(!enableNotifications)
                .opacity(enableNotifications ? 1 : 0.6)
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsToggleRow(
                    title: "Email Notifications",
                    subtitle: "Order confirmations and receipts",
                    isOn: $enableEmailNotifications
                )
                .disabled(!enableNotifications)
                .opacity(enableNotifications ? 1 : 0.6)
            }
        }
    }
    
    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill", color: .purple) {
            SettingsToggleRow(
                title: "Dark Mode",
                subtitle: "Use dark theme throughout the app",
                isOn: $isDarkMode
            )
        }
    }
    
    private var securitySection: some View {
        SettingsSection(title: "Security & Privacy", icon: "shield.fill", color: .blue) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Face ID / Touch ID",
                    subtitle: "Use biometric authentication for payments",
                    isOn: $enableFaceID
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Change Password",
                    subtitle: "Update your account password",
                    icon: "key.fill",
                    color: .green
                ) {
                    // Navigate to change password
                }
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    icon: "doc.text.fill",
                    color: .teal
                ) {
                    // Open privacy policy
                }
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    icon: "doc.plaintext.fill",
                    color: .indigo
                ) {
                    // Open terms of service
                }
            }
        }
    }
    
    private var shoppingPreferencesSection: some View {
        SettingsSection(title: "Shopping Preferences", icon: "cart.fill", color: .primaryGreen) {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    title: "Auto-Reorder",
                    subtitle: "Automatically reorder frequently bought items",
                    isOn: $autoOrder
                )
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Default Address",
                    subtitle: "Set your primary delivery address",
                    icon: "house.fill",
                    color: .blue
                ) {
                    // Navigate to address selection
                }
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Preferred Payment",
                    subtitle: "Set default payment method",
                    icon: "creditcard.fill",
                    color: .purple
                ) {
                    // Navigate to payment methods
                }
            }
        }
    }
    
    private var storageSection: some View {
        SettingsSection(title: "Storage", icon: "internaldrive.fill", color: .gray) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "folder.fill")
                        .font(.title3)
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cache Size")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(cacheSize)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Clear") {
                        showClearCacheAlert = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Download for Offline",
                    subtitle: "Save products for offline browsing",
                    icon: "arrow.down.circle.fill",
                    color: .green
                ) {
                    // Navigate to offline downloads
                }
            }
        }
    }
    
    private var accountActionsSection: some View {
        SettingsSection(title: "Account", icon: "person.fill", color: .red) {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    title: "Export Data",
                    subtitle: "Download your account data",
                    icon: "square.and.arrow.up.fill",
                    color: .blue
                ) {
                    // Handle data export
                }
                
                Divider()
                    .padding(.leading, 60)
                
                Button(action: {
                    showDeleteAccountAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Delete Account")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            Text("Permanently delete your account")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var appInfoSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill", color: .indigo) {
            VStack(spacing: 0) {
                SettingsInfoRow(title: "Version", value: "1.0.0")
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsInfoRow(title: "Build", value: "2024.1.1")
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Rate App",
                    subtitle: "Rate us on the App Store",
                    icon: "star.fill",
                    color: .orange
                ) {
                    // Open app store rating
                }
                
                Divider()
                    .padding(.leading, 60)
                
                SettingsNavigationRow(
                    title: "Contact Support",
                    subtitle: "Get help from our team",
                    icon: "envelope.fill",
                    color: .green
                ) {
                    // Open support contact
                }
            }
        }
    }
    
    private func clearCache() {
        // Simulate cache clearing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            cacheSize = "0 MB"
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
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
            
            Toggle("", isOn: $isOn)
                .tint(.primaryGreen)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
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
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthService())
} 