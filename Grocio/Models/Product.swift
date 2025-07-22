import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct Product: Codable, Identifiable, Hashable {
    #if canImport(FirebaseFirestore)
    @DocumentID var id: String?
    #else
    var id: String? = UUID().uuidString
    #endif
    var name: String
    var description: String
    var price: Double
    var originalPrice: Double?
    var imageURL: String
    var category: String
    var subcategory: String?
    var unit: String // kg, pieces, liters, etc.
    var brand: String?
    var rating: Double
    var reviewCount: Int
    var inStock: Bool
    var nutritionalInfo: NutritionalInfo?
    var tags: [String]
    var createdAt: Date
    
    var discountPercentage: Int? {
        guard let originalPrice = originalPrice, originalPrice > price else { return nil }
        return Int(((originalPrice - price) / originalPrice) * 100)
    }
    
    init(name: String, description: String, price: Double, originalPrice: Double? = nil, 
         imageURL: String, category: String, subcategory: String? = nil, 
         unit: String, brand: String? = nil, rating: Double = 4.0, 
         reviewCount: Int = 0, inStock: Bool = true, tags: [String] = []) {
        #if !canImport(FirebaseFirestore)
        self.id = UUID().uuidString
        #endif
        self.name = name
        self.description = description
        self.price = price
        self.originalPrice = originalPrice
        self.imageURL = imageURL
        self.category = category
        self.subcategory = subcategory
        self.unit = unit
        self.brand = brand
        self.rating = rating
        self.reviewCount = reviewCount
        self.inStock = inStock
        self.tags = tags
        self.createdAt = Date()
    }
}

struct NutritionalInfo: Codable, Hashable, Equatable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var sugar: Double?
}

struct Category: Codable, Identifiable {
    var id = UUID().uuidString
    var name: String
    var icon: String
    var color: String
    var subcategories: [String]
} 