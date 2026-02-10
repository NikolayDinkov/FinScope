import Foundation

@MainActor @Observable
final class CompositionRoot {
    // Core
    let coreDataStack: CoreDataStack

    // Repositories (typed as protocols)
    let userRepository: any UserRepositoryProtocol
    let accountRepository: any AccountRepositoryProtocol
    let transactionRepository: any TransactionRepositoryProtocol
    let categoryRepository: any CategoryRepositoryProtocol
    let budgetRepository: any BudgetRepositoryProtocol
    let portfolioRepository: any PortfolioRepositoryProtocol
    let investmentRepository: any InvestmentRepositoryProtocol
    let forecastRepository: any ForecastRepositoryProtocol

    // Services
    let budgetService: any BudgetServiceProtocol
    let investmentCalculator: any InvestmentCalculatorProtocol
    let forecastService: any ForecastServiceProtocol
    let transactionService: any TransactionServiceProtocol

    // Factory
    let assetFactory: AssetFactoryProtocol

    // Coordinators
    let appCoordinator: AppCoordinator

    init() {
        // 1. Core
        coreDataStack = CoreDataStack(modelName: "FinScope")
        let context = coreDataStack.viewContext

        // 2. Repositories
        let userRepo = CoreDataUserRepository(context: context)
        let accountRepo = CoreDataAccountRepository(context: context)
        let transactionRepo = CoreDataTransactionRepository(context: context)
        let categoryRepo = CoreDataCategoryRepository(context: context)
        let budgetRepo = CoreDataBudgetRepository(context: context)
        let portfolioRepo = CoreDataPortfolioRepository(context: context)
        let investmentRepo = CoreDataInvestmentRepository(context: context)
        let forecastRepo = CoreDataForecastRepository(context: context)

        userRepository = userRepo
        accountRepository = accountRepo
        transactionRepository = transactionRepo
        categoryRepository = categoryRepo
        budgetRepository = budgetRepo
        portfolioRepository = portfolioRepo
        investmentRepository = investmentRepo
        forecastRepository = forecastRepo

        // 3. Services
        let currencyConverter = CurrencyConverter()
        let txService = TransactionService(
            transactionRepository: transactionRepo,
            currencyConverter: currencyConverter
        )
        transactionService = txService

        let budgetSvc = BudgetService(
            budgetRepository: budgetRepo,
            transactionRepository: transactionRepo
        )
        budgetService = budgetSvc

        let invCalculator = InvestmentCalculator()
        investmentCalculator = invCalculator

        let forecastSvc = ForecastService(
            accountRepository: accountRepo,
            transactionRepository: transactionRepo,
            investmentCalculator: invCalculator
        )
        forecastService = forecastSvc

        let factory = AssetFactory()
        assetFactory = factory

        // 4. Use Cases (created as needed in ViewModel factories)

        // 5. Coordinators with ViewModel factories
        let accountsCoordinator = AccountsCoordinator(
            makeListViewModel: {
                AccountListViewModel(
                    fetchAccounts: FetchAccountsUseCase(repository: accountRepo),
                    deleteAccount: DeleteAccountUseCase(
                        accountRepository: accountRepo,
                        transactionRepository: transactionRepo
                    )
                )
            },
            makeDetailViewModel: { account in
                AccountDetailViewModel(
                    account: account,
                    fetchTransactions: FetchTransactionsUseCase(repository: transactionRepo)
                )
            },
            makeFormViewModel: { account in
                AccountFormViewModel(
                    account: account,
                    createAccount: CreateAccountUseCase(repository: accountRepo),
                    accountRepository: accountRepo
                )
            }
        )

        let transactionsCoordinator = TransactionsCoordinator(
            makeListViewModel: {
                TransactionListViewModel(
                    fetchTransactions: FetchTransactionsUseCase(repository: transactionRepo)
                )
            },
            makeFormViewModel: { transaction in
                TransactionFormViewModel(
                    transaction: transaction,
                    addTransaction: AddTransactionUseCase(
                        transactionRepository: transactionRepo,
                        transactionService: txService
                    ),
                    fetchAccounts: FetchAccountsUseCase(repository: accountRepo)
                )
            }
        )

        let budgetCoordinator = BudgetCoordinator(
            makeOverviewViewModel: {
                BudgetOverviewViewModel(
                    evaluateBudget: EvaluateBudgetUseCase(
                        budgetService: budgetSvc,
                        budgetRepository: budgetRepo,
                        transactionRepository: transactionRepo
                    ),
                    budgetRepository: budgetRepo
                )
            },
            makeFormViewModel: { budget in
                BudgetFormViewModel(
                    budget: budget,
                    createBudget: CreateBudgetUseCase(repository: budgetRepo)
                )
            }
        )

        let investmentCoordinator = InvestmentCoordinator(
            makeListViewModel: {
                PortfolioListViewModel(
                    portfolioRepository: portfolioRepo,
                    createPortfolio: CreatePortfolioUseCase(repository: portfolioRepo)
                )
            },
            makeSimulatorViewModel: { portfolio in
                SimulatorViewModel(
                    portfolio: portfolio,
                    simulatePortfolio: SimulatePortfolioUseCase(investmentCalculator: invCalculator),
                    assetFactory: factory
                )
            }
        )

        let forecastCoordinator = ForecastCoordinator(
            makeViewModel: {
                ForecastViewModel(
                    generateForecast: GenerateForecastUseCase(
                        forecastService: forecastSvc,
                        forecastRepository: forecastRepo
                    ),
                    forecastRepository: forecastRepo
                )
            }
        )

        appCoordinator = AppCoordinator(
            accountsCoordinator: accountsCoordinator,
            transactionsCoordinator: transactionsCoordinator,
            budgetCoordinator: budgetCoordinator,
            investmentCoordinator: investmentCoordinator,
            forecastCoordinator: forecastCoordinator,
            makeDashboardViewModel: {
                DashboardViewModel(
                    fetchAccounts: FetchAccountsUseCase(repository: accountRepo),
                    fetchTransactions: FetchTransactionsUseCase(repository: transactionRepo)
                )
            }
        )
    }
}
