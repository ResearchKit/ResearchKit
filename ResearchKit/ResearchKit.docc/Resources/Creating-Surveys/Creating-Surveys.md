# Creating surveys

Configure and present surveys with ResearchKit.

## Overview

A survey is a sequence of questions that you use to collect data from your users. In a ResearchKit app, a survey is composed of a survey task that has a collection of step objects (``ORKStep``). ``ORKFormStep`` instances can be added to the collection of steps to handle one or more questions each such as "What medications are you taking?" or "How many hours did you sleep last night?".

You can collect results for the individual steps or for the task as a whole. There are two types of survey tasks: an ordered task (``ORKOrderedTask``) and a navigable ordered task (``ORKNavigableOrderedTask``) which can be used to apply conditional logic.

In an ordered task, the order that the steps appear are always the same. 


![Ordered Tasks](creating-surveys-ordered-tasks)

In a navigable ordered task, the order of the tasks can change, or branch out, depending on how the user answered a question in a previous task.

![Navigable Ordered Tasks](creating-surveys-navigable-ordered-tasks)

The steps for creating a task to present a survey are:

1. <a href="#create">Create one or more steps</a>
2. <a href="#task">Create a task</a>
3. <a href="#results">Collect results</a>

## 1. Create steps

The survey module provides a form step that can contain one or more questions
(``ORKFormStep``). You can also use an instruction step
(``ORKInstructionStep``) or a video instruction step (``ORKVideoInstructionStep``) to introduce the survey or provide instructions.

### Instruction step

An instruction step explains the purpose of a task and provides
instructions for the user. An ``ORKInstructionStep`` object includes an
identifier, title, text, detail text, and an image. An
instruction step doesn't collect any data and yields an empty
``ORKStepResult`` that records how long the instruction was
on screen.

```swift
let instructionStep = ORKInstructionStep(identifier: "identifier")
instructionStep.title = "Selection Survey"
instructionStep.text = "This survey helps us understand your eligibility for the fitness study."
```

Creating a step as shown in the code above, including it in a task, and presenting with a task view controller, yields something like this:

![Instruction Step](creating-surveys-instruction-step)

### Form Step

Whether your survey has one question or several related questions, you can use a form step (``ORKFormStep``) to present them on one page. Each question in a form step is represented as a form item (``ORKFormItem``), each with its
own answer format.

The result of a form step contains one question result for each form
item. The results are matched to their corresponding form items using
their identifier property.

The following code shows how to create a form that requests some basic details:


```swift
let sectionHeaderFormItem = ORKFormItem(sectionTitle: "Basic Information")
let nameFormItem = ORKFormItem(identifier: "NameIdentifier", text: "What is your name?", answerFormat: ORKTextAnswerFormat())
let emailFormItem = ORKFormItem(identifier: "EmailIdentifier", text: "What is your email?", answerFormat: ORKEmailAnswerFormat())
let headacheFormItem = ORKFormItem(identifier: "HeadacheIdentifier", text: "Do you have a headache?", answerFormat: ORKBooleanAnswerFormat())
 
let formStep = ORKFormStep(identifier: "FormStepIdentifier")
formStep.title = "Basic Information"
formStep.detailText = "please answer the questions below"
formStep.formItems = [sectionHeaderFormItem, nameFormItem, emailFormItem, headacheFormItem]
```

The code above creates this form step:

![Form Step](creating-surveys-form-step)

### Answer Formats

In the ResearchKit™ framework, an answer format defines how the user should be asked to
answer a question or an item in a form.  For example, consider a
survey question such as "On a scale of 1 to 10, how much pain do you
feel?" The answer format for this question would naturally be a
discrete scale on that range, so you can use scale answer format (``ORKScaleAnswerFormat``), 
and set its minimum and maximum
properties to reflect the desired range.  

The screenshots below show the standard answer formats that the ResearchKit framework provides.

|   |   |
|---|---|
| ![Background Check Question](creating-surveys-background-check) | ![Blood Type Question](creating-surveys-blood-type) |
| ![Symptoms Question](creating-surveys-symptom-choice) | ![Age Question](creating-surveys-age) |
| ![Time of Day Question](creating-surveys-time-of-day) | ![Next Meeting Question](creating-surveys-next-meeting) |
| ![Text Entry Question](creating-surveys-feeling-text-entry) | ![Mood Question](creating-surveys-slider) |
| ![Email Question](creating-surveys-email) | ![Location Question](creating-surveys-location) |

## 2. Create a survey task

Once you create one or more steps, create an ``ORKOrderedTask`` object to
contain the steps. The code below shows the steps created above being added to a task.

```swift
// Create a task wrapping the instruction and form steps created earlier.
let orderedTask = ORKOrderedTask(identifier: "OrderedTaskIdentifier", steps: [instructionStep, formStep])
```


You must assign a string identifier to each step. The step identifier must be unique within the task, because it's the key that connects a step in the task hierarchy with the step result in the result hierarchy.

To present the task, attach it to a task view controller and present
it. The code below shows how to create a task view controller and present it modally.
        
```swift
let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
taskViewController.delegate = self

present(taskViewController, animated: true)
```

## 3. Collect Results
The result property of the task view controller gives you the results of the task.
Each step view controller that the user views produces a step result
(``ORKStepResult``). The task view controller collates these results as
the user navigates through the task, in order to produce an
``ORKTaskResult``.

Both the task result and step result are collection results, in that
they can contain other result objects. For example, a task result contains an array of step results.

The results contained in a step result vary depending on the type of
step. For example, a form step produces one question result for
every form item; and an active task with recorders generally produces
one result for each recorder. 

The hierarchy of results corresponds closely to the input
model hierarchy of task and steps as you can see here:

![Results Hierarchy](creating-surveys-results-hierarchy)

Among other properties, every result has an identifier. This
identifier is what connects the result to the model object (task,
step, form item, or recorder) that produced it. Every result also
includes start and end times, using the startDate and endDate
properties respectively. Use these properties to infer how long the user
spent on the step.
 

#### Saving Results on Task Completion

After a task is completed, you can save or upload the results. This approach 
will likely include serializing the result hierarchy in some form,
either using the built-in `NSSecureCoding` support, or another
format appropriate for your application.

If your task can produce file output, the files are generally referenced by an ``ORKFileResult`` object and they are placed in the output directory that you set on the task view controller. After you complete a task, one implementation might be to serialize the result hierarchy into the output directory, compress the entire output
directory, and share it.

In the following example, the result is archived with
`NSKeyedArchiver` on successful completion. If you choose to support
saving and restoring tasks, the user may save the task. This
example also demonstrates how to obtain the restoration data that
would later be needed to restore the task.

```swift
 func taskViewController(_ taskViewController: ORKTaskViewController, 
                         didFinishWith reason: ORKTaskFinishReason, 
                         error: Error?) {
	switch reason {
	case .completed:
	    // Archive the result object first
	    do {
	        let data = try NSKeyedArchiver.archivedData(withRootObject: taskViewController.result, 
	                                                    requiringSecureCoding: true)
			 // Save the data to disk with file protection
	   	 	 // or upload to a remote server securely.
	    
	    	 // If any file results are expected, also zip up the outputDirectory.
	    } catch {
	        print("error archiving result data: \(error.localizedDescription)")
	    }
	    
	    break;
	case .failed, .discarded, .earlyTermination:
	    // Generally, discard the result.
	    // Consider clearing the contents of the output directory.
	    break;
	case .saved:
	    let data = taskViewController.restorationData
	    // Store the restoration data persistently for later use.
	    // Normally, keep the output directory for when you will restore.
	    break;
	}
	    
	taskViewController.dismiss(animated: true, completion: nil)
}
```
