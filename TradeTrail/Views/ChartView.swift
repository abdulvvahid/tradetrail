import SwiftUI
import Charts

struct EquityPoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}

struct ChartView: View {
    @ObservedObject var tradeStore: TradeStore

    var equityPoints: [EquityPoint] {
        let calendar = Calendar(identifier: .gregorian)
        let grouped = Dictionary(grouping: tradeStore.trades) { trade in
            calendar.startOfDay(for: trade.openTime)
        }

        guard let firstDate = tradeStore.trades.map({ calendar.startOfDay(for: $0.openTime) }).min() else {
            return []
        }

        let fullRange = Date.datesBetween(start: firstDate, end: Date())
        var result: [EquityPoint] = []
        var runningBalance = 15000.0

        for date in fullRange {
            let dayProfit = grouped[date]?.map { $0.profit }.reduce(0, +) ?? 0
            runningBalance += dayProfit
            result.append(EquityPoint(date: date, balance: runningBalance))
        }

        return result
    }

    var body: some View {
        let minY = (equityPoints.map { $0.balance }.min() ?? 0) * 0.999
        let maxY = (equityPoints.map { $0.balance }.max() ?? 100) * 1.001

        VStack(alignment: .leading) {
            Text("Equity Curve")
                .font(.title2.bold())
                .padding(.horizontal)

            Chart(equityPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Balance", point.balance)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 2))

                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Balance", point.balance)
                )
                .annotation(position: .top) {
                    Text(String(format: "%.0f", point.balance))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0)))
                }
            }
            .chartYScale(domain: minY...maxY)
            .frame(height: 320)
            .padding()
        }
    }
}

extension Date {
    static func datesBetween(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar(identifier: .gregorian)
        var current = calendar.startOfDay(for: start)
        let end = calendar.startOfDay(for: end)

        while current <= end {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }
}
