//
//  DashboardView.swift
//  Trade Journey
//
//  Created by Abdul Wahid Noor on 7.06.2025.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
            Text("Dashboard")
                .font(.largeTitle)
                .padding()
            
            Text("Your trading performance summary will appear here.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
