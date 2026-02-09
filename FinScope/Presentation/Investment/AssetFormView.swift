import SwiftUI

struct AssetFormView: View {
    let portfolio: Portfolio

    @State private var name = ""
    @State private var assetType: AssetType = .etf
    @State private var initialCapital = ""
    @State private var monthlyContribution = ""
    @State private var durationYears = 10

    var body: some View {
        Form {
            Section("Asset Details") {
                TextField("Name", text: $name)

                Picker("Type", selection: $assetType) {
                    ForEach(AssetType.allCases, id: \.self) { type in
                        Text(type.rawValue.uppercased()).tag(type)
                    }
                }
            }

            Section("Investment") {
                CurrencyTextField(value: $initialCapital, placeholder: "Initial Capital")
                CurrencyTextField(value: $monthlyContribution, placeholder: "Monthly Contribution")

                Stepper("Duration: \(durationYears) years", value: $durationYears, in: 1...50)
            }
        }
        .navigationTitle("Add Asset")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    // Asset creation handled by coordinator
                }
                .disabled(name.trimmed.isEmpty || initialCapital.isEmpty)
            }
        }
    }
}
