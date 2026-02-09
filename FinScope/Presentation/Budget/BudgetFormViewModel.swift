import Foundation

@Observable
final class BudgetFormViewModel {
    private let createBudget: CreateBudgetUseCase

    let editingBudget: Budget?
    var name: String
    var period: BudgetPeriod
    var totalLimit: String
    var errorMessage: String?
    var didSave = false

    var isEditing: Bool { editingBudget != nil }

    init(budget: Budget?, createBudget: CreateBudgetUseCase) {
        self.editingBudget = budget
        self.createBudget = createBudget
        self.name = budget?.name ?? ""
        self.period = budget?.period ?? .monthly
        self.totalLimit = budget?.totalLimit.map { "\($0)" } ?? ""
    }

    func save(userId: UUID) async {
        do {
            let limit = Decimal(string: totalLimit)
            _ = try await createBudget.execute(
                name: name,
                period: period,
                totalLimit: limit,
                userId: userId,
                rules: []
            )
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
