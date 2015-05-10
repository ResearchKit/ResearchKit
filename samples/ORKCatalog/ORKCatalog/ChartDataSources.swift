//
//  ChartDataSources.swift
//  ORKCatalog
//
//  Created by James Cox on 11/05/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

import ResearchKit

class PieChartDataSource: NSObject, ORKPieChartViewDatasource {
    
    var colors = [
        UIColor(red: 217/225, green: 217/255, blue: 217/225, alpha: 1),
        UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
        UIColor(red: 244/255, green: 190/255, blue: 74/255, alpha: 1)]
    
    func numberOfSegmentsInPieChartView() -> Int {
        return colors.count
    }
    
    func pieChartView(pieChartView: ORKPieChartView, valueForSegmentAtIndex index: Int) -> CGFloat {
        return 20
    }
    
    func pieChartView(pieChartView: ORKPieChartView, colorForSegmentAtIndex index: Int) -> UIColor {
        return colors[index]
    }
    
    func pieChartView(pieChartView: ORKPieChartView, titleForSegmentAtIndex index: Int) -> String {
        return "\(index + 1)"
    }
}

class LineGraphDataSource: NSObject, ORKLineGraphViewDataSource {
    
    var firstPlot = [20,30,40,50,60,70] as [CGFloat]
    var secondPlot = [2,4,8,16,32,64] as [CGFloat]
    
    func lineGraph(graphView: ORKLineGraphView, numberOfPointsInPlot plotIndex: Int) -> Int {
        return plotIndex == 0 ? firstPlot.count : secondPlot.count
    }
    
    func lineGraph(graphView: ORKLineGraphView, plot plotIndex: Int, valueForPointAtIndex pointIndex: Int) -> CGFloat {
        return plotIndex == 0 ? firstPlot[pointIndex] : secondPlot[pointIndex]
    }
    
    func numberOfPlotsInLineGraph(graphView: ORKLineGraphView) -> Int {
        return 2
    }
    
    func numberOfDivisionsInXAxisForGraph(graphView: ORKLineGraphView) -> Int {
        return max(firstPlot.count, secondPlot.count)
    }
    
    func maximumValueForLineGraph(graphView: ORKLineGraphView) -> CGFloat {
        return 70
    }
    
    func minimumValueForLineGraph(graphView: ORKLineGraphView) -> CGFloat {
        return 0
    }
    
    func lineGraph(graphView: ORKLineGraphView, titleForXAxisAtIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }
}

class DiscreteGraphDataSource: NSObject, ORKDiscreteGraphViewDataSource {
    
    var firstPlot: [ORKRangePoint] {
        return [ORKRangePoint(minimumValue: 0, maximumValue: 2), ORKRangePoint(minimumValue: 2, maximumValue: 3), ORKRangePoint(minimumValue: 3, maximumValue: 5), ORKRangePoint(minimumValue: 6, maximumValue: 6)]
    }
    
    var secondPlot: [ORKRangePoint] {
        return [ORKRangePoint(minimumValue: 0, maximumValue: 1), ORKRangePoint(minimumValue: 1, maximumValue: 5), ORKRangePoint(minimumValue: 4, maximumValue: 6), ORKRangePoint(minimumValue: 6, maximumValue: 8)]
    }
    
    func discreteGraph(graphView: ORKDiscreteGraphView, numberOfPointsInPlot plotIndex: Int) -> Int {
        return plotIndex == 0 ? firstPlot.count : secondPlot.count
    }
    
    func discreteGraph(graphView: ORKDiscreteGraphView, plot plotIndex: Int, valueForPointAtIndex pointIndex: Int) -> ORKRangePoint {
        return plotIndex == 0 ? firstPlot[pointIndex] : secondPlot[plotIndex]
    }
    
    func maximumValueForDiscreteGraph(graphView: ORKDiscreteGraphView) -> CGFloat {
        return 8
    }
    
    func minimumValueForDiscreteGraph(graphView: ORKDiscreteGraphView) -> CGFloat {
        return 0
    }
    
    func discreteGraph(graphView: ORKDiscreteGraphView, titleForXAxisAtIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }
    
    func numberOfPlotsInDiscreteGraph(graphView: ORKDiscreteGraphView) -> Int {
        return 2
    }
    
    func numberOfDivisionsInXAxisForGraph(graphView: ORKDiscreteGraphView) -> Int {
        return max(firstPlot.count, secondPlot.count)
    }
}