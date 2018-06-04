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


import UIKit
import ResearchKit

class GraphViewController: UITableViewController {
    
    let barGraphChartDataSource = BarGraphDataSource()
    let barGraphChartIdentifier = "BarGraphChartCell"
    var barGraphChartTableViewCell: BarGraphChartTableViewCell!
    var chartTableViewCells: [UITableViewCell]!
    
    override func viewDidLoad() {
        createGraph()
        tableView.backgroundColor = Colors.tableViewBackgroundColor.color
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBar.barTintColor = Colors.appTintColor.color
    }
    
    func createGraph() {
        // ORKBarGraphChartView
        barGraphChartTableViewCell = tableView.dequeueReusableCell(withIdentifier: barGraphChartIdentifier) as? BarGraphChartTableViewCell
        if (barGraphChartTableViewCell == nil) {
            barGraphChartTableViewCell = BarGraphChartTableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        barGraphChartTableViewCell.titleLabel.text = "June 4, 2018"
        
        let barGraphChartView = barGraphChartTableViewCell.graphView
        barGraphChartView.dataSource = barGraphChartDataSource
        barGraphChartView.tintColor = UIColor.lightGray
        barGraphChartView.referenceLineColor = Colors.graphReferenceLinceColor.color
        barGraphChartTableViewCell.backgroundColor = Colors.tableViewCellBackgroundColor.color
        barGraphChartView.axisColor = Colors.graphReferenceLinceColor.color
        barGraphChartView.showsHorizontalReferenceLines = true
        barGraphChartView.showsVerticalReferenceLines = true
        barGraphChartView.yAxisLabelFactors = [0.0, 0.25, 0.5, 0.75, 1.0]

        chartTableViewCells = [barGraphChartTableViewCell]
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 280.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chartTableViewCells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chartTableViewCells[(indexPath as NSIndexPath).row];
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? (UIDevice.current.orientation == .portrait ? 80.0 : 25.0) : 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ? LegendSectionHeaderView.init(legends: [GraphLegend.init(title: "Tremor", color: Colors.tremorGraphColor.color), GraphLegend.init(title: "Dyskinesia", color: Colors.dyskinesiaSymptomGraphColor.color)], layout: .horizontal) : nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barGraphChartTableViewCell.graphView.animate(withDuration: 0.5)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

class GraphLegend: NSObject {
    var title: String
    var color: UIColor
    
    init(title: String, color: UIColor) {
        self.title = title
        self.color = color
        super.init()
    }
}

class LegendSectionHeaderView: UIView {
    var legends:[GraphLegend]
    var axis: NSLayoutConstraint.Axis
    var stackView: UIStackView!
    
    init(legends: [GraphLegend], layout: NSLayoutConstraint.Axis) {
        self.legends = legends
        self.axis = layout
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        if (stackView == nil) {
            stackView = UIStackView()
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = .fillEqually
        addLegends()
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: stackView,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .top,
                                    multiplier: 1.0,
                                    constant: 0.0),
            NSLayoutConstraint.init(item: stackView,
                                    attribute: .bottom,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .bottom,
                                    multiplier: 1.0,
                                    constant: 0.0),
            NSLayoutConstraint.init(item: stackView,
                                    attribute: .left,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .left,
                                    multiplier: 1.0,
                                    constant: 0.0),
            NSLayoutConstraint.init(item: stackView,
                                    attribute: .right,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .right,
                                    multiplier: 1.0,
                                    constant: 0.0)
            ])
    }
    
    func addLegends() {
        for legend in legends {
            let view = UIView.init(frame: CGRect.init(x: 0.0, y: 0.0, width: 15.0, height: 15.0))
            view.translatesAutoresizingMaskIntoConstraints = false
            let colorView = UIView()
            colorView.translatesAutoresizingMaskIntoConstraints = false
            colorView.backgroundColor = legend.color
            let legendLabel = UILabel()
            legendLabel.translatesAutoresizingMaskIntoConstraints = false
            legendLabel.text = legend.title
            legendLabel.textAlignment = .center
            
            view.addSubview(colorView)
            view.addSubview(legendLabel)
            
            NSLayoutConstraint.activate([
                NSLayoutConstraint.init(item: legendLabel,
                                        attribute: .centerY,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .centerY,
                                        multiplier: 1.0,
                                        constant: 0.0),
                NSLayoutConstraint.init(item: legendLabel,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .centerX,
                                        multiplier: 1.0,
                                        constant: 0.0),
                NSLayoutConstraint.init(item: colorView,
                                        attribute: .centerY,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .centerY,
                                        multiplier: 1.0,
                                        constant: 0.0),
                NSLayoutConstraint.init(item: colorView,
                                        attribute: .right,
                                        relatedBy: .equal,
                                        toItem: legendLabel,
                                        attribute: .left,
                                        multiplier: 1.0,
                                        constant: -5.0),
                NSLayoutConstraint.init(item: colorView,
                                        attribute: .width,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 10.0),
                NSLayoutConstraint.init(item: colorView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .notAnAttribute,
                                        multiplier: 1.0,
                                        constant: 10.0)
                ])
            
            stackView.addArrangedSubview(view)
        }
    }
}
