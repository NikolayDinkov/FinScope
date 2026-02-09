import Testing
@testable import FinScope

@Suite("Budget Use Case Tests")
struct BudgetUseCaseTests {

    @Test("CreateBudget succeeds with valid data")
    func createBudgetSuccess() async throws {
        let repo = MockBudgetRepository()
        let useCase = CreateBudgetUseCase(repository: repo)
        let userId = UUID()

        let budget = try await useCase.execute(
            name: "Monthly Budget",
            period: .monthly,
            totalLimit: 2000,
            userId: userId,
            rules: []
        )

        #expect(budget.name == "Monthly Budget")
        #expect(budget.period == .monthly)
        #expect(budget.totalLimit == 2000)
        #expect(repo.saveCalled)
    }

    @Test("CreateBudget fails with empty name")
    func createBudgetEmptyName() async {
        let repo = MockBudgetRepository()
        let useCase = CreateBudgetUseCase(repository: repo)

        await #expect(throws: BudgetError.self) {
            try await useCase.execute(
                name: "",
                period: .monthly,
                totalLimit: nil,
                userId: UUID(),
                rules: []
            )
        }
    }
}
