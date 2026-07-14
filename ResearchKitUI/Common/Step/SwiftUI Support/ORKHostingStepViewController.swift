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

import SwiftUI

class ORKHostingStepViewController<HostedStep, V>: ORKStepViewController where V: View {

    var contentView: (HostedStep) -> V

    init(step: HostedStep, result: ORKResult?, contentView: @escaping (HostedStep) -> V) {
        self.contentView = contentView

        if let orkStep = step as? ORKStep {
            super.init(step: orkStep)
        } else {
            super.init(step: ORKAdapterStep(rawStep: step))
        }
    }

    init<HostableStep>(hostableStep hostableStepViewProvider: HostableStep, result: ORKResult?) where HostableStep: ORKStepViewProvider, HostableStep.ViewPresentingStep == V, HostedStep == HostableStep.Step {
        self.contentView = { hostableStepViewProvider.makeView(for: $0) }

        if let hostedStep = hostableStepViewProvider as? ORKStep {
            super.init(step: hostedStep)
        } else {
            super.init(step: ORKAdapterStep(rawStep: hostableStepViewProvider))
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private var body: some View {
        contentView(hostedStep)
            .onStepCompletion(stepCompletion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingControllerView = UIHostingController(rootView: body)

        addChild(hostingControllerView)
        hostingControllerView.willMove(toParent: self)
        view.addSubview(hostingControllerView.view)

        hostingControllerView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingControllerView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingControllerView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            hostingControllerView.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingControllerView.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        hostingControllerView.didMove(toParent: self)
    }

    private var hostedStep: HostedStep {
        if let step = step as? ORKAdapterStep<HostedStep> {
            return step.rawStep
        } else if let step = step as? HostedStep {
            return step
        } else {
            fatalError("Expected \(String(describing: step)) to be of type \(HostedStep.self)")
        }
    }

    private func stepCompletion(_ result: Result<any StepResult, Error>) {
        do {
            let result = try result.get()
            if let provider = result as? ORKStepResultLegacyProvider {
                addResult(provider.legacyResult)
            }
            goForward()
        } catch {
            ORKLogError(error.localizedDescription)
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            #if DEBUG
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                self.stepCompletion(result)
            }))
            #endif
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

public protocol StepResult {
    associatedtype ID
    var identifier: ID { get }
    var start: Date { get }
    var end: Date { get }
}

public protocol ORKStepResultLegacyProvider {
    var legacyResult: ORKStepResult { get }
}

public typealias StepCompletionFunction = (Result<any StepResult, Error>) -> Void

extension View {
    public func onStepCompletion(_ completion: @escaping StepCompletionFunction) -> some View {
        modifier(StepCompletionEnvironmentViewModifier(completion: completion))
    }
}

struct StepCompletionEnvironmentViewModifier: ViewModifier {
    @Environment(\.stepCompletion)
    private var context

    private let completion: StepCompletionFunction
    init(completion: @escaping StepCompletionFunction) {
        self.completion = completion
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                context.append(completion)
            }
    }
}

struct StepCompletionEnvironmentContextKey: EnvironmentKey {
    static let defaultValue: StepCompletionEnvironmentContext = .init()
}

extension EnvironmentValues {
    public var stepCompletion: StepCompletionEnvironmentContext {
        get { self[StepCompletionEnvironmentContextKey.self] }
        set { self[StepCompletionEnvironmentContextKey.self] = newValue }
    }
}

public class StepCompletionEnvironmentContext {
    private var completions: [StepCompletionFunction] = []

    public func callAsFunction(_ result: Result<any StepResult, Error>) {
        completions.forEach { $0(result) }
    }

    func append(_ function: @escaping StepCompletionFunction) {
        completions.append(function)
    }

    var function: StepCompletionFunction {
        callAsFunction(_:)
    }
}
