//
//  LineGraph.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/19/24.
//

import SwiftUI
import Charts
import Foundation

class LineGraphData: ObservableObject {
    // DataModel(id: "1", weight: 1291, createdAt: LineGraph.dateFormatter.date(from: "01/25/2022") ?? Date())
    @Published var list: [DataModel] = []
}

struct DataModel: Identifiable {
    let id: String
    let weight: Double
    let createdAt: Date
}

struct LineGraph: View {
    @ObservedObject var data: LineGraphData
    
    let HEIGHT: CGFloat = 250
    let xAxisLabel: String = UserDefaults.standard.object(forKey: "weightMetric") as! Int == 0 ? "Weight (LBS)" : "Weight (KG)"
    
    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy"
        return df
    }()
    
    func formatDate( _ date: Date) -> String {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.month, .day, .year], from: date)
        guard let day = dateComponents.day, let month = dateComponents.month, let year = dateComponents.year else {
            return "-"
        }
        let twoDigitYear = year % 100
        return "\(month)/\(day)/\(twoDigitYear)"
    }
    
    func formatWeight(weight: Double) -> String {
        let roundedWeight = weight.toFixed(2)
        if roundedWeight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", roundedWeight) // Return as an integer
        } else {
            return String(format: "%.2f", roundedWeight) // Return as a float
        }
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                Chart(data.list) { dataModel in
                    LineMark(
                        x: .value("Month", formatDate(dataModel.createdAt)),
                        y: .value("Weight", dataModel.weight)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(Utilities.loadThemeSwiftUI())
                    
                    PointMark(
                        x: .value("Month", formatDate(dataModel.createdAt)),
                        y: .value("Weight", dataModel.weight)
                    )
                    .foregroundStyle(.green)
                    .symbolSize(35)
                    .annotation(position: .overlay,
                                alignment: .bottomTrailing,
                                spacing: 8) {
                        Text(formatWeight(weight: dataModel.weight))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }.background(Color.white)
                    .chartYAxis {
                        AxisMarks(position: .leading) // Y-axis remains fixed
                    }
                    .chartYAxisLabel(position: .top, alignment: .topLeading) {
                        Text(xAxisLabel).italic().padding(.bottom, 6) // Add padding to the Y-axi
                    }
                    .chartXAxisLabel(position: .bottom, alignment: .bottomLeading) {
                        Text("Month/Day/Year").italic()
                    }
                    .frame(width: data.list.count > 5 ? CGFloat(data.list.count) * 60 : 300, height: HEIGHT) // Dynamic width for scrolling
                
            }.background(Color.white)
                .frame(height: HEIGHT) // Set height for the scrolling area
                
            
        }
    }
        

    
}
