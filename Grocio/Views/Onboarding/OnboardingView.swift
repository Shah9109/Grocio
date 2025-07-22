import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showAuthView = false
    
    private let pages = [
        OnboardingPage(
            title: "Fresh Groceries\nDelivered Fast",
            description: "Get fresh fruits, vegetables and daily essentials delivered to your doorstep in minutes",
            imageName: "cart.fill",
            color: Color.green
        ),
        OnboardingPage(
            title: "Wide Range\nof Products",
            description: "Choose from thousands of products across multiple categories at the best prices",
            imageName: "bag.fill",
            color: Color.blue
        ),
        OnboardingPage(
            title: "Quick & Safe\nDelivery",
            description: "Track your orders in real-time and enjoy contactless delivery at your convenience",
            imageName: "truck.box.fill",
            color: Color.orange
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [pages[currentPage].color.opacity(0.1), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    
                    Spacer()
                    
                    // Bottom Section
                    VStack(spacing: 30) {
                        // Page Indicators
                        HStack(spacing: 12) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? pages[currentPage].color : Color.gray.opacity(0.3))
                                    .frame(width: currentPage == index ? 12 : 8, height: currentPage == index ? 12 : 8)
                                    .animation(.gentleBounce, value: currentPage)
                            }
                        }
                        
                        // Buttons
                        VStack(spacing: 16) {
                            Button(action: {
                                if currentPage < pages.count - 1 {
                                    withAnimation(.gentleBounce) {
                                        currentPage += 1
                                    }
                                } else {
                                    showAuthView = true
                                }
                            }) {
                                Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: pages[currentPage].color.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            if currentPage < pages.count - 1 {
                                Button("Skip") {
                                    showAuthView = true
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView()
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var imageScale: CGFloat = 0.8
    @State private var imageOpacity: Double = 0
    @State private var textOffset: CGFloat = 50
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(page.color)
                    .scaleEffect(imageScale)
                    .opacity(imageOpacity)
            }
            
            Spacer()
            
            // Text Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .padding(.horizontal, 40)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.gentleBounce.delay(0.2)) {
                imageScale = 1.0
                imageOpacity = 1.0
            }
            
            withAnimation(.gentleBounce.delay(0.4)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

#Preview {
    OnboardingView()
} 