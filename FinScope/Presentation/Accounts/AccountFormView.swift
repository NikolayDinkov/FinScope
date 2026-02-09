import SwiftUI

struct AccountFormView: View {
    let viewModel: AccountFormViewModel
    let coordinator: AccountsCoordinator

    var body: some View {
        Form {
            Section("Account Details") {
                TextField("Name", text: Bindable(viewModel).name)

                Picker("Type", selection: Bindable(viewModel).selectedType) {
                    ForEach(AccountType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }

                TextField("Currency", text: Bindable(viewModel).currency)
                    .textInputAutocapitalization(.characters)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Account" : "New Account")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    // TODO: Pass actual user ID from session
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
