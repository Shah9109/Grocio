import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import Combine

class ProductService: ObservableObject {
    @Published var products: [Product] = []
    @Published var categories: [Category] = []
    @Published var featuredProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if canImport(FirebaseFirestore)
    private var db = Firestore.firestore()
    #endif
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProducts()
        loadCategories()
    }
    
    func loadProducts() {
        // Load from Firebase or use dummy data
        isLoading = true
        
        #if canImport(FirebaseFirestore)
        db.collection("products").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.loadDummyProducts() // Fallback to dummy data
                } else if let documents = snapshot?.documents {
                    if documents.isEmpty {
                        self?.seedDummyData()
                    } else {
                        do {
                            self?.products = try documents.compactMap { doc in
                                try doc.data(as: Product.self)
                            }
                            self?.updateFeaturedProducts()
                        } catch {
                            self?.loadDummyProducts()
                        }
                    }
                } else {
                    self?.loadDummyProducts()
                }
                self?.isLoading = false
            }
        }
        #else
        // Use local data when Firebase is not available
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadDummyProducts()
            self.isLoading = false
        }
        #endif
    }
    
    private func loadDummyProducts() {
        products = createDummyProducts()
        updateFeaturedProducts()
    }
    
    private func updateFeaturedProducts() {
        featuredProducts = Array(products.filter { $0.rating >= 4.5 }.shuffled().prefix(6))
    }
    
    private func loadCategories() {
        categories = createCategories()
    }
    
    func getProductsByCategory(_ category: String) -> [Product] {
        return products.filter { $0.category == category }
    }
    
    func searchProducts(_ query: String) -> [Product] {
        guard !query.isEmpty else { return products }
        
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    private func seedDummyData() {
        #if canImport(FirebaseFirestore)
        let dummyProducts = createDummyProducts()
        
        for product in dummyProducts {
            do {
                try db.collection("products").addDocument(from: product)
            } catch {
                print("Error seeding product: \(error)")
            }
        }
        
        self.products = dummyProducts
        updateFeaturedProducts()
        #else
        loadDummyProducts()
        #endif
    }
    
    private func createCategories() -> [Category] {
        return [
            Category(name: "Fruits & Vegetables", icon: "🥬", color: "green", subcategories: ["Fresh Fruits", "Fresh Vegetables", "Herbs"]),
            Category(name: "Dairy & Eggs", icon: "🥛", color: "blue", subcategories: ["Milk", "Cheese", "Yogurt", "Eggs"]),
            Category(name: "Meat & Seafood", icon: "🍗", color: "red", subcategories: ["Chicken", "Mutton", "Fish", "Prawns"]),
            Category(name: "Pantry Staples", icon: "🌾", color: "orange", subcategories: ["Rice", "Flour", "Oil", "Spices"]),
            Category(name: "Snacks & Beverages", icon: "🍿", color: "purple", subcategories: ["Chips", "Biscuits", "Soft Drinks", "Juices"]),
            Category(name: "Personal Care", icon: "🧴", color: "pink", subcategories: ["Skincare", "Hair Care", "Oral Care"]),
            Category(name: "Household", icon: "🧽", color: "gray", subcategories: ["Cleaning", "Detergent", "Kitchen Items"])
        ]
    }
    
    private func createDummyProducts() -> [Product] {
        return [
            // Fruits & Vegetables
            Product(name: "Fresh Bananas", description: "Sweet and ripe yellow bananas, perfect for smoothies and snacks", 
                   price: 40, originalPrice: 50, imageURL: "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400", category: "Fruits & Vegetables", 
                   subcategory: "Fresh Fruits", unit: "1 dozen", brand: "Farm Fresh", rating: 4.3, reviewCount: 245, tags: ["fresh", "organic"]),
            
            Product(name: "Red Apples", description: "Crisp and juicy red apples from Himachal Pradesh", 
                   price: 120, originalPrice: 140, imageURL: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400", category: "Fruits & Vegetables", 
                   subcategory: "Fresh Fruits", unit: "1 kg", brand: "Hill Fresh", rating: 4.5, reviewCount: 189, tags: ["fresh", "premium"]),
            
            Product(name: "Fresh Spinach", description: "Leafy green spinach rich in iron and vitamins", 
                   price: 25, imageURL: "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400", category: "Fruits & Vegetables", 
                   subcategory: "Fresh Vegetables", unit: "250g", brand: "Green Fields", rating: 4.2, reviewCount: 156, tags: ["leafy", "healthy"]),
            
            Product(name: "Organic Tomatoes", description: "Vine-ripened organic tomatoes with rich flavor", 
                   price: 80, originalPrice: 95, imageURL: "https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400", category: "Fruits & Vegetables", 
                   subcategory: "Fresh Vegetables", unit: "1 kg", brand: "Organic Valley", rating: 4.6, reviewCount: 234, tags: ["organic", "fresh"]),
            
            Product(name: "Fresh Onions", description: "Premium quality onions for everyday cooking", 
                   price: 35, imageURL: "https://images.unsplash.com/photo-1508313880080-c4bef43d8db9?w=400", category: "Fruits & Vegetables", 
                   subcategory: "Fresh Vegetables", unit: "1 kg", brand: "Farm Direct", rating: 4.1, reviewCount: 98, tags: ["essential", "cooking"]),
            
            // Dairy & Eggs
            Product(name: "Amul Milk", description: "Fresh full cream milk from Amul", 
                   price: 28, imageURL: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400", category: "Dairy & Eggs", 
                   subcategory: "Milk", unit: "500ml", brand: "Amul", rating: 4.7, reviewCount: 567, tags: ["fresh", "daily"]),
            
            Product(name: "Farm Fresh Eggs", description: "Brown eggs from free-range chickens", 
                   price: 84, originalPrice: 90, imageURL: "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400", category: "Dairy & Eggs", 
                   subcategory: "Eggs", unit: "12 pieces", brand: "Country Eggs", rating: 4.4, reviewCount: 189, tags: ["protein", "fresh"]),
            
            Product(name: "Amul Cheese Slices", description: "Processed cheese slices perfect for sandwiches", 
                   price: 135, imageURL: "https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=400", category: "Dairy & Eggs", 
                   subcategory: "Cheese", unit: "200g", brand: "Amul", rating: 4.3, reviewCount: 234, tags: ["creamy", "convenient"]),
            
            Product(name: "Greek Yogurt", description: "Thick and creamy Greek style yogurt", 
                   price: 65, originalPrice: 75, imageURL: "https://images.unsplash.com/photo-1571212515416-8c7ad409bcc4?w=400", category: "Dairy & Eggs", 
                   subcategory: "Yogurt", unit: "200g", brand: "Mother Dairy", rating: 4.5, reviewCount: 156, tags: ["healthy", "probiotic"]),
            
            // Meat & Seafood
            Product(name: "Fresh Chicken Breast", description: "Boneless chicken breast, antibiotic-free", 
                   price: 250, imageURL: "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400", category: "Meat & Seafood", 
                   subcategory: "Chicken", unit: "500g", brand: "Licious", rating: 4.6, reviewCount: 345, tags: ["fresh", "protein"]),
            
            Product(name: "Rohu Fish", description: "Fresh water fish, cleaned and cut", 
                   price: 180, originalPrice: 200, imageURL: "https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=400", category: "Meat & Seafood", 
                   subcategory: "Fish", unit: "500g", brand: "FreshToHome", rating: 4.4, reviewCount: 123, tags: ["fresh", "omega3"]),
            
            // Pantry Staples
            Product(name: "Basmati Rice", description: "Premium aged basmati rice with long grains", 
                   price: 185, originalPrice: 200, imageURL: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400", category: "Pantry Staples", 
                   subcategory: "Rice", unit: "1 kg", brand: "India Gate", rating: 4.8, reviewCount: 678, tags: ["premium", "aromatic"]),
            
            Product(name: "Wheat Flour", description: "Fresh ground whole wheat flour", 
                   price: 45, imageURL: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400", category: "Pantry Staples", 
                   subcategory: "Flour", unit: "1 kg", brand: "Aashirvaad", rating: 4.5, reviewCount: 456, tags: ["whole grain", "fresh"]),
            
            Product(name: "Sunflower Oil", description: "Refined sunflower cooking oil", 
                   price: 140, originalPrice: 155, imageURL: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400", category: "Pantry Staples", 
                   subcategory: "Oil", unit: "1L", brand: "Fortune", rating: 4.3, reviewCount: 234, tags: ["cooking", "healthy"]),
            
            Product(name: "Turmeric Powder", description: "Pure turmeric powder with natural color", 
                   price: 25, imageURL: "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=400", category: "Pantry Staples", 
                   subcategory: "Spices", unit: "100g", brand: "MDH", rating: 4.6, reviewCount: 189, tags: ["spice", "natural"]),
            
            // Snacks & Beverages
            Product(name: "Lay's Classic Chips", description: "Crispy potato chips with classic salted flavor", 
                   price: 20, imageURL: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400", category: "Snacks & Beverages", 
                   subcategory: "Chips", unit: "52g", brand: "Lay's", rating: 4.2, reviewCount: 567, tags: ["crispy", "snack"]),
            
            Product(name: "Oreo Cookies", description: "Chocolate sandwich cookies with cream filling", 
                   price: 25, originalPrice: 30, imageURL: "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400", category: "Snacks & Beverages", 
                   subcategory: "Biscuits", unit: "120g", brand: "Oreo", rating: 4.7, reviewCount: 789, tags: ["sweet", "chocolate"]),
            
            Product(name: "Coca Cola", description: "Refreshing cola soft drink", 
                   price: 40, imageURL: "https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=400", category: "Snacks & Beverages", 
                   subcategory: "Soft Drinks", unit: "600ml", brand: "Coca Cola", rating: 4.1, reviewCount: 234, tags: ["refreshing", "cold"]),
            
            Product(name: "Real Mango Juice", description: "100% natural mango fruit juice", 
                   price: 35, originalPrice: 40, imageURL: "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400", category: "Snacks & Beverages", 
                   subcategory: "Juices", unit: "200ml", brand: "Real", rating: 4.4, reviewCount: 345, tags: ["natural", "vitamin"]),
            
            // Personal Care
            Product(name: "Dove Soap", description: "Moisturizing beauty bar with 1/4 moisturizing cream", 
                   price: 45, originalPrice: 50, imageURL: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400", category: "Personal Care", 
                   subcategory: "Skincare", unit: "100g", brand: "Dove", rating: 4.5, reviewCount: 456, tags: ["moisturizing", "gentle"]),
            
            Product(name: "Head & Shoulders Shampoo", description: "Anti-dandruff shampoo for healthy scalp", 
                   price: 180, imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400", category: "Personal Care", 
                   subcategory: "Hair Care", unit: "400ml", brand: "Head & Shoulders", rating: 4.3, reviewCount: 234, tags: ["anti-dandruff", "clean"]),
            
            Product(name: "Colgate Toothpaste", description: "Complete care toothpaste for healthy teeth", 
                   price: 95, originalPrice: 105, imageURL: "https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400", category: "Personal Care", 
                   subcategory: "Oral Care", unit: "200g", brand: "Colgate", rating: 4.6, reviewCount: 567, tags: ["fluoride", "fresh"]),
            
            // Household
            Product(name: "Vim Dishwash Gel", description: "Powerful grease cutting dishwash gel", 
                   price: 85, imageURL: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=400", category: "Household", 
                   subcategory: "Cleaning", unit: "500ml", brand: "Vim", rating: 4.4, reviewCount: 234, tags: ["cleaning", "grease-cutting"]),
            
            Product(name: "Surf Excel Detergent", description: "Removes tough stains with easy wash technology", 
                   price: 245, originalPrice: 260, imageURL: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400", category: "Household", 
                   subcategory: "Detergent", unit: "1 kg", brand: "Surf Excel", rating: 4.5, reviewCount: 345, tags: ["stain-removal", "effective"])
        ]
    }
} 