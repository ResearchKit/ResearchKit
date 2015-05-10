//
//  ChartTableViewCells.swift
//  ORKCatalog
//
//  Created by James Cox on 11/05/2015.
//  Copyright (c) 2015 researchkit.org. All rights reserved.
//

import UIKit
import ResearchKit

class PieChartTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pieChartView: ORKPieChartView!
}

class BaseGraphTableViewCell: UITableViewCell {
    
    @IBOutlet weak var graphView: ORKBaseGraphView!
}

class DiscreteGraphTableViewCell: BaseGraphTableViewCell { }

class LineGraphTableViewCell: BaseGraphTableViewCell { }

