import SwiftUI

struct DashboardTransactionRowView: View {
    let transaction: Transaction
    let categoryName: String
    let categoryIcon: String
    let categoryColorHex: String

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

    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return prefix + transaction.amount.currencyFormatted()
    }

    private var amountColor: Color {
        transaction.type == .income ? .green : .primary
    }
}
