//
//  TradeRepository.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import Foundation

protocol TradeRepository {
    func save(_ entry: TradeEntry) -> Bool 
    func fetchAll() -> [TradeEntry]
    func deleteAll()
}
