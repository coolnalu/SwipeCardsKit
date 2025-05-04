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
- 🔄 Card stack management with visual depth effect
- 🎭 Customizable animations and thresholds
- 📢 Comprehensive callback support for swipe actions

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
            }
            .onSwipeEnd { card, direction in
                print("Swiped \(direction) on card: \(card.title)")
            }
            .onNoMoreCardsLeft {
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

## Core Components

### CardSwipeView

The main component that manages the card stack and swipe interactions.

```swift
public struct CardSwipeView<Item: Identifiable, Content: View>: View
```

#### Initialization

```swift
public init(
    items: [Item],
    @ViewBuilder content: @escaping (Item, _ fraction: CGFloat, _ isRight: CardSwipeDirection) -> Content
)
```

- `items`: An array of items that conform to `Identifiable`
- `content`: A view builder that creates the content for each card
  - `item`: The current item being displayed
  - `fraction`: A value between 0 and 1 indicating how far the card has been swiped
  - `direction`: The current swipe direction (`.left`, `.right`, or `.idle`)

### CardSwipeDirection

An enum that represents the direction a card can be swiped:

```swift
public enum CardSwipeDirection {
    case left, right, idle
}
```

- `.left`: The card was swiped to the left
- `.right`: The card was swiped to the right
- `.idle`: The card is not being swiped or is at rest

## Customization Options

### Trigger Threshold

Set the minimum distance a card needs to be swiped before it's considered a complete swipe:

```swift
CardSwipeView(items: cards) { card, fraction, direction in
    // Card content
}
.triggerThreshold(200) // Default is 150
```

### Swipe Callbacks

Register callbacks for swipe events:

```swift
CardSwipeView(items: cards) { card, fraction, direction in
    // Card content
}
.onSwipeEnd { card, direction in
    // Handle swipe end
    switch direction {
    case .left:
        print("Swiped left on \(card.id)")
    case .right:
        print("Swiped right on \(card.id)")
    case .idle:
        print("Card returned to center")
    }
}
.onNoMoreCardsLeft {
    // Handle when all cards are swiped
    print("No more cards left!")
}
```

## Advanced Usage

### Custom Card Appearance

You have full control over the appearance of your cards:

```swift
CardSwipeView(items: profiles) { profile, fraction, direction in
    VStack {
        Image(profile.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 300)
            .clipped()
        
        VStack(alignment: .leading) {
            Text(profile.name)
                .font(.title)
                .bold()
            
            Text(profile.bio)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        
        // Show swipe indicators
        if fraction > 0 {
            if direction == .left {
                Text("NOPE")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.red)
                    .cornerRadius(10)
                    .rotationEffect(Angle(degrees: -30))
                    .opacity(fraction)
                    .position(x: 75, y: 100)
            } else if direction == .right {
                Text("LIKE")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.green)
                    .cornerRadius(10)
                    .rotationEffect(Angle(degrees: 30))
                    .opacity(fraction)
                    .position(x: 275, y: 100)
            }
        }
    }
    .background(Color.white)
    .cornerRadius(10)
    .shadow(radius: 5)
}
```

### Card Stack Behavior

SwipeCardsKit automatically manages a stack of cards with a visually appealing depth effect. The top 4 cards are visible at any time, with the following properties:

- **Top card**: Fully interactive, can be swiped left or right
- **Second card**: Scales up and moves forward as the top card is swiped
- **Third card**: Becomes more visible as cards above it are swiped
- **Fourth card**: Fades in as cards are swiped

This creates a realistic card stack effect similar to popular dating apps.

### Implementation Details

The library uses SwiftUI's gesture system combined with custom animations to create a smooth, realistic card swiping experience. The `CardSwipeEffect` modifier handles the visual transformations of each card based on its position in the stack and the current swipe state.

## Best Practices

1. **Performance**: Keep your card content views as lightweight as possible for smooth animations
2. **Card Size**: Use a consistent aspect ratio for your cards (the default is 2:3)
3. **Feedback**: Provide visual feedback during swipes to indicate the action that will occur
4. **Error Handling**: Always implement the `onNoMoreCardsLeft` callback to handle the empty state

## License

SwipeCardsKit is available under the MIT license. See the LICENSE file for more info.