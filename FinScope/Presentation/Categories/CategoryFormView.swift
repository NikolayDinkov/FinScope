import SwiftUI

struct CategoryFormView: View {
    @State private var name = ""
    @State private var selectedIcon = "circle.fill"
    @State private var selectedColor = "#007AFF"
    @State private var selectedType: TransactionType = .expense

    var onSave: ((Category) -> Void)?
    var onCancel: (() -> Void)?

    private let iconOptions = [
        "circle.fill", "star.fill", "heart.fill", "banknote",
        "fork.knife", "car", "house", "film", "heart",
        "bag", "bolt", "book", "laptopcomputer", "chart.line.uptrend.xyaxis",
        "plus.circle", "ellipsis.circle", "gift", "airplane",
        "pawprint", "figure.walk", "dumbbell"
    ]

    private let colorOptions = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#00C7BE", "#30D158", "#007AFF", "#5856D6",
        "#AF52DE", "#FF2D55", "#8E8E93", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category Name", text: $name)
                }

                Section("Type") {
                    Picker("Transaction Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 36, height: 36)
                                .overlay {
                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.caption.bold())
                                    }
                                }
                                .onTapGesture { selectedColor = color }
                        }
                    }
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel?() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let category = Category(
                            name: name.trimmingCharacters(in: .whitespaces),
                            icon: selectedIcon,
                            colorHex: selectedColor,
                            isDefault: false,
                            transactionType: selectedType
                        )
                        onSave?(category)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
