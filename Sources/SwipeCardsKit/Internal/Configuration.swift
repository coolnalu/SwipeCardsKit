//
//  Configuration.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 04.05.25.
//

import SwiftUI

final class Configuration<Item: Identifiable> {
    var triggerThreshold: CGFloat = 150
    var onSwipeEnd: ((Item, CardSwipeDirection) -> Void)?
    var onThresholdPassed: (() -> Void)?
    var onNoMoreCardsLeft: (() -> Void)?
    let visibleCount = 4
}
