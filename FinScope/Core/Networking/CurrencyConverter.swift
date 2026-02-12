import Foundation

struct CurrencyConverter: Sendable {
    private static let ratesToUSD: [String: Decimal] = [
        "USD": 1.0,
        "EUR": 1.08,
        "GBP": 1.27,
        "BGN": 0.55,
        "JPY": 0.0067,
        "CHF": 1.13,
        "CAD": 0.74,
        "AUD": 0.65,
        "CNY": 0.14,
        "INR": 0.012
    ]

    static func convert(amount: Decimal, from sourceCurrency: String, to targetCurrency: String) -> Decimal {
        guard sourceCurrency != targetCurrency else { return amount }

        let sourceRate = ratesToUSD[sourceCurrency] ?? 1.0
        let targetRate = ratesToUSD[targetCurrency] ?? 1.0

        let amountInUSD = amount * sourceRate
        let converted = amountInUSD / targetRate

        return converted.rounded(scale: 2)
    }

    static var supportedCurrencies: [String] {
        ratesToUSD.keys.sorted()
    }
}
