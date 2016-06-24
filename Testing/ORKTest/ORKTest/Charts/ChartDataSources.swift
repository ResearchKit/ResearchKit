/*
Copyright (c) 2015, James Cox. All rights reserved.
Copyright (c) 2015, Ricardo Sánchez-Sáez.

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

func randomColorArray(number: Int) -> [UIColor] {
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        }
        
        var colors: [UIColor] = []
        for _ in 0 ..< number {
            colors.append(UIColor(red: random(), green: random(), blue: random(), alpha: 1))
        }
        return colors
    }

let NumberOfPieChartSegments = 8

class ColorlessPieChartDataSource: NSObject, ORKPieChartViewDataSource {
    
    func numberOfSegmentsInPieChartView(pieChartView: ORKPieChartView ) -> Int {
        return NumberOfPieChartSegments
    }
    
    func pieChartView(pieChartView: ORKPieChartView, valueForSegmentAtIndex index: Int) -> CGFloat {
        return CGFloat(index + 1)
    }
    
    func pieChartView(pieChartView: ORKPieChartView, titleForSegmentAtIndex index: Int) -> String {
        return "Title \(index + 1)"
    }
}

class RandomColorPieChartDataSource: ColorlessPieChartDataSource {
    
    lazy var backingStore: [UIColor] = {
        return randomColorArray(NumberOfPieChartSegments)
        }()

    func pieChartView(pieChartView: ORKPieChartView, colorForSegmentAtIndex index: Int) -> UIColor {
        return backingStore[index]
    }
}

class BaseGraphChartDataSource:  NSObject, ORKGraphChartViewDataSource {
    var plotPoints: [[ORKRangedPoint]] = [[]]
    
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
}

class LineGraphChartDataSource: BaseGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                ],
                [
                    ORKRangedPoint(value: 2),
                    ORKRangedPoint(value: 4),
                    ORKRangedPoint(value: 8),
                    ORKRangedPoint(value: 16),
                    ORKRangedPoint(value: 32),
                    ORKRangedPoint(value: 50),
                    ORKRangedPoint(value: 64),
                ],
                [
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                ],
        ]
    }
    
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 70
    }
    
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 10
    }

    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return (pointIndex % 2 == 0) ? nil : "\(pointIndex + 1)"
    }

    func graphChartView(graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return (pointIndex % 2 == 1) ? false : true
    }

    func scrubbingPlotIndexForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}

class ColoredLineGraphChartDataSource: LineGraphChartDataSource {
    func graphChartView(graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        let color: UIColor
        switch plotIndex {
        case 0:
            color = UIColor.cyanColor()
        case 1:
            color = UIColor.magentaColor()
        case 2:
            color = UIColor.yellowColor()
        default:
            color = UIColor.redColor()
        }
        return color
    }
}

class DiscreteGraphChartDataSource: BaseGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKRangedPoint(),
                    ORKRangedPoint(minimumValue: 0, maximumValue: 2),
                    ORKRangedPoint(minimumValue: 1, maximumValue: 3),
                    ORKRangedPoint(minimumValue: 2, maximumValue: 6),
                    ORKRangedPoint(minimumValue: 3, maximumValue: 9),
                    ORKRangedPoint(minimumValue: 4, maximumValue: 13),
                ],
                [
                    ORKRangedPoint(value: 1),
                    ORKRangedPoint(minimumValue: 2, maximumValue: 4),
                    ORKRangedPoint(minimumValue: 3, maximumValue: 8),
                    ORKRangedPoint(minimumValue: 5, maximumValue: 11),
                    ORKRangedPoint(minimumValue: 7, maximumValue: 13),
                    ORKRangedPoint(minimumValue: 10, maximumValue: 13),
                    ORKRangedPoint(minimumValue: 12, maximumValue: 15),
                ],
        ]
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 8
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String {
        return "\(pointIndex + 1)"
    }

    func scrubbingPlotIndexForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
}

class PerformanceLineGraphChartDataSource: BaseGraphChartDataSource {
    
    override init() {
        super.init()
        plotPoints =
            [
                [
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                ],
                [
                    ORKRangedPoint(value: 2),
                    ORKRangedPoint(value: 4),
                    ORKRangedPoint(value: 8),
                    ORKRangedPoint(value: 16),
                    ORKRangedPoint(value: 32),
                    ORKRangedPoint(value: 50),
                    ORKRangedPoint(value: 64),
                    ORKRangedPoint(value: 2),
                    ORKRangedPoint(value: 4),
                    ORKRangedPoint(value: 8),
                    ORKRangedPoint(value: 16),
                    ORKRangedPoint(value: 32),
                    ORKRangedPoint(value: 50),
                    ORKRangedPoint(value: 64),
                    ORKRangedPoint(value: 2),
                    ORKRangedPoint(value: 4),
                    ORKRangedPoint(value: 8),
                    ORKRangedPoint(value: 16),
                    ORKRangedPoint(value: 32),
                    ORKRangedPoint(value: 50),
                    ORKRangedPoint(value: 64),
                    ORKRangedPoint(value: 2),
                    ORKRangedPoint(value: 4),
                    ORKRangedPoint(value: 8),
                    ORKRangedPoint(value: 16),
                    ORKRangedPoint(value: 32),
                    ORKRangedPoint(value: 50),
                    ORKRangedPoint(value: 64),
                ],
                [
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 20),
                    ORKRangedPoint(value: 25),
                    ORKRangedPoint(),
                    ORKRangedPoint(value: 30),
                    ORKRangedPoint(value: 40),
                    ORKRangedPoint(),
                ],
        ]
    }
    
    func maximumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 70
    }
    
    func minimumValueForGraphChartView(graphChartView: ORKGraphChartView) -> CGFloat {
        return 0
    }
    
    func numberOfDivisionsInXAxisForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 10
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return (pointIndex % 2 == 0) ? nil : "\(pointIndex + 1)"
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, drawsVerticalReferenceLineAtPointIndex pointIndex: Int) -> Bool {
        return (pointIndex % 2 == 1) ? false : true
    }
    
    func scrubbingPlotIndexForGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return 2
    }
}
