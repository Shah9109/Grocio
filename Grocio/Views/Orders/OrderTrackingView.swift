import SwiftUI

struct OrderTrackingView: View {
    let order: Order
    @EnvironmentObject var orderService: OrderService
    @Environment(\.presentationMode) var presentationMode
    @State private var animateProgress = false
    @State private var showConfetti = false
    
    let statusSteps: [OrderStatus] = [.placed, .confirmed, .packed, .onTheWay, .delivered]
    
    private var currentStepIndex: Int {
        statusSteps.firstIndex(of: order.status) ?? 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Order Header
                        orderHeaderView
                        
                        // Progress Tracker
                        progressTrackerView
                        
                        // Order Details
                        // orderDetailsView - Not needed for this implementation
                        
                        // Delivery Info
                        deliveryInfoView
                        
                        // Order Items
                        orderItemsView
                        
                        // Payment Summary
                        paymentSummaryView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
                
                // Confetti Animation for Delivered Orders
                if showConfetti && order.status == .delivered {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("Track Order")
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                withAnimation(.gentleBounce.delay(0.5)) {
                    animateProgress = true
                }
                
                if order.status == .delivered {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showConfetti = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            showConfetti = false
                        }
                    }
                }
            }
        }
    }
    
    private var orderHeaderView: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [statusColor.opacity(0.2), statusColor.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: order.status.iconName)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(statusColor)
            }
            .scaleEffect(animateProgress ? 1.2 : 1.0)
            .animation(.gentleBounce.delay(0.3), value: animateProgress)
            
            VStack(spacing: 8) {
                Text(order.status.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Order #\(order.id?.suffix(8) ?? "12345678")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if order.status == .delivered {
                    Text("🎉 Your order has been delivered!")
                        .font(.headline)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                } else {
                    Text(getStatusMessage())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var progressTrackerView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Order Progress")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ForEach(Array(statusSteps.enumerated()), id: \.offset) { index, status in
                    HStack {
                        // Step Indicator
                        ZStack {
                            Circle()
                                .fill(index <= currentStepIndex ? statusColor : Color.gray.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .scaleEffect(animateProgress && index <= currentStepIndex ? 1.2 : 1.0)
                                .animation(.gentleBounce.delay(Double(index) * 0.1), value: animateProgress)
                            
                            if index <= currentStepIndex {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(animateProgress ? 1 : 0)
                                    .animation(.gentleBounce.delay(Double(index) * 0.1 + 0.2), value: animateProgress)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(status.displayName)
                                .font(.subheadline)
                                .fontWeight(index <= currentStepIndex ? .semibold : .medium)
                                .foregroundColor(index <= currentStepIndex ? .primary : .secondary)
                            
                            Text(getStepTime(for: status, index: index))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if index <= currentStepIndex {
                            Image(systemName: status.iconName)
                                .font(.title3)
                                .foregroundColor(statusColor)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // Connecting Line
                    if index < statusSteps.count - 1 {
                        Rectangle()
                            .fill(index < currentStepIndex ? statusColor : Color.gray.opacity(0.3))
                            .frame(width: 2, height: 20)
                            .padding(.leading, 26)
                            .scaleEffect(x: 1, y: animateProgress && index < currentStepIndex ? 1 : 0.5, anchor: .top)
                            .animation(.gentleBounce.delay(Double(index) * 0.1 + 0.1), value: animateProgress)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var deliveryInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Delivery Information")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                InfoRow(
                    icon: "clock",
                    title: "Estimated Delivery",
                    value: order.estimatedDeliveryTime.formatted(date: .omitted, time: .shortened),
                    color: .blue
                )
                
                if let actualDeliveryTime = order.actualDeliveryTime {
                    InfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Delivered At",
                        value: actualDeliveryTime.formatted(date: .omitted, time: .shortened),
                        color: .green
                    )
                }
                
                InfoRow(
                    icon: "location.fill",
                    title: "Delivery Address",
                    value: order.deliveryAddress.fullAddress,
                    color: .orange
                )
                
                InfoRow(
                    icon: "creditcard.fill",
                    title: "Payment Method",
                    value: order.paymentMethod.displayName,
                    color: .purple
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var orderItemsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Items (\(order.items.count))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(order.items, id: \.id) { item in
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: item.product.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.white)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.product.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text("\(item.quantity) × \(item.product.price.currencyFormat)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.totalPrice.currencyFormat)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    if item.id != order.items.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var paymentSummaryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Summary")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(order.totalAmount.currencyFormat)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Delivery Fee")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(order.deliveryFee == 0 ? "FREE" : order.deliveryFee.currencyFormat)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(order.deliveryFee == 0 ? .green : .primary)
                }
                
                if order.discount > 0 {
                    HStack {
                        Text("Discount")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("-\(order.discount.currencyFormat)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total Paid")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(order.finalAmount.currencyFormat)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
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
    
    private func getStatusMessage() -> String {
        switch order.status {
        case .placed:
            return "Your order has been placed successfully"
        case .confirmed:
            return "Your order has been confirmed and is being prepared"
        case .packed:
            return "Your order has been packed and ready for pickup"
        case .onTheWay:
            return "Your order is on the way to your address"
        case .delivered:
            return "Your order has been delivered successfully"
        case .cancelled:
            return "Your order has been cancelled"
        }
    }
    
    private func getStepTime(for status: OrderStatus, index: Int) -> String {
        let baseTime = order.orderDate
        let stepTime = baseTime.addingTimeInterval(TimeInterval(index * 900)) // 15 minutes each step
        
        if index <= currentStepIndex {
            return stepTime.formatted(date: .omitted, time: .shortened)
        } else {
            return "Pending"
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                Circle()
                    .fill(Color.random)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? .random(in: -200...200) : 0,
                        y: animate ? .random(in: -400...400) : -100
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 2.0)
                            .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

#Preview {
    let sampleOrder = Order(
        userId: "123",
        items: [],
        deliveryAddress: Address(street: "123 Main Street", city: "Mumbai", state: "Maharashtra", zipCode: "400001", isDefault: true),
        paymentMethod: .card
    )
    
    OrderTrackingView(order: sampleOrder)
        .environmentObject(OrderService())
} 