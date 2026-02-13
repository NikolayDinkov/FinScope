import SwiftUI

struct MarketView: View {
    @Bindable var viewModel: MarketViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: FinScopeTheme.sectionSpacing) {
                PillSegmentControl(
                    options: AssetTypeFilter.allCases,
                    selected: $viewModel.selectedFilter,
                    label: { $0.rawValue }
                )

                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(viewModel.filteredAssets.enumerated()), id: \.element.id) { index, asset in
                        AssetRowView(
                            asset: asset,
                            price: viewModel.currentPrices[asset.ticker] ?? asset.basePrice,
                            change: viewModel.priceChanges[asset.ticker] ?? 0
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.onSelectAsset?(asset.ticker)
                        }

                        if index < viewModel.filteredAssets.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .cardStyle()
            }
            .padding(.horizontal)
            .padding(.bottom, FinScopeTheme.sectionSpacing)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Market")
        .searchable(text: $viewModel.searchText, prompt: "Search by ticker or name")
        .task {
            viewModel.load()
        }
    }
}

private struct AssetRowView: View {
    let asset: MockAsset
    let price: Decimal
    let change: Decimal

    private var iconColor: Color {
        switch asset.type {
        case .stock: .blue
        case .bond: .purple
        case .etf: .orange
        }
    }

    private var iconName: String {
        switch asset.type {
        case .stock: "chart.line.uptrend.xyaxis"
        case .bond: "building.columns"
        case .etf: "square.grid.2x2"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            CircularIcon(systemName: iconName, color: iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(asset.ticker)
                    .font(.headline)
                Text(asset.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(price.currencyFormatted())
                    .font(.body.bold().monospacedDigit())
                Text("\(change >= 0 ? "+" : "")\(change.percentageFormatted())")
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(change >= 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((change >= 0 ? Color.green : Color.red).opacity(0.12), in: Capsule())
            }
        }
        .padding(.vertical, 6)
    }
}
