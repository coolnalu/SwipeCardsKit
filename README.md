# SwipeCardsKit

A lightweight, customizable SwiftUI library for creating Tinder-like swipeable card interfaces in your iOS applications.

<p align="center">
  <img src="https://github.com/yourusername/SwipeCardsKit/raw/main/Assets/demo.gif" alt="SwipeCardsKit Demo" width="300">
</p>

## Features

- 🔄 Smooth swipe animations with realistic physics
- 🎨 Fully customizable card appearance
- 📱 iOS 15.0+ support
- 🔌 Simple integration with SwiftUI
- 📊 Swipe direction tracking (left/right)
- 🔄 Card stack management
- 🎭 Customizable animations
- 📢 Callback support for swipe actions

## Requirements

- iOS 15.0+
- Swift 6.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SwipeCardsKit to your project using Swift Package Manager:

1. In Xcode, select **File** > **Add Packages...**
2. Enter the repository URL: `https://github.com/yourusername/SwipeCardsKit.git`
3. Select the version you want to use

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwipeCardsKit.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI
import SwipeCardsKit

struct ContentView: View {
    // Sample data
    @State private var cards = [
        Card(id: 1, title: "Card 1", color: .red),
        Card(id: 2, title: "Card 2", color: .blue),
        Card(id: 3, title: "Card 3", color: .green),
        Card(id: 4, title: "Card 4", color: .orange),
        Card(id: 5, title: "Card 5", color: .purple)
    ]
    
    var body: some View {
        VStack {
            CardSwipeView(items: cards) { card, fraction, direction in
                // Card content
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(card.color)
                    
                    VStack {
                        Text(card.title)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        // Show direction indicator based on swipe
                        if fraction > 0 {
                            HStack {
                                if direction == .left {
                                    Text("NOPE")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                        .opacity(fraction)
                                } else if direction == .right {
                                    Text("LIKE")
                                        .font(.title)
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                        .opacity(fraction)
                                }
                            }
                        }
                    }
                }
                .frame(width: 300, height: 400)
                .shadow(radius: 5)
            } onSwipeEnd: { card, direction in
                print("Swiped \(direction) on card: \(card.title)")
            } onNoMoreCardsLeft: {
                print("No more cards left!")
            }
        }
    }
}

// Sample card model
struct Card: Identifiable {
    let id: Int
    let title: String
    let color: Color
}
```

## Usage

### Basic Implementation

The `CardSwipeView` is the main component of SwipeCardsKit. It takes a collection of items that conform to `Identifiable` and a view builder to create the card content.

```swift
CardSwipeView(
    items: yourItems,
    content: { item, fraction, direction in
        // Your card content here
    },
    onSwipeEnd: { item, direction in
        // Handle swipe end
    },
    onNoMoreCardsLeft: {
        // Handle when all cards are swiped
    }
)
```

### Parameters

- `items`: An array of items that conform to `Identifiable`
- `content`: A view builder that creates the content for each card
  - `item`: The current item
  - `fraction`: A value between 0 and 1 indicating how far the card has been swiped
  - `direction`: The current swipe direction (`.left`, `.right`, or `.idle`)
- `onSwipeEnd`: A callback that is called when a card is swiped
  - `item`: The swiped item
  - `direction`: The direction the card was swiped (`.left` or `.right`)
- `onNoMoreCardsLeft`: A callback that is called when all cards have been swiped

### Swipe Direction

The `CardSwipeDirection` enum has three cases:

- `.left`: The card was swiped to the left
- `.right`: The card was swiped to the right
- `.idle`: The card is not being swiped

## Advanced Usage

### Custom Card Appearance

You have full control over the appearance of your cards:

```swift
CardSwipeView(items: cards) { card, fraction, direction in
    VStack {
        Image(card.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 300)
            .clipped()
        
        VStack(alignment: .leading) {
            Text(card.title)
                .font(.title)
                .bold()
            
            Text(card.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    .background(Color.white)
    .cornerRadius(10)
    .shadow(radius: 5)
}
```

### Responding to Swipes

Use the `onSwipeEnd` callback to respond to swipes:

```swift
CardSwipeView(
    items: profiles,
    content: { profile, fraction, direction in
        ProfileCardView(profile: profile, swipeDirection: direction, swipeFraction: fraction)
    },
    onSwipeEnd: { profile, direction in
        switch direction {
        case .left:
            rejectProfile(profile)
        case .right:
            likeProfile(profile)
        default:
            break
        }
    },
    onNoMoreCardsLeft: {
        showNoMoreProfilesView()
    }
)
```

## License

SwipeCardsKit is available under the MIT license. See the LICENSE file for more info.