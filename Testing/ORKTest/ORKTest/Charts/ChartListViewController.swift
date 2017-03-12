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

func executeAfterDelay(_ delay:Double, closure:@escaping ()->()) {
    let delayTime = DispatchTime.now() + delay
    let dispatchWorkItem = DispatchWorkItem(block: closure);
    DispatchQueue.main.asyncAfter(
        deadline: delayTime, execute: dispatchWorkItem)
}

class ChartListViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let colorlessPieChartDataSource = ColorlessPieChartDataSource()
    let randomColorPieChartDataSource = RandomColorPieChartDataSource()
    
    let lineGraphChartDataSource = LineGraphChartDataSource()
    let coloredLineGraphChartDataSource = ColoredLineGraphChartDataSource()
    
    let discreteGraphChartDataSource = DiscreteGraphChartDataSource()
    let coloredDiscreteGraphChartDataSource = ColoredDiscreteGraphChartDataSource()

    let barGraphChartDataSource = BarGraphChartDataSource()
    let coloredBarGraphChartDataSource = ColoredBarGraphChartDataSource()
    
    let pieChartIdentifier = "PieChartCell"
    let lineGraphChartIdentifier = "LineGraphChartCell"
    let discreteGraphChartIdentifier = "DiscreteGraphChartCell"
    let barGraphChartIdentifier = "BarGraphChartCell"
    
    var pieChartTableViewCell: PieChartTableViewCell!
    var lineGraphChartTableViewCell: LineGraphChartTableViewCell!
    var discreteGraphChartTableViewCell: DiscreteGraphChartTableViewCell!
    var barGraphChartTableViewCell: BarGraphChartTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    @IBAction func dimiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self;
        
        // ORKPieChartView
        pieChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: pieChartIdentifier) as! PieChartTableViewCell
        let pieChartView = pieChartTableViewCell.pieChartView
        pieChartView?.dataSource = randomColorPieChartDataSource
        // Optional custom configuration

        pieChartView?.title = "TITLE"
        pieChartView?.text = "TEXT"
        pieChartView?.lineWidth = 1000
        pieChartView?.showsTitleAboveChart = true
        pieChartView?.showsPercentageLabels = false
        pieChartView?.drawsClockwise = false
        executeAfterDelay(2.5) {
            pieChartView?.showsTitleAboveChart = false
            pieChartView?.lineWidth = 12
            pieChartView?.title = "UPDATED"
            pieChartView?.text = "UPDATED TEXT"
            pieChartView?.titleColor = UIColor.red
            pieChartView?.textColor = UIColor.orange
        }
        executeAfterDelay(3.5) {
            pieChartView?.drawsClockwise = true
            pieChartView?.dataSource = self.colorlessPieChartDataSource
        }
        executeAfterDelay(4.5) {
            pieChartView?.showsPercentageLabels = true
            pieChartView?.tintColor = UIColor.purple
        }
        executeAfterDelay(5.5) {
            pieChartView?.titleColor = nil
            pieChartView?.textColor = nil
        }

        // ORKBarGraphChartView
        barGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: barGraphChartIdentifier) as! BarGraphChartTableViewCell
        let barGraphChartView = barGraphChartTableViewCell.graphChartView as! ORKBarGraphChartView
        barGraphChartView.dataSource = barGraphChartDataSource
        executeAfterDelay(1.5) {
            barGraphChartView.tintColor = UIColor.purple
            barGraphChartView.showsHorizontalReferenceLines = true
            barGraphChartView.showsVerticalReferenceLines = true
        }
        executeAfterDelay(2.5) {
            barGraphChartView.axisColor = UIColor.red
            barGraphChartView.verticalAxisTitleColor = UIColor.red
            barGraphChartView.referenceLineColor = UIColor.orange
            barGraphChartView.scrubberLineColor = UIColor.blue
            barGraphChartView.scrubberThumbColor = UIColor.green
        }
        executeAfterDelay(3.5) {
            barGraphChartView.axisColor = nil
            barGraphChartView.verticalAxisTitleColor = nil
            barGraphChartView.referenceLineColor = nil
            barGraphChartView.scrubberLineColor = nil
            barGraphChartView.scrubberThumbColor = nil
        }
        executeAfterDelay(4.5) {
            barGraphChartView.dataSource = self.coloredBarGraphChartDataSource
        }
        executeAfterDelay(5.5) {
            let maximumValueImage = UIImage(named: "GraphMaximumValueTest")!
            let minimumValueImage = UIImage(named: "GraphMinimumValueTest")!
            barGraphChartView.maximumValueImage = maximumValueImage
            barGraphChartView.minimumValueImage = minimumValueImage
        }

        // ORKLineGraphChartView
        lineGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        let lineGraphChartView = lineGraphChartTableViewCell.graphChartView as! ORKLineGraphChartView
        lineGraphChartView.dataSource = lineGraphChartDataSource
        // Optional custom configuration
        executeAfterDelay(1.5) {
            lineGraphChartView.tintColor = UIColor.purple
            lineGraphChartView.showsHorizontalReferenceLines = true
            lineGraphChartView.showsVerticalReferenceLines = true
        }
        executeAfterDelay(2.5) {
            lineGraphChartView.axisColor = UIColor.red
            lineGraphChartView.verticalAxisTitleColor = UIColor.red
            lineGraphChartView.referenceLineColor = UIColor.orange
            lineGraphChartView.scrubberLineColor = UIColor.blue
            lineGraphChartView.scrubberThumbColor = UIColor.green
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
        discreteGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: discreteGraphChartIdentifier) as! DiscreteGraphChartTableViewCell
        let discreteGraphChartView = discreteGraphChartTableViewCell.graphChartView as! ORKDiscreteGraphChartView
        discreteGraphChartView.dataSource = discreteGraphChartDataSource
        // Optional custom configuration
        discreteGraphChartView.showsHorizontalReferenceLines = true
        discreteGraphChartView.showsVerticalReferenceLines = true
        discreteGraphChartView.drawsConnectedRanges = true
        executeAfterDelay(2.5) {
            discreteGraphChartView.tintColor = UIColor.purple
        }
        executeAfterDelay(3.5) {
            discreteGraphChartView.drawsConnectedRanges = false
        }
        executeAfterDelay(4.5) {
            discreteGraphChartView.dataSource = self.coloredDiscreteGraphChartDataSource
        }
        executeAfterDelay(5.5) {
            discreteGraphChartView.drawsConnectedRanges = true
        }
        
        chartTableViewCells = [pieChartTableViewCell, barGraphChartTableViewCell, lineGraphChartTableViewCell, discreteGraphChartTableViewCell]
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chartTableViewCells[(indexPath as NSIndexPath).row];
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        pieChartTableViewCell.pieChartView.animate(withDuration: 0.5)
        lineGraphChartTableViewCell.graphChartView.animate(withDuration: 0.5)
        discreteGraphChartTableViewCell.graphChartView.animate(withDuration: 0.5)
        discreteGraphChartTableViewCell.graphChartView.animate(withDuration: 2.5)
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
    
    @IBAction func dimiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.tableView.dataSource = self;
        
        // ORKLineGraphChartView
        lineGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        let lineGraphChartView = lineGraphChartTableViewCell.graphChartView as! ORKLineGraphChartView
        lineGraphChartView.dataSource = graphChartDataSource
        // Optional custom configuration
        lineGraphChartView.showsHorizontalReferenceLines = true
        lineGraphChartView.showsVerticalReferenceLines = true

        // ORKDiscreteGraphChartView
        discreteGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: discreteGraphChartIdentifier) as! DiscreteGraphChartTableViewCell
        let discreteGraphChartView = discreteGraphChartTableViewCell.graphChartView as! ORKDiscreteGraphChartView
        discreteGraphChartView.dataSource = graphChartDataSource
        // Optional custom configuration
        discreteGraphChartView.showsHorizontalReferenceLines = true
        discreteGraphChartView.showsVerticalReferenceLines = true
        discreteGraphChartView.drawsConnectedRanges = true

        chartTableViewCells = [lineGraphChartTableViewCell, discreteGraphChartTableViewCell]

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chartTableViewCells[(indexPath as NSIndexPath).row];
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lineGraphChartTableViewCell.graphChartView.animate(withDuration: 0.5)
    }    
}
