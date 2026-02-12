import Testing
import Foundation
@testable import FinScope

struct CategoryTests {
    @Test func testCategoryCreation() {
        let category = FinScope.Category(
            name: "Food",
            icon: "fork.knife",
            colorHex: "#FF9500",
            isDefault: true,
            transactionType: .expense
        )
        #expect(category.name == "Food")
        #expect(category.icon == "fork.knife")
        #expect(category.colorHex == "#FF9500")
        #expect(category.isDefault == true)
        #expect(category.transactionType == .expense)
    }

    @Test func testSubcategoryCreation() {
        let categoryId = UUID()
        let sub = FinScope.Subcategory(
            categoryId: categoryId,
            name: "Groceries",
            isDefault: true
        )
        #expect(sub.categoryId == categoryId)
        #expect(sub.name == "Groceries")
        #expect(sub.isDefault == true)
    }

    @Test func testDefaultCategoryDataHasCategories() {
        let categories = DefaultCategoryData.allCategories
        #expect(categories.count > 0)

        let incomeCategories = categories.filter { $0.transactionType == .income }
        let expenseCategories = categories.filter { $0.transactionType == .expense }
        #expect(incomeCategories.count >= 4)
        #expect(expenseCategories.count >= 9)
    }
}
