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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CarouselStack(sneakers, initialIndex: 0) { sneaker, translation in
                SneakerCard(sneaker: sneaker, translation: translation)
            }
            .carouselScale(1)
            .carouselPadding(horizontalSizeClass == .compact ? 20 : 40)
            .carouselSpacing(horizontalSizeClass == .compact ? 10 : 30)
            .carouselStyle(.infiniteScroll)
            .onCarousel { context in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowItems = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        sneaker = sneakers[context.index]
                        isShowItems = true
                    }
                }
            }
            .carouselTrigger(on: carouselPublisher)
            .carouselAnimation(.easeInOut)
        }
        .background {
            if let sneaker = sneaker {
                GeometryReader { proxy in
                    ZStack {
                        Circle()
                            .scale(1.1, anchor: .bottomTrailing)
                            .position(x: proxy.size.width, y: proxy.size.height / 2.5)
                            .foregroundColor(Color(hex: sneaker.theme.tertiary).opacity(0.3))
                        Circle()
                            .scale(0.7, anchor: .bottomTrailing)
                            .position(x: 0, y: proxy.size.height)
                            .foregroundColor(Color(hex: sneaker.theme.primary).opacity(0.45))
                    }
                    .blur(radius: 40)
                    .background(.white)
                    .ignoresSafeArea()
                }
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
