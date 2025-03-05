import SwiftUI
import Combine
import ShuffleIt

struct CarouselStackDemoView: View {
    @Environment(\.dismiss) var dismiss
    @State private var sneaker: Sneaker?
    @State private var isShowItems: Bool = false
    let carouselPublisher = PassthroughSubject<CarouselDirection, Never>()
    let timer = Timer.publish(every: 10, tolerance: 0.1, on: .main, in: .default).autoconnect()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let columns: [GridItem] = .init(repeating: GridItem(.flexible(), spacing: 20, alignment: .leading), count: 2)
    let sneakers: [Sneaker] = .sneakers()
    @State private var currentIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GeometryReader { geometry in
                let cardWidth: CGFloat = geometry.size.width // 70% of screen width
                let spacing: CGFloat = 10
                
                TabView(selection: $currentIndex) {
                    ForEach(sneakers.indices, id: \.self) { index in
                        SneakerCard(sneaker: sneakers[index], translation: 1.0)
                            .frame(width: cardWidth)
                            .animation(.easeInOut, value: currentIndex)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Remove default page dots
                .padding(.horizontal, (geometry.size.width - cardWidth) / 2) // Center the first card
            }

            CarouselStack(sneakers, initialIndex: 0) { sneaker, translation in
                SneakerCard(sneaker: sneaker, translation: translation)
            }
            .carouselScale(1)
            .carouselPadding(horizontalSizeClass == .compact ? 20 : 40)
            .carouselSpacing(horizontalSizeClass == .compact ? 10 : 30)
            .onCarousel { context in
            }
        }
        .onAppear {
            sneaker = sneakers.first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowItems = true
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .background {
                        Circle()
                            .foregroundColor(.black.opacity(0.4))
                            .padding(4)
                    }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
        .onReceive(timer) { _ in
            carouselPublisher.send(.right)
        }
    }
}
