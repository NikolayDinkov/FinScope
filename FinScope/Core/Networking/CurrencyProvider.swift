import Foundation

/// Provides exchange rates for currency conversion.
/// Currently uses hardcoded rates; future implementation will fetch from an API.
protocol CurrencyProviderProtocol: Sendable {
    func exchangeRate(from source: String, to target: String) async throws -> Decimal
}

struct StaticCurrencyProvider: CurrencyProviderProtocol {
    // Rates relative to EUR
    private let ratesToEUR: [String: Decimal] = [
        "EUR": 1,
        "USD": Decimal(string: "1.08")!,
        "BGN": Decimal(string: "1.9558")!,
        "GBP": Decimal(string: "0.86")!,
        "CHF": Decimal(string: "0.94")!,
        "JPY": Decimal(string: "162.50")!,
    ]

    func exchangeRate(from source: String, to target: String) async throws -> Decimal {
        guard source != target else { return 1 }

        guard let sourceRate = ratesToEUR[source],
              let targetRate = ratesToEUR[target] else {
            throw CurrencyError.unsupportedCurrency
        }

        // Convert: source -> EUR -> target
        return (targetRate / sourceRate).rounded(scale: 6)
    }
}

enum CurrencyError: Error, LocalizedError {
    case unsupportedCurrency
    case conversionFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedCurrency: "Unsupported currency code"
        case .conversionFailed: "Currency conversion failed"
        }
    }
}
