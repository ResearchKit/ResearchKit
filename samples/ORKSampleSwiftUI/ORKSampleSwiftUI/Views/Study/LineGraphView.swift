/*
Copyright (c) 2020, Helio Tejedor. All rights reserved.

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
import SwiftUI

class LineGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
    var plotPoints = [
        [
            ORKValueRange(value: 10),
            ORKValueRange(value: 20),
            ORKValueRange(value: 25),
            ORKValueRange(),
            ORKValueRange(value: 30),
            ORKValueRange(value: 40)
        ],
        [
            ORKValueRange(value: 2),
            ORKValueRange(value: 4),
            ORKValueRange(value: 8),
            ORKValueRange(value: 16),
            ORKValueRange(value: 32),
            ORKValueRange(value: 64)
        ]
    ]

    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        plotPoints.count
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        plotPoints[plotIndex][pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        plotPoints[plotIndex].count
    }
    
    func maximumValue(for graphChartView: ORKGraphChartView) -> Double {
        70
    }
    
    func minimumValue(for graphChartView: ORKGraphChartView) -> Double {
        0
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        "\(pointIndex + 1)"
    }
}

struct LineGraphView: UIViewRepresentable {
    var dataSource: ORKValueRangeGraphChartViewDataSource
    var animate: Bool = false
    
    func makeUIView(context: Context) -> ORKLineGraphChartView {
        ORKLineGraphChartView()
    }
    
    func updateUIView(_ uiView: ORKLineGraphChartView, context: Context) {
        uiView.dataSource = dataSource
        if animate {
            uiView.animate(withDuration: 1.0)
        }
    }
}

struct LineGraphView_Previews: PreviewProvider {
    static var exampleDataSource = LineGraphDataSource()
    
    static var previews: some View {
        LineGraphView(dataSource: exampleDataSource, animate: false)
    }
}

