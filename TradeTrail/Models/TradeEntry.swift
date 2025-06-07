//
//  TradeEntry.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import Foundation

struct TradeEntry: Identifiable {
    let id: String
    var symbol: String
    var type: String
    var openTime: Date
    var closeTime: Date
    var openPrice: Double
    var closePrice: Double
    var lots: Double
    var profit: Double
    var sl: Double
    var tp: Double
    
    init(
        id: String,
        symbol: String,
        type: String,
        openTime: Date,
        closeTime: Date,
        openPrice: Double,
        closePrice: Double,
        lots: Double,
        profit: Double,
        sl: Double,
        tp: Double
    ) {
        self.id = id
        self.symbol = symbol
        self.type = type
        self.openTime = openTime
        self.closeTime = closeTime
        self.openPrice = openPrice
        self.closePrice = closePrice
        self.lots = lots
        self.profit = profit
        self.sl = sl
        self.tp = tp
    }

}
