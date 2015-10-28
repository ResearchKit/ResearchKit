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
    
    let colorlessPieChartDataSource = ColorlessPieChartDataSource()
    let randomColorPieChartDataSource = RandomColorPieChartDataSource()
    
    let lineGraphChartDataSource = LineGraphChartDataSource()
    let coloredLineGraphChartDataSource = ColoredLineGraphChartDataSource()
    
    let discreteGraphChartDataSource = DiscreteGraphChartDataSource()

    let pieChartIdentifier = "PieChartCell"
    let lineGraphChartIdentifier = "LineGraphChartCell"
    let discreteGraphChartIdentifier = "DiscreteGraphChartCell"
    
    var pieChartTableViewCell: PieChartTableViewCell!
    var lineGraphChartTableViewCell: LineGraphChartTableViewCell!
    var discreteGraphChartTableViewCell: DiscreteGraphChartTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    @IBAction func dimiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self;
        
        // ORKPieChartView
        pieChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(pieChartIdentifier) as! PieChartTableViewCell
        let pieChartView = pieChartTableViewCell.pieChartView
        pieChartView.dataSource = randomColorPieChartDataSource
        // Optional custom configuration
        pieChartView.title = "TITLE"
        pieChartView.text = "TEXT"
        pieChartView.lineWidth = 1000
        pieChartView.showsTitleAboveChart = true
        pieChartView.showsPercentageLabels = false
        pieChartView.drawsClockwise = false
        executeAfterDelay(1.5) {
            pieChartView.showsTitleAboveChart = false
            pieChartView.lineWidth = 12
            pieChartView.title = "UPDATED"
            pieChartView.text = "UPDATED TEXT"
            pieChartView.titleColor = UIColor.redColor()
            pieChartView.textColor = UIColor.orangeColor()
        }
        executeAfterDelay(2.5) {
            pieChartView.drawsClockwise = true
            pieChartView.dataSource = self.colorlessPieChartDataSource
        }
        executeAfterDelay(3.5) {
            pieChartView.showsPercentageLabels = true
            pieChartView.tintColor = UIColor.purpleColor()
        }
        executeAfterDelay(4.5) {
            pieChartView.titleColor = nil
            pieChartView.textColor = nil
        }

        // ORKLineGraphChartView
        lineGraphChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        let lineGraphChartView = lineGraphChartTableViewCell.graphChartView as! ORKLineGraphChartView
        lineGraphChartView.dataSource = lineGraphChartDataSource
        // Optional custom configuration
        executeAfterDelay(1.5) {
            lineGraphChartView.tintColor = UIColor.purpleColor()
            lineGraphChartView.showsHorizontalReferenceLines = true
            lineGraphChartView.showsVerticalReferenceLines = true
        }
        executeAfterDelay(2.5) {
            lineGraphChartView.axisColor = UIColor.redColor()
            lineGraphChartView.verticalAxisTitleColor = UIColor.redColor()
            lineGraphChartView.referenceLineColor = UIColor.orangeColor()
            lineGraphChartView.scrubberLineColor = UIColor.blueColor()
            lineGraphChartView.scrubberThumbColor = UIColor.greenColor()
        }
        executeAfterDelay(3.5) {
            lineGraphChartView.axisColor = nil
            lineGraphChartView.verticalAxisTitleColor = nil
            lineGraphChartView.referenceLineColor = nil
            lineGraphChartView.scrubberLineColor = nil
            lineGraphChartView.scrubberThumbColor = nil
        }
        executeAfterDelay(4.5) {
            lineGraphChartView.dataSource = self.coloredLineGraphChartDataSource
        }
        executeAfterDelay(5.5) {
            let maximumValueImage = UIImage(named: "GraphMaximumValueTest")!
            let minimumValueImage = UIImage(named: "GraphMinimumValueTest")!
            lineGraphChartView.maximumValueImage = maximumValueImage
            lineGraphChartView.minimumValueImage = minimumValueImage
        }
        
        // ORKDiscreteGraphChartView
        discreteGraphChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(discreteGraphChartIdentifier) as! DiscreteGraphChartTableViewCell
        let discreteGraphChartView = discreteGraphChartTableViewCell.graphChartView as! ORKDiscreteGraphChartView
        discreteGraphChartView.dataSource = discreteGraphChartDataSource
        // Optional custom configuration
        discreteGraphChartView.showsHorizontalReferenceLines = true
        discreteGraphChartView.showsVerticalReferenceLines = true
        discreteGraphChartView.drawsConnectedRanges = true
        executeAfterDelay(3.5) {
            discreteGraphChartView.drawsConnectedRanges = false
        }
        executeAfterDelay(5.5) {
            discreteGraphChartView.drawsConnectedRanges = true
        }

        chartTableViewCells = [pieChartTableViewCell, lineGraphChartTableViewCell, discreteGraphChartTableViewCell]
        
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
        lineGraphChartTableViewCell.graphChartView.animateWithDuration(0.5)
        discreteGraphChartTableViewCell.graphChartView.animateWithDuration(0.5)
    }    
}

class ChartPerformanceListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let lineGraphChartIdentifier = "LineGraphChartCell"
    let discreteGraphChartIdentifier = "DiscreteGraphChartCell"
    let graphChartDataSource = PerformanceLineGraphChartDataSource()
    var lineGraphChartTableViewCell: LineGraphChartTableViewCell!
    let discreteGraphChartDataSource = DiscreteGraphChartDataSource()
    var discreteGraphChartTableViewCell: DiscreteGraphChartTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    @IBAction func dimiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self;
        
        // ORKLineGraphChartView
        lineGraphChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        let lineGraphChartView = lineGraphChartTableViewCell.graphChartView as! ORKLineGraphChartView
        lineGraphChartView.dataSource = graphChartDataSource
        // Optional custom configuration
        lineGraphChartView.showsHorizontalReferenceLines = true
        lineGraphChartView.showsVerticalReferenceLines = true

        // ORKDiscreteGraphChartView
        discreteGraphChartTableViewCell = tableView.dequeueReusableCellWithIdentifier(discreteGraphChartIdentifier) as! DiscreteGraphChartTableViewCell
        let discreteGraphChartView = discreteGraphChartTableViewCell.graphChartView as! ORKDiscreteGraphChartView
        discreteGraphChartView.dataSource = graphChartDataSource
        // Optional custom configuration
        discreteGraphChartView.showsHorizontalReferenceLines = true
        discreteGraphChartView.showsVerticalReferenceLines = true
        discreteGraphChartView.drawsConnectedRanges = true

        chartTableViewCells = [lineGraphChartTableViewCell, discreteGraphChartTableViewCell]

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
        lineGraphChartTableViewCell.graphChartView.animateWithDuration(0.5)
    }    
}
