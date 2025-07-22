import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var productService = ProductService()
    @StateObject private var cartService = CartService()
    @StateObject private var orderService = OrderService()
    @StateObject private var wishlistService = WishlistService()
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            CategoriesView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "square.grid.2x2.fill" : "square.grid.2x2")
                    Text("Categories")
                }
                .tag(1)
            
            CartView()
                .tabItem {
                    ZStack {
                        Image(systemName: selectedTab == 2 ? "cart.fill" : "cart")
                        
                        if cartService.itemCount > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text("\(cartService.itemCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                    }
                    Text("Cart")
                }
                .tag(2)
            
            WishlistView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "heart.fill" : "heart")
                    Text("Wishlist")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.primaryGreen)
        .environmentObject(productService)
        .environmentObject(cartService)
        .environmentObject(orderService)
        .environmentObject(wishlistService)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
} 