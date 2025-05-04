//
//  Configuration.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 04.05.25.
//

import SwiftUI

final class Configuration<Item: Identifiable>: ObservableObject {
    @Published var triggerThreshold: CGFloat = 150
    @Published var onSwipeEnd: ((Item, CardSwipeDirection) -> Void)?
    @Published var onNoMoreCardsLeft: (() -> Void)?
    let visibleCount = 4
}
