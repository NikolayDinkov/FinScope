import SwiftUI

struct CurrencyTextField: View {
    @Binding var value: String
    let placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $value)
                .keyboardType(.decimalPad)
                .textFieldStyle(.plain)

            if let decimal = Decimal(string: value), decimal > 0 {
                Text(decimal.currencyFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
