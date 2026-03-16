import Charts
import SwiftUI

struct SpendingChartView: View {
    let data: [(category: String, total: Double)]

    var body: some View {
        Chart(data, id: \.category) { item in
            SectorMark(
                angle: .value("Amount", item.total),
                innerRadius: .ratio(0.55),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Category", item.category))
        }
        .chartLegend(position: .bottom)
    }
}
