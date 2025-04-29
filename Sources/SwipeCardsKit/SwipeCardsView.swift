//
//  SwipeCardsView.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 27.04.25.
//

import SwiftUI

public struct CardSwipeView<Item: Identifiable, Content: View>: View {
    @State private var items: [Item]
    @State private var poppedItem: Item?
    @State private var poppedOffset: CGFloat = 0
    @State private var poppedDirection: CardSwipeDirection = .idle
    @State private var lastDirection: CardSwipeDirection = .idle
    @State private var offsetX: CGFloat = 0
    @State private var appear = false
    
    private let visibleCount = 4
    private let triggerThreshold: CGFloat = 150
    private let content: (Item, _ fraction: CGFloat, _ isRight: CardSwipeDirection) -> Content
    private let onSwipeEnd: ((Item, CardSwipeDirection) -> Void)?
    private let onNoMoreCardsLeft: (() -> Void)?

    public init(
        items: [Item],
        @ViewBuilder content: @escaping (Item, _ fraction: CGFloat, _ isRight: CardSwipeDirection) -> Content,
        onSwipeEnd: ((Item, CardSwipeDirection) -> Void)? = nil,
        onNoMoreCardsLeft: (() -> Void)? = nil
    ) {
        self._items = State(wrappedValue: items)
        self.content = content
        self.onSwipeEnd = onSwipeEnd
        self.onNoMoreCardsLeft = onNoMoreCardsLeft
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
                if abs(value.translation.width) < triggerThreshold {
                    withAnimation(.bouncy) {
                        offsetX = 0
                    }
                } else if !items.isEmpty {
                    poppedOffset = offsetX
                    poppedDirection = lastDirection
                    poppedItem = items.removeFirst()
                    if let poppedItem {
                        onSwipeEnd?(poppedItem, lastDirection)
                    }
                    offsetX = 0
                }
            }
    }

    public var body: some View {
        ZStack {
            ForEach(Array(items.prefix(visibleCount).enumerated()), id: \.element.id) { index, item in
                let fraction = index == 0 ? min(abs(offsetX) / triggerThreshold, 1) : 0

                content(item, fraction, lastDirection)
                    .modifier(CardSwipeEffect(index: index, offsetX: offsetX, triggerThreshold: triggerThreshold))
                    .modifier(CardAppearEffect(appear: appear, index: index))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2/3, contentMode: .fit)
        .overlay {
            if let poppedItem {
                content(poppedItem, 1, poppedDirection)
                    .modifier(CardSwipeEffect(index: 0, offsetX: poppedOffset, triggerThreshold: triggerThreshold))
                    .id(poppedItem.id)
                    .onAppear {
                        if #available(iOS 17.0, *) {
                            withAnimation(.spring(duration: 0.5)) {
                                poppedOffset *= 3
                            } completion: {
                                self.poppedItem = nil
                                
                                if items.isEmpty {
                                    onNoMoreCardsLeft?()
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
                                    onNoMoreCardsLeft?()
                                }
                            }
                        }
                    }
            }
        }
        .gesture(swipeGesture)
        .rotation3DEffect(.degrees(appear ? 0 : -30), axis: (1, 0, 0))
        .offset(y: appear ? 0 : 280)
        .onAppear {
            withAnimation(.bouncy) {
                appear = true
            }
        }
    }
}

private struct CardSwipeEffect: ViewModifier {
    let index: Int
    let offsetX: CGFloat
    let triggerThreshold: CGFloat

    func body(content: Content) -> some View {
        switch index {
        case 0:
            let angle = Angle(degrees: Double(offsetX) / 20)
            content
                .offset(x: offsetX)
                .rotationEffect(angle, anchor: .bottom)
                .zIndex(4)
        case 1:
            let progress = min(abs(offsetX) / triggerThreshold, 1)
            content
                .offset(y: CGFloat((1 - progress) * 50))
                .scaleEffect(CGFloat(0.9 + progress * 0.1))
                .zIndex(3)
        case 2:
            let progress = min(abs(offsetX) / triggerThreshold, 1)
            content
                .offset(y: CGFloat(110 - progress * 60))
                .scaleEffect(CGFloat(0.8 + progress * 0.1))
                .zIndex(2)
        case 3:
            let progress = min(abs(offsetX) / triggerThreshold, 1)
            content
                .opacity(progress)
                .offset(y: CGFloat(180 - progress * 70))
                .scaleEffect(CGFloat(0.7 + progress * 0.1))
                .zIndex(1)
        default:
            content
                .opacity(0)
        }
    }
}

private struct CardAppearEffect: ViewModifier {
    let appear: Bool
    let index: Int

    func body(content: Content) -> some View {
        switch index {
        case 0:
            content
        case 1:
            content
                .offset(y: CGFloat(appear ? 0 : -50))
        case 2:
            content
                .offset(y: CGFloat(appear ? 0 : -110))
        case 3:
            content
                .offset(y: CGFloat(appear ? 0 : -180))
        default:
            content
        }
    }
}

public enum CardSwipeDirection {
    case left, right, idle
    
    init (offset: CGFloat) {
        if offset > 0 {
            self = .right
        } else if offset == 0 {
            self = .idle
        } else {
            self = .left
        }
    }
}
