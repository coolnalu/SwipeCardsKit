//
//  SwipeCardsView.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 27.04.25.
//

import SwiftUI

public struct CardSwipeView<Item: Identifiable & Hashable, Content: View>: View {
    @State private var configuration = Configuration<Item>()
    @State private var poppedItem: Item?
    @State private var poppedOffset: CGFloat = 0
    @State private var poppedDirection: CardSwipeDirection = .idle
    @State private var lastDirection: CardSwipeDirection = .idle
    @State private var offsetX: CGFloat = 0
    @State private var thresholdPassed = false
    
    @Binding private var items: [Item]
    @Binding private var selectedItem: Item?
    @Binding private var popTrigger: CardSwipeDirection?
    private let content: (Item, _ progress: CGFloat, _ direction: CardSwipeDirection) -> Content
    
    private var screenWidth: CGFloat {
        configuration.screenWidth
    }
    
    public init(
        items: Binding<[Item]>,
        selectedItem: Binding<Item?> = .constant(nil),
        popTrigger: Binding<CardSwipeDirection?> = .constant(nil),
        @ViewBuilder content: @escaping (Item, _ progress: CGFloat, _ direction: CardSwipeDirection) -> Content
    ) {
        self._items = items
        self._selectedItem = selectedItem
        self._popTrigger = popTrigger
        self.content = content
        self.selectedItem = self.items.first
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: configuration.minimumDistance)
            .onChanged { value in
                onDragChanged(value)
            }
            .onEnded { value in
                if abs(value.translation.width) < configuration.triggerThreshold {
                    withAnimation(.bouncy) {
                        offsetX = 0
                    }
                } else if !items.isEmpty {
                    popItem()
                }
            }
    }
    
    public var body: some View {
        ZStack {
            ForEach(Array(items.prefix(configuration.visibleCount).enumerated()), id: \.element.id) { index, item in
                let progress = index == 0 ? min(abs(offsetX) / configuration.triggerThreshold, 1) : 0
                
                content(item, progress, lastDirection)
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
        .overlay { poppedCard }
        .gesture(swipeGesture)
        .onChange(of: popTrigger ?? .idle) { newValue in
            guard newValue != .idle else { return }
            lastDirection = newValue
            popItem(notifyCaller: false)
            popTrigger = nil
        }
    }
    
    @ViewBuilder
    var poppedCard: some View {
        if let poppedItem {
            content(poppedItem, min(abs(poppedOffset) / configuration.triggerThreshold, 1), poppedDirection)
                .modifier(
                    CardSwipeEffect(
                        index: 0,
                        offsetX: poppedOffset,
                        triggerThreshold: configuration.triggerThreshold
                    )
                )
                .id(poppedItem.id)
                .onAppear {
                    animatePoppedItem()
                }
        }
    }
    
    func onDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        let correction = correction(for: translation)
        offsetX = translation + correction
        
        let newDirection = CardSwipeDirection(offset: offsetX)
        if lastDirection != newDirection {
            lastDirection = newDirection
        }
        
        let thresholdReached = abs(offsetX) >= configuration.triggerThreshold
        if thresholdReached != thresholdPassed {
            thresholdPassed = thresholdReached
            if thresholdReached {
                configuration.onThresholdPassed?()
            }
        }
    }

    func correction(for translation: CGFloat) -> CGFloat {
        if translation >= configuration.minimumDistance {
            -configuration.minimumDistance
        } else if translation <= -configuration.minimumDistance {
            configuration.minimumDistance
        } else {
            -translation
        }
    }
    
    func animatePoppedItem() {
        let multiplier: CGFloat = poppedDirection == .left ? -1 : 1
        
        if #available(iOS 17.0, *) {
            withAnimation(.spring(duration: 0.5)) {
                poppedOffset += (screenWidth * multiplier)
            } completion: {
                self.poppedItem = nil
                self.poppedOffset = 0
                
                if items.isEmpty {
                    configuration.onNoMoreCardsLeft?()
                }
            }
        } else {
            withAnimation(.spring(duration: 0.5)) {
                poppedOffset += (screenWidth * multiplier)
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
    
    func popItem(notifyCaller: Bool = true) {
        guard !items.isEmpty else { return }
        poppedOffset = offsetX
        poppedDirection = lastDirection
        poppedItem = items.removeFirst()
        selectedItem = items.first
        if let poppedItem, notifyCaller {
            configuration.onSwipeEnd?(poppedItem, lastDirection)
        }
        offsetX = 0
    }
}

public extension CardSwipeView {
    func configure(threshold: CGFloat, minimumDistance: CGFloat) -> CardSwipeView {
        configuration.triggerThreshold = threshold
        configuration.minimumDistance = minimumDistance
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
    
    func onThresholdPassed(_ newValue: @escaping () -> Void) -> CardSwipeView {
        configuration.onThresholdPassed = newValue
        return self
    }
}
