# ResearchKit Release Notes

## ResearchKit 1.2 Release Notes

- **New Active Tasks**

  * **Tower of Hanoi Task**

    The *[Tower of Hanoi](https://en.wikipedia.org/wiki/Tower_of_Hanoi#Applications) task* is frequently used in psychological research on problem solving.

    It is a mathematical puzzle consisting of three rods and a number of disks of different sizes which can slide onto any rod. The puzzle starts with the disks in a stack in ascending order of size on one rod (the smallest at the top).

    The objective of the puzzle is to move the entire stack to another rod, obeying the following rules:

    1. Only one disk can be moved at a time.
    2. Each move consists of taking the upper disk from one of the stacks and placing it on top of another stack.
    3. No disk may be placed on top of a smaller disk.

  * **Paced Serial Addition Test (PSAT) Task**

    The *PSAT task* provides support for both the *Paced Auditory Serial Addition Test (PASAT)* and the *Paced Visual Serial Addition Test (PVSAT)* versions.

    The *[PASAT](https://en.wikipedia.org/wiki/Paced_Auditory_Serial_Addition_Test)* is a neuropsychological test used to assess capacity and rate of information processing and sustained and divided attention.

    This task is documented in the scientific literature ([[Fos et al., 2000]](http://www.ncbi.nlm.nih.gov/pubmed/11125707), [[Nagels et al., 2005]](http://www.ncbi.nlm.nih.gov/pubmed/15823678)) as a measure of the [*Multiple Sclerosis Functional Score*](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/Multiple-Sclerosis-Functional-Composite-(MSFC).

    It generates a series of single digits (for example, 60), at the specific frequency (for example, one new digit every 2 or 3 seconds). The user must add the newly presented digit to the one prior to it.

  * **Timed Walk Task**

    This task measures gait speed, in the form of the [Timed 25-Foot Walk](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/Timed-25-Foot-Walk-(T25-FW)) in the context of *multiple sclerosis*.

    Gait speed has been demonstrated to be a useful and reliable functional measure of walking ability. When administering the *Timed Walk Task*, patients are allowed to use assistive devices (canes, crutches, walkers).

- **Charts Module**

   A *Charts Module* has been implemented. It features three chart types: a *pie chart* (`ORKPieChartView`), a *line graph chart* (`ORKLineGraphChartView`), and a *discrete graph chart* (`ORKDiscreteGraphChartView`).

   The views in the *Charts Module* can be used independently of the rest of *ResearchKit*. It doesn't automatically connect with any other *ResearchKit* module: the developer has to supply the data to be displayed through the views' `dataSources`, which allows maximum flexibility.

- **General stability and performance improvements**.

## ResearchKit 1.1 Release Notes

- **Navigable Ordered Task**

  A new type of *conditional ordered task* (`ORKNavigableOrderedTask`) has been implemented.

  The developer can use the `ORKStepNavigationRule` subclasses to dynamically navigate between the task steps:
   - `ORKPredicateStepNavigationRule` allows to make conditional jumps by matching previous results (either those of the the ongoing task, or those of any previously stored task result tree). You typically use the class methods in the `ORKResultPredicate` class to match answers in the most commonly used result types.
   - `ORKDirectStepNavigationRule` provides support for unconditional jumps.

- **New Active Tasks**
  - **Reaction Time Task**

    The [*Simple Reaction Time (SRT)*](http://www.cambridgecognition.com/tests/simple-reaction-time-srt) is a test which measures simple reaction time through delivery of a known stimulus to a known location to elicit a known response.

    This test is deployed in a range of research questions across fields including medicine, sports science and psychology.

    Although it classically involves pressing the space bar or clicking a mouse in response to an event on screen, the *ResearchKit* implementation relies on the study participant shaking the device when she sees a blue circle on the screen, which we think is more correlatable to a true stimulus reaction test.

  - **Tone Audiometry Task**

    The [*Pure Tone Audiometry (PTA)*](https://en.wikipedia.org/wiki/Pure_tone_audiometry) test is a key hearing test used to identify hearing threshold levels of an individual, enabling determination of the degree, type and configuration of a hearing loss.

    The *ResearchKit* implementation generates a series of pure sinusoid sounds, with different frequencies and on different channels (left or right). The test starts at the minimum volume and is gradually increased until the participant perceives it and taps a button. At that time, the current sound amplitude, frequency and channel are recorded.

- **Vertical Slider Answer Format**

   Support for *continuous* and *vertical sliders* has been added. Some questions, like *mood measurements* or *symptom severity measurements* may be more naturally presented using a *vertical scale*.

- **Image Capture Step**

   An *Image Capture Step* has been added. The researcher can ask the participant to take pictures of relevant body parts. The researcher can provide a body part image template to facilitate the scale and orientation of the taken pictures.

- **iPhone landscape support and iPad support**

   *iPhone landscape orientation support* and *iPad (all orientations) support* have been implemented.

- **General stability and performance improvements**.
