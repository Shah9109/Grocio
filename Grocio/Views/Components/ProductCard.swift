import SwiftUI

struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    @State private var showProductDetail = false
    @State private var animateAddToCart = false
    @State private var showQuantitySelector = false
    
    private var isInCart: Bool {
        cartService.getQuantity(for: product) > 0
    }
    
    private var quantity: Int {
        cartService.getQuantity(for: product)
    }
    
    var body: some View {
        Button(action: {
            showProductDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Product Image and Wishlist
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: product.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 120)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Wishlist Button
                    Button(action: {
                        withAnimation(.quickSpring) {
                            wishlistService.toggleWishlist(product)
                        }
                    }) {
                        Image(systemName: wishlistService.isInWishlist(product) ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(wishlistService.isInWishlist(product) ? .red : .gray)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(8)
                    .scaleEffect(wishlistService.isInWishlist(product) ? 1.2 : 1.0)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Brand
                    if let brand = product.brand {
                        Text(brand.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    // Product Name
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Unit
                    Text(product.unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        
                        Text(String(format: "%.1f", product.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text("(\(product.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    // Price and Discount
                    HStack(alignment: .bottom, spacing: 4) {
                        Text(product.price.currencyFormat)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let originalPrice = product.originalPrice, originalPrice > product.price {
                            Text(originalPrice.currencyFormat)
                                .font(.caption)
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let discount = product.discountPercentage {
                            Text("\(discount)% OFF")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Add to Cart Button
                HStack {
                    if isInCart {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.quickSpring) {
                                    if let item = cartService.cartItems.first(where: { $0.product.id == product.id }) {
                                        cartService.decreaseQuantity(for: item)
                                    }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryGreen)
                                    .frame(width: 24, height: 24)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primaryGreen, lineWidth: 1)
                                    )
                            }
                            
                            Text("\(quantity)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .frame(minWidth: 20)
                            
                            Button(action: {
                                withAnimation(.quickSpring) {
                                    if let item = cartService.cartItems.first(where: { $0.product.id == product.id }) {
                                        cartService.increaseQuantity(for: item)
                                    }
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.primaryGreen)
                                    .clipShape(Circle())
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Button(action: {
                            withAnimation(.quickSpring) {
                                cartService.addToCart(product)
                                animateAddToCart = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    animateAddToCart = false
                                }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                
                                Text("ADD")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.primaryGreen)
                            .cornerRadius(8)
                        }
                        .scaleEffect(animateAddToCart ? 1.1 : 1.0)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showProductDetail) {
            ProductDetailView(product: product)
                .environmentObject(cartService)
                .environmentObject(wishlistService)
        }
    }
}

struct FeaturedProductCard: View {
    let product: Product
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    @State private var showProductDetail = false
    
    var body: some View {
        Button(action: {
            showProductDetail = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Product Image
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 100, height: 80)
                .background(Color.white)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(product.price.currencyFormat)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
                .frame(width: 100, alignment: .leading)
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showProductDetail) {
            ProductDetailView(product: product)
                .environmentObject(cartService)
                .environmentObject(wishlistService)
        }
    }
}

#Preview {
    let sampleProduct = Product(
        name: "Fresh Bananas",
        description: "Sweet and ripe yellow bananas",
        price: 40,
        originalPrice: 50,
        imageURL: "banana",
        category: "Fruits & Vegetables",
        unit: "1 dozen",
        brand: "Farm Fresh",
        rating: 4.3,
        reviewCount: 245,
        tags: ["fresh", "organic"]
    )
    
    return VStack {
        ProductCard(product: sampleProduct)
            .environmentObject(CartService())
            .environmentObject(WishlistService())
        
        FeaturedProductCard(product: sampleProduct)
            .environmentObject(CartService())
            .environmentObject(WishlistService())
    }
    .padding()
} 