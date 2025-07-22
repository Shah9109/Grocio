import Foundation
import Combine

class CartService: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var totalAmount: Double = 0
    @Published var itemCount: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCartFromStorage()
        
        // Update calculations whenever cart changes
        $cartItems
            .sink { [weak self] items in
                self?.updateCalculations()
            }
            .store(in: &cancellables)
    }
    
    private func updateCalculations() {
        totalAmount = cartItems.reduce(0) { $0 + $1.totalPrice }
        itemCount = cartItems.reduce(0) { $0 + $1.quantity }
        saveCartToStorage()
    }
    
    func addToCart(_ product: Product, quantity: Int = 1) {
        if let existingItemIndex = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[existingItemIndex].quantity += quantity
        } else {
            let cartItem = CartItem(product: product, quantity: quantity)
            cartItems.append(cartItem)
        }
    }
    
    func removeFromCart(_ cartItem: CartItem) {
        cartItems.removeAll { $0.id == cartItem.id }
    }
    
    func updateQuantity(for cartItem: CartItem, quantity: Int) {
        guard quantity > 0 else {
            removeFromCart(cartItem)
            return
        }
        
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            cartItems[index].quantity = quantity
        }
    }
    
    func increaseQuantity(for cartItem: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            cartItems[index].quantity += 1
        }
    }
    
    func decreaseQuantity(for cartItem: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                removeFromCart(cartItem)
            }
        }
    }
    
    func getQuantity(for product: Product) -> Int {
        return cartItems.first { $0.product.id == product.id }?.quantity ?? 0
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    func getTotalDeliveryAmount() -> Double {
        let deliveryFee: Double = totalAmount > 500 ? 0.0 : 40.0
        return totalAmount + deliveryFee
    }
    
    // MARK: - Local Storage
    private func saveCartToStorage() {
        if let encoded = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(encoded, forKey: "cart_items")
        }
    }
    
    private func loadCartFromStorage() {
        if let data = UserDefaults.standard.data(forKey: "cart_items"),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            cartItems = decoded
        }
    }
} 