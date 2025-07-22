import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedAddress = Address(street: "123 Main Street", city: "Mumbai", state: "Maharashtra", zipCode: "400001", isDefault: true)
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var orderNotes = ""
    @State private var showOrderPlaced = false
    @State private var isPlacingOrder = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Delivery Address
                        addressSection
                        
                        // Order Summary
                        orderSummarySection
                        
                        // Payment Method
                        paymentMethodSection
                        
                        // Order Notes
                        orderNotesSection
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                
                // Place Order Button
                placeOrderButton
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Checkout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .fullScreenCover(isPresented: $showOrderPlaced) {
            if let order = orderService.currentOrder {
                OrderTrackingView(order: order)
                    .environmentObject(orderService)
            }
        }
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Delivery Address")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundColor(.primaryGreen)
                    
                    Text("Home")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if selectedAddress.isDefault {
                        Text("DEFAULT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.primaryGreen)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        // Show address selection
                    }
                    .font(.caption)
                    .foregroundColor(.primaryGreen)
                }
                
                Text(selectedAddress.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryGreen, lineWidth: 1)
            )
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(cartService.cartItems, id: \.id) { item in
                    HStack {
                        AsyncImage(url: URL(string: item.product.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("\(item.quantity) x \(item.product.price.currencyFormat)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.totalPrice.currencyFormat)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                Divider()
                
                VStack(spacing: 6) {
                    HStack {
                        Text("Subtotal")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(cartService.totalAmount.currencyFormat)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Delivery Fee")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(cartService.totalAmount > 500 ? "FREE" : "₹40")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(cartService.totalAmount > 500 ? .green : .primary)
                    }
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(cartService.getTotalDeliveryAmount().currencyFormat)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    PaymentMethodRow(
                        method: method,
                        isSelected: selectedPaymentMethod == method
                    ) {
                        selectedPaymentMethod = method
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private var orderNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Instructions (Optional)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("Add any special delivery instructions...", text: $orderNotes, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    private var placeOrderButton: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Button(action: {
                placeOrder()
            }) {
                HStack {
                    if isPlacingOrder {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                    }
                    
                    Text(isPlacingOrder ? "Placing Order..." : "Place Order")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(cartService.getTotalDeliveryAmount().currencyFormat)
                        .font(.subheadline)
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
            .disabled(isPlacingOrder)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: -4)
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private func placeOrder() {
        isPlacingOrder = true
        
        // Simulate order placement delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let userId = authService.user?.id ?? "guest"
            
            orderService.placeOrder(
                userId: userId,
                cartItems: cartService.cartItems,
                deliveryAddress: selectedAddress,
                paymentMethod: selectedPaymentMethod,
                notes: orderNotes.isEmpty ? nil : orderNotes
            )
            
            cartService.clearCart()
            isPlacingOrder = false
            presentationMode.wrappedValue.dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showOrderPlaced = true
            }
        }
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: paymentIcon)
                    .font(.title3)
                    .foregroundColor(.primaryGreen)
                    .frame(width: 24)
                
                Text(method.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Circle()
                    .fill(isSelected ? Color.primaryGreen : Color.clear)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.primaryGreen, lineWidth: 2)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var paymentIcon: String {
        switch method {
        case .card: return "creditcard"
        case .upi: return "qrcode"
        case .cash: return "banknote"
        }
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartService())
        .environmentObject(OrderService())
        .environmentObject(AuthService())
} 