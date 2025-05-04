//
//  SwipeCardsView.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 27.04.25.
//

import SwiftUI

public struct CardSwipeView<Item: Identifiable, Content: View>: View {
    @State private var configuration = Configuration<Item>()
    @State private var items: [Item]
    @State private var poppedItem: Item?
    @State private var poppedOffset: CGFloat = 0
    @State private var poppedDirection: CardSwipeDirection = .idle
    @State private var lastDirection: CardSwipeDirection = .idle
    @State private var offsetX: CGFloat = 0
    
    private let content: (Item, _ fraction: CGFloat, _ isRight: CardSwipeDirection) -> Content

    public init(
        items: [Item],
        @ViewBuilder content: @escaping (Item, _ fraction: CGFloat, _ isRight: CardSwipeDirection) -> Content
    ) {
        self._items = State(wrappedValue: items)
        self.content = content
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                offsetX = value.translation.width
                let newDirection = CardSwipeDirection(offset: offsetX)
                if lastDirection != newDirection {
                    lastDirection = newDirection
                }
            }
            .onEnded { value in
                if abs(value.translation.width) < configuration.triggerThreshold {
                    withAnimation(.bouncy) {
                        offsetX = 0
                    }
                } else if !items.isEmpty {
                    poppedOffset = offsetX
                    poppedDirection = lastDirection
                    poppedItem = items.removeFirst()
                    if let poppedItem {
                        configuration.onSwipeEnd?(poppedItem, lastDirection)
                    }
                    offsetX = 0
                }
            }
    }

    public var body: some View {
        ZStack {
            ForEach(Array(items.prefix(configuration.visibleCount).enumerated()), id: \.element.id) { index, item in
                let fraction = index == 0 ? min(abs(offsetX) / configuration.triggerThreshold, 1) : 0
                
                content(item, fraction, lastDirection)
                    .modifier(
                        CardSwipeEffect(
                            index: index,
                            offsetX: offsetX,
                            triggerThreshold: configuration.triggerThreshold
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2/3, contentMode: .fit)
        .overlay {
            if let poppedItem {
                content(poppedItem, 1, poppedDirection)
                    .modifier(
                        CardSwipeEffect(
                            index: 0,
                            offsetX: poppedOffset,
                            triggerThreshold: configuration.triggerThreshold
                        )
                    )
                    .id(poppedItem.id)
                    .onAppear {
                        if #available(iOS 17.0, *) {
                            withAnimation(.spring(duration: 0.5)) {
                                poppedOffset *= 3
                            } completion: {
                                self.poppedItem = nil
                                
                                if items.isEmpty {
                                    configuration.onNoMoreCardsLeft?()
                                }
                            }
                        } else {
                            withAnimation(.spring(duration: 0.5)) {
                                poppedOffset *= 3
                            }
                            
                            Task {
                                try? await Task.sleep(nanoseconds: (1 * NSEC_PER_SEC) / 2)
                                
                                self.poppedItem = nil
                                
                                if items.isEmpty {
                                    configuration.onNoMoreCardsLeft?()
                                }
                            }
                        }
                    }
            }
        }
        .gesture(swipeGesture)
    }
}

public extension CardSwipeView {
    func triggerThreshold(_ newValue: CGFloat) -> CardSwipeView {
        configuration.triggerThreshold = newValue
        return self
    }
    
    func onSwipeEnd(_ newValue: @escaping (Item, CardSwipeDirection) -> Void) -> CardSwipeView {
        configuration.onSwipeEnd = newValue
        return self
    }
    
    func onNoMoreCardsLeft(_ newValue: @escaping () -> Void) -> CardSwipeView {
        configuration.onNoMoreCardsLeft = newValue
        return self
    }
}
