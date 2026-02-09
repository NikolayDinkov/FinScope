import Foundation

enum AppTab: String, Hashable, CaseIterable {
    case dashboard
    case accounts
    case transactions
    case budget
    case investment
    case forecast

    var title: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .dashboard: "house.fill"
        case .accounts: "banknote.fill"
        case .transactions: "arrow.left.arrow.right"
        case .budget: "chart.pie.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        case .forecast: "crystal.ball"
        }
    }
}

enum AccountRoute: Hashable {
    case detail(Account)
    case form(Account?)
}

enum TransactionRoute: Hashable {
    case form(Transaction?)
    case csvImport(Account)
}

enum BudgetRoute: Hashable {
    case form(Budget?)
}

enum InvestmentRoute: Hashable {
    case simulator(Portfolio)
    case assetForm(Portfolio)
}

enum ForecastRoute: Hashable {
    case comparison([Forecast])
}
