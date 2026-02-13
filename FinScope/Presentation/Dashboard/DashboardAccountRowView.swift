import SwiftUI

struct DashboardAccountRowView: View {
    let account: Account

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(account.name)
                    .font(.body)
                Text(account.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(account.balance.currencyFormatted(code: account.currencyCode))
                .font(.body.monospacedDigit())
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch account.type {
        case .cash: "banknote"
        case .bank: "building.columns"
        case .investment: "chart.line.uptrend.xyaxis"
        }
    }

    private var iconColor: Color {
        switch account.type {
        case .cash: .green
        case .bank: .blue
        case .investment: .orange
        }
    }
}
