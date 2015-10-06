# ResearchKit Release Notes


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
 - `ORKPredicateStepNavigationRule` allows to make conditional jumps by matching previous results (either those of the the ongoing task, or those of any previously stored task result tree). You typically use the class methods in the `ORKResultPredicate` class to match answers in the most commonly used result types.
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
