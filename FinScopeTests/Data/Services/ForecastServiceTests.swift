import Testing
import Foundation
@testable import FinScope

struct ForecastServiceTests {
    let service = ForecastService()
    let referenceDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!

    @Test func testBasicMonthlyForecast() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 10000)]
        let salary = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .income,
            amount: 5000,
            date: referenceDate,
            isRecurring: true,
            recurrenceRule: RecurrenceRule(frequency: .monthly)
        )
        let rent = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .expense,
            amount: 1500,
            date: referenceDate,
            isRecurring: true,
            recurrenceRule: RecurrenceRule(frequency: .monthly)
        )

        let result = try await service.generateForecast(
            accounts: accounts,
            transactions: [salary, rent],
            horizon: .threeMonths,
            referenceDate: referenceDate
        )

        #expect(result.count == 3)
        #expect(result[0].projectedIncome == 5000)
        #expect(result[0].projectedExpenses == 1500)
        #expect(result[0].netCashFlow == 3500)
        #expect(result[0].projectedBalance == 13500)
        #expect(result[2].projectedBalance == 20500)
    }

    @Test func testHistoricalAverageIncluded() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 5000)]
        let threeMonthsAgo = referenceDate.adding(months: -3).startOfMonth
        let expense1 = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .expense,
            amount: 300,
            date: threeMonthsAgo.adding(days: 10)
        )
        let expense2 = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .expense,
            amount: 600,
            date: referenceDate.adding(months: -1)
        )

        let result = try await service.generateForecast(
            accounts: accounts,
            transactions: [expense1, expense2],
            horizon: .threeMonths,
            referenceDate: referenceDate
        )

        #expect(result.count == 3)
        #expect(result[0].projectedExpenses == 300)
        #expect(result[0].projectedBalance == 4700)
    }

    @Test func testWeeklyFrequencyConversion() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 1000)]
        let weeklyIncome = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .income,
            amount: 100,
            date: referenceDate,
            isRecurring: true,
            recurrenceRule: RecurrenceRule(frequency: .weekly)
        )

        let result = try await service.generateForecast(
            accounts: accounts,
            transactions: [weeklyIncome],
            horizon: .threeMonths,
            referenceDate: referenceDate
        )

        #expect(result[0].projectedIncome == 433)
    }

    @Test func testEmptyTransactionsProduceFlatForecast() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 2000)]
        let result = try await service.generateForecast(
            accounts: accounts,
            transactions: [],
            horizon: .threeMonths,
            referenceDate: referenceDate
        )

        #expect(result.count == 3)
        #expect(result[0].projectedBalance == 2000)
        #expect(result[2].projectedBalance == 2000)
    }

    @Test func testNegativeBalanceForecast() async throws {
        let accounts = [Account(name: "Bank", type: .bank, balance: 500)]
        let bigExpense = FinScope.Transaction(
            accountId: accounts[0].id,
            type: .expense,
            amount: 1000,
            date: referenceDate,
            isRecurring: true,
            recurrenceRule: RecurrenceRule(frequency: .monthly)
        )

        let result = try await service.generateForecast(
            accounts: accounts,
            transactions: [bigExpense],
            horizon: .threeMonths,
            referenceDate: referenceDate
        )

        #expect(result[0].projectedBalance == -500)
        #expect(result[0].netCashFlow == -1000)
    }
}
