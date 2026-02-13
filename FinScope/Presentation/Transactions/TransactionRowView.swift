import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    var viewingAccountId: UUID? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: categoryIcon)
                .foregroundStyle(Color(hex: categoryColorHex))
                .frame(width: 32, height: 32)
                .background(Color(hex: categoryColorHex).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(categoryName)
                    .font(.body)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amountText)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(amountColor)
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var isIncomingTransfer: Bool {
        transaction.type == .transfer && transaction.destinationAccountId == viewingAccountId
    }

    private var amountText: String {
        let prefix = (transaction.type == .income || isIncomingTransfer) ? "+" : "-"
        return prefix + transaction.amount.currencyFormatted()
    }

    private var amountColor: Color {
        (transaction.type == .income || isIncomingTransfer) ? .green : .primary
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
}
