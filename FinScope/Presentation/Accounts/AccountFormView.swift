import SwiftUI

struct AccountFormView: View {
    @Bindable var viewModel: AccountFormViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $viewModel.name)

                    Picker("Type", selection: $viewModel.selectedType) {
                        ForEach(AccountType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    Picker("Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(CurrencyConverter.supportedCurrencies, id: \.self) { code in
                            Text(code).tag(code)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Account" : "New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.onCancel?() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await viewModel.save() }
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
