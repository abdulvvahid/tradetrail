//
//  CoreDataTradeRepository.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import CoreData

class CoreDataTradeRepository: TradeRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func save(_ entry: TradeEntry) -> Bool {
        let request: NSFetchRequest<TradeEntity> = TradeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "tradeID == %@", entry.id)

        let existing = (try? context.fetch(request)) ?? []
        if !existing.isEmpty {
            return false
        }

        let entity = TradeEntity(context: context)
        entity.tradeID = entry.id
        entity.symbol = entry.symbol
        entity.type = entry.type
        entity.openTime = entry.openTime
        entity.closeTime = entry.closeTime
        entity.openPrice = entry.openPrice
        entity.closePrice = entry.closePrice
        entity.lots = entry.lots
        entity.profit = entry.profit
        entity.sl = entry.sl
        entity.tp = entry.tp

        do {
            try context.save()
            return true
        } catch {
            print("Failed to save trade: \(error)")
            return false
        }
    }

    func fetchAll() -> [TradeEntry] {
        let request: NSFetchRequest<TradeEntity> = TradeEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.map { entity in
                TradeEntry(
                    id: entity.tradeID ?? UUID().uuidString,
                    symbol: entity.symbol ?? "",
                    type: entity.type ?? "",
                    openTime: entity.openTime ?? Date(),
                    closeTime: entity.closeTime ?? Date(),
                    openPrice: entity.openPrice,
                    closePrice: entity.closePrice,
                    lots: entity.lots,
                    profit: entity.profit,
                    sl: entity.sl,
                    tp: entity.tp
                )
            }
        } catch {
            print("Failed to fetch trades: \(error)")
            return []
        }
    }

    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TradeEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete all trades: \(error)")
        }
    }
}
