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
        case showTaskResult = "ShowTaskResult"
    }
    
    // MARK: Properties

    var result: ORKResult?
    var currentResult: ORKResult?

    var resultTableViewProvider: UITableViewDataSource & UITableViewDelegate = resultTableViewProviderForResult(nil, delegate: nil)
    
    private let outputDirectory = URL.documentsDirectory
    private let operationQueue = OperationQueue()
    private var shareButton: UIButton?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.systemGroupedBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add share button to AirDrop results.
        
        if shareButton == nil, outputDirectory.isEmpty == false {
            let shareButton = UIButton(type: .system)
            shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
            shareButton.translatesAutoresizingMaskIntoConstraints = false
            shareButton.addTarget(self, action: #selector(handleShareButtonTap), for: .touchUpInside)
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
            footerView.addSubview(shareButton)
            
            tableView.tableFooterView = footerView
            
            NSLayoutConstraint.activate([
                shareButton.widthAnchor.constraint(equalToConstant: 44),
                shareButton.heightAnchor.constraint(equalToConstant: 44),
                shareButton.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                shareButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
            ])
            
            self.shareButton = shareButton
        }
        
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
        resultTableViewProvider = resultTableViewProviderForResult(result, delegate: self)
        
        tableView.dataSource = resultTableViewProvider
        tableView.delegate = resultTableViewProvider
    }
    
    // MARK: UIStoryboardSegue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*
            Check to see if the segue identifier is meant for presenting a new
            result view controller.
        */
        if let identifier = segue.identifier,
           let segueIdentifier = SegueIdentifier(rawValue: identifier), segueIdentifier == .showTaskResult {
            
            let cell = sender as! UITableViewCell

            let indexPath = tableView.indexPath(for: cell)!
            
            let destinationViewController = segue.destination as! ResultViewController
            
            let collectionResult = result as! ORKCollectionResult
            destinationViewController.result = collectionResult.results![(indexPath as NSIndexPath).row]
        }
    }

    override func shouldPerformSegue(withIdentifier segueIdentifier: String?, sender: Any?) -> Bool {
        /*
            Only perform a segue if the cell that was tapped has a disclosure
            indicator. These are the only kinds of cells that we allow to perform
            segues in a `ResultViewController`.
        */
        if let cell = sender as? UITableViewCell {
            return cell.accessoryType == .disclosureIndicator
        }
        
        return false
    }
    
    @objc
    private func handleShareButtonTap() {
        guard let result else { return }
        display(
            shareSheetOperation: makeShareSheetOperation(for: result),
            using: operationQueue
        )
    }
    
    private func display(shareSheetOperation: Operation, using operationQueue: OperationQueue) {
        operationQueue.addOperation(shareSheetOperation)
    }
    
    private func makeShareSheetOperation(for result: ORKResult) -> Operation {
        let path = outputDirectory.appending(path: "result_data", directoryHint: .isDirectory)
                                    
        let displayShareSheetOperation = BlockOperation {
            DispatchQueue.main.async { [weak self] in
                let activityViewController = UIActivityViewController(
                    activityItems: [path],
                    applicationActivities: nil
                )
                self?.present(activityViewController, animated: true, completion: nil)
            }
        }
        
        addOperationsToPrepareFiles(
            for: result,
            relativeTo: path,
            forShareOperation: displayShareSheetOperation
        )
        
        return displayShareSheetOperation
    }
    
    private func addOperationsToPrepareFiles(
        for result: ORKResult,
        relativeTo path: URL,
        forShareOperation shareOperation: Operation
    ) {
        var operationsToPrepareFiles: [Operation] = []
        
        let moveRecordedFilesOperation = moveRecordedFiles(for: result, at: path)
        operationsToPrepareFiles.append(moveRecordedFilesOperation)
        
        operationsToPrepareFiles.forEach { resultOperation in
            shareOperation.addDependency(resultOperation)
            operationQueue.addOperation(resultOperation)
        }
    }
    
    private func moveRecordedFiles(for result: ORKResult, at path: URL) -> Operation {
        BlockOperation {
            do { 
                let fileManager: FileManager = .default
                try? fileManager.removeItem(atPath: path.relativePath)
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
                try fileManager.moveRecordedFiles(storedInDirectory: self.outputDirectory, to: path)
            } catch {
                print("Could not move recorded files to export directory.")
            }
        }
    }
    
}

private extension FileManager {
    /// Move all content in `sourceDirectory` to `exportDirectory`.
    /// - Parameters:
    ///     - sourceDirectory: The source directory containing files to be moved
    ///     - exportDirectory: the destination directory to move the files to
    func moveRecordedFiles(storedInDirectory sourceDirectory: URL, to exportDirectory: URL) throws {
        try listOfFilesToMove(in: sourceDirectory, to: exportDirectory).forEach { source in
            try FileManager.default.moveItem(
                at: source,
                to: exportDirectory.appendingPathComponent(source.lastPathComponent)
            )
        }
    }
    
    /// Lists all the files in `directory` that could be moved to `exportDirectory`.
    /// If `exportDirectory` is a subdirectory of `directory`, it will not be listed.
    /// - Parameters:
    ///     - directory: The URL of the directory containing files to be moved
    ///     - exportDirectory: the URL of the destination directory to move the files to
    func listOfFilesToMove(in directory: URL, to exportDirectory: URL) throws -> [URL] {
        let resourceValues: [URLResourceKey] = [.isRegularFileKey]

        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: resourceValues,
            options: []
        ) else {
            fatalError("\(#function) Cannot create enumerator")
        }

        return try enumerator
            .lazy
            .compactMap { $0 as? URL }
            .filter { try $0.resourceValues(forKeys: Set(resourceValues)).isRegularFile == true }
            .filter { $0.lastPathComponent != exportDirectory.lastPathComponent } // skip exportDirectory itself
    }
}

private extension URL {
    var isEmpty: Bool {
        (try? FileManager.default.contentsOfDirectory(atPath: relativePath).isEmpty) ?? false
    }
}
extension ResultViewController: ResultProviderDelegate {
    func presentShareSheet(shareSheet: UIActivityViewController) {
        present(shareSheet, animated: true, completion: nil)
    }
}


