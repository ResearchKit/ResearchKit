/*
Copyright (c) 2026, Apple Inc. All rights reserved.

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

import ResearchKit
import SwiftUI
import UIKit

/// A `UIViewController` that hosts the SwiftUI `ResultView`.
/// Any `ORKResult` set on this controller is serialized via
/// `ORKESerializer` and displayed as an expandable JSON tree.
class ResultHostingController: UIViewController {

    var result: ORKResult? {
        didSet {
            viewModel.update(with: result)
            navigationItem.title = "Task Results"
            navigationItem.rightBarButtonItem = viewModel.jsonString.map { json in
                UIBarButtonItem(
                    image: UIImage(systemName: "square.and.arrow.up"),
                    primaryAction: UIAction { [weak self] _ in
                        let url = FileManager.default.temporaryDirectory
                            .appendingPathComponent("result")
                            .appendingPathExtension("json")
                        do {
                            try json.write(to: url, atomically: true, encoding: .utf8)
                            let sheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            self?.present(sheet, animated: true)
                        } catch {
                            let alert = UIAlertController(
                                title: "Export Failed",
                                message: "Failed to write JSON file: \(error)",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self?.present(alert, animated: true)
                        }
                    }
                )
            }
        }
    }

    private let viewModel = ResultViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        embedResultView()
    }

    private func embedResultView() {
        let hostingController = UIHostingController(rootView: ResultView(viewModel: viewModel))
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
