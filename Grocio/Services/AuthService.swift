import Foundation
#if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
import FirebaseAuth
import FirebaseFirestore
#endif
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if canImport(FirebaseFirestore)
    private var db = Firestore.firestore()
    #endif
    private var cancellables = Set<AnyCancellable>()
    
    // Dummy credentials
    private let dummyEmail = "testuser@grocio.com"
    private let dummyPassword = "123456"
    
    init() {
        #if canImport(FirebaseAuth)
        // Check if user is already logged in
        if let currentUser = Auth.auth().currentUser {
            fetchUser(uid: currentUser.uid)
        }
        
        // Listen to auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.fetchUser(uid: user.uid)
                } else {
                    self?.user = nil
                    self?.isAuthenticated = false
                }
            }
        }
        #else
        // Fallback for development without Firebase
        print("Firebase not available - using local authentication")
        #endif
    }
    
    func signInWithDummyCredentials() {
        isLoading = true
        errorMessage = nil
        
        #if canImport(FirebaseAuth)
        Auth.auth().signIn(withEmail: dummyEmail, password: dummyPassword) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    // If user doesn't exist, create them
                    self?.createDummyUser()
                } else if let user = result?.user {
                    self?.fetchUser(uid: user.uid)
                }
            }
        }
        #else
        // Simulate login without Firebase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let dummyUser = User(email: self.dummyEmail, name: "Test User", phoneNumber: "+91 9876543210")
            self.user = dummyUser
            self.isAuthenticated = true
            self.isLoading = false
        }
        #endif
    }
    
    private func createDummyUser() {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        isLoading = true
        
        Auth.auth().createUser(withEmail: dummyEmail, password: dummyPassword) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                    return
                }
                
                guard let firebaseUser = result?.user else {
                    self?.errorMessage = "Failed to create user"
                    self?.isLoading = false
                    return
                }
                
                // Create user document in Firestore
                let newUser = User(email: self?.dummyEmail ?? "", name: "Test User", phoneNumber: "+91 9876543210")
                
                do {
                    try self?.db.collection("users").document(firebaseUser.uid).setData(from: newUser) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self?.errorMessage = error.localizedDescription
                            } else {
                                self?.user = newUser
                                self?.isAuthenticated = true
                            }
                            self?.isLoading = false
                        }
                    }
                } catch {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            }
        }
        #else
        // Fallback without Firebase
        let newUser = User(email: dummyEmail, name: "Test User", phoneNumber: "+91 9876543210")
        self.user = newUser
        self.isAuthenticated = true
        self.isLoading = false
        #endif
    }
    
    func guestLogin() {
        let guestUser = User(email: "guest@grocio.com", name: "Guest User")
        self.user = guestUser
        self.isAuthenticated = true
    }
    
    private func fetchUser(uid: String) {
        #if canImport(FirebaseFirestore)
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        self?.user = user
                        self?.isAuthenticated = true
                    } catch {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
        #else
        // Fallback without Firebase
        let dummyUser = User(email: "testuser@grocio.com", name: "Test User", phoneNumber: "+91 9876543210")
        self.user = dummyUser
        self.isAuthenticated = true
        #endif
    }
    
    func signOut() {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
        #else
        user = nil
        isAuthenticated = false
        #endif
    }
    
    func updateUser(_ updatedUser: User) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(uid).setData(from: updatedUser) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.user = updatedUser
                    }
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        #else
        // Update locally
        self.user = updatedUser
        #endif
    }
} 