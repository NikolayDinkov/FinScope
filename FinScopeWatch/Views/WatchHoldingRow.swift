import SwiftUI

struct WatchHoldingRow: View {
    let holding: PortfolioHolding
    let currentPrice: Decimal

    private var marketValue: Decimal {
        holding.quantity * currentPrice
    }

    private var gainLoss: Decimal {
        (currentPrice - holding.averageCostBasis) * holding.quantity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(holding.assetTicker)
                    .font(.caption.bold())
                Spacer()
                Text(marketValue.currencyFormatted())
                    .font(.caption.monospacedDigit())
            }
            HStack {
                Text("\(holding.quantity) shares")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(gainLoss.currencyFormatted())
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(gainLoss >= 0 ? .green : .red)
            }
        }
    }
}
