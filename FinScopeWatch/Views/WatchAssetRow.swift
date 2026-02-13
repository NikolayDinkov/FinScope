import SwiftUI

struct WatchAssetRow: View {
    let asset: MockAsset
    let price: Decimal
    let change: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(asset.ticker)
                    .font(.caption.bold())
                Spacer()
                Text(price.currencyFormatted())
                    .font(.caption.monospacedDigit())
            }
            HStack {
                Text(asset.type.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(change >= 0 ? "+" : "")\(change.percentageFormatted())")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(change >= 0 ? .green : .red)
            }
        }
    }
}
