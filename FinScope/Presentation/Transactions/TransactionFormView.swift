import SwiftUI

struct TransactionFormView: View {
    let viewModel: TransactionFormViewModel
    let coordinator: TransactionsCoordinator

    var body: some View {
        Form {
            Section("Details") {
                Picker("Type", selection: Bindable(viewModel).type) {
                    ForEach(TransactionType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }

                CurrencyTextField(value: Bindable(viewModel).amount, placeholder: "Amount")

                DatePicker("Date", selection: Bindable(viewModel).date, displayedComponents: .date)

                TextField("Note", text: Bindable(viewModel).note)
            }

            Section("Account") {
                Picker("Account", selection: Bindable(viewModel).selectedAccountId) {
                    Text("Select account").tag(nil as UUID?)
                    ForEach(viewModel.accounts) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
            }

            Section("Recurring") {
                Toggle("Recurring", isOn: Bindable(viewModel).isRecurring)

                if viewModel.isRecurring {
                    Picker("Interval", selection: Bindable(viewModel).recurringInterval) {
                        ForEach(RecurringInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue.capitalized).tag(interval)
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Transaction" : "New Transaction")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save() }
                }
            }
        }
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave {
                coordinator.router.pop()
            }
        }
        .task {
            await viewModel.loadAccounts()
        }
    }
}
