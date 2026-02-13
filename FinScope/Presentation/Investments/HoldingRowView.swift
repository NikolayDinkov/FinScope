import SwiftUI

struct HoldingRowView: View {
    let holding: PortfolioHolding
    let currentPrice: Decimal

    private var marketValue: Decimal {
        holding.quantity * currentPrice
    }

    private var gainLoss: Decimal {
        (currentPrice - holding.averageCostBasis) * holding.quantity
    }

    private var gainLossPercent: Decimal {
        guard holding.averageCostBasis != 0 else { return 0 }
        return ((currentPrice - holding.averageCostBasis) / holding.averageCostBasis * 100).rounded(scale: 2)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(holding.assetTicker)
                    .font(.headline)
                Text("\(holding.quantity) shares")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(marketValue.currencyFormatted())
                    .font(.body.monospacedDigit())
                HStack(spacing: 2) {
                    Image(systemName: gainLoss >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text("\(gainLoss.currencyFormatted()) (\(gainLossPercent.percentageFormatted()))")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(gainLoss >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}
