import Foundation
import UniformTypeIdentifiers

@MainActor @Observable
final class CSVImportExportViewModel {
    var importedCount: Int?
    var exportData: Data?
    var errorMessage: String?
    var isShowingImporter = false
    var isShowingExporter = false

    var onDismiss: (() -> Void)?

    private let accountId: UUID
    private let importUseCase: ImportTransactionsUseCase
    private let exportUseCase: ExportTransactionsUseCase

    init(
        accountId: UUID,
        importUseCase: ImportTransactionsUseCase,
        exportUseCase: ExportTransactionsUseCase
    ) {
        self.accountId = accountId
        self.importUseCase = importUseCase
        self.exportUseCase = exportUseCase
    }

    func importCSV(data: Data) async {
        do {
            let count = try await importUseCase.execute(data: data, accountId: accountId)
            importedCount = count
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func exportCSV() async {
        do {
            exportData = try await exportUseCase.execute(accountId: accountId)
            isShowingExporter = true
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }
    }
}
