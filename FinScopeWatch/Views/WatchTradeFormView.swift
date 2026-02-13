import SwiftUI

struct WatchTradeFormView: View {
    let ticker: String
    let action: TradeAction
    let marketService: MarketSimulatorServiceProtocol
    let portfolioRepository: PortfolioRepositoryProtocol

    @State private var viewModel: WatchTradeFormViewModel?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    List {
                        Section {
                            LabeledContent("Price") {
                                Text(viewModel.currentPrice.currencyFormatted())
                                    .font(.caption.monospacedDigit())
                            }
                            .font(.caption)
                        }

                        Section {
                            Stepper(
                                "Qty: \(viewModel.quantity)",
                                value: Binding(
                                    get: { viewModel.quantity },
                                    set: { viewModel.quantity = $0 }
                                ),
                                in: 1...10000
                            )
                            .font(.caption)

                            LabeledContent("Total") {
                                Text(viewModel.totalCost.currencyFormatted())
                                    .font(.caption.monospacedDigit())
                            }
                            .font(.caption)
                        }

                        Section {
                            if viewModel.action == .buy {
                                LabeledContent("Cash") {
                                    Text(viewModel.availableCash.currencyFormatted())
                                        .font(.caption.monospacedDigit())
                                }
                                .font(.caption)
                            } else {
                                LabeledContent("Shares") {
                                    Text("\(viewModel.availableShares)")
                                        .font(.caption.monospacedDigit())
                                }
                                .font(.caption)
                            }
                        }

                        Section {
                            Button {
                                Task {
                                    await viewModel.executeTrade()
                                    if viewModel.didComplete {
                                        dismiss()
                                    }
                                }
                            } label: {
                                Text("Confirm \(viewModel.action == .buy ? "Buy" : "Sell")")
                                    .frame(maxWidth: .infinity)
                            }
                            .disabled(!viewModel.isValid)
                            .tint(viewModel.action == .buy ? .green : .red)
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
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("\(action == .buy ? "Buy" : "Sell") \(ticker)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                let vm = WatchTradeFormViewModel(
                    ticker: ticker,
                    action: action,
                    executeTradeUseCase: ExecuteTradeUseCase(
                        repository: portfolioRepository,
                        marketService: marketService
                    ),
                    marketService: marketService,
                    portfolioRepository: portfolioRepository
                )
                viewModel = vm
                await vm.load()
            }
        }
    }
}
