import SwiftUI

struct PortfolioView: View {
    @Bindable var viewModel: PortfolioViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: FinScopeTheme.sectionSpacing) {
                // Hero Portfolio Value Card
                VStack(spacing: 8) {
                    Text("Total Portfolio Value")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))

                    Text(viewModel.totalPortfolioValue.currencyFormatted())
                        .font(.system(size: 36, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)

                    ChangeIndicator(
                        value: viewModel.totalGainLoss,
                        formatted: "\(viewModel.totalGainLoss.currencyFormatted()) (\(viewModel.totalGainLossPercent.percentageFormatted()))",
                        font: .subheadline.weight(.medium).monospacedDigit()
                    )
                    .colorScheme(.dark)

                    Divider().overlay(Color.white.opacity(0.2))

                    HStack {
                        Text("Cash Available")
                            .foregroundStyle(.white.opacity(0.7))
                        Spacer()
                        Text(viewModel.cashBalance.currencyFormatted())
                            .monospacedDigit()
                            .foregroundStyle(.white)
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, FinScopeTheme.cardPadding)
                .background(FinScopeTheme.primaryGradient, in: RoundedRectangle(cornerRadius: FinScopeTheme.cardCornerRadius))

                // Holdings Section
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Holdings")

                    if viewModel.holdings.isEmpty {
                        ContentUnavailableView(
                            "No Holdings",
                            systemImage: "chart.pie",
                            description: Text("Tap the market icon to browse assets and start trading.")
                        )
                        .frame(minHeight: 120)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.holdings.enumerated()), id: \.element.id) { index, holding in
                                HoldingRowView(
                                    holding: holding,
                                    currentPrice: viewModel.currentPrices[holding.assetTicker] ?? holding.averageCostBasis
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.onSelectAsset?(holding.assetTicker)
                                }

                                if index < viewModel.holdings.count - 1 {
                                    Divider().padding(.leading, 52)
                                }
                            }
                        }
                    }
                }
                .cardStyle()
            }
            .padding(.horizontal)
            .padding(.bottom, FinScopeTheme.sectionSpacing)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Investments")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.onOpenMarket?() }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
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
