import Foundation

@Observable
final class PortfolioListViewModel {
    private let portfolioRepository: any PortfolioRepositoryProtocol
    private let createPortfolio: CreatePortfolioUseCase

    var portfolios: [Portfolio] = []
    var errorMessage: String?

    init(portfolioRepository: any PortfolioRepositoryProtocol, createPortfolio: CreatePortfolioUseCase) {
        self.portfolioRepository = portfolioRepository
        self.createPortfolio = createPortfolio
    }

    func load() async {
        do {
            portfolios = try await portfolioRepository.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createNewPortfolio(name: String, userId: UUID) async {
        do {
            let portfolio = try await createPortfolio.execute(name: name, userId: userId)
            portfolios.append(portfolio)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
