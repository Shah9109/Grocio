import SwiftUI

struct AuthView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var showMainApp = false
    @State private var animateGradient = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryGreen.opacity(animateGradient ? 0.3 : 0.1),
                        Color.blue.opacity(animateGradient ? 0.2 : 0.1),
                        Color.white
                    ]),
                    startPoint: animateGradient ? .topTrailing : .topLeading,
                    endPoint: animateGradient ? .bottomLeading : .bottomTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Logo and Title
                        VStack(spacing: 24) {
                            // App Icon
                            ZStack {
                                Circle()
                                    .fill(Color.primaryGreen.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 50, weight: .medium))
                                    .foregroundColor(.primaryGreen)
                            }
                            .shadow(color: Color.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            VStack(spacing: 8) {
                                Text("Welcome to Grocio")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Fresh groceries delivered to your door")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            VStack(spacing: 16) {
                                // Email Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Enter your email", text: $email)
                                        .textFieldStyle(CustomTextFieldStyle())
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Password")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    SecureField("Enter your password", text: $password)
                                        .textFieldStyle(CustomTextFieldStyle())
                                }
                            }
                            
                            // Demo Credentials Info
                            VStack(spacing: 8) {
                                Text("Demo Credentials:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                VStack(spacing: 4) {
                                    Text("Email: testuser@grocio.com")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Password: 123456")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // Auto-fill button
                            Button("Use Demo Credentials") {
                                withAnimation(.quickSpring) {
                                    email = "testuser@grocio.com"
                                    password = "123456"
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.primaryGreen)
                        }
                        .padding(.horizontal, 32)
                        
                        // Buttons
                        VStack(spacing: 16) {
                            // Login Button
                            Button(action: {
                                authService.signInWithDummyCredentials()
                            }) {
                                HStack {
                                    if authService.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.title3)
                                    }
                                    
                                    Text(authService.isLoading ? "Signing In..." : "Sign In")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(authService.isLoading)
                            
                            // Guest Login Button
                            Button(action: {
                                authService.guestLogin()
                            }) {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .font(.title3)
                                    
                                    Text("Continue as Guest")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.primaryGreen)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primaryGreen, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 32)
                        
                        // Error Message
                        if let errorMessage = authService.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: authService.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                showMainApp = true
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
                .environmentObject(authService)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    AuthView()
} 