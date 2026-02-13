import SwiftUI

struct TradeRowView: View {
    let trade: Trade

    var body: some View {
        HStack {
            Image(systemName: trade.action == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundStyle(trade.action == .buy ? .green : .red)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(trade.action == .buy ? "Buy" : "Sell") \(trade.quantity) shares")
                    .font(.body)
                Text(trade.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(trade.totalAmount.currencyFormatted())
                    .font(.body.monospacedDigit())
                Text("@ \(trade.pricePerUnit.currencyFormatted())")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
