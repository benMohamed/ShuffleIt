import SwiftUI

// MARK: - ShuffleStack
public struct ShuffleStack<Data: RandomAccessCollection, StackContent: View>: View where Data.Element: Identifiable, Data.Index == Int {
    // MARK: - Environments
    @Environment(\.shuffleStackStyle) internal var style
    @Environment(\.shuffleStackAnimation) internal var animation
    @Environment(\.swipeDisabled) internal var disabled
    @Environment(\.shufflingPublisher) internal var shufflingPublisher
    
    // MARK: - States
    @State internal var index: Data.Index
    @State internal var xPosition: CGFloat = .zero
    @State internal var direction: Direction = .left
    @State internal var isLockedLeft: Bool = false
    @State internal var isLockedRight: Bool = false
    @State internal var size: CGSize = .zero
    @State internal var autoShuffling: Bool = false
    
    // MARK: - Properties
    internal let data: Data
    internal let stackContent: (Data.Element) -> StackContent
    
    public var body: some View {
        ZStack {
            Group {
                leftContent
                rightContent
                if disabled {
                    mainContent
                } else {
                    mainContent
                        .gesture(dragGesture)
                }
            }
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: size.height)
        .onPreferenceChange(SizePreferenceKey.self) { size in
            DispatchQueue.main.async {
                self.size = size
            }
        }
        .onReceive(shufflingPublisher) { direction in
            if !autoShuffling && xPosition == 0 {
                performShuffling(direction)
            }
        }
        .disabled(autoShuffling)
    }
}

// MARK: - Initizer
extension ShuffleStack {
    public init(
        _ data: Data,
        initialIndex: Int = 0,
        @ViewBuilder stackContent: @escaping (Data.Element) -> StackContent
    ) {
        self.data = data
        self._index = State(initialValue: initialIndex)
        self.stackContent = stackContent
    }
}
