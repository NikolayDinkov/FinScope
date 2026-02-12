import Testing
import Foundation
@testable import FinScope

struct CSVParserTests {
    @Test func testParseValidCSV() throws {
        let csv = """
        name,amount,type
        Groceries,50.00,expense
        Salary,1000.00,income
        """
        let data = csv.data(using: .utf8)!
        let records = try CSVParser.parse(data: data)
        #expect(records.count == 2)
        #expect(records[0]["name"] == "Groceries")
        #expect(records[0]["amount"] == "50.00")
        #expect(records[1]["type"] == "income")
    }

    @Test func testParseCSVWithQuotedFields() throws {
        let csv = """
        name,note
        Test,"Hello, World"
        """
        let data = csv.data(using: .utf8)!
        let records = try CSVParser.parse(data: data)
        #expect(records.count == 1)
        #expect(records[0]["note"] == "Hello, World")
    }

    @Test func testParseEmptyCSVThrows() {
        let data = Data()
        #expect(throws: CSVParser.CSVError.self) {
            try CSVParser.parse(data: data)
        }
    }

    @Test func testGenerateCSV() {
        let records: [[String: String]] = [
            ["name": "A", "amount": "10"],
            ["name": "B", "amount": "20"]
        ]
        let data = CSVParser.generate(from: records)
        let content = String(data: data, encoding: .utf8) ?? ""
        #expect(content.contains("name"))
        #expect(content.contains("amount"))
        #expect(content.contains("A"))
        #expect(content.contains("20"))
    }

    @Test func testRoundTrip() throws {
        let original: [[String: String]] = [
            ["type": "expense", "amount": "42.50", "note": "Test"]
        ]
        let data = CSVParser.generate(from: original)
        let parsed = try CSVParser.parse(data: data)
        #expect(parsed.count == 1)
        #expect(parsed[0]["type"] == "expense")
        #expect(parsed[0]["amount"] == "42.50")
    }
}
