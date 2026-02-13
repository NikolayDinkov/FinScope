import SwiftUI

struct TradeFormView: View {
    @Bindable var viewModel: TradeFormViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Asset") {
                    LabeledContent("Ticker", value: viewModel.ticker)
                    LabeledContent("Action", value: viewModel.action == .buy ? "Buy" : "Sell")
                    LabeledContent("Current Price") {
                        Text(viewModel.currentPrice.currencyFormatted())
                            .monospacedDigit()
                    }
                }

                Section("Order") {
                    TextField("Quantity", text: $viewModel.quantityText)
                        .keyboardType(.decimalPad)

                    LabeledContent("Estimated Cost") {
                        Text(viewModel.totalCost.currencyFormatted())
                            .monospacedDigit()
                    }
                }

                Section {
                    if viewModel.action == .buy {
                        LabeledContent("Available Cash") {
                            Text(viewModel.availableCash.currencyFormatted())
                                .monospacedDigit()
                        }
                    } else {
                        LabeledContent("Available Shares") {
                            Text("\(viewModel.availableShares)")
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.action == .buy ? "Buy \(viewModel.ticker)" : "Sell \(viewModel.ticker)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.onCancel?() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        Task { await viewModel.executeTrade() }
                    }
                    .disabled(!viewModel.isValid)
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
}
