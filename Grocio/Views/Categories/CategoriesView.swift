import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var productService: ProductService
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var wishlistService: WishlistService
    
    @State private var selectedCategory: Category?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                if selectedCategory == nil {
                    // Categories Grid
                    categoriesGridView
                } else {
                    // Products in Selected Category
                    categoryProductsView
                }
            }
            .background(Color.lightGray.opacity(0.3))
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                if selectedCategory != nil {
                    Button(action: {
                        withAnimation(.quickSpring) {
                            selectedCategory = nil
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
                
                VStack(alignment: selectedCategory == nil ? .center : .leading) {
                    Text(selectedCategory?.name ?? "Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if selectedCategory != nil {
                        Text("\(productService.getProductsByCategory(selectedCategory!.name).count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if selectedCategory != nil {
                    Button(action: {
                        // Filter or sort options
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            // Search Bar (only for selected category)
            if selectedCategory != nil {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search in \(selectedCategory?.name ?? "category")...", text: $searchText)
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var categoriesGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 20) {
                ForEach(productService.categories, id: \.id) { category in
                    CategoryCardView(category: category) {
                        withAnimation(.quickSpring) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var categoryProductsView: some View {
        let filteredProducts = searchText.isEmpty ? 
            productService.getProductsByCategory(selectedCategory!.name) :
            productService.getProductsByCategory(selectedCategory!.name).filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        
        return ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 8),
                GridItem(.flexible(), spacing: 8)
            ], spacing: 16) {
                ForEach(filteredProducts, id: \.id) { product in
                    ProductCard(product: product)
                        .environmentObject(cartService)
                        .environmentObject(wishlistService)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
}

struct CategoryCardView: View {
    let category: Category
    let action: () -> Void
    @State private var animate = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    categoryColor.opacity(0.2),
                                    categoryColor.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(category.icon)
                        .font(.system(size: 40))
                }
                
                VStack(spacing: 4) {
                    Text(category.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("\(category.subcategories.count) subcategories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Subcategories Preview
                HStack(spacing: 4) {
                    ForEach(category.subcategories.prefix(2), id: \.self) { subcategory in
                        Text(subcategory)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(categoryColor)
                    }
                    
                    if category.subcategories.count > 2 {
                        Text("+\(category.subcategories.count - 2)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .scaleEffect(animate ? 1 : 0.95)
            .opacity(animate ? 1 : 0.8)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.gentleBounce.delay(Double.random(in: 0...0.5))) {
                animate = true
            }
        }
    }
    
    private var categoryColor: Color {
        switch category.color.lowercased() {
        case "green": return .green
        case "blue": return .blue
        case "red": return .red
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        default: return .gray
        }
    }
}

#Preview {
    CategoriesView()
        .environmentObject(ProductService())
        .environmentObject(CartService())
        .environmentObject(WishlistService())
} 