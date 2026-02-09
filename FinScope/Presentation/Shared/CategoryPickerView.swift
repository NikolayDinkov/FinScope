import SwiftUI

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedId: UUID?

    var body: some View {
        Picker("Category", selection: $selectedId) {
            Text("None").tag(nil as UUID?)
            ForEach(categories) { category in
                Label(category.name, systemImage: category.icon ?? "tag")
                    .tag(category.id as UUID?)
            }
        }
    }
}
