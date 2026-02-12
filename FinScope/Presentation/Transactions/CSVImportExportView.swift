import SwiftUI
import UniformTypeIdentifiers

struct CSVImportExportView: View {
    @Bindable var viewModel: CSVImportExportViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Import") {
                    Button {
                        viewModel.isShowingImporter = true
                    } label: {
                        Label("Import from CSV", systemImage: "square.and.arrow.down")
                    }

                    if let count = viewModel.importedCount {
                        Text("Successfully imported \(count) transactions.")
                            .foregroundStyle(.green)
                    }
                }

                Section("Export") {
                    Button {
                        Task { await viewModel.exportCSV() }
                    } label: {
                        Label("Export to CSV", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .navigationTitle("CSV Import/Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { viewModel.onDismiss?() }
                }
            }
            .fileImporter(
                isPresented: $viewModel.isShowingImporter,
                allowedContentTypes: [UTType.commaSeparatedText]
            ) { result in
                switch result {
                case .success(let url):
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    if let data = try? Data(contentsOf: url) {
                        Task { await viewModel.importCSV(data: data) }
                    }
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
