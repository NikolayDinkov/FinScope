import SwiftUI
import UniformTypeIdentifiers

struct CSVImportView: View {
    let account: Account
    let coordinator: TransactionsCoordinator

    @State private var showFileImporter = false
    @State private var importResult: String?
    @State private var isImporting = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Import CSV")
                .font(.title2.bold())

            Text("Expected format: date,amount,type,note")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button {
                showFileImporter = true
            } label: {
                Label("Select CSV File", systemImage: "folder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isImporting)

            if let result = importResult {
                Text(result)
                    .font(.callout)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .navigationTitle("Import Transactions")
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType.commaSeparatedText]
        ) { result in
            switch result {
            case .success(let url):
                importResult = "File selected: \(url.lastPathComponent)"
            case .failure(let error):
                importResult = "Error: \(error.localizedDescription)"
            }
        }
    }
}
