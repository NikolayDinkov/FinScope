import Foundation

struct CategoryWithSubcategories {
    let name: String
    let icon: String
    let colorHex: String
    let transactionType: TransactionType
    let subcategories: [String]
}

enum DefaultCategoryData {
    static let categoriesWithSubcategories: [CategoryWithSubcategories] = [
        CategoryWithSubcategories(
            name: "Salary",
            icon: "banknote",
            colorHex: "#34C759",
            transactionType: .income,
            subcategories: ["Full-time", "Part-time", "Bonus"]
        ),
        CategoryWithSubcategories(
            name: "Freelance",
            icon: "laptopcomputer",
            colorHex: "#30D158",
            transactionType: .income,
            subcategories: ["Consulting", "Projects", "Commissions"]
        ),
        CategoryWithSubcategories(
            name: "Investment Income",
            icon: "chart.line.uptrend.xyaxis",
            colorHex: "#00C7BE",
            transactionType: .income,
            subcategories: ["Dividends", "Interest", "Capital Gains"]
        ),
        CategoryWithSubcategories(
            name: "Other Income",
            icon: "plus.circle",
            colorHex: "#32ADE6",
            transactionType: .income,
            subcategories: ["Gifts", "Refunds", "Miscellaneous"]
        ),
        CategoryWithSubcategories(
            name: "Food & Dining",
            icon: "fork.knife",
            colorHex: "#FF9500",
            transactionType: .expense,
            subcategories: ["Groceries", "Restaurants", "Coffee", "Delivery"]
        ),
        CategoryWithSubcategories(
            name: "Transport",
            icon: "car",
            colorHex: "#FF3B30",
            transactionType: .expense,
            subcategories: ["Fuel", "Public Transit", "Taxi", "Parking"]
        ),
        CategoryWithSubcategories(
            name: "Housing",
            icon: "house",
            colorHex: "#AF52DE",
            transactionType: .expense,
            subcategories: ["Rent", "Mortgage", "Maintenance", "Insurance"]
        ),
        CategoryWithSubcategories(
            name: "Entertainment",
            icon: "film",
            colorHex: "#FF2D55",
            transactionType: .expense,
            subcategories: ["Movies", "Games", "Subscriptions", "Events"]
        ),
        CategoryWithSubcategories(
            name: "Healthcare",
            icon: "heart",
            colorHex: "#FF6482",
            transactionType: .expense,
            subcategories: ["Doctor", "Pharmacy", "Insurance"]
        ),
        CategoryWithSubcategories(
            name: "Shopping",
            icon: "bag",
            colorHex: "#5856D6",
            transactionType: .expense,
            subcategories: ["Clothing", "Electronics", "Home Goods"]
        ),
        CategoryWithSubcategories(
            name: "Utilities",
            icon: "bolt",
            colorHex: "#FFCC00",
            transactionType: .expense,
            subcategories: ["Electricity", "Water", "Internet", "Phone"]
        ),
        CategoryWithSubcategories(
            name: "Education",
            icon: "book",
            colorHex: "#007AFF",
            transactionType: .expense,
            subcategories: ["Tuition", "Books", "Courses"]
        ),
        CategoryWithSubcategories(
            name: "Other Expense",
            icon: "ellipsis.circle",
            colorHex: "#8E8E93",
            transactionType: .expense,
            subcategories: ["Fees", "Taxes", "Miscellaneous"]
        ),
    ]

    static var allCategories: [Category] {
        categoriesWithSubcategories.map { data in
            Category(
                name: data.name,
                icon: data.icon,
                colorHex: data.colorHex,
                isDefault: true,
                transactionType: data.transactionType
            )
        }
    }
}
