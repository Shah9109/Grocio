import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
import Combine

class OrderService: ObservableObject {
    @Published var orders: [Order] = []
    @Published var currentOrder: Order?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    #if canImport(FirebaseFirestore)
    private var db = Firestore.firestore()
    #endif
    private var orderStatusTimer: Timer?
    
    init() {
        loadOrders()
    }
    
    func placeOrder(userId: String, cartItems: [CartItem], deliveryAddress: Address, paymentMethod: PaymentMethod = .card, notes: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        let order = Order(userId: userId, items: cartItems, deliveryAddress: deliveryAddress, paymentMethod: paymentMethod, notes: notes)
        
        #if canImport(FirebaseFirestore)
        do {
            try db.collection("orders").addDocument(from: order) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else {
                        self?.currentOrder = order
                        self?.orders.insert(order, at: 0)
                        self?.startOrderTracking(for: order)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
        #else
        // Simulate order placement without Firebase
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var newOrder = order
            newOrder.id = UUID().uuidString
            self.currentOrder = newOrder
            self.orders.insert(newOrder, at: 0)
            self.startOrderTracking(for: newOrder)
            self.isLoading = false
        }
        #endif
    }
    
    private func loadOrders() {
        #if canImport(FirebaseFirestore)
        // In a real app, filter by current user
        db.collection("orders")
            .order(by: "orderDate", descending: true)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                    } else if let documents = snapshot?.documents {
                        do {
                            self?.orders = try documents.compactMap { doc in
                                try doc.data(as: Order.self)
                            }
                        } catch {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        #else
        // Use dummy orders for demonstration
        loadDummyOrders()
        #endif
    }
    
    private func loadDummyOrders() {
        // Create some sample orders for demonstration
        let sampleAddress = Address(street: "123 Main Street", city: "Mumbai", state: "Maharashtra", zipCode: "400001", isDefault: true)
        
        let order1 = createSampleOrder(id: "ORD001", status: .delivered, address: sampleAddress, daysAgo: 7)
        let order2 = createSampleOrder(id: "ORD002", status: .onTheWay, address: sampleAddress, daysAgo: 1)
        let order3 = createSampleOrder(id: "ORD003", status: .placed, address: sampleAddress, daysAgo: 0)
        
        self.orders = [order3, order2, order1] // Most recent first
    }
    
    private func createSampleOrder(id: String, status: OrderStatus, address: Address, daysAgo: Int) -> Order {
        let sampleProduct = Product(name: "Sample Product", description: "Demo product", price: 100, imageURL: "placeholder", category: "Demo", unit: "1 unit")
        let cartItem = CartItem(product: sampleProduct, quantity: 2)
        
        var order = Order(userId: "demo-user", items: [cartItem], deliveryAddress: address)
        order.id = id
        order.status = status
        order.orderDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        
        if status == .delivered {
            order.actualDeliveryTime = Calendar.current.date(byAdding: .hour, value: 1, to: order.orderDate)
        }
        
        return order
    }
    
    private func startOrderTracking(for order: Order) {
        // Simulate real-time order status updates
        var currentOrder = order
        
        orderStatusTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let nextStatus = self.getNextOrderStatus(current: currentOrder.status)
            
            if let nextStatus = nextStatus {
                currentOrder.status = nextStatus
                self.updateOrderStatus(order: currentOrder, newStatus: nextStatus)
                
                if nextStatus == .delivered {
                    currentOrder.actualDeliveryTime = Date()
                    timer.invalidate()
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func getNextOrderStatus(current: OrderStatus) -> OrderStatus? {
        switch current {
        case .placed: return .confirmed
        case .confirmed: return .packed
        case .packed: return .onTheWay
        case .onTheWay: return .delivered
        case .delivered, .cancelled: return nil
        }
    }
    
    private func updateOrderStatus(order: Order, newStatus: OrderStatus) {
        #if canImport(FirebaseFirestore)
        guard let orderId = order.id else { return }
        
        db.collection("orders").document(orderId).updateData([
            "status": newStatus.rawValue
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    // Update local order
                    if let index = self?.orders.firstIndex(where: { $0.id == orderId }) {
                        self?.orders[index].status = newStatus
                    }
                    
                    if self?.currentOrder?.id == orderId {
                        self?.currentOrder?.status = newStatus
                    }
                }
            }
        }
        #else
        // Update locally without Firebase
        DispatchQueue.main.async {
            guard let orderId = order.id else { return }
            
            // Update local order
            if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                self.orders[index].status = newStatus
            }
            
            if self.currentOrder?.id == orderId {
                self.currentOrder?.status = newStatus
            }
        }
        #endif
    }
    
    func cancelOrder(_ order: Order) {
        #if canImport(FirebaseFirestore)
        guard let orderId = order.id else { return }
        
        db.collection("orders").document(orderId).updateData([
            "status": OrderStatus.cancelled.rawValue
        ]) { [weak self] error in
            DispatchQueue.main.async {
                if error == nil {
                    if let index = self?.orders.firstIndex(where: { $0.id == orderId }) {
                        self?.orders[index].status = .cancelled
                    }
                    
                    if self?.currentOrder?.id == orderId {
                        self?.currentOrder?.status = .cancelled
                    }
                    
                    self?.orderStatusTimer?.invalidate()
                }
            }
        }
        #else
        // Cancel locally without Firebase
        guard let orderId = order.id else { return }
        
        if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
            self.orders[index].status = .cancelled
        }
        
        if self.currentOrder?.id == orderId {
            self.currentOrder?.status = .cancelled
        }
        
        self.orderStatusTimer?.invalidate()
        #endif
    }
    
    func getOrderById(_ id: String) -> Order? {
        return orders.first { $0.id == id }
    }
    
    deinit {
        orderStatusTimer?.invalidate()
    }
} 