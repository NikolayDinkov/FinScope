import Foundation
import Combine

@Observable
final class BudgetOverviewViewModel {
    private let evaluateBudget: EvaluateBudgetUseCase
    private let budgetRepository: any BudgetRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    var budgets: [Budget] = []
    var budgetStatuses: [UUID: BudgetStatus] = [:]
    var alerts: [BudgetAlert] = []
    var errorMessage: String?

    init(evaluateBudget: EvaluateBudgetUseCase, budgetRepository: any BudgetRepositoryProtocol) {
        self.evaluateBudget = evaluateBudget
        self.budgetRepository = budgetRepository

        evaluateBudget.alertPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alert in
                self?.alerts.append(alert)
            }
            .store(in: &cancellables)
    }

    func load() async {
        do {
            budgets = try await budgetRepository.fetchAll()
            for budget in budgets {
                let status = try await evaluateBudget.execute(budgetId: budget.id)
                budgetStatuses[budget.id] = status
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
