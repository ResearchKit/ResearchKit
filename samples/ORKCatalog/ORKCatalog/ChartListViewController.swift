//
//  ChartListViewController.swift
//  ORKCatalog
//
//  Created by James Cox on 10/05/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

class ChartListViewController: UITableViewController {
    
    let discreteGraphDataSource: DiscreteGraphDataSource = DiscreteGraphDataSource(),
    lineGraphDataSource: LineGraphDataSource = LineGraphDataSource(),
    pieChartDataSource: PieChartDataSource = PieChartDataSource(),
    discreteGraphIdentifier = "DiscreteGraphCell",
    lineGraphIdentifier = "LineGraphCell",
    pieChartIdentifier = "PieChartCell"
    
    var line: UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier(lineGraphIdentifier) as! LineGraphTableViewCell
        (c.graphView as! ORKLineGraphView).datasource = lineGraphDataSource
        return c
    }
    
    var discrete: UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier(discreteGraphIdentifier) as! DiscreteGraphTableViewCell
        (c.graphView as! ORKDiscreteGraphView).datasource = discreteGraphDataSource
        return c
    }
    
     var pie: UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier(pieChartIdentifier) as! PieChartTableViewCell
        c.pieChartView.datasource = pieChartDataSource
        return c
    }
    
    var charts: [UITableViewCell] {
        return [line, discrete, pie]
    }
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return charts[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let graph = (cell as? BaseGraphTableViewCell)?.graphView {
            configureGraph(graph)
        }
        else if let pie = (cell as? PieChartTableViewCell)?.pieChartView {
            configurePie(pie)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        tableView.reloadData()
    }
}

extension ChartListViewController {
    
    func configureGraph(graph: ORKBaseGraphView) {
        graph.showsVerticalReferenceLines = true
        /* set more ORKBaseGraphView properties as desired */
        graph.setNeedsLayout()
        graph.layoutIfNeeded()
        graph.refreshGraph()
    }
    
    func configurePie(pie: ORKPieChartView) {
        let font = UIFont(name: "HelveticaNeue", size: 11)
        pie.legendFont = font
        pie.percentageFont = font
        pie.legendPaddingHeight = 42
        /* set more ORKPieChartView properties as desired */
    }
}