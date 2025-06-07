//
//  TradeListView.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import SwiftUI

struct TradeListView: View {
    @EnvironmentObject var tradeStore: TradeStore

    var body: some View {
        NavigationStack {
            List(tradeStore.trades.sorted(by: { $0.openTime > $1.openTime })) { trade in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(trade.symbol)
                            .font(.headline)
                        Spacer()
                        Text(trade.type)
                            .font(.subheadline)
                            .foregroundColor(trade.type.lowercased() == "buy" ? .green : .red)
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
            .navigationTitle("Trades")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}



