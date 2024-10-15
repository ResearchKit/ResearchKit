# Family History Step

Use the Family History Step to collect insightful health trends.

## Overview

Accurate family health history is a highly valuable data set that can help patients prepare for or avoid common health conditions they might face in the future. However, obtaining this information has always been a struggle to collect manually and even digitally. Now, with ResearchKit, developers and researchers can quickly construct an ORKFamilyHistoryStep and present a survey to collect data for family health history that is tailored to their specific needs. 

With the ``ORKFamilyHistoryStep`` you can specify:

- **Relative Types** - Determine the exact type of family members the survey asks about. 
- **Survey Questions** - Use the same questions for each relative group or create a different survey for each.
- **Health Conditions** - Include a list of health conditions that can be the same or different for each relative group.
- **Displayed Results** - Determine which results are displayed back to the user after completing each relative's survey.

## Understanding the Family History Step classes

Before initializing an ``ORKFamilyHistoryStep`` you should familiarize yourself with the classes required. 

- **ORKHealthCondition** - This represents a single health condition presented in your survey.
- **ORKConditionStepConfiguration** - This object provides the information needed for the health conditions list presented to the user. 
- **ORKRelativeGroup** - This represents a specific relative group such as Grandparents, Children, or Siblings.
- **ORKRelatedPerson** -This represents a family member added during the survey. Retrieve this object from the result of the ``ORKFamilyHistoryStep``.

In the next section, we will construct an ``ORKFamilyHistoryStep`` using the classes above.

## Constructing a Family History Step

Following the example below, we will recreate the same Family History Step only for the parent group.

![Instruction Step](family-history-step-instruction-step)
![Family History Step With No Relatives](family-history-step-no-relatives)
![Family History Step With Parent Added](family-history-step-parent-added)

### Creating Health Condition Objects

First, create the ``ORKHealthCondition`` objects necessary to display the health conditions specific to your survey.

```swift
 let healthConditions = [
        ORKHealthCondition(identifier: "healthConditionIdentifier1", displayName: "Diabetes", value: "Diabetes" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier2", displayName: "Heart Attack", value: "Heart Attack" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier3", displayName: "Stroke", value: "Stroke" as NSString)
        ]
```

### Create Condition Step Configuration

Next, initialize an ``ORKConditionStepConfiguration`` and add the necessary information, which includes the health conditions array created before this.

```swift
let conditionStepConfiguration = ORKConditionStepConfiguration(stepIdentifier: "FamilyHistoryConditionStepIdentifier", 
                                                               conditionsFormItemIdentifier: "HealthConditionsFormItemIdentifier",
                                                               conditions: healthConditions,
                                                               formItems: [])
```

- **stepIdentifier** - When the user is presented with the health conditions to select, they are technically looking at an ``ORKFormStep`` that was initialized by the ``ORKFamilyHistoryStep`` itself. The value you set for this property is the step identifier for the health conditions form step.
- **conditionsFormItemIdentifier** - The string used as the identifier for the health conditions text choice question. Use this identifier to locate each family member's health condition selected in the ORKResult.
- **conditions** - The user will be presented with an individual text choice for each "ORKHealthCondition" in this list.
- **formItems** - Optionally, provide more form items to present additional questions under the health conditions text choices.

### Create Relative Group

The last object needed for the family history step is the ``ORKRelativeGroup``. 

```swift
let parentFormStep = ORKFormStep(identifier: "ParentSurveyIdentifier")
parentFormStep.isOptional = false
parentFormStep.title = "Parent"
parentFormStep.detailText = "Answer these questions to the best of your ability."
parentFormStep.formItems = parentFormStepFormItems()

let parentRelativeGroup = ORKRelativeGroup(identifier: "ParentGroupIdentifier",
                                           name: "Biological Parent",
                                           sectionTitle: "Biological Parents",
                                           sectionDetailText: "Include your blood-related parents.",
                                           identifierForCellTitle: "ParentNameIdentifier",
                                           maxAllowed: 2,
                                           formSteps: [parentFormStep],
                                           detailTextIdentifiers: ["ParentSexAtBirthIdentifier", "ParentVitalStatusIdentifier", "ParentAgeFormItemIdentifier"])
```

### Create Family History Step

For the last step, we will construct an ``ORKFamilyHistoryStep`` and pass in the initialized objects from above.
        
```swift
let familyHistoryStep = ORKFamilyHistoryStep(identifier: "FamilyHistoryStepIdentifier)
familyHistoryStep.title = "Family Health History"
familyHistoryStep.detailText = "The overview of your biological family members can inform health risks and lifestyle."
familyHistoryStep.conditionStepConfiguration = conditionStepConfiguration
familyHistoryStep.relativeGroups = relativeGroups
```

### Parsing Family History Step Result

After presenting the task, parse the ``ORKTaskResult`` to access the ``ORKFamilyHistoryResult``.


```swift
guard let stepResult = (taskViewController.result.results?[1] as? ORKStepResult) else { return }
        
if let familyHistoryResult = stepResult.results?.first as? ORKFamilyHistoryResult {
	let relatedPersons = familyHistoryResult.relatedPersons
}
```
