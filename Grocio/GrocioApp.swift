//
//  GrocioApp.swift
//  Grocio
//
//  Created by Sanjay Shah on 21/07/25.
//

import SwiftUI
#if canImport(FirebaseCore)
import FirebaseCore
#endif

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #else
        print("Firebase not available - running in local mode")
        #endif
        return true
    }
}

@main
struct GrocioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                        .onReceive(authService.$isAuthenticated) { isAuthenticated in
                            if isAuthenticated {
                                hasCompletedOnboarding = true
                            }
                        }
                } else {
                    if authService.isAuthenticated {
                        MainTabView()
                            .environmentObject(authService)
                    } else {
                        AuthView()
                            .environmentObject(authService)
                            .onReceive(authService.$isAuthenticated) { isAuthenticated in
                                if !isAuthenticated {
                                    hasCompletedOnboarding = false
                                }
                            }
                    }
                }
            }
            .preferredColorScheme(.light) // Force light mode for demo
        }
    }
}
