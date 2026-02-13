import SwiftUI

struct AccountListView: View {
    @Bindable var viewModel: AccountListViewModel

    var body: some View {
        List {
            ForEach(viewModel.groupedAccounts, id: \.0) { type, accounts in
                Section(header: Text(type.displayName)) {
                    ForEach(accounts) { account in
                        AccountRowView(account: account)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.onSelectAccount?(account.id)
                            }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let account = accounts[index]
                            Task {
                                await viewModel.deleteAccount(id: account.id)
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            if viewModel.accounts.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Accounts",
                    systemImage: "creditcard",
                    description: Text("Tap + to add your first account.")
                )
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { viewModel.onAddAccount?() }) {
                    Image(systemName: "plus")
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
            await viewModel.loadAccounts()
        }
    }
}

private struct AccountRowView: View {
    let account: Account

    var body: some View {
        HStack(spacing: 12) {
            CircularIcon(systemName: account.type.iconName, color: account.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.body.weight(.medium))
                Text(account.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(account.balance.currencyFormatted(code: account.currencyCode))
                .font(.body.bold().monospacedDigit())
                .foregroundStyle(account.balance >= 0 ? Color.primary : Color.red)
        }
        .padding(.vertical, 6)
    }
}

extension AccountType {
    var displayName: String {
        switch self {
        case .cash: "Cash"
        case .bank: "Bank"
        case .investment: "Investment"
        }
    }

    var iconName: String {
        switch self {
        case .cash: "banknote"
        case .bank: "building.columns"
        case .investment: "chart.line.uptrend.xyaxis"
        }
    }

    var color: Color {
        switch self {
        case .cash: .green
        case .bank: .blue
        case .investment: .purple
        }
    }
}
