//
//  CardSwipeDirection.swift
//  SwipeCardsKit
//
//  Created by Beka Demuradze on 04.05.25.
//

import Foundation

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
