//
//  LineChartRepresentable.swift
//  Portal (macOS)
//
//  Created by Farid on 26.08.2021.
//

import SwiftUI
import Charts

struct LineChartRepresentable: NSViewRepresentable {
    let chartDataEntries: [ChartDataEntry]

    class Coordinator: NSObject, ChartViewDelegate {
        var lineChartRepresentable: LineChartRepresentable
        var lineChartView: LineChartView
        var chartDataEntries: [ChartDataEntry]?

        init(_ lineChartRepresentable: LineChartRepresentable) {
            self.lineChartRepresentable = lineChartRepresentable
            self.lineChartView = LineChartView()
            self.lineChartView.applyStandardSettings()
            super.init()
            self.lineChartView.delegate = self
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                chartView.clear()
                self.updateChartData()
            }
        }

        func updateChartData() {
            let data = LineChartData()
            
            if let chartDataEntries = self.chartDataEntries {
                let dataSet = chartDataEntries.dataSet()

                data.dataSets = [dataSet]

                let maxValue = chartDataEntries.map{$0.y}.max()

                if maxValue != nil {
                    dataSet.gradientPositions = [0, CGFloat(maxValue!)]
                    lineChartView.data = data
                    lineChartView.notifyDataSetChanged()
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> LineChartView {
        context.coordinator.updateChartData()
        return context.coordinator.lineChartView
    }

    func updateNSView(_ lineChart: LineChartView, context: Context) {
        context.coordinator.chartDataEntries = chartDataEntries
        context.coordinator.updateChartData()
    }
}
