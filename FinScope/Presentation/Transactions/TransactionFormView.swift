import SwiftUI

struct TransactionFormView: View {
    @Bindable var viewModel: TransactionFormViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Transaction Type", selection: $viewModel.selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedType) {
                        viewModel.selectedCategoryId = nil
                        viewModel.selectedDestinationAccountId = nil
                        Task { await viewModel.loadSubcategories() }
                    }
                }

                Section("Amount") {
                    TextField("0.00", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }

                if viewModel.selectedType == .transfer {
                    Section("Destination Account") {
                        Picker("To Account", selection: $viewModel.selectedDestinationAccountId) {
                            Text("Select Account").tag(nil as UUID?)
                            ForEach(viewModel.availableDestinationAccounts) { account in
                                Text(account.name).tag(account.id as UUID?)
                            }
                        }
                    }
                }

                if viewModel.selectedType != .transfer {
                    Section("Category") {
                        Picker("Category", selection: $viewModel.selectedCategoryId) {
                            Text("Select Category").tag(nil as UUID?)
                            ForEach(viewModel.filteredCategories) { category in
                                Label(category.name, systemImage: category.icon)
                                    .tag(category.id as UUID?)
                            }
                        }
                        .onChange(of: viewModel.selectedCategoryId) {
                            Task { await viewModel.loadSubcategories() }
                        }

                        if !viewModel.subcategories.isEmpty {
                            Picker("Subcategory", selection: $viewModel.selectedSubcategoryId) {
                                Text("None").tag(nil as UUID?)
                                ForEach(viewModel.subcategories) { sub in
                                    Text(sub.name).tag(sub.id as UUID?)
                                }
                            }
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                    TextField("Note", text: $viewModel.note)
                }

                Section("Recurring") {
                    Toggle("Recurring Transaction", isOn: $viewModel.isRecurring)

                    if viewModel.isRecurring {
                        Picker("Frequency", selection: $viewModel.selectedFrequency) {
                            ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                                Text(freq.displayName).tag(freq)
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Transaction" : "New Transaction")
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

extension TransactionType {
    var displayName: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        case .transfer: "Transfer"
        }
    }
}

extension RecurrenceFrequency {
    var displayName: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .biweekly: "Biweekly"
        case .monthly: "Monthly"
        case .quarterly: "Quarterly"
        case .yearly: "Yearly"
        }
    }
}
