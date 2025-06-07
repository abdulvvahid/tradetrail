import SwiftUI

struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalPnL: Double
    let tradeCount: Int
}

struct WeeklyStats: Identifiable, Hashable {
    let id = UUID()
    let weekStart: Date
    let totalPnL: Double
    let tradeCount: Int
}

struct TradeCalendarView: View {
    @ObservedObject var tradeStore: TradeStore
    @State private var selectedMonth: Date = Date()

    var calendarWithMonday: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }

    var body: some View {
        let calendar = calendarWithMonday
        let monthDays = generateMonthDays(for: selectedMonth, calendar: calendar)
        let dailyStatsDict = Dictionary(grouping: tradeStore.dailyStats(), by: { calendar.startOfDay(for: $0.date) })
        let weeklyStats = tradeStore.weeklyStats().filter { calendar.isDate($0.weekStart, equalTo: selectedMonth, toGranularity: .month) }
        let weeklyStatsDict = Dictionary(uniqueKeysWithValues: weeklyStats.map { ($0.weekStart, $0) })
        let weeks = monthDays.chunked(into: 7)

        let monthlyPnL = tradeStore.trades
            .filter { calendar.isDate($0.openTime, equalTo: selectedMonth, toGranularity: .month) }
            .map { $0.profit }
            .reduce(0, +)

        VStack(spacing: 12) {
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthTitle(for: selectedMonth))
                    .font(.title2).bold()
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            Text("Aylık PnL: \(monthlyPnL, specifier: "%.2f")")
                .font(.subheadline)
                .foregroundColor(monthlyPnL >= 0 ? .green : .red)

            let rawSymbols = calendar.shortStandaloneWeekdaySymbols
            let weekdaySymbols = Array(rawSymbols[calendar.firstWeekday - 1..<rawSymbols.count] + rawSymbols[0..<calendar.firstWeekday - 1])

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8)) {
                ForEach(weekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption).bold()
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
                Text("Özet")
                    .font(.caption).bold()
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                ForEach(weeks, id: \.self) { week in
                    ForEach(week, id: \.self) { day in
                        if calendar.isDate(day, equalTo: Date.distantPast, toGranularity: .day) {
                            Color.clear.frame(height: 70)
                        } else {
                            let dayStat = dailyStatsDict[calendar.startOfDay(for: day)]?.first

                            VStack(spacing: 4) {
                                Text("\(calendar.component(.day, from: day))")
                                    .font(.caption2).bold()

                                if let stat = dayStat {
                                    Text("💰 \(stat.totalPnL, specifier: "%.0f")")
                                        .font(.caption2)
                                        .foregroundColor(stat.totalPnL >= 0 ? .green : .red)
                                    Text("📊 \(stat.tradeCount)")
                                        .font(.caption2)
                                }
                            }
                            .frame(height: 70)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }

                    if let weekStart = week.first, let summary = weeklyStatsDict[calendar.startOfDay(for: weekStart)] {
                        VStack(spacing: 4) {
                            Text("Toplam")
                                .font(.caption2).bold()
                            Text("PnL: \(summary.totalPnL, specifier: "%.2f")")
                                .font(.caption2)
                                .foregroundColor(summary.totalPnL >= 0 ? .green : .red)
                            Text("İşlem: \(summary.tradeCount)")
                                .font(.caption2)
                        }
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(6)
                    } else {
                        Color.clear.frame(height: 70)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Monthly Calendar")
    }

    func generateMonthDays(for month: Date, calendar: Calendar) -> [Date] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!

        var days: [Date] = []
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        let weekdayOffset = calendar.component(.weekday, from: days.first!) - calendar.firstWeekday
        return Array(repeating: Date.distantPast, count: weekdayOffset < 0 ? weekdayOffset + 7 : weekdayOffset) + days
    }

    func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }

    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
        }
    }

    func formattedWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        let end = Calendar.current.date(byAdding: .day, value: 6, to: date) ?? date
        return "\(formatter.string(from: date)) - \(formatter.string(from: end))"
    }
}
