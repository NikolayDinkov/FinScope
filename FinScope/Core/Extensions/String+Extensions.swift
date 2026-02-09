import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    var isValidCurrencyCode: Bool {
        count == 3 && allSatisfy(\.isUppercase)
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        trimmed.isEmpty ? nil : trimmed
    }
}
