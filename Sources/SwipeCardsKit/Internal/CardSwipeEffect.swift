
struct CardSwipeEffect: ViewModifier {
  let index: Int
  let offset: CGPoint
  let triggerThreshold: CGFloat
  let cardDistance: CGFloat

  init(index: Int, offset: CGPoint, triggerThreshold: CGFloat, cardDistance: CGFloat = 16) {
    self.index = index
    self.offset = offset
    self.triggerThreshold = triggerThreshold
    self.cardDistance = cardDistance
  }

  func body(content: Content) -> some View {
      // Perspective: scale decreases as card is further back, and increases as it comes forward
      // We'll use a base scale and a scale step per card, so that the scale matches the cardDistance
    let baseScale: CGFloat = 1.0
    let scaleStep: CGFloat = 0.1 // how much smaller each card is behind the top card

    switch index {
    case 0:
      let angle = Angle(degrees: Double(offset.x) / 20)
      content
        .offset(x: offset.x, y: offset.y)
        .rotationEffect(angle, anchor: .bottom)
        .scaleEffect(baseScale)
        .zIndex(4)
    case 1:
      let progress = min(abs(offset.x) / triggerThreshold, 1)
      let yOffset = (1 - progress) * cardDistance
      let scale = baseScale - scaleStep + progress * scaleStep
      content
        .offset(y: yOffset)
        .scaleEffect(scale)
        .zIndex(3)
    case 2:
      let progress = min(abs(offset.x) / triggerThreshold, 1)
      let yOffset = cardDistance * 2 - progress * cardDistance
      let scale = baseScale - 2 * scaleStep + progress * scaleStep
      content
        .offset(y: yOffset)
        .scaleEffect(scale)
        .zIndex(2)
    case 3:
      let progress = min(abs(offset.x) / triggerThreshold, 1)
      let yOffset = cardDistance * 3 - progress * cardDistance
      let scale = baseScale - 3 * scaleStep + progress * scaleStep
      content
        .opacity(progress)
        .offset(y: yOffset)
        .scaleEffect(scale)
        .zIndex(1)
    default:
      content
        .opacity(0)
    }
  }
}
