import SwiftUI

struct SparklineView: View {
    let ticks: [PriceTick]

    var body: some View {
        GeometryReader { geometry in
            let prices = ticks.map { NSDecimalNumber(decimal: $0.price).doubleValue }
            let minPrice = prices.min() ?? 0
            let maxPrice = prices.max() ?? 1
            let range = maxPrice - minPrice
            let effectiveRange = range > 0 ? range : 1.0

            let isPositive = (prices.last ?? 0) >= (prices.first ?? 0)
            let color: Color = isPositive ? .green : .red

            Path { path in
                guard prices.count > 1 else { return }
                let stepX = geometry.size.width / CGFloat(prices.count - 1)
                let height = geometry.size.height

                for (index, price) in prices.enumerated() {
                    let x = CGFloat(index) * stepX
                    let normalizedY = (price - minPrice) / effectiveRange
                    let y = height - (CGFloat(normalizedY) * height)

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}
