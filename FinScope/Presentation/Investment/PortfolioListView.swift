import SwiftUI

struct PortfolioListView: View {
    let viewModel: PortfolioListViewModel
    let coordinator: InvestmentCoordinator

    @State private var showNewPortfolio = false
    @State private var newPortfolioName = ""

    var body: some View {
        List {
            if viewModel.portfolios.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Portfolios",
                    message: "Create a portfolio to start simulating investments"
                )
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.portfolios) { portfolio in
                Button {
                    coordinator.router.push(.simulator(portfolio))
                } label: {
                    VStack(alignment: .leading) {
                        Text(portfolio.name)
                            .font(.headline)
                        Text("\(portfolio.investments.count) investments")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Portfolios")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewPortfolio = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Portfolio", isPresented: $showNewPortfolio) {
            TextField("Portfolio Name", text: $newPortfolioName)
            Button("Create") {
                Task { await viewModel.createNewPortfolio(name: newPortfolioName, userId: UUID()) }
                newPortfolioName = ""
            }
            Button("Cancel", role: .cancel) {
                newPortfolioName = ""
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
