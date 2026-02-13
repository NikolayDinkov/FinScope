import SwiftUI

struct AssetDetailView: View {
    @Bindable var viewModel: AssetDetailViewModel

    var body: some View {
        ScrollView {
            if let asset = viewModel.asset {
                VStack(spacing: FinScopeTheme.sectionSpacing) {
                    // Price + Chart Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.currentPrice.currencyFormatted())
                            .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())

                        ChangeIndicator(
                            value: viewModel.priceChange,
                            formatted: "\(viewModel.priceChange >= 0 ? "+" : "")\(viewModel.priceChange.percentageFormatted())",
                            showBackground: true
                        )

                        if !viewModel.priceHistory.isEmpty {
                            SparklineView(ticks: viewModel.priceHistory)
                                .frame(height: 160)
                        }
                    }
                    .cardStyle()

                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Info")

                        HStack(spacing: 8) {
                            InfoPill(label: "Type", value: asset.type.displayName)
                            InfoPill(label: "Sector", value: asset.sector)
                            InfoPill(label: "Base", value: asset.basePrice.currencyFormatted())
                        }
                    }
                    .cardStyle()

                    // Position Section
                    if let holding = viewModel.holding {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Your Position")

                            VStack(spacing: 10) {
                                HStack {
                                    Text("Shares")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(holding.quantity)")
                                        .bold().monospacedDigit()
                                }
                                Divider()
                                HStack {
                                    Text("Avg Cost")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(holding.averageCostBasis.currencyFormatted())
                                        .bold().monospacedDigit()
                                }
                                Divider()
                                HStack {
                                    Text("Market Value")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(viewModel.holdingValue.currencyFormatted())
                                        .bold().monospacedDigit()
                                }
                                Divider()
                                HStack {
                                    Text("Gain/Loss")
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    ChangeIndicator(
                                        value: viewModel.holdingGainLoss,
                                        formatted: viewModel.holdingGainLoss.currencyFormatted(),
                                        font: .body.bold().monospacedDigit(),
                                        showBackground: true
                                    )
                                }
                            }
                            .font(.subheadline)
                        }
                        .cardStyle()
                    }

                    // Trade History
                    if !viewModel.trades.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Trade History")

                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.trades.enumerated()), id: \.element.id) { index, trade in
                                    TradeRowView(trade: trade)
                                    if index < viewModel.trades.count - 1 {
                                        Divider().padding(.leading, 52)
                                    }
                                }
                            }
                        }
                        .cardStyle()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, FinScopeTheme.sectionSpacing)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(viewModel.asset?.ticker ?? "")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { viewModel.onBuy?() }) {
                        Label("Buy", systemImage: "plus.circle")
                    }
                    Button(action: { viewModel.onSell?() }) {
                        Label("Sell", systemImage: "minus.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - Info Pill

private struct InfoPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemGray6), in: RoundedRectangle(cornerRadius: 10))
    }
}

extension AssetType {
    var displayName: String {
        switch self {
        case .stock: "Stock"
        case .bond: "Bond"
        case .etf: "ETF"
        }
    }
}
