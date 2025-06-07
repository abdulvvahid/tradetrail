//
//  ContentView.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var tradeStore: TradeStore
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Dashboard", destination: DashboardView())
                NavigationLink("Import CSV", destination: ImportView())
                NavigationLink("Trade List", destination: TradeListView())
                NavigationLink("Trade Chart", destination: ChartView())
                NavigationLink("Settings", destination: SettingsView())
                NavigationLink("📅 Calendar", destination: TradeCalendarView(tradeStore: tradeStore))

            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200)
            
            Text("Please select a screen from the sidebar.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView(tradeStore: TradeStore())
}
