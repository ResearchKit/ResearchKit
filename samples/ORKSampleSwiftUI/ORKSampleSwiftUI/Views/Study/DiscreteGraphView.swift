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

class DiscreteGraphDataSource: NSObject, ORKValueRangeGraphChartViewDataSource {
    var plotPoints = [
        [
            ORKValueRange(minimumValue: 0, maximumValue: 2),
            ORKValueRange(minimumValue: 1, maximumValue: 4),
            ORKValueRange(minimumValue: 2, maximumValue: 6),
            ORKValueRange(minimumValue: 3, maximumValue: 8),
            ORKValueRange(minimumValue: 5, maximumValue: 10),
            ORKValueRange(minimumValue: 8, maximumValue: 13)
        ],
        [
            ORKValueRange(value: 1),
            ORKValueRange(minimumValue: 2, maximumValue: 6),
            ORKValueRange(minimumValue: 3, maximumValue: 10),
            ORKValueRange(minimumValue: 5, maximumValue: 11),
            ORKValueRange(minimumValue: 7, maximumValue: 13),
            ORKValueRange(minimumValue: 10, maximumValue: 13)
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
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        "\(pointIndex + 1)"
    }
}

struct DiscreteGraphView: UIViewRepresentable {
    var dataSource: DiscreteGraphDataSource
    var animate: Bool = false
    
    func makeUIView(context: Context) -> ORKDiscreteGraphChartView {
        ORKDiscreteGraphChartView()
    }
    
    func updateUIView(_ uiView: ORKDiscreteGraphChartView, context: Context) {
        uiView.dataSource = dataSource
        if animate {
            uiView.animate(withDuration: 1.0)
        }
    }
}

struct DiscreteGraphView_Previews: PreviewProvider {
    static var exampleDataSource = DiscreteGraphDataSource()
    
    static var previews: some View {
        DiscreteGraphView(dataSource: exampleDataSource, animate: false)
    }
}
