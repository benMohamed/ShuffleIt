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
