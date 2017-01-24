/*
Copyright (c) 2015, Ricardo Sánchez-Sáez.

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
import ResearchKit

@objc class TaskFactory : NSObject {

    class func makeNavigableOrderedTask(_ taskIdentifier : String) -> ORKNavigableOrderedTask {
        var steps: [ORKStep] = []
        var answerFormat: ORKAnswerFormat
        var step: ORKStep
        var textChoices: [ORKTextChoice]
        
        // Form step
        textChoices = [
            ORKTextChoice(text: "Good", value: "good" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Bad", value: "bad" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        let formItemFeeling: ORKFormItem = ORKFormItem(identifier: "formFeeling", text: "How do you feel", answerFormat: answerFormat)
        let formItemMood: ORKFormItem = ORKFormItem(identifier: "formMood", text: "How is your mood", answerFormat: answerFormat)
        let formStep: ORKFormStep = ORKFormStep(identifier: "introForm")
        formStep.isOptional = false
        formStep.formItems = [formItemFeeling, formItemMood]
        steps.append(formStep)
        
        // Question steps
        textChoices = [
            ORKTextChoice(text: "Headache", value: "headache" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Dizziness", value: "dizziness" as NSCoding & NSCopying & NSObjectProtocol),
            ORKTextChoice(text: "Nausea", value: "nausea" as NSCoding & NSCopying & NSObjectProtocol)
        ]
        answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        step = ORKQuestionStep(identifier: "symptom", title: "Which is your most severe symptom?", answer: answerFormat)
        step.isOptional = false
        steps.append(step)
        
        answerFormat = ORKAnswerFormat.booleanAnswerFormat()
        step = ORKQuestionStep(identifier: "severity", title: "Does your symptom interfere with your daily life?", answer: answerFormat)
        step.isOptional = false
        steps.append(step)
        
        // Instruction steps
        step = ORKInstructionStep(identifier: "blank")
        step.title = "This step is intentionally left blank (you should not see it)"
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "severe_headache")
        step.title = "You have a severe headache"
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "light_headache")
        step.title = "You have a light headache"
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "other_symptom")
        step.title = "Your symptom is not a headache"
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "survey_skipped")
        step.title = "Please come back to this survey when you don't feel good or your mood is low."
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "end")
        step.title = "You have finished the task"
        steps.append(step)
        
        step = ORKInstructionStep(identifier: "blankB")
        step.title = "This step is intentionally left blank (you should not see it)"
        steps.append(step)
        
        let task: ORKNavigableOrderedTask = ORKNavigableOrderedTask(identifier: taskIdentifier, steps: steps)
        
        // Navigation rules
        var predicateRule: ORKPredicateStepNavigationRule
        
        // From the feel/mood form step, skip the survey if the user is feeling okay and has a good mood
        var resultSelector = ORKResultSelector.init(stepIdentifier: "introForm", resultIdentifier: "formFeeling");
        let predicateGoodFeeling: NSPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "good" as NSCoding & NSCopying & NSObjectProtocol)
        resultSelector = ORKResultSelector.init(stepIdentifier: "introForm", resultIdentifier: "formMood");
        let predicateGoodMood: NSPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "good" as NSCoding & NSCopying & NSObjectProtocol)
        let predicateGoodMoodAndFeeling: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateGoodFeeling, predicateGoodMood])
        predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
            [ (predicateGoodMoodAndFeeling, "survey_skipped") ])
        task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "introForm")
        
        // From the "symptom" step, go to "other_symptom" is user didn't chose headache.
        // Otherwise, default to going to next step (the regular ORKOrderedTask order applies
        //  when the defaultStepIdentifier argument is omitted).
        
        // User chose headache at the symptom step
        // Equivalent to:
        //      [NSPredicate predicateWithFormat:
        //          @"SUBQUERY(SELF, $x, $x.identifier like 'symptom' \
        //                     AND SUBQUERY($x.answer, $y, $y like 'headache').@count > 0).@count > 0"];
        resultSelector = ORKResultSelector.init(resultIdentifier: "symptom");
        let predicateHeadache: NSPredicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: "headache" as NSCoding & NSCopying & NSObjectProtocol)
        
        // User didn't chose headache at the symptom step
        let predicateNotHeadache: NSCompoundPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: predicateHeadache)

        predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
            [ (predicateNotHeadache, "other_symptom") ])
        task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "symptom")
        
        // From the "severity" step, go to "severe_headache" or "light_headache" depending on the user answer
        
        // User chose YES at the severity step
        // Equivalent to:
        //      [NSPredicate predicateWithFormat:
        //          @"SUBQUERY(SELF, $x, $x.identifier like 'severity' AND $x.answer == YES).@count > 0"];
        resultSelector = ORKResultSelector.init(resultIdentifier: "severity");
        let predicateSevereYes: NSPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
        
        // User chose NO at the severity step
        resultSelector = ORKResultSelector.init(resultIdentifier: "severity");
        let predicateSevereNo: NSPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: false)
        
        let predicateSevereHeadache: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateHeadache, predicateSevereYes])
        let predicateLightHeadache: NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateHeadache, predicateSevereNo])
        
        predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers:
            [ (predicateSevereHeadache, "severe_headache"), (predicateLightHeadache, "light_headache") ])
        task.setNavigationRule(predicateRule, forTriggerStepIdentifier: "severity")
        
        // Direct rules to skip unneeded steps
        var directRule: ORKDirectStepNavigationRule
        
        directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "end")
        task.setNavigationRule(directRule, forTriggerStepIdentifier: "severe_headache")
        task.setNavigationRule(directRule, forTriggerStepIdentifier: "light_headache")
        task.setNavigationRule(directRule, forTriggerStepIdentifier: "other_symptom")
        task.setNavigationRule(directRule, forTriggerStepIdentifier: "survey_skipped")
        
        directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
        task.setNavigationRule(directRule, forTriggerStepIdentifier: "end")
        
        return task
    }
}
