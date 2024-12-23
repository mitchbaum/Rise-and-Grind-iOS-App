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
    @Published var xAxisLabel: String = ""
    @Published var dataKey: String = ""
}

struct DataModel: Identifiable {
    let id: String
    let weight: Double
    let reps: Int
    let createdAt: Date
}

struct LineGraph: View {
    @ObservedObject var data: LineGraphData
    
    let HEIGHT: CGFloat = 250
    
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
    
    func formatPointNumber(key: String, num: Double) -> String {
        if (key == "Reps") { return "\(Int(num))" }
        let roundedWeight = num.toFixed(2)
        if roundedWeight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", roundedWeight) // Return as an integer
        } else {
            return String(format: "%.2f", roundedWeight) // Return as a float
        }
    }
    
    func getYValue(dataModel: DataModel) -> Double {
        if data.dataKey == "Weight" {
            return dataModel.weight
        } else {
            return Double(dataModel.reps)
        }
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                Chart(data.list) { dataModel in
                    LineMark(
                        x: .value("Month", formatDate(dataModel.createdAt)),
                        y: .value(data.dataKey, getYValue(dataModel: dataModel))
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(Utilities.loadThemeSwiftUI())
                    
                    PointMark(
                        x: .value("Month", formatDate(dataModel.createdAt)),
                        y: .value(data.dataKey, getYValue(dataModel: dataModel))
                    )
                    .foregroundStyle(.green)
                    .symbolSize(35)
                    .annotation(position: .overlay,
                                alignment: .bottomTrailing,
                                spacing: 8) {
                        Text(formatPointNumber(key: data.dataKey, num: getYValue(dataModel: dataModel)))
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }.background(Color.white)
                    .chartYAxis {
                        AxisMarks(position: .leading) // Y-axis remains fixed
                    }
                    .chartYAxisLabel(position: .top, alignment: .topLeading) {
                        Text(data.xAxisLabel).italic().padding(.bottom, 6) // Add padding to the Y-axi
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
