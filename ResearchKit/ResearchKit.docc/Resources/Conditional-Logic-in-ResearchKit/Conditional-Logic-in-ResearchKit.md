# Conditional Logic in ResearchKit

How to use conditional logic for ResearchKit steps and forms.

## Understanding Conditional Logic

When presenting a survey or task, conditionally show specific content based on the participant's responses. ResearchKit provides two solutions for conditional logic.

- **Step Navigation rules**: Conditionally navigate to a specific step based on the participant's response.
- **Form Item Visibility rules** - Conditionally hide or show specific form questions based on results from the same form or a form within another step.



### Navigating Steps Conditionally
Review the following classes to conditionally navigate to or skip specific steps during an `ORKTask`.

- `ORKResultSelector` - A class that identifies a result within a set of task results.
- `ORKResultPredicate` - Creates a predicate by accepting an `ORKResultSelector` and the expected result.
- `ORKPredicateStepNavigationRule` - A class that determines what step to navigate to if a given `ORKResultPredicate` is true.
- `ORKNavigableOrderedTask` - A subclass of the `ORKOrderedTask` that can accept one or more `ORKPredicateStepNavigationRule` objects and apply the expected conditional navigation.


The task for this example includes the steps seen below.

![Step 1](conditional-logic-in-researchKit-step1)
![Step 2](conditional-logic-in-researchKit-step2)
![Step 3](conditional-logic-in-researchKit-step3)

The conditional logic is based on answering `Yes` or `No` for the first question ("Do you like Apples?"):

- **Answering yes**: navigates to the second screen to select your favorite apple.
- **Answering no**: skips the second screen and navigates directly to the completion step.

```swift

//Construct Steps
let boolFormStep = ORKFormStep(identifier: "FormStep1")
boolFormStep.title = "Apple Task"
boolFormStep.text = "Please answer the following question."
        
let boolAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
let boolFormItem = ORKFormItem(identifier: "BooleanFormItemIdentifier", 
							   text: "Do you like Apples?", 
							   answerFormat: boolAnswerFormat)
        
boolFormStep.formItems = [boolFormItem]

let appleTextChoiceFormStep = appleTextChoiceFormStepExample()
let completionStep = completionStepExample()

//Conditional Logic
let boolResultSelector = ORKResultSelector(stepIdentifier: boolFormStep.identifier, resultIdentifier: boolFormItem.identifier)
let boolResultPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: boolResultSelector, expectedAnswer: false)
let navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [ (boolResultPredicate, completionStep.identifier) ])

//Construct Navigable Task + Set Navigation Rule
let navigableTask = ORKNavigableOrderedTask(identifier: "NavigableTaskIdentifier", steps: [formStep1, appleTextChoiceFormStep, completionStep])
navigableTask.setNavigationRule(navigationRule, forTriggerStepIdentifier: formStep1.identifier)
```

Selecting yes:

@Video(source: "conditional-logic-in-researchKit-step-yes")

Selecting no:

@Video(source: "conditional-logic-in-researchKit-step-no")

### Managing Form Item Visibility

Familiarize yourself with the following classes to conditionally hide or show a question based on results from questions within the same form.

- `ORKResultSelector` - A class that identifies a result within a set of task results.
- `ORKResultPredicate` - Creates a predicate by accepting an `ORKResultSelector` and the expected result.
- `ORKPredicateFormItemVisibilityRule` - A class that determines if the form item it's attached to is hidden or visible if a given `ORKResultPredicate` is true.

Following the previous example, use the same questions but now with both on the same page.


- **Answering yes**: makes the apple choice question visible.
- **Answering no**: hides the apple choice question if visible.


```swift
//Construct FormStep
let formStep = ORKFormStep(identifier: "FormStep1")
formStep.title = "Apple Task"
formStep.text = "Please answer the following question."
        
let boolAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
let boolFormItem = ORKFormItem(identifier: "BooleanFormItemIdentifier", 
							   text: "Do you like Apples?", 
							   answerFormat: boolAnswerFormat)
							   
							   
let appleChoiceFormItem = appleChoiceFormItem()
        
formStep.formItems = [boolFormItem, appleChoiceFormItem]

let completionStep = completionStepExample()

//Conditional Logic
let resultSelector: ORKResultSelector = .init(stepIdentifier: formStep.identifier, resultIdentifier: boolFormItem.identifier)
let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
let visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicate)
        
appleChoiceFormItem.visibilityRule = visibilityRule

//Construct Navigable Task
 let navigableTask = ORKNavigableOrderedTask(identifier: "NavigableTaskIdentifier", steps: [formStep, completionStep])
```

Selecting yes & no:

@Video(source: "conditional-logic-in-researchKit-formItem-yes-no")
