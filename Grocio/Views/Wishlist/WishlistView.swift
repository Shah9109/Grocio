import SwiftUI

struct WishlistView: View {
    @EnvironmentObject var wishlistService: WishlistService
    @EnvironmentObject var cartService: CartService
    @State private var animateItems = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                if wishlistService.wishlistItems.isEmpty {
                    emptyWishlistView
                } else {
                    VStack(spacing: 0) {
                        headerView
                        wishlistItemsGrid
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.gentleBounce.delay(0.2)) {
                    animateItems = true
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Wishlist")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !wishlistService.wishlistItems.isEmpty {
                    Button("Clear All") {
                        withAnimation(.quickSpring) {
                            wishlistService.clearWishlist()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            
            if !wishlistService.wishlistItems.isEmpty {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Text("\(wishlistService.wishlistItems.count) items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Add All to Cart") {
                        withAnimation(.quickSpring) {
                            for product in wishlistService.wishlistItems {
                                cartService.addToCart(product)
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var wishlistItemsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(Array(wishlistService.wishlistItems.enumerated()), id: \.element.id) { index, product in
                    WishlistProductCard(product: product)
                        .environmentObject(cartService)
                        .environmentObject(wishlistService)
                        .scaleEffect(animateItems ? 1 : 0.8)
                        .opacity(animateItems ? 1 : 0)
                        .animation(.gentleBounce.delay(Double(index) * 0.1), value: animateItems)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyWishlistView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("Your wishlist is empty")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Save your favorite items to find them easily later")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                // Navigate to home/categories
            }) {
                Text("Start Browsing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct WishlistProductCard: View {
    let product: Product
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    @State private var showProductDetail = false
    @State private var animateRemoval = false
    
    private var isInCart: Bool {
        cartService.getQuantity(for: product) > 0
    }
    
    var body: some View {
        Button(action: {
            showProductDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Product Image with Remove Button
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
                    
                    // Remove from Wishlist Button
                    Button(action: {
                        withAnimation(.quickSpring) {
                            animateRemoval = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                wishlistService.removeFromWishlist(product)
                            }
                        }
                    }) {
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundColor(.red)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(8)
                    .scaleEffect(animateRemoval ? 0.8 : 1.2)
                    .opacity(animateRemoval ? 0.5 : 1.0)
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
                    
                    // Unit and Rating
                    HStack {
                        Text(product.unit)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text(String(format: "%.1f", product.rating))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
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
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Add to Cart Button
                Button(action: {
                    withAnimation(.quickSpring) {
                        cartService.addToCart(product)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isInCart ? "checkmark.circle.fill" : "cart.badge.plus")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text(isInCart ? "ADDED" : "ADD TO CART")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(isInCart ? .green : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isInCart ? Color.green.opacity(0.1) : Color.primaryGreen)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isInCart ? Color.green : Color.clear, lineWidth: 1)
                    )
                }
                .disabled(isInCart)
                .scaleEffect(isInCart ? 1.05 : 1.0)
                .animation(.quickSpring, value: isInCart)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .scaleEffect(animateRemoval ? 0.95 : 1.0)
            .opacity(animateRemoval ? 0.7 : 1.0)
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
    WishlistView()
        .environmentObject(WishlistService())
        .environmentObject(CartService())
} 