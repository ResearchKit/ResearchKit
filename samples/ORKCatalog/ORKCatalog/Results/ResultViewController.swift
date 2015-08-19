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

import UIKit
import ResearchKit

/**
    The purpose of this view controller is to show you the kinds of data
    you can fetch from a specific `ORKResult`. The intention is for this view
    controller to be purely for demonstration and testing purposes--specifically,
    it should not ever be shown to a user. Because of this, the UI for this view
    controller is not localized.
*/
class ResultViewController: UITableViewController {
    // MARK: Types
    
    enum SegueIdentifier: String {
        case ShowTaskResult = "ShowTaskResult"
    }
    
    // MARK: Properties

    var result: ORKResult?

    var currentResult: ORKResult?

    var resultTableViewProvider: protocol<UITableViewDataSource, UITableViewDelegate>?
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
            Don't update the UI if there hasn't been a change between the currently
            displayed result, and the result that has been most recently set on
            the `ResultViewController`.
        */
        guard result != currentResult || currentResult == nil else { return }
        
        // Update the currently displayed result.
        currentResult = result

        /*
            Display result specific metadata, done by a result table view provider.
            Although we're not going to use `resultTableViewProvider` directly,
            we need to maintain a reference to it so that it can remain "alive"
            while its the table view's delegate and data source.
        */
        resultTableViewProvider = resultTableViewProviderForResult(result)
        
        tableView.dataSource = resultTableViewProvider
        tableView.delegate = resultTableViewProvider
    }
    
    // MARK: UIStoryboardSegue Handling
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
            Check to see if the segue identifier is meant for presenting a new
            result view controller.
        */
        if let identifier = segue.identifier,
               segueIdentifier = SegueIdentifier(rawValue: identifier)
               where segueIdentifier == .ShowTaskResult {
            
            let cell = sender as! UITableViewCell
            
            let indexPath = tableView.indexPathForCell(cell)!
            
            let destinationViewController = segue.destinationViewController as! ResultViewController
            
            let collectionResult = result as! ORKCollectionResult
            
            destinationViewController.result = collectionResult.results![indexPath.row]
        }
    }

    override func shouldPerformSegueWithIdentifier(segueIdentifier: String?, sender: AnyObject?) -> Bool {
        /*
            Only perform a segue if the cell that was tapped has a disclosure
            indicator. These are the only kinds of cells that we allow to perform
            segues in a `ResultViewController`.
        */
        if let cell = sender as? UITableViewCell {
            return cell.accessoryType == .DisclosureIndicator
        }
        
        return false
    }
}
