import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct CartItem: Codable, Identifiable {
    var id = UUID().uuidString
    var product: Product
    var quantity: Int
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
}

struct Order: Codable, Identifiable {
    #if canImport(FirebaseFirestore)
    @DocumentID var id: String?
    #else
    var id: String? = UUID().uuidString
    #endif
    var userId: String
    var items: [CartItem]
    var totalAmount: Double
    var deliveryFee: Double
    var discount: Double
    var finalAmount: Double
    var status: OrderStatus
    var deliveryAddress: Address
    var orderDate: Date
    var estimatedDeliveryTime: Date
    var actualDeliveryTime: Date?
    var paymentMethod: PaymentMethod
    var notes: String?
    
    init(userId: String, items: [CartItem], deliveryAddress: Address, 
         paymentMethod: PaymentMethod = .card, notes: String? = nil) {
        #if !canImport(FirebaseFirestore)
        self.id = UUID().uuidString
        #endif
        self.userId = userId
        self.items = items
        self.totalAmount = items.reduce(0) { $0 + $1.totalPrice }
        self.deliveryFee = totalAmount > 500 ? 0 : 40
        self.discount = 0
        self.finalAmount = totalAmount + deliveryFee - discount
        self.status = .placed
        self.deliveryAddress = deliveryAddress
        self.orderDate = Date()
        self.estimatedDeliveryTime = Date().addingTimeInterval(3600) // 1 hour
        self.paymentMethod = paymentMethod
        self.notes = notes
    }
}

enum OrderStatus: String, CaseIterable, Codable {
    case placed = "placed"
    case confirmed = "confirmed"
    case packed = "packed"
    case onTheWay = "on_the_way"
    case delivered = "delivered"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .placed: return "Order Placed"
        case .confirmed: return "Confirmed"
        case .packed: return "Packed"
        case .onTheWay: return "On the Way"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }
    
    var iconName: String {
        switch self {
        case .placed: return "checkmark.circle.fill"
        case .confirmed: return "hand.thumbsup.fill"
        case .packed: return "shippingbox.fill"
        case .onTheWay: return "truck.box.fill"
        case .delivered: return "house.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

enum PaymentMethod: String, CaseIterable, Codable {
    case card = "card"
    case upi = "upi"
    case cash = "cash"
    
    var displayName: String {
        switch self {
        case .card: return "Credit/Debit Card"
        case .upi: return "UPI"
        case .cash: return "Cash on Delivery"
        }
    }
} 