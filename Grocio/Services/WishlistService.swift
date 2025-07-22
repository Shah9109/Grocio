import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import Combine

class WishlistService: ObservableObject {
    @Published var wishlistItems: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if canImport(FirebaseFirestore)
    private var db = Firestore.firestore()
    #endif
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadWishlist()
    }
    
    func toggleWishlist(_ product: Product) {
        if isInWishlist(product) {
            removeFromWishlist(product)
        } else {
            addToWishlist(product)
        }
    }
    
    func addToWishlist(_ product: Product) {
        guard !isInWishlist(product) else { return }
        
        wishlistItems.append(product)
        saveToFirestore()
        saveToLocal()
    }
    
    func removeFromWishlist(_ product: Product) {
        wishlistItems.removeAll { $0.id == product.id }
        saveToFirestore()
        saveToLocal()
    }
    
    func isInWishlist(_ product: Product) -> Bool {
        return wishlistItems.contains { $0.id == product.id }
    }
    
    func clearWishlist() {
        wishlistItems.removeAll()
        saveToFirestore()
        saveToLocal()
    }
    
    private func loadWishlist() {
        // Load from local storage first for immediate UI update
        loadFromLocal()
        
        // Then sync from Firebase if user is authenticated
        // In a real app, use current user ID
        loadFromFirestore()
    }
    
    private func saveToFirestore() {
        // In a real app, use current user ID and save wishlist product IDs
        #if canImport(FirebaseFirestore)
        // For now, we'll just use local storage
        // In production, save to user's document in Firestore
        #endif
    }
    
    private func loadFromFirestore() {
        #if canImport(FirebaseFirestore)
        // In a real app, load user's wishlist from Firestore
        // For demo purposes, we'll stick to local storage
        #else
        // No Firebase, use local storage only
        #endif
    }
    
    private func saveToLocal() {
        if let encoded = try? JSONEncoder().encode(wishlistItems) {
            UserDefaults.standard.set(encoded, forKey: "wishlist_items")
        }
    }
    
    private func loadFromLocal() {
        if let data = UserDefaults.standard.data(forKey: "wishlist_items"),
           let decoded = try? JSONDecoder().decode([Product].self, from: data) {
            wishlistItems = decoded
        }
    }
} 