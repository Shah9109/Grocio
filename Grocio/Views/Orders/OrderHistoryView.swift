import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject var orderService: OrderService
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedOrder: Order?
    @State private var animateItems = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                if orderService.orders.isEmpty {
                    emptyOrdersView
                } else {
                    VStack(spacing: 0) {
                        headerView
                        ordersList
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Order History")
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                withAnimation(.gentleBounce.delay(0.2)) {
                    animateItems = true
                }
            }
        }
        .fullScreenCover(item: $selectedOrder) { order in
            OrderTrackingView(order: order)
                .environmentObject(orderService)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(orderService.orders.count) orders")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick Stats
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Total Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(totalSpent.currencyFormat)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
            }
            
            // Order Status Summary
            HStack(spacing: 16) {
                StatusSummaryCard(
                    status: .delivered,
                    count: deliveredCount,
                    color: .green
                )
                
                StatusSummaryCard(
                    status: .onTheWay,
                    count: activeCount,
                    color: .blue
                )
                
                StatusSummaryCard(
                    status: .cancelled,
                    count: cancelledCount,
                    color: .red
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(orderService.orders.enumerated()), id: \.element.id) { index, order in
                    OrderHistoryCard(order: order) {
                        selectedOrder = order
                    }
                    .scaleEffect(animateItems ? 1 : 0.9)
                    .opacity(animateItems ? 1 : 0)
                    .animation(.gentleBounce.delay(Double(index) * 0.1), value: animateItems)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyOrdersView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.primaryGreen.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bag")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.primaryGreen)
            }
            
            VStack(spacing: 12) {
                Text("No orders yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("When you place your first order, it will appear here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
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
            
            Spacer()
        }
    }
    
    private var totalSpent: Double {
        orderService.orders.reduce(0) { $0 + $1.finalAmount }
    }
    
    private var deliveredCount: Int {
        orderService.orders.filter { $0.status == .delivered }.count
    }
    
    private var activeCount: Int {
        orderService.orders.filter { [.placed, .confirmed, .packed, .onTheWay].contains($0.status) }.count
    }
    
    private var cancelledCount: Int {
        orderService.orders.filter { $0.status == .cancelled }.count
    }
}

struct StatusSummaryCard: View {
    let status: OrderStatus
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var displayName: String {
        switch status {
        case .delivered: return "Delivered"
        case .onTheWay: return "Active"
        case .cancelled: return "Cancelled"
        default: return status.displayName
        }
    }
}

struct OrderHistoryCard: View {
    let order: Order
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Order Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(order.id?.suffix(8) ?? "12345678")")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(order.orderDate.orderDateFormat)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(order.finalAmount.currencyFormat)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryGreen)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                            
                            Text(order.status.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }
                    }
                }
                
                // Order Items Preview
                if !order.items.isEmpty {
                    Divider()
                    
                    HStack(spacing: 12) {
                        // First item image
                        AsyncImage(url: URL(string: order.items.first?.product.imageURL ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(order.items.first?.product.name ?? "")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if order.items.count > 1 {
                                Text("+\(order.items.count - 1) more items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(order.items.first?.quantity ?? 0) × \(order.items.first?.product.unit ?? "")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if order.status != .delivered && order.status != .cancelled {
                            Text("Track Order")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryGreen)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.primaryGreen.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Delivery Info (if delivered)
                if order.status == .delivered, let deliveryTime = order.actualDeliveryTime {
                    Divider()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Text("Delivered on \(deliveryTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Button("Reorder") {
                            // Handle reorder
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.primaryGreen.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusColor: Color {
        switch order.status {
        case .placed: return .blue
        case .confirmed: return .orange
        case .packed: return .purple
        case .onTheWay: return .indigo
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
}

#Preview {
    OrderHistoryView()
        .environmentObject(OrderService())
} 