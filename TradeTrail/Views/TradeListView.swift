import SwiftUI

struct TradeListView: View {
    @EnvironmentObject var tradeStore: TradeStore
    var filterDate: Date? = nil

    var body: some View {
        NavigationStack {
            List(filteredTrades.sorted(by: { $0.openTime > $1.openTime })) { trade in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(trade.symbol)
                            .font(.headline)
                        Spacer()
                        Text(trade.type)
                            .font(.subheadline)
                    }

                    Text("Open: \(formatted(trade.openTime)) @ \(String(format: "%.2f", trade.openPrice))")
                        .font(.caption)

                    Text("Close: \(formatted(trade.closeTime)) @ \(String(format: "%.2f", trade.closePrice))")
                        .font(.caption)

                    HStack {
                        Text("Lots: \(trade.lots, specifier: "%.2f")")
                        Spacer()
                        Text("P/L: \(trade.profit, specifier: "%.2f")")
                            .foregroundColor(trade.profit >= 0 ? .green : .red)
                    }
                    .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
            .navigationTitle(filterDate != nil ? "Trades on \(formatted(filterDate!))" : "All Trades")
        }
    }

    var filteredTrades: [TradeEntry] {
        if let date = filterDate {
            let cal = Calendar.current
            return tradeStore.trades.filter {
                cal.isDate($0.openTime, inSameDayAs: date)
            }
        }
        return tradeStore.trades
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
