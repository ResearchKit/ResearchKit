# ResearchKit Release Notes

## ResearchKit 2.0 Release Notes

*ResearchKit 2.0* supports *iOS* and requires *Xcode 9.0* or newer. 
The minimum supported *Base SDK* is *11.0*.

*ResearchKit 2.0* is a beta release with updates and support for documentation, localization, accessibility and QA coming over the next few months ahead of our stable release.

In addition to general stability and performance improvements, *ResearchKit 2.0* includes the following new features and enhancements.

### Community Updates
 
- **Repo Privileges**
We have opened up our access rights and have expanded our GitHub privileges to some of the external members of our community.  This gives these community members direct write access to the ResearchKit repository and merge pull requests.
 
- **Schedule Changes**
Previously the ResearchKit framework pushed to our master and stable branches simultaneously.  With this release we want to allow for more participation from the community so to accomplish this, we will push to the stable branch some time after our initial push to master.  This will enable the community to check out the new features, provide suggestions and submit pull requests.  During this time between master and stable, we will complete accessibility, localization and QA sweeps of the code so if you make contributions during this time, they will be reflected in the official stable release branch to follow.

### UI Updates

- **iOS Look and Feel**
We have updated ResearchKit to support the look and feel of *iOS 11*.  Updates across all of our modules include bold titles and fonts as well as left alignment for all text.

- **Footers and Buttons**
The step footers and buttons have been updated across all our modules to enable a better and more intuitive user experience as participants navigate through your apps.  Footers are now sticky to the bottom of all views and support new filled button styles.  The cancel button has also been relocated to the under the continue button and these updates are able to handle ‘cancel’ and ‘skip’ buttons simultaneously.  Progress indicators have also been aligned to the top right to allow for the new scrolling title implementation. 

- **Card View**
This new view enhances the look and feel of surveys and forms.  These updates improve the user experience for participants completing forms and surveys by more clearly segmenting the various steps and questions a user is asked to complete.

- **PDF Viewer**
This steps allows users to easily navigate, annotate, search and share any PDF.

### Active Tasks

- **Speech Recognition**
The speech recognition task lets developers present participants with either an image for users to describe or a block of text for users to repeat.  The participant will press record while they follow the prompt and when they have completed recording, a transcription will appear for them to edit if they feel anything was transcribed incorrectly.  The task will generate results that include an audio recording of what the participant said, a transcription of the output from the speech to text engine and the transcription which is editable by the participant if they made any changes to the output.

- **Environment SPL Meter**
This task measures the current noise in the participant’s environment. The task can be incorporated as a step into any hearing test or module and used as a gating step to ensure that the participant is in a suitable environment to complete their assessments. 

- **Tone Audiometry**
The tone audiometry task has been enhanced to include an updated algorithm and implementation to better evaluate a user’s hearing.  Tones will decrease in dBHL until a user’s failed attempt and then again increasing until a successful attempt.  This tasks also utilizes a variety of different calibrations, metrics and tables which are calibrated for AirPods only.  This allows developers to now collect the hearing threshold level of participants who complete this test.

- **Speech in Noise**
The Speech in Noise test is another task that can be used to measure the hearing health of users.  During this test, users will listen to a recording which includes ambient noises in the background as well as a phrase.  The participant will be asked to repeat back the phrase using the Speech Recognition task.  Throughout the task, the ambient background noise will increase or decrease in levels, allowing developers to measure the Speech Reception Threshold (SRT) of a user.  Stay tuned as more audio files will be added to the repository over the coming months!

- **Amsler Grid**
The Amsler Grid test is a task that can be used to collect data about a users vision.  During this task participants will hold the phone at a certain distance from their face and close one eye or the other as instructed.  A grid is displayed for users to view and if they see any distortions such as wavy or blurred lines, they can mark those areas on the grid using their finger or a stylus to annotate.

### New Sample App

- **Parkinson's Research Sample App**
This sample app demonstrates how to leverage the new Movement Disorder API which is available within the CoreMotion framework. 


### Please Note

*ResearchKit 2.0* is a beta release.  We will be updating our master branch at regular intervals in the coming months to address various issues and expand support for localization and accessibility.


## ResearchKit 1.5 Release Notes

*ResearchKit 1.5* supports *iOS* and requires *Xcode 8.0* or newer. The minimum supported *Base SDK* is *8.0*.

In addition to general stabiltiy and performance improvements, *ResearchKit 1.5* includes the following new features and enhancements.

- **New Active Tasks**

 - **Stroop Test**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Stroop Test* shows the participant different combinations of text and tint colors on the screen.
    
    Users must ignore the text and instead select the button that reflects the first letter of the tint color.

 - **Trail Making Test**

    *Contributed by Faraz Hussain.*

    The *Trail Making Test* instructs participants to connect a series of labelled circles and the time to complete the test is recorded.

 - **Range of Motion Test**

    *Contributed by Daren Levy, Dr. Raj Karia, John Guydo.*

    Participants are instructed to follow a series of steps while accelerometer and gyroscope data is captured to measure flexed and extended positions for both the shoulder and knee.
    
 - **Touch Anywhere Active Task**

    *Contributed by Daren Levy, Dr. Raj Karia, John Guydo*

    Allows the user to get their device in the proper position and then tap the screen to indicate they are ready to  begin the next step.
    
- **New Steps**

 - **Video Instruction Step**

    *Contributed by [Oliver Schäfer](https://github.com/oliverschaefer).*

    The *Video Instruction Step* provides a step to be used to display a video.

    This step can be used to display videos to users from either a local or remote source.

- **Other Improvements**
 
 - **Tone Audiometry Test**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    Updated to include both a left and right button.

 - **Digital Object Identifier**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    Assigns a Digital Object Identifier to the ResearchKit repository on GitHub to use when referencing the framework.


## ResearchKit 1.4 Release Notes

*ResearchKit 1.4* supports *iOS* and requires *Xcode 8.0* or newer. The minimum supported *Base SDK* is *8.0*.

In addition to general stabiltiy and performance improvements, *ResearchKit 1.4* includes the following new features and enhancements.

- **New Active Task**

 - **Hand Tremor Task**

    *Contributed by [Shannon Young](https://github.com/syoung-smallwisdom).*

    The *Hand Tremor Task* asks the participant to hold the device with their most affected hand in various positions while accelerometer and motion data is captured.

 - **Walk Back and Forth Task**

    *Contributed by [Shannon Young](https://github.com/syoung-smallwisdom).*

    The *Walk Back and Forth Task* addresses the concern of researchers/participants who have difficulty locating an unobstructed path for 20 steps.

    Instructs users to walk and turn in a full circle, allowing the tests to be conducted in a smaller space.

- **New Steps**

 - **Video Capture Step**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Video Capture Step* provides a step to be used to record video.

    The step can be used as part of a survey to capture video respones as well.

 - **Review Step**
    
    *Contributed by [Oliver Schäfer](https://github.com/oliverschaefer).*

    The *Review Step* allows a participant to review and modify their answers to a survey.

    The step can be used in the middle of a survey, at the end of a survey, or a standalone module.

 - **Signature Step**

    *Contributed by [Oliver Schäfer](https://github.com/oliverschaefer).*

    The *Signature Step* provides an interface for a participant to sign their name.

    The step can be used for handwriting detection or simply to sign a document.

 - **Table Step**

    *Contributed by [Shannon Young](https://github.com/syoung-smallwisdom).*

    The *Table Step* provides a way to neatly display data in a table.

- **Other Improvements**
 
 - **Data Collection Module**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Data Collection Module* makes it even easier to aggregate data from HealthKit and device sensors.

 - **Tapping Test**

    *Contributed by [Michał Zaborowski](https://github.com/m1entus).*

    The *Tapping Test* is updated to include tap duration as part of the result.


## ResearchKit 1.3 Release Notes

*ResearchKit 1.3* supports *iOS* and requires *Xcode 7.2* or newer. The minimum supported *Base SDK* is *8.0*.

In addition to general stability and performance improvements, *ResearchKit 1.3* includes the following new features and enhancements.

- **New Active Task**

 - **9-Hole Peg Test**

    *Contributed by [Julien Therier](https://github.com/julientherier).*

    The *9-Hole Peg Test task* is used to test upper extremity functionality.

    The test involves putting a variable number of pegs in a hole and subsequently removing them.

    The test is documented in the scientific literature to measure the *[MSFC score in Multiple Sclerosis](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/9-Hole-Peg-Test-(9-HPT))* or *[Parkinson's Disease](http://www.ncbi.nlm.nih.gov/pubmed/22020457)*.

- **Sample App**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Sample App* (`ORKSample` project on *ResearchKit*'s workspace) serves as a template application that combines different modules from the *ResearchKit framework*.

- **Account Module**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Account Module* provides steps to facilitate account creation and login.

    The module includes the following steps:

    1. *Registration*, used to allow the participant to create a new account.
    2. *Verification*, used to confirm if the participant has verified the provided email address.
    3. *Login*, used to allow registered users to login.

- **Passcode with Touch ID**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    The *Passcode with Touch ID module* provides the ability to secure any *ResearchKit* application with a numeric passcode.

    This module includes a *Keychain Wrapper* that stores the passcode on the device, as well as the option to use *Touch ID* on compatible devices. The passcode module supports 4-digit and 6-digit numeric codes.

    The passcode module provides the following components:

    1. *Passcode creation step*, which can be used as part of onboarding to create a passcode and store it in the keychain.
    2. *Passcode authentication view controller*, which can be modally presented when appropriate.
    3. *Passcode modification view controller*, which allows the participant to change their passcode.

- **Other Improvements**

 - **Optional Form Items**

    *Contributed by [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez).*

    Adds the `optional` property to `ORKFormItem`.

    The *Continue/Done* button of form steps is enabled when all of the following conditions are met:

    - At least one form item has an answer.
    - All the non-optional form items have answers.
    - All answered form items have valid answers.

 - **Location Question**

    *Contributed by [Quintiles](https://github.com/QuintilesRK).*

    A *Location Question* can be used to request details about the participant's current location or about a specific address.

    The question uses *MapKit* to provide a visual representation for the specified address.

 - **Wait Step**

    *Contributed by [Quintiles](https://github.com/QuintilesRK).*

    The *Wait Step* provides a step to be used in-between steps when additional data processing is required.

    The step supports both indeterminate and determinate progress views, as well as the ability to show text status updates.

 - **Validated Text Answer Format**

    *Contributed by [Quintiles](https://github.com/QuintilesRK).*

    The *Validated Text Answer Format* enhances the existing *Text Answer Format* by providing input validation using a regular expression.

    A valid *NSRegularExpression* object and an *error message* string are required to properly use this answer format.


## ResearchKit 1.2 Release Notes

*ResearchKit 1.2* supports *iOS* and requires *Xcode 7.0* or newer. The minimum supported *Base SDK* is *8.0*.

In addition to general stability and performance improvements, *ResearchKit 1.2* includes the following new features and enhancements.

- **New Active Tasks**

 - **Tower of Hanoi Task**

    *Contributed by [coxy1989](https://github.com/coxy1989).*

    The *[Tower of Hanoi](https://en.wikipedia.org/wiki/Tower_of_Hanoi#Applications) task* is frequently used in psychological research on problem solving.

    It is a mathematical puzzle consisting of three rods and a number of disks of different sizes which can slide onto any rod. The puzzle starts with the disks in a stack in ascending order of size on one rod (the smallest at the top).

    The objective of the puzzle is to move the entire stack to another rod, obeying the following rules:

    1. Only one disk can be moved at a time.
    2. Each move consists of taking the upper disk from one of the stacks and placing it on top of another stack.
    3. No disk may be placed on top of a smaller disk.

 - **Paced Serial Addition Test Task**

    *Contributed by [Julien Therier](https://github.com/julientherier).*

    The *Paced Serial Addition Test task* provides adaptations of both the *Paced Auditory Serial Addition Test (PASAT)* and the *Paced Visual Serial Addition Test (PVSAT)*.

    The *[PASAT](https://en.wikipedia.org/wiki/Paced_Auditory_Serial_Addition_Test)* is a neuropsychological test used to assess capacity and rate of information processing and sustained and divided attention.

    Both tests are documented in the scientific literature ([Fos et al., 2000](http://www.ncbi.nlm.nih.gov/pubmed/11125707); [Nagels et al., 2005](http://www.ncbi.nlm.nih.gov/pubmed/15823678)) as a measure of the [*Multiple Sclerosis Functional Score*](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/Multiple-Sclerosis-Functional-Composite-%28MSFC%29).

    This task generates a series of single digits (for example, 60 of them), at the specific frequency (for example, one new digit every 2 or 3 seconds). The user must add the newly presented digit to the one prior to it.

 - **Timed Walk Task**

    *Contributed by [Julien Therier](https://github.com/julientherier).*

    The *Timed Walk task* measures gait speed and is an adaptation of the [*Timed 25-Foot Walk*](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/Timed-25-Foot-Walk-%28T25-FW%29) in the context of *multiple sclerosis*.

    Gait speed has been demonstrated to be a useful and reliable functional measure of walking ability. When administering the *Timed Walk Task*, patients are allowed to use assistive devices (canes, crutches, walkers).

- **Charts Module**

 *Contributed by [coxy1989](https://github.com/coxy1989) and [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez).*

 A *Charts module* has been implemented. It features three chart types: a *pie chart* (`ORKPieChartView`), a *line graph chart* (`ORKLineGraphChartView`), and a *discrete graph chart* (`ORKDiscreteGraphChartView`).

 The views in the *Charts module* can be used independently of the rest of *ResearchKit*. It doesn't automatically connect with any other *ResearchKit* module: the developer has to supply the data to be displayed through the views' `dataSources`, which allows for maximum flexibility.

- **Other Improvements**

 - **Scale Answer Format**

    *Contributed by [Apple Inc](https://github.com/researchkit).*

    *Discrete scales* now support *text choice* labels, and all *scales* support images in place of the minimum and maximum range labels.

 - **Result Predicates**

    *Contributed by [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez).*

    The predicate-building methods in `ORKResultPredicate` now use the new `ORKResultSelector` class for unequivocally identifying a *question step result* or a *form item result*.

    This eliminates ambiguity when matching results with the same inner scope identifier. For example, a *form item result* can have the same identifier as a *question step result* or as another *form item result* in a different *form step*, and you can now match them separately.


## ResearchKit 1.1 Release Notes

*ResearchKit 1.1* supports *iOS* and requires *Xcode 6.3* or newer. The minimum supported *Base SDK* is *8.0*.

In addition to general stability and performance improvements, *ResearchKit 1.1* includes the following new features and enhancements.

- **Navigable Ordered Task**

 *Contributed by [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez).*

 A new type of *conditional ordered task* (`ORKNavigableOrderedTask`) has been implemented.

 The developer can use the `ORKStepNavigationRule` subclasses to dynamically navigate between the task steps:
 - `ORKPredicateStepNavigationRule` allows to make conditional jumps by matching previous results (either those of the ongoing task, or those of any previously stored task result tree). You typically use the class methods in the `ORKResultPredicate` class to match answers in the most commonly used result types.
 - `ORKDirectStepNavigationRule` provides support for unconditional jumps.

- **New Active Tasks**
 - **Reaction Time Task**

    *Contributed by [coxy1989](https://github.com/coxy1989).*

    The *Reaction Time Task* is an adaptation of the [*Simple Reaction Time test (SRT)*](http://www.cambridgecognition.com/tests/simple-reaction-time-srt). *SRT* measures reaction time through delivery of a known stimulus to a known location to elicit a known response.

    This test is deployed in a range of research questions across fields including medicine, sports science and psychology.

    Although it classically involves pressing the space bar or clicking a mouse in response to an event on screen, the *ResearchKit* implementation relies on the study participant shaking the device when she sees a blue circle on the screen, which we think is more correlatable to a true stimulus reaction test.

 - **Tone Audiometry Task**

    *Contributed by [Vincent Tourraine](https://github.com/vtourraine).*

    The *Tone Audiometry Task* is an adaptation of the [*Pure Tone Audiometry test (PTA)*](https://en.wikipedia.org/wiki/Pure_tone_audiometry). *PTA* is a key hearing test used to identify hearing threshold levels of an individual, enabling determination of the degree, type and configuration of a hearing loss.

    The *ResearchKit* implementation generates a series of pure sinusoid sounds, with different frequencies and on different channels (left or right). The test starts at the minimum volume and is gradually increased until the participant perceives it and taps a button. At that time, the current sound amplitude, frequency and channel are recorded.

- **Scale Answer Format Enhancements**

 *Contributed by [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez) and [Bruce Duncan](https://github.com/brucehappy).*

 Support for discrete and continuous *vertical scales* has been added. Some questions, like mood measurement or symptom severity measurement queries may be more naturally presented using a *vertical scale*.

 The *Scale Answer Format* has also been improved by making it usable within forms.

- **Image Capture Step**

 *Contributed by [Bruce Duncan](https://github.com/brucehappy).*

 An *Image Capture Step* has been added. The researcher can ask the participant to take pictures of relevant body parts. The researcher can provide a body part image template to facilitate the scale and orientation of the taken pictures.

- **iPad Support**

 *Contributed by [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez) and [Apple Inc](https://github.com/researchkit).*

 *iPad support* for all orientations has been implemented.

- **iPhone Landscape Support**

  *Contributed by [Apple Inc.](https://github.com/researchkit) and [Ricardo Sánchez-Sáez](https://github.com/rsanchezsaez).*

  *iPhone landscape orientation support* has been implemented.
