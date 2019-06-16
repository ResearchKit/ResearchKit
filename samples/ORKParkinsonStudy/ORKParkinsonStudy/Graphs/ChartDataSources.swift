/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
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


import Foundation
import ResearchKit

class BarGraphDataSource: NSObject, ORKValueStackGraphChartViewDataSource {
    
    var plotPoints: [[ORKValueStack]]!
    var datePoints = [String]()

    
    override init() {
        super.init()
        generatePlotPoints()
    }
    
    func generatePlotPoints() {
        
        var tremorPoints = [ORKValueStack]()
        var dyskinesiaPoints = [ORKValueStack]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        
        if let tremorPath = Bundle.main.path(forResource: "tremor", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: tremorPath), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let tremorData = jsonResult as? [Dictionary<String, AnyObject>] {
                    
                    let tremorPerHour = stride(from: 0, to: tremorData.count, by: 60).map {
                        Array(tremorData[$0..<min($0 + 60, tremorData.count)])
                    }

                    for hour in tremorPerHour {
                        var percentSlight = 0.0
                        var percentMild = 0.0
                        var percentModerate = 0.0
                        var percentStrong = 0.0
                        
                        let timeInterval = hour.first!["startDate"] as! String
                        let date: Date = Date(timeIntervalSince1970: Double(timeInterval)!)
                        datePoints.append(dateFormatter.string(from: date))
                        
                        for minute in hour {
                            percentSlight += (minute["percentSlight"] as! Double) * 100
                            percentMild += (minute["percentMild"] as! Double) * 100
                            percentModerate += (minute["percentModerate"] as! Double) * 100
                            percentStrong += (minute["percentStrong"] as! Double) * 100
                        }
    
                        tremorPoints.append(ORKValueStack(stackedValues: [NSNumber(value: percentSlight / 60.0), NSNumber(value: percentMild / 60.0), NSNumber(value: percentModerate / 60.0), NSNumber(value: percentStrong / 60.0)]))
                    }
                }
            } catch {
                // handle error
            }
        }
        if let dyskinesiaPath = Bundle.main.path(forResource: "dyskinesia", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: dyskinesiaPath), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                if let dyskinesiaData = jsonResult as? [Dictionary<String, AnyObject>] {
                    
                    let dyskinesiaPerHour = stride(from: 0, to: dyskinesiaData.count, by: 60).map {
                        Array(dyskinesiaData[$0..<min($0 + 60, dyskinesiaData.count)])
                    }
                    
                    for hour in dyskinesiaPerHour {
                        var percentLikely = 0.0
                        for minute in hour {
                            percentLikely += (minute["percentLikely"] as! Double) * 100
                        }
                        dyskinesiaPoints.append(ORKValueStack(stackedValues: [NSNumber(value: percentLikely / 60.0)]))
                    }
                }
            } catch {
                // handle error
            }
        }
        
        plotPoints = [tremorPoints, dyskinesiaPoints]
    }
    
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
        return datePoints[pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, colorForPlotIndex plotIndex: Int) -> UIColor {
        return plotIndex == 0 ? Colors.tremorGraphColor.color : Colors.dyskinesiaSymptomGraphColor.color
    }
}
