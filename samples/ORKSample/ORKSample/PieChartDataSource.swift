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

class PieChartDataSource: NSObject, ORKPieChartViewDataSource {
    // MARK: Types
    
    struct Segment {
        let title: String
        let value: Float
        let color: UIColor
    }
    
    // MARK: Properties
    
    let segments = [
        Segment(title: "Title 1", value: 10.0, color: UIColor(red: 217/225, green: 217/255, blue: 217/225, alpha: 1)),
        Segment(title: "Title 2", value: 25.0, color: UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 1)),
        Segment(title: "Title 3", value: 45.0, color: UIColor(red: 244/225, green: 190/255, blue: 74/225, alpha: 1))
    ]
    
    // MARK: ORKPieChartViewDataSource
    
    func numberOfSegments(in pieChartView: ORKPieChartView ) -> Int {
        return segments.count
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
        return CGFloat(segments[index].value)
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, colorForSegmentAt index: Int) -> UIColor {
        return segments[index].color
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, titleForSegmentAt index: Int) -> String {
        return segments[index].title
    }
}
