/*
Copyright (c) 2015, Apple Inc. All rights reserved.

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

class DiscreteGraphDataSource: NSObject, ORKGraphChartViewDataSource {
    // MARK: Properties
    
    var plotPoints =
    [
        [
            ORKRangedPoint(minimumValue: 0, maximumValue: 2),
            ORKRangedPoint(minimumValue: 1, maximumValue: 4),
            ORKRangedPoint(minimumValue: 2, maximumValue: 6),
            ORKRangedPoint(minimumValue: 3, maximumValue: 8),
            ORKRangedPoint(minimumValue: 5, maximumValue: 10),
            ORKRangedPoint(minimumValue: 8, maximumValue: 13),
        ],
        [
            ORKRangedPoint(value: 1),
            ORKRangedPoint(minimumValue: 2, maximumValue: 6),
            ORKRangedPoint(minimumValue: 3, maximumValue: 10),
            ORKRangedPoint(minimumValue: 5, maximumValue: 11),
            ORKRangedPoint(minimumValue: 7, maximumValue: 13),
            ORKRangedPoint(minimumValue: 10, maximumValue: 13),
        ]
    ]
    
    // MARK: ORKGraphChartViewDataSource
    
    func numberOfPlotsInGraphChartView(graphChartView: ORKGraphChartView) -> Int {
        return plotPoints.count
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, pointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKRangedPoint {
        return plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, numberOfPointsForPlotIndex plotIndex: Int) -> Int {
        return plotPoints[plotIndex].count
    }
    
    func graphChartView(graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return "\(pointIndex + 1)"
    }
}
