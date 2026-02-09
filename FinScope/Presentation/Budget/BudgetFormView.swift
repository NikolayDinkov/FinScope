import SwiftUI

struct BudgetFormView: View {
    let viewModel: BudgetFormViewModel
    let coordinator: BudgetCoordinator

    var body: some View {
        Form {
            Section("Budget Details") {
                TextField("Name", text: Bindable(viewModel).name)

                Picker("Period", selection: Bindable(viewModel).period) {
                    ForEach(BudgetPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue.capitalized).tag(period)
                    }
                }

                CurrencyTextField(value: Bindable(viewModel).totalLimit, placeholder: "Total Limit (optional)")
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Budget" : "New Budget")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save(userId: UUID()) }
                }
                .disabled(viewModel.name.trimmed.isEmpty)
            }
        }
        .onChange(of: viewModel.didSave) { _, didSave in
            if didSave {
                coordinator.router.pop()
            }
        }
    }
}
