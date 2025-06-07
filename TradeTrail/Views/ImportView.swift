import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @EnvironmentObject var tradeStore: TradeStore

    @State private var isImporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var newTrades: [TradeEntry] = []

    var body: some View {
        VStack {
            Button("Import Trading CSV") {
                isImporting = true
            }
            .padding()
            
            Button(action: {
                tradeStore.deleteAllTrades()
            }) {
                Label("Delete All Trades", systemImage: "trash")
                    .foregroundColor(.red)
            }

            if newTrades.isEmpty {
                Text("No new trades imported yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(newTrades) { trade in
                    VStack(alignment: .leading) {
                        Text("\(trade.symbol) - \(trade.type)")
                            .font(.headline)
                        Text("Opened: \(formatted(trade.openTime)) at \(trade.openPrice)")
                        Text("Closed: \(formatted(trade.closeTime)) at \(trade.closePrice)")
                        Text("Profit: $\(String(format: "%.2f", trade.profit)) | Lots: \(trade.lots)")
                            .foregroundColor(trade.profit >= 0 ? .green : .red)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let fileURL = urls.first {
                    readCSVSecurely(from: fileURL)
                }
            case .failure(let error):
                errorMessage = "File selection error: \(error.localizedDescription)"
                showError = true
            }
        }
        .alert("Import Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    func readCSVSecurely(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            errorMessage = "Permission denied to access the file."
            showError = true
            return
        }

        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let new = tradeStore.importFromCSV(content: content)
            newTrades = new
        } catch {
            errorMessage = "CSV read error: \(error.localizedDescription)"
            showError = true
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

