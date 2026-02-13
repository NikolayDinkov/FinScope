import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String
    var viewingAccountId: UUID? = nil

    var body: some View {
        HStack(spacing: 12) {
            CircularIcon(systemName: categoryIcon, color: Color(hex: categoryColorHex))

            VStack(alignment: .leading, spacing: 2) {
                Text(categoryName)
                    .font(.body.weight(.medium))
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
                    .font(.body.bold().monospacedDigit())
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
