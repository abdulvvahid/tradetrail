//
//  Trade_JourneyApp.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import SwiftUI

@main
struct TradeTrail: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var tradeStore = TradeStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(tradeStore: tradeStore)
                .environmentObject(tradeStore)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
