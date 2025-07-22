import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedQuantity = 1
    @State private var showFullDescription = false
    @State private var animateImage = false
    @State private var animateContent = false
    
    private var isInCart: Bool {
        cartService.getQuantity(for: product) > 0
    }
    
    private var cartQuantity: Int {
        cartService.getQuantity(for: product)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Product Image
                        productImageView
                        
                        // Product Info
                        productInfoView
                        
                        // Description
                        descriptionView
                        
                        // Nutritional Info (if available)
                        if product.nutritionalInfo != nil {
                            nutritionalInfoView
                        }
                        
                        // Reviews Section
                        reviewsView
                        
                        Spacer(minLength: 120) // Space for bottom button
                    }
                    .padding(.horizontal, 20)
                }
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.gentleBounce.delay(0.1)) {
                    animateImage = true
                }
                withAnimation(.gentleBounce.delay(0.3)) {
                    animateContent = true
                }
            }
        }
    }
    
    private var productImageView: some View {
        VStack(spacing: 16) {
            // Back Button and Wishlist
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.quickSpring) {
                        wishlistService.toggleWishlist(product)
                    }
                }) {
                    Image(systemName: wishlistService.isInWishlist(product) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(wishlistService.isInWishlist(product) ? .red : .primary)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .scaleEffect(wishlistService.isInWishlist(product) ? 1.2 : 1.0)
            }
            .padding(.top, 50)
            
            // Product Image
            AsyncImage(url: URL(string: product.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 250)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
            .scaleEffect(animateImage ? 1 : 0.8)
            .opacity(animateImage ? 1 : 0)
        }
    }
    
    private var productInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Brand and Category
            HStack {
                if let brand = product.brand {
                    Text(brand.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text(product.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Product Name
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Unit
            Text(product.unit)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Rating and Reviews
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(product.rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(index < Int(product.rating) ? .orange : .gray.opacity(0.5))
                    }
                }
                
                Text(String(format: "%.1f", product.rating))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("(\(product.reviewCount) reviews)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !product.inStock {
                    Text("OUT OF STOCK")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Price
            HStack(alignment: .bottom, spacing: 8) {
                Text(product.price.currencyFormat)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let originalPrice = product.originalPrice, originalPrice > product.price {
                    Text(originalPrice.currencyFormat)
                        .font(.headline)
                        .strikethrough()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let discount = product.discountPercentage {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(discount)% OFF")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("You save \((product.originalPrice ?? 0) - product.price, format: .currency(code: "INR"))")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 4)
        .offset(y: animateContent ? 0 : 20)
        .opacity(animateContent ? 1 : 0)
    }
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About this product")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(product.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(showFullDescription ? nil : 3)
            
            if product.description.count > 100 {
                Button(showFullDescription ? "Show Less" : "Show More") {
                    withAnimation(.quickSpring) {
                        showFullDescription.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.primaryGreen)
            }
            
            // Tags
            if !product.tags.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(product.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.primaryGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryGreen.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var nutritionalInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutritional Information")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            if let nutrition = product.nutritionalInfo {
                VStack(spacing: 8) {
                    NutritionRow(label: "Calories", value: "\(nutrition.calories) kcal")
                    NutritionRow(label: "Protein", value: "\(nutrition.protein)g")
                    NutritionRow(label: "Carbs", value: "\(nutrition.carbs)g")
                    NutritionRow(label: "Fat", value: "\(nutrition.fat)g")
                    
                    if let fiber = nutrition.fiber {
                        NutritionRow(label: "Fiber", value: "\(fiber)g")
                    }
                    
                    if let sugar = nutrition.sugar {
                        NutritionRow(label: "Sugar", value: "\(sugar)g")
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var reviewsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Customer Reviews")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to reviews
                }
                .font(.caption)
                .foregroundColor(.primaryGreen)
            }
            
            VStack(spacing: 12) {
                ReviewRow(rating: 5, comment: "Excellent quality! Fresh and delivered on time.", author: "Priya M.")
                ReviewRow(rating: 4, comment: "Good product, will order again.", author: "Rahul S.")
                ReviewRow(rating: 5, comment: "Best quality in this price range. Highly recommended!", author: "Anjali K.")
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack(spacing: 16) {
                // Quantity Selector
                VStack(spacing: 4) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            if selectedQuantity > 1 {
                                selectedQuantity -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryGreen)
                                .frame(width: 32, height: 32)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        .disabled(selectedQuantity <= 1)
                        
                        Text("\(selectedQuantity)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            selectedQuantity += 1
                        }) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.primaryGreen)
                                .clipShape(Circle())
                        }
                    }
                }
                
                // Add to Cart Button
                Button(action: {
                    withAnimation(.quickSpring) {
                        cartService.addToCart(product, quantity: selectedQuantity)
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.headline)
                        
                        Text(isInCart ? "UPDATE CART" : "ADD TO CART")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("• \((Double(selectedQuantity) * product.price).currencyFormat)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
                .disabled(!product.inStock)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: -4)
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

struct ReviewRow: View {
    let rating: Int
    let comment: String
    let author: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<rating) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    ForEach(rating..<5) { _ in
                        Image(systemName: "star")
                            .font(.caption2)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                Spacer()
                
                Text(author)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            Text(comment)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let sampleProduct = Product(
        name: "Fresh Bananas",
        description: "Sweet and ripe yellow bananas, perfect for smoothies and snacks. Rich in potassium and vitamins.",
        price: 40,
        originalPrice: 50,
        imageURL: "banana",
        category: "Fruits & Vegetables",
        unit: "1 dozen",
        brand: "Farm Fresh",
        rating: 4.3,
        reviewCount: 245,
        tags: ["fresh", "organic", "healthy"]
    )
    
    return ProductDetailView(product: sampleProduct)
        .environmentObject(CartService())
        .environmentObject(WishlistService())
} 