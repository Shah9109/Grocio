import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var authService: AuthService
    @State private var showCheckout = false
    @State private var animateItems = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                if cartService.cartItems.isEmpty {
                    emptyCartView
                } else {
                    VStack(spacing: 0) {
                        headerView
                        
                        // Scrollable cart items list
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(cartService.cartItems.enumerated()), id: \.element.id) { index, item in
                                    CartItemRow(item: item)
                                        .environmentObject(cartService)
                                        .scaleEffect(animateItems ? 1 : 0.8)
                                        .opacity(animateItems ? 1 : 0)
                                        .animation(.gentleBounce.delay(Double(index) * 0.1), value: animateItems)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        }
                        
                        checkoutSection
                            .padding(.bottom, 10) // Reduced padding to 10pt
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
        .sheet(isPresented: $showCheckout) {
            CheckoutView()
                .environmentObject(cartService)
                .environmentObject(orderService)
                .environmentObject(authService)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Cart")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !cartService.cartItems.isEmpty {
                    Button("Clear All") {
                        withAnimation(.quickSpring) {
                            cartService.clearCart()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                }
            }
            .padding(.top, 44) // Add padding for status bar
            
            if !cartService.cartItems.isEmpty {
                HStack {
                    Text("\(cartService.itemCount) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Total: \(cartService.totalAmount.currencyFormat)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var checkoutSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                // Checkout Button
                Button(action: {
                    showCheckout = true
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                            .font(.headline)
                        
                        Text("Proceed to Checkout")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(cartService.getTotalDeliveryAmount().currencyFormat)
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
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
                .padding(.bottom, 8)
                
                // Price Breakdown
                VStack(spacing: 12) {
                    HStack {
                        Text("Subtotal")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(cartService.totalAmount.currencyFormat)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        HStack(spacing: 4) {
                            Text("Delivery Fee")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            if cartService.totalAmount > 500 {
                                Text("(Free on orders above ₹500)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        Text(cartService.totalAmount > 500 ? "FREE" : "₹40")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(cartService.totalAmount > 500 ? .green : .primary)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(cartService.getTotalDeliveryAmount().currencyFormat)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                    }
                }
                .padding(16)
                .background(Color.lightGray.opacity(0.5))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: -4)
            )
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "cart")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.primaryGreen)
            }
            
            VStack(spacing: 12) {
                Text("Your cart is empty")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Add some products to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to home/categories
            }) {
                Text("Start Shopping")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryGreen)
                    .cornerRadius(16)
                    .shadow(color: Color.primaryGreen.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.bottom, 10) // Reduced padding to 10pt
    }
}

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartService: CartService
    @State private var dragOffset: CGSize = .zero
    @State private var showDeleteButton = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Delete Button (revealed on swipe)
            if showDeleteButton {
                Button(action: {
                    withAnimation(.quickSpring) {
                        cartService.removeFromCart(item)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                }
                .transition(.move(edge: .trailing))
            }
            
            // Item Content
            HStack(alignment: .center, spacing: 12) {
                // Product Image
                AsyncImage(url: URL(string: item.product.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(Color.white)
                
                // Product Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.product.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(item.product.unit)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(item.product.price.currencyFormat)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Quantity Controls
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.quickSpring) {
                                cartService.decreaseQuantity(for: item)
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryGreen)
                                .frame(width: 28, height: 28)
                                .background(Color.white)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.primaryGreen, lineWidth: 1)
                                )
                        }
                        
                        Text("\(item.quantity)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 25)
                        
                        Button(action: {
                            withAnimation(.quickSpring) {
                                cartService.increaseQuantity(for: item)
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.primaryGreen)
                                .clipShape(Circle())
                        }
                    }
                    
                    Text(item.totalPrice.currencyFormat)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.leading, 4)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .offset(x: dragOffset.width)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        withAnimation(.quickSpring) {
                            if value.translation.width < -100 {
                                showDeleteButton = true
                                dragOffset = CGSize(width: -60, height: 0)
                            } else {
                                showDeleteButton = false
                                dragOffset = .zero
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CartView()
        .environmentObject(CartService())
        .environmentObject(OrderService())
        .environmentObject(AuthService())
} 