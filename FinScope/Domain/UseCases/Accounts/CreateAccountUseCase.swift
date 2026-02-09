import Foundation

struct CreateAccountUseCase: Sendable {
    private let repository: any AccountRepositoryProtocol

    init(repository: any AccountRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String, type: AccountType, currency: String, userId: UUID) async throws -> Account {
        guard !name.trimmed.isEmpty else {
            throw AccountError.invalidName
        }
        guard currency.isValidCurrencyCode else {
            throw AccountError.invalidCurrency
        }

        let account = Account(
            name: name.trimmed,
            type: type,
            currency: currency,
            userId: userId
        )
        try await repository.save(account)
        return account
    }
}

enum AccountError: Error, LocalizedError {
    case invalidName
    case invalidCurrency
    case hasTransactions

    var errorDescription: String? {
        switch self {
        case .invalidName: "Account name cannot be empty"
        case .invalidCurrency: "Invalid currency code"
        case .hasTransactions: "Cannot delete account with existing transactions"
        }
    }
}
