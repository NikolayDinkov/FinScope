import Foundation

struct CurrencyConverter: Sendable {
    private let provider: CurrencyProviderProtocol

    init(provider: CurrencyProviderProtocol = StaticCurrencyProvider()) {
        self.provider = provider
    }

    func convert(amount: Decimal, from source: String, to target: String) async throws -> Decimal {
        guard source != target else { return amount }
        let rate = try await provider.exchangeRate(from: source, to: target)
        return (amount * rate).rounded(scale: 2)
    }
}
