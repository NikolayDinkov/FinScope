import SwiftUI

struct BudgetFormView: View {
    @Bindable var viewModel: BudgetFormViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $viewModel.selectedCategoryId) {
                        Text("Select Category").tag(nil as UUID?)
                        ForEach(viewModel.availableCategories) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category.id as UUID?)
                        }
                    }
                    .disabled(viewModel.isEditing)
                }

                Section("Monthly Limit") {
                    TextField("0.00", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Budget" : "New Budget")
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
