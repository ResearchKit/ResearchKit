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

class ChartListViewController: UITableViewController {
    
    let discreteGraphDataSource: DiscreteGraphDataSource = DiscreteGraphDataSource()
    let lineGraphDataSource: LineGraphDataSource = LineGraphDataSource()
    let pieChartDataSource: PieChartDataSource = PieChartDataSource()
    let discreteGraphIdentifier = "DiscreteGraphCell"
    let lineGraphIdentifier = "LineGraphCell"
    let pieChartIdentifier = "PieChartCell"
    
    var lineGraphTableViewCell: UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(lineGraphIdentifier) as! LineGraphTableViewCell
        (cell.graphView as! ORKLineGraphView).dataSource = lineGraphDataSource
        return cell
    }
    
    var discreteGraphTableViewCell: UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(discreteGraphIdentifier) as! DiscreteGraphTableViewCell
        (cell.graphView as! ORKDiscreteGraphView).dataSource = discreteGraphDataSource
        return cell
    }
    
     var pieChartTableViewCell: UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(pieChartIdentifier) as! PieChartTableViewCell
        cell.pieChartView.datasource = pieChartDataSource
        return cell
    }
    
    var chartTableViewCells: [UITableViewCell] {
        return [lineGraphTableViewCell, discreteGraphTableViewCell, pieChartTableViewCell]
    }
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return chartTableViewCells[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let graph = (cell as? GraphTableViewCell)?.graphView {
            configureGraphView(graph)
        }
        else if let pieChartView = (cell as? PieChartTableViewCell)?.pieChartView {
            configurePieChartView(pieChartView)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
}

extension ChartListViewController {
    
    func configureGraphView(graphView: ORKGraphView) {
        graphView.showsVerticalReferenceLines = true
        /* set more ORKGraphView properties as desired */
        graphView.setNeedsLayout()
        graphView.layoutIfNeeded()
        graphView.refreshGraph()
    }
    
    func configurePieChartView(pieChartView: ORKPieChartView) {
        let font = UIFont(name: "HelveticaNeue", size: 11)
        pieChartView.legendFont = font
        pieChartView.percentageFont = font
        pieChartView.centreTitleLabel.text = "TITLE"
        pieChartView.centreSubtitleLabel.text = "SUBTITLE"
        /* set more ORKPieChartView properties as desired */
    }
}
