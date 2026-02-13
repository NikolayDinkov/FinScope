import SwiftUI

struct TradeRowView: View {
    let trade: Trade

    var body: some View {
        HStack(spacing: 12) {
            CircularIcon(
                systemName: trade.action == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                color: trade.action == .buy ? .green : .red
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("\(trade.action == .buy ? "Buy" : "Sell") \(trade.quantity) shares")
                    .font(.body.weight(.medium))
                Text(trade.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(trade.totalAmount.currencyFormatted())
                    .font(.body.bold().monospacedDigit())
                Text("@ \(trade.pricePerUnit.currencyFormatted())")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
