import SwiftUI

struct CategoryListView: View {
    @Bindable var viewModel: CategoryListViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Income") {
                    ForEach(viewModel.incomeCategories) { category in
                        CategoryRow(category: category)
                    }
                }

                Section("Expense") {
                    ForEach(viewModel.expenseCategories) { category in
                        CategoryRow(category: category)
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { viewModel.onDismiss?() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { viewModel.onAddCategory?() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

private struct CategoryRow: View {
    let category: Category

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundStyle(Color(hex: category.colorHex))
                .frame(width: 28, height: 28)

            Text(category.name)
                .font(.body)

            Spacer()

            if category.isDefault {
                Text("Default")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
