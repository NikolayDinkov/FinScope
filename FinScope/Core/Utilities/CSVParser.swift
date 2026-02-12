import Foundation

struct CSVParser: Sendable {
    enum CSVError: Error {
        case invalidData
        case emptyFile
        case missingHeaders
    }

    static func parse(data: Data) throws -> [[String: String]] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw CSVError.invalidData
        }

        let rows = content.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        guard !rows.isEmpty else { throw CSVError.emptyFile }
        guard rows.count > 1 else { throw CSVError.missingHeaders }

        let headers = parseRow(rows[0])

        return rows.dropFirst().map { row in
            let values = parseRow(row)
            var dict = [String: String]()
            for (index, header) in headers.enumerated() {
                dict[header] = index < values.count ? values[index] : ""
            }
            return dict
        }
    }

    static func generate(from records: [[String: String]]) -> Data {
        guard let first = records.first else { return Data() }

        let headers = first.keys.sorted()
        var lines = [headers.map { escapeField($0) }.joined(separator: ",")]

        for record in records {
            let values = headers.map { key in
                escapeField(record[key] ?? "")
            }
            lines.append(values.joined(separator: ","))
        }

        return lines.joined(separator: "\n").data(using: .utf8) ?? Data()
    }

    private static func parseRow(_ row: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false

        for char in row {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
            } else {
                current.append(char)
            }
        }
        fields.append(current.trimmingCharacters(in: .whitespaces))

        return fields
    }

    private static func escapeField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }
}
