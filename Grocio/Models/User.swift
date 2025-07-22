import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct User: Codable, Identifiable {
    #if canImport(FirebaseFirestore)
    @DocumentID var id: String?
    #else
    var id: String? = UUID().uuidString
    #endif
    var email: String
    var name: String
    var phoneNumber: String?
    var address: [Address]
    var wishlist: [String] // Product IDs
    var createdAt: Date
    var profileImageURL: String?
    
    init(email: String, name: String, phoneNumber: String? = nil) {
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = []
        self.wishlist = []
        self.createdAt = Date()
    }
}

struct Address: Codable, Identifiable {
    var id = UUID().uuidString
    var street: String
    var city: String
    var state: String
    var zipCode: String
    var isDefault: Bool
    
    var fullAddress: String {
        return "\(street), \(city), \(state) \(zipCode)"
    }
} 