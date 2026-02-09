import Foundation

extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "\(self)"
    }

    func formatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "\(self)"
    }

    var percentageFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? "\(self)"
    }

    func rounded(scale: Int = 2, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var mutableSelf = self
        NSDecimalRound(&result, &mutableSelf, scale, roundingMode)
        return result
    }

    static var zero: Decimal { 0 }

    var isNegative: Bool {
        self < 0
    }

    var isPositive: Bool {
        self > 0
    }

    var absoluteValue: Decimal {
        isNegative ? -self : self
    }
}
