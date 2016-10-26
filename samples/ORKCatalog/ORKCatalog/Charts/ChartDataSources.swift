/*
Copyright (c) 2015, James Cox. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import ResearchKit

class PieChartDataSource: NSObject, ORKPieChartViewDataSource {
    
    let colors = [
        UIColor(red: 217/225, green: 217/255, blue: 217/225, alpha: 1),
        UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1),
        UIColor(red: 244/255, green: 190/255, blue: 74/255, alpha: 1)
    ]
    let values = [10.0, 25.0, 45.0]
    
    func numberOfSegments(in pieChartView: ORKPieChartView ) -> Int {
        return colors.count
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
        return CGFloat(values[index])
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, colorForSegmentAt index: Int) -> UIColor {
        return colors[index]
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, titleForSegmentAt index: Int) -> String {
        return "Title \(index + 1)"
    }
}

class LineGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
    
    var plotPoints =
    [
        [
            ORKValueRange(value: 10),
            ORKValueRange(value: 20),
            ORKValueRange(value: 25),
            ORKValueRange(),
            ORKValueRange(value: 30),
            ORKValueRange(value: 40),
        ],
        [
            ORKValueRange(value: 2),
            ORKValueRange(value: 4),
            ORKValueRange(value: 8),
            ORKValueRange(value: 16),
            ORKValueRange(value: 32),
            ORKValueRange(value: 64),
        ]
    ]
    
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
       return plotPoints[plotIndex].count
    }
    
    func maximumValue(for graphChartView: ORKGraphChartView) -> Double {
        return 70
    }
    
    func minimumValue(for graphChartView: ORKGraphChartView) -> Double {
        return 0
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, drawsPointIndicatorsForPlotIndex plotIndex: Int) -> Bool {
        if plotIndex == 1 {
            return false
        }
        return true
    }
}

class DiscreteGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
    
    var plotPoints =
    [
        [
            ORKValueRange(minimumValue: 0, maximumValue: 2),
            ORKValueRange(minimumValue: 1, maximumValue: 4),
            ORKValueRange(minimumValue: 2, maximumValue: 6),
            ORKValueRange(minimumValue: 3, maximumValue: 8),
            ORKValueRange(minimumValue: 5, maximumValue: 10),
            ORKValueRange(minimumValue: 8, maximumValue: 13),
        ],
        [
            ORKValueRange(value: 1),
            ORKValueRange(minimumValue: 2, maximumValue: 6),
            ORKValueRange(minimumValue: 3, maximumValue: 10),
            ORKValueRange(minimumValue: 5, maximumValue: 11),
            ORKValueRange(minimumValue: 7, maximumValue: 13),
            ORKValueRange(minimumValue: 10, maximumValue: 13),
        ]
    ]
    
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }

}

class BarGraphDataSource: NSObject, ORKValueStackGraphChartViewDataSource {
    
    var plotPoints =
    [
        [
            ORKValueStack(stackedValues: [4, 6]),
            ORKValueStack(stackedValues: [2, 4, 4]),
            ORKValueStack(stackedValues: [2, 6, 3, 6]),
            ORKValueStack(stackedValues: [3, 8, 10, 12]),
            ORKValueStack(stackedValues: [5, 10, 12, 8]),
            ORKValueStack(stackedValues: [8, 13, 18]),
        ],
        [
            ORKValueStack(stackedValues: [14]),
            ORKValueStack(stackedValues: [6, 6]),
            ORKValueStack(stackedValues: [3, 10, 12]),
            ORKValueStack(stackedValues: [5, 11, 14]),
            ORKValueStack(stackedValues: [7, 13, 20]),
            ORKValueStack(stackedValues: [10, 13, 25]),
        ]
    ]
    
    public func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueStack {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }
    
}
