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

struct DataModel: Identifiable, Equatable {
    let id: String
    let weight: Double
    let reps: Int
    let createdAt: Date
}

struct LineGraph: View {
    @ObservedObject var data: LineGraphData
    @State private var scrollPosition: String  = ""
    
    let HEIGHT: CGFloat = 250
    let CHART_SIZE_IN_SEGMENTS: Int = 5
    
    let bgColor: Color = Color(Utilities.loadAppearanceTheme(property: "primary"))
    
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
    
    func reverse(data: [DataModel]) -> [DataModel] {
        return data.reversed()
    }
    
    func elementFromEnd(data: [DataModel]) -> DataModel? {
        // Calculate the index of the element CHART_SIZE_IN_SEGMENTS from the end
        let indexFromEnd = data.count - CHART_SIZE_IN_SEGMENTS
        
        if indexFromEnd >= 0 {
            return data[indexFromEnd]
        } else {
            return data.first! // Return the first element if the array has fewer than CHART_SIZE_IN_SEGMENTS elements
        }
    }
    var body: some View {
        VStack {
                    Chart(reverse(data: data.list)) { dataModel in
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
                                .foregroundColor(Color(UIColor.lightGray))
                        }
                    }.background(bgColor)
                        .chartYAxis {
                            AxisMarks(position: .trailing)  { value in
                                AxisValueLabel()
                                    .foregroundStyle(Color(UIColor.lightGray)) // Change label color here
                            } // Y-axis remains fixed
                        }
                        .chartScrollableAxes(.horizontal)
                        .chartXVisibleDomain(length: CHART_SIZE_IN_SEGMENTS)
                        .chartXAxis {
                            AxisMarks()  { value in
                                AxisValueLabel()
                                    .foregroundStyle(Color(UIColor.lightGray)) // Change label color here
                            } // X-axis remains fixed
                        }
                        .onChange(of: data.list) { view in
                            DispatchQueue.main.async {
                                if let graphStartDate = elementFromEnd(data: reverse(data:data.list))?.createdAt {
                                    scrollPosition = formatDate(graphStartDate)
                                    
                                }
                                
                            }
                        }
                        .if(!scrollPosition.isEmpty) { view in
                            view.chartScrollPosition(initialX: scrollPosition)
                        }
                
            }.background(bgColor)
                .frame(height: HEIGHT) // Set height for the scrolling area
                
        
        
    }
        

    
}
