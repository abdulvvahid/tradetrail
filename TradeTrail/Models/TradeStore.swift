//
//  TradeStore.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import Foundation
import SwiftUI

class TradeStore: ObservableObject {
    @Published var trades: [TradeEntry] = []
    private var repository: TradeRepository

    init(repository: TradeRepository? = nil) {
        let context = PersistenceController.shared.container.viewContext
        self.repository = repository ?? CoreDataTradeRepository(context: context)
        self.trades = self.repository.fetchAll()
    }

    func importFromCSV(content: String) -> [TradeEntry] {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy.MM.dd HH:mm:ss"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "dd/MM/yyyy HH:mm:ss.SSS"

        var newEntries: [TradeEntry] = []

        let lines = content.components(separatedBy: .newlines)
        let header = lines.first?.lowercased() ?? ""
        let isCTFormat = header.contains("opening direction")

        for line in lines.dropFirst() where !line.isEmpty {
            let values = line.components(separatedBy: ",")
            guard values.count > 10 else { continue }

            var entry: TradeEntry?

            if isCTFormat {
                // ✅ cTrader format
                let id = values[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let symbol = values[2].replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
                let type = values[3].replacingOccurrences(of: "\"", with: "").capitalized

                let openTime = formatter2.date(from: values[5]
                    .replacingOccurrences(of: "\"", with: "")
                    .trimmingCharacters(in: .whitespaces)) ?? Date()

                let closeTime = formatter2.date(from: values[6]
                    .replacingOccurrences(of: "\"", with: "")
                    .trimmingCharacters(in: .whitespaces)) ?? Date()

                let openPrice = Double(values[7]
                    .replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                    .trimmingCharacters(in: .whitespaces)) ?? 0

                let closePrice = Double(values[8]
                    .replacingOccurrences(of: "\"", with: "")
                    .replacingOccurrences(of: ",", with: ".")
                    .trimmingCharacters(in: .whitespaces)) ?? 0

                let lotsRaw = values[9].replacingOccurrences(of: "\"", with: "")
                let lotsString = lotsRaw.components(separatedBy: " ").first ?? "0"
                let lots = Double(lotsString.replacingOccurrences(of: ",", with: ".")) ?? 0

                let profit = Double(values[15].cleanedForDouble) ?? 0

                
                print("[PARSED] ID: \(id), Symbol: \(symbol), Type: \(type), Lots: \(lots), P/L: \(profit), Open: \(openTime), Close: \(closeTime), values[15]: \(values[15])")
                let raw = values[15]
                print("[RAW DEBUG] \(raw) / HEX: \(raw.utf8.map { String(format: "%02X", $0) }.joined(separator: " "))")
                entry = TradeEntry(
                    id: id,
                    symbol: symbol,
                    type: type,
                    openTime: openTime,
                    closeTime: closeTime,
                    openPrice: openPrice,
                    closePrice: closePrice,
                    lots: lots,
                    profit: profit,
                    sl: 0,
                    tp: 0
                )
            } else {
                // ✅ MetaTrader format
                let id = values[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let openTime = formatter1.date(from: values[1].trimmingCharacters(in: .whitespaces)) ?? Date()
                let openPrice = Double(values[2].replacingOccurrences(of: ",", with: ".")) ?? 0
                let closeTime = formatter1.date(from: values[3].trimmingCharacters(in: .whitespaces)) ?? Date()
                let closePrice = Double(values[4].replacingOccurrences(of: ",", with: ".")) ?? 0
                let profit = Double(values[5].replacingOccurrences(of: ",", with: ".")) ?? 0
                let lots = Double(values[6].replacingOccurrences(of: ",", with: ".")) ?? 0
                let symbol = values[9].trimmingCharacters(in: .whitespaces)
                let type = values[10].trimmingCharacters(in: .whitespaces)
                let sl = Double(values[12].replacingOccurrences(of: ",", with: ".")) ?? 0
                let tp = Double(values[13].replacingOccurrences(of: ",", with: ".")) ?? 0

                entry = TradeEntry(
                    id: id,
                    symbol: symbol,
                    type: type,
                    openTime: openTime,
                    closeTime: closeTime,
                    openPrice: openPrice,
                    closePrice: closePrice,
                    lots: lots,
                    profit: profit,
                    sl: sl,
                    tp: tp
                )
            }

            if let entry = entry, repository.save(entry) {
                
                print("[PARSED] ID: \(entry.id), Symbol: \(entry.symbol), Type: \(entry.type), Lots: \(entry.lots), P/L: \(entry.profit), Open: \(entry.openTime), Close: \(entry.closeTime)")

            
                    trades.append(entry)
                    newEntries.append(entry)

            }
        }

        return newEntries
    }

    func deleteAllTrades() {
        repository.deleteAll()
        trades = []
    }
    
    func dailyStats() -> [DailyStats] {
        let calendar = Calendar(identifier: .gregorian)
        let grouped = Dictionary(grouping: trades) { trade in
            calendar.startOfDay(for: trade.openTime)
        }

        return grouped.map { (date, trades) in
            DailyStats(
                date: date,
                totalPnL: trades.map { $0.profit }.reduce(0, +),
                tradeCount: trades.count
            )
        }.sorted(by: { $0.date > $1.date })
    }

    func weeklyStats() -> [WeeklyStats] {
        let calendar = Calendar(identifier: .gregorian)
        var calendarWithMonday = calendar
        calendarWithMonday.firstWeekday = 2

        let grouped = Dictionary(grouping: trades) { trade in
            calendarWithMonday.dateInterval(of: .weekOfYear, for: trade.openTime)?.start ?? trade.openTime
        }

        return grouped.map { (weekStart, trades) in
            WeeklyStats(
                weekStart: weekStart,
                totalPnL: trades.map { $0.profit }.reduce(0, +),
                tradeCount: trades.count
            )
        }.sorted(by: { $0.weekStart > $1.weekStart })
    }
}

