/*
Copyright (c) 2015, James Cox. All rights reserved.
Copyright (c) 2015-2016, Ricardo Sánchez-Sáez.

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

func randomColorArray(_ number: Int) -> [UIColor] {
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        }
        
        var colors: [UIColor] = []
        for _ in 0 ..< number {
            colors.append(UIColor(red: random(), green: random(), blue: random(), alpha: 1))
        }
        return colors
    }

let NumberOfPieChartSegments = 13

class ColorlessPieChartDataSource: NSObject, ORKPieChartViewDataSource {
    
    func numberOfSegments(in pieChartView: ORKPieChartView ) -> Int {
        return NumberOfPieChartSegments
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
        return CGFloat(index + 1)
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, titleForSegmentAt index: Int) -> String {
        return "Title \(index + 1)"
    }
}

class RandomColorPieChartDataSource: ColorlessPieChartDataSource {
    
    lazy var backingStore: [UIColor] = {
        return randomColorArray(NumberOfPieChartSegments)
        }()

    func pieChartView(_ pieChartView: ORKPieChartView, colorForSegmentAtIndex index: Int) -> UIColor {
        return backingStore[index]
    }
}

class BaseFloatRangeGraphChartDataSource:  NSObject, ORKValueRangeGraphChartViewDataSource {
    var plotPoints: [[ORKValueRange]] = [[]]
    
    internal func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
}

class BaseFloatStackGraphChartDataSource:  NSObject, ORKValueStackGraphChartViewDataSource {
    
    var plotPoints: [[ORKValueStack]] = [[]]
    
    public func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueStack {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
}

class LineGraphChartDataSource: BaseFloatRangeGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                ],
                [
                    ORKValueRange(value: 2),
                    ORKValueRange(value: 4),
                    ORKValueRange(value: 8),
                    ORKValueRange(value: 16),
                    ORKValueRange(value: 32),
                    ORKValueRange(value: 50),
                    ORKValueRange(value: 64),
                ],
                [
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                ],
        ]
    }
    
    func maximumValueForGraphChartView(_ graphChartView: ORKGraphChartView) -> Double {
        return 70
    }
    
    func minimumValueForGraphChartView(_ graphChartView: ORKGraphChartView) -> Double {
        return 0
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 10
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return (pointIndex % 2 == 0) ? nil : "\(pointIndex + 1)"
    }

    func graphChartView(_ graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return (pointIndex % 2 == 1) ? false : true
    }

    func scrubbingPlotIndexForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}

class ColoredLineGraphChartDataSource: LineGraphChartDataSource {
    func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        let color: UIColor
        switch plotIndex {
        case 0:
            color = UIColor.cyan
        case 1:
            color = UIColor.magenta
        case 2:
            color = UIColor.yellow
        default:
            color = UIColor.red
        }
        return color
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, fillColorForPlotIndex plotIndex: Int) -> UIColor {
        let color: UIColor
        switch plotIndex {
        case 0:
            color = UIColor.blue.withAlphaComponent(0.6)
        case 1:
            color = UIColor.red.withAlphaComponent(0.6)
        case 2:
            color = UIColor.green.withAlphaComponent(0.6)
        default:
            color = UIColor.cyan.withAlphaComponent(0.6)
        }
        return color
    }
}

class DiscreteGraphChartDataSource: BaseFloatRangeGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKValueRange(),
                    ORKValueRange(minimumValue: 0, maximumValue: 2),
                    ORKValueRange(minimumValue: 1, maximumValue: 3),
                    ORKValueRange(minimumValue: 2, maximumValue: 6),
                    ORKValueRange(minimumValue: 3, maximumValue: 9),
                    ORKValueRange(minimumValue: 4, maximumValue: 13),
                ],
                [
                    ORKValueRange(value: 1),
                    ORKValueRange(minimumValue: 2, maximumValue: 4),
                    ORKValueRange(minimumValue: 3, maximumValue: 8),
                    ORKValueRange(minimumValue: 5, maximumValue: 11),
                    ORKValueRange(minimumValue: 7, maximumValue: 13),
                    ORKValueRange(minimumValue: 10, maximumValue: 13),
                    ORKValueRange(minimumValue: 12, maximumValue: 15),
                ],
                [
                    ORKValueRange(),
                    ORKValueRange(minimumValue: 5, maximumValue: 6),
                    ORKValueRange(),
                    ORKValueRange(minimumValue: 2, maximumValue: 15),
                    ORKValueRange(minimumValue: 4, maximumValue: 11),
                ],
        ]
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 8
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }

    func scrubbingPlotIndexForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}

class ColoredDiscreteGraphChartDataSource: DiscreteGraphChartDataSource {
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        let color: UIColor
        switch plotIndex {
        case 0:
            color = UIColor.cyan
        case 1:
            color = UIColor.magenta
        case 2:
            color = UIColor.yellow
        default:
            color = UIColor.red
        }
        return color
    }
}

class BarGraphChartDataSource: BaseFloatStackGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKValueStack(),
                    ORKValueStack(stackedValues: [0, 2, 5]),
                    ORKValueStack(stackedValues: [1, 3, 2]),
                    ORKValueStack(stackedValues: [2, 6, 1]),
                    ORKValueStack(stackedValues: [3, 9, 4]),
                    ORKValueStack(stackedValues: [4, 13, 2]),
                ],
                [
                    ORKValueStack(stackedValues: [1]),
                    ORKValueStack(stackedValues: [2, 4]),
                    ORKValueStack(stackedValues: [3, 8]),
                    ORKValueStack(stackedValues: [5, 11]),
                    ORKValueStack(stackedValues: [7, 13]),
                    ORKValueStack(stackedValues: [10, 13]),
                    ORKValueStack(stackedValues: [12, 15]),
                ],
                [
                    ORKValueStack(),
                    ORKValueStack(stackedValues: [5, 6]),
                    ORKValueStack(stackedValues: [2, 15]),
                    ORKValueStack(stackedValues: [4, 11]),
                    ORKValueStack(),
                    ORKValueStack(stackedValues: [6, 16]),
                ],
        ]
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 8
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }
    
    func scrubbingPlotIndexForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}

class ColoredBarGraphChartDataSource: BarGraphChartDataSource {
    
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        let color: UIColor
        switch plotIndex {
        case 0:
            color = UIColor.cyan
        case 1:
            color = UIColor.magenta
        case 2:
            color = UIColor.yellow
        default:
            color = UIColor.red
        }
        return color
    }
    
    override func scrubbingPlotIndexForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
}

class PerformanceLineGraphChartDataSource: BaseFloatRangeGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                ],
                [
                    ORKValueRange(value: 2),
                    ORKValueRange(value: 4),
                    ORKValueRange(value: 8),
                    ORKValueRange(value: 16),
                    ORKValueRange(value: 32),
                    ORKValueRange(value: 50),
                    ORKValueRange(value: 64),
                    ORKValueRange(value: 2),
                    ORKValueRange(value: 4),
                    ORKValueRange(value: 8),
                    ORKValueRange(value: 16),
                    ORKValueRange(value: 32),
                    ORKValueRange(value: 50),
                    ORKValueRange(value: 64),
                    ORKValueRange(value: 2),
                    ORKValueRange(value: 4),
                    ORKValueRange(value: 8),
                    ORKValueRange(value: 16),
                    ORKValueRange(value: 32),
                    ORKValueRange(value: 50),
                    ORKValueRange(value: 64),
                    ORKValueRange(value: 2),
                    ORKValueRange(value: 4),
                    ORKValueRange(value: 8),
                    ORKValueRange(value: 16),
                    ORKValueRange(value: 32),
                    ORKValueRange(value: 50),
                    ORKValueRange(value: 64),
                ],
                [
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(),
                    ORKValueRange(value: 20),
                    ORKValueRange(value: 25),
                    ORKValueRange(),
                    ORKValueRange(value: 30),
                    ORKValueRange(value: 40),
                    ORKValueRange(),
                ],
        ]
    }
    
    func maximumValueForGraphChartView(_ graphChartView: ORKGraphChartView) -> Double {
        return 70
    }
    
    func minimumValueForGraphChartView(_ graphChartView: ORKGraphChartView) -> Double {
        return 0
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 10
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return (pointIndex % 2 == 0) ? nil : "\(pointIndex + 1)"
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return (pointIndex % 2 == 1) ? false : true
    }
    
    func scrubbingPlotIndexForGraphChartView(_ graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}
