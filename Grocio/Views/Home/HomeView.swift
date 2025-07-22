import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var productService: ProductService
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    
    @State private var searchText = ""
    @State private var selectedCategory = ""
    @State private var showSearch = false
    @State private var animateProducts = false
    
    private var filteredProducts: [Product] {
        let categoryFiltered = selectedCategory.isEmpty ? productService.products : productService.getProductsByCategory(selectedCategory)
        return searchText.isEmpty ? categoryFiltered : productService.searchProducts(searchText)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.lightGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Search Bar
                        searchBarView
                        
                        // Categories
                        categoriesView
                        
                        // Featured Products (only shown when no search/filter)
                        if searchText.isEmpty && selectedCategory.isEmpty {
                            featuredProductsView
                        }
                        
                        // Products Grid
                        productsGridView
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                productService.loadProducts()
            }
        }
        .onAppear {
            withAnimation(.gentleBounce.delay(0.3)) {
                animateProducts = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning! 👋")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Welcome, \(authService.user?.name.components(separatedBy: " ").first ?? "User")!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: {
                // Notification action
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "bell")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private var searchBarView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search for products...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            .scaleEffect(showSearch ? 1 : 0.95)
            .opacity(showSearch ? 1 : 0.8)
        }
        .onAppear {
            withAnimation(.gentleBounce.delay(0.1)) {
                showSearch = true
            }
        }
    }
    
    private var categoriesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Categories")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to categories
                }
                .font(.subheadline)
                .foregroundColor(.primaryGreen)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All Categories Button
                    CategoryButton(
                        category: Category(name: "All", icon: "square.grid.2x2", color: "gray", subcategories: []),
                        isSelected: selectedCategory.isEmpty
                    ) {
                        withAnimation(.quickSpring) {
                            selectedCategory = ""
                        }
                    }
                    
                    ForEach(productService.categories, id: \.id) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category.name
                        ) {
                            withAnimation(.quickSpring) {
                                selectedCategory = selectedCategory == category.name ? "" : category.name
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var featuredProductsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Products")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(productService.featuredProducts, id: \.id) { product in
                        FeaturedProductCard(product: product)
                            .environmentObject(cartService)
                            .environmentObject(wishlistService)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var productsGridView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(searchText.isEmpty && selectedCategory.isEmpty ? "All Products" : 
                     selectedCategory.isEmpty ? "Search Results" : selectedCategory)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(filteredProducts.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(Array(filteredProducts.enumerated()), id: \.element.id) { index, product in
                    ProductCard(product: product)
                        .environmentObject(cartService)
                        .environmentObject(wishlistService)
                        .scaleEffect(animateProducts ? 1 : 0.8)
                        .opacity(animateProducts ? 1 : 0)
                        .animation(.gentleBounce.delay(Double(index) * 0.1), value: animateProducts)
                }
            }
        }
        .padding(.bottom, 100) // Extra padding for tab bar
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryGreen : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    if category.name == "All" {
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundColor(isSelected ? .white : .primary)
                    } else {
                        Text(category.icon)
                            .font(.title2)
                    }
                }
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primaryGreen : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.quickSpring, value: isSelected)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
} 