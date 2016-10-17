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
    
    let pieChartDataSource = PieChartDataSource()
    let lineGraphChartDataSource = LineGraphDataSource()
    let discreteGraphChartDataSource = DiscreteGraphDataSource()
    let barGraphChartDataSource = BarGraphDataSource()

    let pieChartIdentifier = "PieChartCell"
    let lineGraphChartIdentifier = "LineGraphChartCell"
    let discreteGraphChartIdentifier = "DiscreteGraphChartCell"
    let barGraphChartIdentifier = "BarGraphChartCell"
    
    var pieChartTableViewCell: PieChartTableViewCell!
    var lineGraphChartTableViewCell: LineGraphChartTableViewCell!
    var discreteGraphChartTableViewCell: DiscreteGraphChartTableViewCell!
    var barGraphChartTableViewCell: BarGraphChartTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    override func viewDidLoad() {
        // ORKPieChartView
        pieChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: pieChartIdentifier) as! PieChartTableViewCell
        let pieChartView = pieChartTableViewCell.pieChartView
        pieChartView?.dataSource = pieChartDataSource
        // Optional custom configuration

        pieChartView?.title = "TITLE"
        pieChartView?.text = "TEXT"
        pieChartView?.lineWidth = 14
        pieChartView?.radiusScaleFactor = 0.6
        
        // ORKLineGraphChartView
        lineGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: lineGraphChartIdentifier) as! LineGraphChartTableViewCell
        let lineGraphChartView = lineGraphChartTableViewCell.graphView as! ORKLineGraphChartView
        lineGraphChartView.dataSource = lineGraphChartDataSource
        lineGraphChartView.tintColor = UIColor(red: 244/255, green: 190/255, blue: 74/255, alpha: 1)
        // Optional custom configuration
        lineGraphChartView.showsHorizontalReferenceLines = true
        lineGraphChartView.showsVerticalReferenceLines = true
        
        // ORKDiscreteGraphChartView
        discreteGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: discreteGraphChartIdentifier) as! DiscreteGraphChartTableViewCell
        let discreteGraphChartView = discreteGraphChartTableViewCell.graphView as! ORKDiscreteGraphChartView
        discreteGraphChartView.dataSource = discreteGraphChartDataSource
        discreteGraphChartView.tintColor = UIColor(red: 244/255, green: 190/255, blue: 74/255, alpha: 1)
        // Optional custom configuration
        discreteGraphChartView.showsHorizontalReferenceLines = true
        discreteGraphChartView.showsVerticalReferenceLines = true

        // ORKBarGraphChartView
        barGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: barGraphChartIdentifier) as! BarGraphChartTableViewCell
        let barGraphChartView = barGraphChartTableViewCell.graphView as! ORKBarGraphChartView
        barGraphChartView.dataSource = barGraphChartDataSource
        barGraphChartView.tintColor = UIColor(red: 244/255, green: 190/255, blue: 74/255, alpha: 1)
        // Optional custom configuration
        barGraphChartView.showsHorizontalReferenceLines = true
        barGraphChartView.showsVerticalReferenceLines = true

        chartTableViewCells = [pieChartTableViewCell, lineGraphChartTableViewCell, discreteGraphChartTableViewCell, barGraphChartTableViewCell]
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chartTableViewCells[(indexPath as NSIndexPath).row];
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pieChartTableViewCell.pieChartView.animate(withDuration: 0.5)
        lineGraphChartTableViewCell.graphView.animate(withDuration: 0.5)
        discreteGraphChartTableViewCell.graphView.animate(withDuration: 0.5)
        barGraphChartTableViewCell.graphView.animate(withDuration: 0.5)
    }    

}
