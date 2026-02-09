import SwiftUI

struct AccountListView: View {
    let viewModel: AccountListViewModel
    let coordinator: AccountsCoordinator

    var body: some View {
        List {
            if viewModel.accounts.isEmpty {
                EmptyStateView(
                    icon: "banknote",
                    title: "No Accounts",
                    message: "Tap + to create your first account"
                )
                .listRowBackground(Color.clear)
            }

            ForEach(viewModel.accounts) { account in
                Button {
                    coordinator.router.push(.detail(account))
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            Text(account.type.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(account.currency)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        Task { await viewModel.delete(account) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    coordinator.router.push(.form(nil))
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.showDeleteError)) {
            Button("OK") { viewModel.showDeleteError = false }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await viewModel.load()
        }
    }
}
