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


import Foundation
import UIKit
import ResearchKit

enum TaskListViewTableSections: Int {
    case surveys = 0
    case activeTasks
    case count
    
    func title() -> String {
        switch self {
        case .surveys:
            return "Surveys"
        case .activeTasks:
            return "Active Tasks"
        default:
            return ""
        }
    }
}

class TaskListViewController: UIViewController {
    
    var tableView: UITableView!
    var headerView: HeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Colors.appTintColor.color
        setupHeader()
        setupTableView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.backgroundColor = Colors.appTintColor.color
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.tableViewBackgroundColor.color
        view.addSubview(tableView)
    }
    
    func setupHeader() {
        
        let attributedDescription = NSMutableAttributedString(string: "Powered by ResearchKit", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .light)])
        attributedDescription.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16.0, weight: .bold), range: NSRange(location: 11, length: 11))
        
        headerView = HeaderView(title: "Parkinson's Study", descriptionText: attributedDescription, iconName: "CheckMark", invertColors: true)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(headerView)
    }
    
    func setupConstraints() {
        headerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -20.0).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        switch indexPath.section {
        case TaskListViewTableSections.surveys.rawValue:
            if indexPath.row == 0 {
                cell = StudyTableCell(text: "Activities of Daily Life", iconName: "heartbeat", style: .default, reuseIdentifier: "tableCell")
            } else if indexPath.row == 1 {
                cell = StudyTableCell(text: "Basic Survey", iconName: "timer", style: .default, reuseIdentifier: "tableCell")
            }
        case TaskListViewTableSections.activeTasks.rawValue:
            if indexPath.row == 0 {
                cell = StudyTableCell(text: "6-Minute Walk", iconName: "walkingman", style: .default, reuseIdentifier: "tableCell")
            } else if indexPath.row == 1 {
                cell = StudyTableCell(text: "Spatial Span Memory", iconName: "memory-second-screen", style: .default, reuseIdentifier: "tableCell")
            } else if indexPath.row == 2 {
                cell = StudyTableCell(text: "Speech Recognition", iconName: "audioGraph", style: .default, reuseIdentifier: "tableCell")
            }
        default:
            break
        }
        cell.backgroundColor = Colors.tableViewCellBackgroundColor.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var task: ORKOrderedTask?
        
        switch indexPath.section {
        case TaskListViewTableSections.surveys.rawValue:
            if indexPath.row == 0 {
                let overallHealthAnswerFormat = ORKAnswerFormat.scale(withMaximumValue: 10, minimumValue: 1, defaultValue: NSIntegerMax, step: 1, vertical: false, maximumValueDescription: "Perfect Health", minimumValueDescription: "Very Poor")
                
                let overallHealthQStep = ORKQuestionStep(identifier: "OverallHealthQuestion", title: "ADL", question: "How would you rate your overall health?", answer: overallHealthAnswerFormat)
                task = ORKOrderedTask(identifier: "task", steps: [overallHealthQStep])
            } else if indexPath.row == 1 {
                let significantEventAnswerFormat = ORKBooleanAnswerFormat(yesString: "Yes", noString: "No")
                let significantEventQStep = ORKQuestionStep(identifier: "significantEventQuestion", title: "Basic Survey", question: "Have you experienced any falls or significant events that have limited your mobility in the past three months?", answer: significantEventAnswerFormat)
                
                let nonmotorSymptomsAnswerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: [ORKTextChoice(text: "Pain", value: 1 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Fatigue", value: 2 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Cognitive impairments", value: 3 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Digestive or Bowel issues", value: 4 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Gait Impairments", value: 5 as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Other", value: 6 as NSCoding & NSCopying & NSObjectProtocol)])
                
                let nonmotorSymptomsQStep = ORKQuestionStep(identifier: "nonmotorSymptomsQuestion", title: "Basic Survey", question: "Which of the following non-motor symptoms do you feel", answer: nonmotorSymptomsAnswerFormat)
                task = ORKOrderedTask(identifier: "task", steps: [significantEventQStep, nonmotorSymptomsQStep])
            }
        case TaskListViewTableSections.activeTasks.rawValue:
            if indexPath.row == 0 {
                task = ORKOrderedTask.fitnessCheck(withIdentifier: "sixMinuteWalk", intendedUseDescription: "", walkDuration: 6 * 60, restDuration: 2 * 60, options: [])
            } else if indexPath.row == 1 {
                task = ORKOrderedTask.spatialSpanMemoryTask(withIdentifier: String(describing: "spatialSpan"), intendedUseDescription: "", initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maximumTests: 5, maximumConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: [])
                break
            } else if indexPath.row == 2 {
                task = ORKOrderedTask.speechRecognitionTask(withIdentifier: "speechRecognition", intendedUseDescription: "", speechRecognizerLocale: .englishUS, speechRecognitionImage: nil, speechRecognitionText: "A quick brown fox jumps over the lazy dog.", shouldHideTranscript: true, allowsEdittingTranscript: true, options: [])
                break
            }
        default:
            break
        }
        
        if task != nil {
            let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
            taskViewController.delegate = self
            
            // Assign a directory to store `taskViewController` output.
            taskViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.present(taskViewController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TaskListViewTableSections(rawValue: section)?.title()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case TaskListViewTableSections.surveys.rawValue:
            return 2
        case TaskListViewTableSections.activeTasks.rawValue:
            return 3
        default:
            break
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TaskListViewTableSections.count.rawValue
    }
}

extension TaskListViewController: ORKTaskViewControllerDelegate {
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed, .discarded, .failed, .saved:
            self.dismiss(animated: false, completion: nil)
        }
    }
}

class StudyTableCell: UITableViewCell {
    
    init(text: String, iconName: String, style: UITableViewCell.CellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let PADDING: CGFloat = 25.0
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.textColor = Colors.tableCellTextColor.color
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        let imageView = UIImageView()
        let bundle = Bundle(for: ORKOrderedTask.self)
        let image = UIImage(named: iconName, in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: PADDING).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        
        if image != nil {
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10.0).isActive = true
        } else {
            titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: PADDING).isActive = true
        }
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: PADDING).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -PADDING).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -PADDING).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
