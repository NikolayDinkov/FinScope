import SwiftUI

struct MarketView: View {
    @Bindable var viewModel: MarketViewModel

    var body: some View {
        List {
            Picker("Filter", selection: $viewModel.selectedFilter) {
                ForEach(AssetTypeFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)

            ForEach(viewModel.filteredAssets) { asset in
                AssetRowView(
                    asset: asset,
                    price: viewModel.currentPrices[asset.ticker] ?? asset.basePrice,
                    change: viewModel.priceChanges[asset.ticker] ?? 0
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.onSelectAsset?(asset.ticker)
                }
            }
        }
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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.ticker)
                    .font(.headline)
                Text(asset.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(price.currencyFormatted())
                    .font(.body.monospacedDigit())
                Text("\(change >= 0 ? "+" : "")\(change.percentageFormatted())")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(change >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 2)
    }
}
