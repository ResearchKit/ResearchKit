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

import UIKit
import ResearchKit

func executeAfterDelay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class ChartListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let discreteGraphDataSource = DiscreteGraphDataSource()
    let lineGraphDataSource = LineGraphDataSource()
    let pieChartDataSource = PieChartDataSource()
    let discreteGraphIdentifier = "DiscreteGraphCell"
    let lineGraphIdentifier = "LineGraphCell"
    let pieChartIdentifier = "PieChartCell"
    
    var pieChartTableViewCell: PieChartTableViewCell!
    var lineGraphTableViewCell: LineGraphTableViewCell!
    var discreteGraphTableViewCell: DiscreteGraphTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    @IBAction func dimiss(sender: AnyObject) {        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self;
        
        // ORKPieChartView
        pieChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(pieChartIdentifier) as! PieChartTableViewCell
        let pieChartView = pieChartTableViewCell.pieChartView
        pieChartView.dataSource = pieChartDataSource
        // Optional custom configuration
        pieChartView.title = "TITLE"
        pieChartView.text = "TEXT"
        pieChartView.lineWidth = 1000
        pieChartView.showsTitleAboveChart = true
        executeAfterDelay(1.5) {
            pieChartView.showsTitleAboveChart = false
            pieChartView.lineWidth = 12
            pieChartView.title = "UPDATED"
            pieChartView.text = "UPDATED TEXT"
            pieChartView.titleColor = UIColor.redColor()
            pieChartView.textColor = UIColor.orangeColor()
        }
        executeAfterDelay(2.5) {
            pieChartView.drawsClockwise = false
        }
        executeAfterDelay(3.5) {
            pieChartView.showsPercentageLabels = false
        }
        
        // ORKLineGraphView
        lineGraphTableViewCell = tableView.dequeueReusableCellWithIdentifier(lineGraphIdentifier) as! LineGraphTableViewCell
        let lineGraphView = lineGraphTableViewCell.graphView as! ORKLineGraphView
        lineGraphView.dataSource = lineGraphDataSource
        // Optional custom configuration
        executeAfterDelay(1.5) {
            lineGraphView.showsHorizontalReferenceLines = true
            lineGraphView.showsVerticalReferenceLines = true
        }
        executeAfterDelay(2.5) {
            lineGraphView.axisColor = UIColor.redColor()
            lineGraphView.axisTitleColor = UIColor.redColor()
            lineGraphView.referenceLineColor = UIColor.orangeColor()
            lineGraphView.scrubberLineColor = UIColor.blueColor()
            lineGraphView.scrubberThumbColor = UIColor.greenColor()
        }
        executeAfterDelay(3.5) {
            let maximumValueImage = UIImage(named: "GraphMaximumValueTest")!
            let minimumValueImage = UIImage(named: "GraphMinimumValueTest")!
            lineGraphView.maximumValueImage = maximumValueImage
            lineGraphView.minimumValueImage = minimumValueImage
        }
        
        // ORKDiscreteGraphView
        discreteGraphTableViewCell = tableView.dequeueReusableCellWithIdentifier(discreteGraphIdentifier) as! DiscreteGraphTableViewCell
        let discreteGraphView = discreteGraphTableViewCell.graphView as! ORKDiscreteGraphView
        discreteGraphView.dataSource = discreteGraphDataSource
        // Optional custom configuration
        discreteGraphView.showsVerticalReferenceLines = true
        discreteGraphView.drawsConnectedRanges = false
        executeAfterDelay(3.5) {
            discreteGraphView.drawsConnectedRanges = true
        }

        chartTableViewCells = [pieChartTableViewCell, lineGraphTableViewCell, discreteGraphTableViewCell]
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = chartTableViewCells[indexPath.row];
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        pieChartTableViewCell.pieChartView.animateWithDuration(0.5)
        lineGraphTableViewCell.graphView.animateWithDuration(0.5)
        discreteGraphTableViewCell.graphView.animateWithDuration(0.5)
    }    
}
