# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Active Tasks

Active tasks invite users to perform activities under partially
controlled conditions while iPhone sensors are used to collect data.
For example, an active task for analyzing gait and balance might ask
the user to walk a short distance, while collecting accelerometer data on the device.

##Predefined Active Tasks

The ResearchKit™ framework includes a number of predefined tasks, which fall into six categories: motor activities, fitness, cognition, voice, audio, and hand dexterity. The table below summarizes each task and describes the data it generates.

<table>
<caption>Active Tasks in ResearchKit</caption>
<thead>
    <tr>
        <td>CATEGORY</td>
        <td>TASK</td>
        <td>SENSOR</td>
        <td>DATA COLLECTED</td>
    </tr>
</thead>
<tbody>
 <tr><td rowspan = 3>Motor Activities</td> 
      <td><a href="#range">Range of Motion</a></td>
     <td>Accelerometer<br>
  Gyroscope</td> 
  <td>Device motion<br></td> 
 </tr>
<td><a href="#gait">Gait and Balance</a></td>
     <td>Accelerometer<br>
  Gyroscope</td> 
  <td>Device motion<br>Pedometer</td> 
 </tr>
<tr><td><a href="#tapping">Tapping Speed</a></td> 
<td>Multi-Touch display <br>
Accelerometer (optional)
</td> 
  <td>Touch activity<br/>
  </td> 
</tr>
<tr><td rowspan = 2>Fitness</td>
 <td><a href="#fitness">Fitness</a></td>
 <td>GPS<br>Gyroscope</td>
<td>Device motion<br>Pedometer<br>Location<br>Heart rate
   </td> 
</tr>
<tr><td><a href="#timed">Timed Walk</a></td>
  <td>GPS<br>Gyroscope</td>
<td>Device motion<br>Pedometer<br>Location
   </td> 
</tr>
<tr><td rowspan = 6>Cognition</td>

<td><a href="#spatial">Spatial Memory</a></td>
<td>Multi-Touch display <br>
Accelerometer (optional)</td>
<td>
Touch activity<br>Correct answer<br> Actual sequences
</td>
</tr>

<tr><td><a href="#stroop">Stroop Test</a></td> 
<td>Multi-Touch display</td> 
  <td>Actual color<br>Actual text<br>User selection<br>Completion time </td> 
</tr>
<tr><td><a href="#trail">Trail Making Test</a></td> 
<td>Multi-Touch display</td> 
  <td>Completion time<br>Touch activity</td> 
</tr>

<tr><td><a href="#paced">Paced Serial Addition Test (PSAT)</a></td> 
<td>Multi-Touch display</td> 
  <td>Addition results from user</td> 
</tr>

<tr><td><a href="#tower">Tower of Hanoi</a></td> 
<td>Multi-Touch display
</td> 
  <td>Every move taken by the user
  </td> 
</tr>

<tr><td><a href="#reaction">Reaction Time</a></td> 
<td>Accelerometer<br>Gyroscope
</td> 
  <td>Device motion 
  </td> 

</tr>
<tr><td>Voice</td>
<td><a href="#sustained">Sustained Phonation</a></td>
    <td>Microphone</td>
    <td>Uncompressed audio</td>
</tr>
<tr><td>Audio</td>
 <td><a href="#tone">Tone Audiometry</a></td>
 <td>N/A</td>
<td>Minimum amplitude for the user 
to recognize the sound<br>
   </td> 
</tr>
<tr><td>Hand Dexterity</td>
 <td><a href="#nine">9-Hole Peg</td>
 <td>Multi-Touch display</td>
<td>Completion time<br>Move distance
   </td> 
</tr>
</tbody>
</table>

#### Options for Predefined Tasks

You can disable the instruction or completion steps that are automatically
included in the framework by passing appropriate options when you create an active task. See the
`ORKPredefinedTaskOption` constants for the available options.

You can use options flags to exclude data collection for data types that are not needed for your study. For example, to perform the fitness task without recording heart rate data, use the `ORKPredefinedTaskOptionExcludeHeartrate` option.

## Range of Motion Test<a name="range"></a>
In the range of motion test, participants follow movement instructions while accelerometer and gyroscope data is captured to measure flexed and extended positions for the shoulder or knee.The screenshots below show examples of range of motion tasks for knee and shoulder.

###Range of motion test for a knee
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_1.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_2.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_3.png" style="width: 100%;border: solid black 1px;">Specific instructions with an illustration.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_4.png" style="width: 100%;border: solid black 1px; ">Further instructions with an illustration.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_5.png" style="width: 100%;border: solid black 1px;">A touch anywhere step.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_6.png" style="width: 100%;border: solid black 1px;">A touch anywhere step with audible instructions.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/knee_7.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

###Range of motion test for a shoulder
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_1.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_2.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_3.png" style="width: 100%;border: solid black 1px;">Specific instructions with an illustration</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_4.png" style="width: 100%;border: solid black 1px; ">Further instructions with an illustration.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_5.png" style="width: 100%;border: solid black 1px;">A touch anywhere step.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_6.png" style="width: 100%;border: solid black 1px;">A touch anywhere step with audible instructions.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/shoulder_7.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Stroop Test<a name="stroop"></a>
In the Stroop test, the participant is shown a series of words that are displayed in color, and must select the first letter of the color's name. The screenshots below show an example of a Stroop test active task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_1.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_2.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_3.png" style="width: 100%;border: solid black 1px;">Further instructions.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_5.png" style="width: 100%;border: solid black 1px;">A typical Stroop test screen. The correct answer in this example is "B" for blue.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/stroop_6.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Trail Making Test<a name="trail"></a>
In the trail making test, the participant connects a series of labelled circles, in order. The time to complete the test is recorded. The circles can be labelled with sequential numbers (1, 2, 3,..) or with alternating numbers and letters  (1, a, 2, b, 3, c...). 
The screenshots below show an example of a trail making task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_1.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_2.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_3.png" style="width: 100%;border: solid black 1px;">Further instructions.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_5.png" style="width: 100%;border: solid black 1px;">The activity screen, shown mid-task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/trail_6.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>


## Fitness<a name="fitness"></a>

In the fitness task (see the method [ORKOrderedTask fitnessCheckTaskWithIdentifier:intendedUseDescription:walkDuration:restDuration:options]([ORKOrderedTask fitnessCheckTaskWithIdentifier:intendedUseDescription:walkDuration:restDuration:options:])), the user walks for a specified duration (usually
several minutes). Sensor data is collected and returned through the
task view controller's delegate. Sensor data can include
accelerometer, device motion, pedometer, location, and heart rate data
where available.

Toward the end of the walk, if heart rate data is available, the user
is asked to sit down and rest for a period. Data collection continues
during the rest period.

The screenshots below show how a fitness task might look.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/TaskIntroduction.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskIntroduction.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessCountDownStep.png" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task.</p>
<p style="clear: both;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskWalkStep.png" style="width: 100%;border: solid black 1px; ">Displays distance and heart rate.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskRestStep.png" style="width: 100%;border: solid black 1px;">The rest step. This step is skipped if heart rate data is unavailable.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskCompletionStep.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

All of the data is collected from public <a href="https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html">CoreMotion</a> and <a href="https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/">HealthKit</a> APIs on iOS, and serialized to JSON. No analysis is applied to the data by the ResearchKit framework.

## Audio<a name="audio"></a> 

In the audio task (see the method [ORKOrderedTask audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:options]([ORKOrderedTask audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:options:])), the user makes a sustained sound, and an audio
recording is made. Analysis of the audio data is not included in the
ResearchKit framework, but might naturally involve looking at the power spectrum
and how it relates to the ability to produce certain
sounds. The ResearchKit framework uses the <a href="https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVFoundationFramework/">AVFoundation framework</a> to collect this
data and to present volume indication during recording. No data
analysis is done by ResearchKit; you can define your analysis on this
task according to your own requirements.
The screenshots below show an example of an audio task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AboutTaskIntroduction.png" alt="Welcome Screen"  style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskIntroduction.png" alt="Instruction Screen" style="width: 100%;border: solid black 1px;">Instruction step describes user action during the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskCountdownStep.png" alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskStep.png" alt="Task Screen" style="width: 100%;border: solid black 1px; ">Displays a graph during audio playback (Audio collection step).</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskCompletionStep.png"  alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Gait and Balance<a name="gait"></a>

In the gait and balance task (see the method [ORKOrderedTask shortWalkTaskWithIdentifier:intendedUseDescription:numberOfStepsPerLeg:restDuration:options]([ORKOrderedTask shortWalkTaskWithIdentifier:intendedUseDescription:numberOfStepsPerLeg:restDuration:options:])),
the user walks for a short distance, which may be indoors. You might
use this semi-controlled task to collect objective measurements that
can be used to estimate stride length, smoothness, sway, and other
aspects of the participant's walking.

The screenshots below show an example of a gait and balance task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep2.png" style="width: 100%;border: solid black 1px;">Instruction step giving motivation and instruction for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep3.png" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task.</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep4.png" style="width: 100%;border: solid black 1px; ">Asking user to walk.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep5.png" style="width: 100%;border: solid black 1px;">Asking user to walk.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep6.png" style="width: 100%;border: solid black 1px;">Asking user to rest.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep7.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

##  Tapping Speed<a name="tapping"></a>

In the tapping task (see the method [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:options]([ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:options:])), the user rapidly alternates between tapping two
targets on the touch screen. The resulting touch data can be used to
assess basic motor capabilities such as speed, accuracy, and rhythm.

Touch data, and optionally accelerometer data from CoreMotion in iOS, are
collected using public APIs. No analysis is performed by the ResearchKit framework on the data.

The screenshots below show an example of a tapping speed task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Motivation for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep2.png" style="width: 100%;border: solid black 1px;">Providing instruction for the task.</p><p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep3.png" style="width: 100%;border: solid black 1px; ">The user rapidly taps on the targets.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep4.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Spatial Memory<a name="spatial"></a>

In the spatial memory task (see the method [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:intendedUseDescription:initialSpan:minimumSpan:maximumSpan:playSpeed:maxTests:maxConsecutiveFailures:customTargetImage:customTargetPluralName:requireReversal:options:]([ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:intendedUseDescription:initialSpan:minimumSpan:maximumSpan:playSpeed:maxTests:maxConsecutiveFailures:customTargetImage:customTargetPluralName:requireReversal:options:])),
the user is asked to observe and then recall pattern sequences of
increasing length in a game-like environment. The task collects data that
can be used to assess visuospatial memory and executive function.

The span (that is, the length of the pattern sequence) is automatically varied
during the task, increasing after successful completion of a sequence,
and decreasing after failures, in the range from `minimumSpan` to
`maximumSpan`. The `playSpeed` property lets you control the speed of sequence
playback, and the `customTargetImage` property lets you customize the shape of the
tap target. The game finishes when either `maxTests` tests have been
completed, or the user has made `maxConsecutiveFailures` errors in a
row.

The results collected are scores derived from the game, the details of
the game, and the touch inputs made by the user.

The screenshots below show an example of a spatial memory task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3.png" alt="Initial sequence playback screen" style="width: 100%;border: solid black 1px;">The flowers light up in sequence.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_1.png" alt="Recall sequence screen" style="width: 100%;border: solid black 1px; ">The user must recall the sequence.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_2.png" alt="Consecutive failure screen" style="width: 100%;border: solid black 1px;">If users make a mistake, they will be offered a new pattern.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_3.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px;">The user is offered a shorter sequence.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep4.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Paced Serial Addition Test (PSAT)<a name="paced"></a>

The Paced Serial Addition Test (PSAT) task (see method [ORKOrderedTask PSATTaskWithIdentifier:intendedUseDescription:presentationMode:interStimulusInterval:stimulusDuration:seriesLength:options]([ORKOrderedTask PSATTaskWithIdentifier:intendedUseDescription:presentationMode:interStimulusInterval:stimulusDuration:seriesLength:options:])) measures the cognitive function that assesses auditory and/or visual information processing speed, flexibility, and the calculation ability of the user.

Single digits are presented every 2 or 3 seconds and the user must add each new digit to the one immediately before.

There are three variations of this test:

1. PASAT: Paced Auditory Serial Addition Test - the device speaks the digit every 2 or 3 seconds.
2. PVSAT: Paced Visual Serial Addition Test - the device shows the digit on screen.
3. PAVSAT: Paced Auditory and Visual Serial Addition Test - the device speaks the digit and shows it onscreen every 2 to 3 seconds.
 
The score for the PSAT task is the total number correct answers out of the number of possible correct answers. Data collected by the task is in the form of an `ORKPSATResult` object. 

The screenshots below show an example of a PVSAT task. Note that the visual and auditory components of the task are optional. You can choose to include either of them or both.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep3.png" alt="Countdown screen" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep4.png" alt="The user must add each new digit on the screen to the one immediately prior to it." style="width: 100%;border: solid black 1px; ">The user must add each new digit on the screen to the one immediately prior to it.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep5.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>


## Reaction Time <a name="reaction"></a>

In the reaction time task, the user shakes the device in response to a visual clue on the device's screen. The task is divided into a number of attempts, which you determine. To complete an attempt in a task, the user must shake or move the device with an acceleration that exceeds a threshold value ( `thresholdAcceleration` property) within the given time. The task finishes when the user successfully completes all the attempts as instructed in the task. Use this task to evaluate a user's response to the stimulus and calculate their reaction time. (See the method [ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:option]([ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:options:])).

Data collected by this task is in the form of `ORKReactionTimeResult` objects. Each of these objects contain a timestamp representing the delivery of the stimulus and an `ORKFileResult` object that references the motion data collected during an attempt. To present this task, use an `ORKTaskViewController` object. 

The screenshots below show an example of a reaction time task.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep3.png" alt="Actual task screen." style="width: 100%;border: solid black 1px; ">Actual task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Tone Audiometry<a name="tone"></a>

In the tone audiometry task users listen through headphones to a series of tones, and tap left or right buttons on the screen when they hear each tone.  These tones are of different audio frequencies, playing on different channels (left and right), with the volume being progressively increased until the user taps one of the buttons. A tone audiometry task measures different properties of a user's hearing ability, based on their reaction to a wide range of frequencies. (See the method [ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:]([ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:]).)

Data collected in this task consists of audio signal amplitude for specific frequencies and channels for each ear. 
 
The screenshots below show an example of a tone audiometry task.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_1.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_2.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_3.png" style="width: 100%;border: solid black 1px;">Further instructions.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_5.png" style="width: 100%;border: solid black 1px;">The tone test screen with buttons for left and right ears.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ActiveTaskImages/tone_6.png" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Tower Of Hanoi <a name="tower"></a>

In the Tower of Hanoi task (see the method [ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:]([ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:])), the user is asked to solve the classic Tower of Hanoi puzzle in a minimum number of moves. To solve the puzzle, the user must move the entire stack to the highlighted platform in as few moves as possible. This task measures the user's problem solving skills. A Tower of Hanoi task finishes when the user completes the puzzle correctly or concedes that they cannot solve the puzzle.
 
Data collected by this task is in the form of an `ORKTowerOfHanoiResult` object. It contains every move taken by the user and indicates whether the puzzle was successfully completed or not.
 
The screenshots below show an example of a Tower of Hanoi task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep3.png" alt="Actual task screen." style="width: 100%;border: solid black 1px; ">Actual task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion.</p>
<p style="clear: both;"></p>

## Timed Walk<a name="timed"></a> 

In the timed walk task (see the method [ORKOrderedTask timedWalkTaskWithIdentifier:intendedUseDescription:distanceInMeters:timeLimit:options:]([ORKOrderedTask timedWalkTaskWithIdentifier:intendedUseDescription:distanceInMeters:timeLimit:options:])), the user is asked to walk for a specific distance quickly with safety. The task is immediately administered again by having the user walk the same distance in the opposite direction. The timed walk task differs from both the fitness and the short walk tasks in that the distance walked by the user is fixed. A timed walk task measures the user's lower-extremity function.
 
The data collected by this task includes accelerometer, device motion, pedometer data, and location of the user. Note that the location is available only if the user agrees to share their location.
Data collected by the task is in the form of an `ORKTimedWalkResult` object. 

The screenshots below show an example of a timed walk task.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep2.png" alt="Gather information about the user's assistive device." style="width: 100%;border: solid black 1px;">Gathers information about the user's assistive device.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep3.png" alt="Instruction to perform the task" style="width: 100%;border: solid black 1px; ">Instructions on how to perform the task.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep4.png" alt="Count down a specified duration to begin the task." style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep5.png" alt="Actual task screen" style="width: 100%;border: solid black 1px;">Actual task screen.</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep6.png" alt="Actual task screen" style="width: 100%;border: solid black 1px;">Actual task screen.</p>
<p style="clear: both;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep7.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

## 9-Hole Peg Test<a name="nine"></a>

The 9-hole peg test is a two step test of hand dexterity to measure the <a href="http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/9-Hole-Peg-Test-(9-HPT)">MSFC score in Multiple Sclerosis</a>, <a href="http://www.rehabmeasures.org/Lists/RehabMeasures/DispForm.aspx?ID=925">Parkinson's disease, or stroke</a>. This task is well documented in the scientific literature (see <a href="http://www.ncbi.nlm.nih.gov/pubmed/22020457">Earhart et al., 2011</a>).

The data collected by this task includes the number of pegs, an array of move samples, and the total duration that the user spent taking the test.

Practically speaking, this task generates a two step test in which the participant must put a variable number of pegs in a hole (the place step), and then remove them (the remove step). This task tests both hands.

The `ORKHolePegTestPlaceStep` class represents the place step. In this step, the user uses two fingers to touch the peg and drag it into the hole using their left hand.

The `ORKHolePegTestRemoveStep` class represents the remove step. Here, the user moves the peg over a line using two fingers on their right hand.

The screenshots below show an example of both place and remove tasks.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegPlaceStep.png" style="width: 100%;border: solid black 1px; ">The peg place task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegRemoveStep.png"  style="width: 100%;border: solid black 1px;">The peg remove step.</p><p style="clear: both;"></p>

## Getting the Data

The data collected in active tasks is recorded in a hierarchy of `ORKResult` objects in memory. It is up to you to serialize this hierarchy for storage or transmission in a way that’s appropriate for your application.

If the data collected is too large for in-memory delivery, an `ORKFileResult` object is included in the hierarchy instead. The file result
references a file in the output directory (specified by the `outputDirectory` property of `ORKTaskViewController`). For example,
recorders that log at high sample rates, such as the accelerometer, log directly to a file like this.

The recommended approach for handling file-based output is to create a new directory per task and to remove it after you have processed the results of the task.

Active steps support attaching recorder configurations
(`ORKRecorderConfiguration`). A recorder configuration defines a type of
data that should be collected for the duration of the step from a sensor or
a database on the device. For example:

* The pedometer sensor returns a `CMPedometerData` object that provides step counts computed by the motion coprocessor on supported devices.
* The accelerometer sensor returns a `CMAccelerometerData` object that provides raw accelerometer samples indicating the forces on the device.
* A `CMDeviceMotion` object provides information about the orientation and movement of the device by combining data collected from the accelerometer, gyroscope, and magnetometer.
* HealthKit returns sample types, such as heart rate.
* CoreLocation returns location data (combined from GPS, Wi-Fi and cell tower information).

The recorders used by ResearchKit's predefined active tasks always use
`NSFileProtectionCompleteUnlessOpen` while writing data to disk, and
then change the file protection level on any files generated to
`NSFileProtectionComplete` when recording is finished.

## Creating Custom Active Tasks

You can build your own custom active tasks by creating your own custom subclasses of `ORKActiveStep` and
`ORKActiveStepViewController`. Follow the example of active steps in ResearchKit's predefined tasks. (A helpful tutorial on creating active tasks <a href="http://blog.shazino.com/articles/dev/researchkit-new-active-task/">can be found here</a>).

Some steps used in the predefined tasks may be useful as guides for creating your own tasks. For example:
*  the `ORKCountdownStep` displays a timer that counts down with animation for the step duration
*  the `ORKCompletionStep` object displays a confirmation that the task is completed.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep3.png" alt="Countdown step" style="width: 100%;border: solid black 1px; ">Example of a  countdown step.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep4.png" alt="Completion step" style="width: 100%;border: solid black 1px;">Example of a task completion step.</p>
<p style="clear: both;"></p>


