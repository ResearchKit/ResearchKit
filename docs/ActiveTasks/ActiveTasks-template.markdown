# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Active Tasks

Active tasks invite users to perform activities under partially
controlled conditions while iPhone sensors are used to collect data.
For example, an active task for analyzing gait and balance might ask
the user to walk a short distance, while collecting accelerometer data on the device.

## Predefined Active Tasks

ResearchKit™ includes a number of predefined tasks, which fall into seven categories: motor activities, fitness, cognition, speech, hearing, hand dexterity, and vision. Table 1 summarizes each task and describes the data it generates.

<table>
<caption>Table 1. Active tasks in ResearchKit</caption>
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
<tr><td rowspan=3>Speech</td>
<td><a href="#sustained">Sustained Phonation</a></td>
    <td>Microphone</td>
    <td>Uncompressed audio</td>
</tr>

<tr><td><a href="#speech_recognition">Speech Recognition</a></td> 
<td>Microphone</td> 
<td>Raw audio recording<br>Transcription in the form of an SFTranscription object.<br>Edited transcript (if any, by the user)</td> 
</tr>

<tr><td><a href="#speech_in_noise">Speech-in-Noise</a></td> 
<td>Microphone</td> 
<td>Raw audio recording<br>Transcription in the form of an SFTranscription object<br>Edited transcript (if any, by the user). This can be used to calculate the Speech Reception Threshold (SRT) for a user.</td> 
</tr>

<tr><td rowspan=3>Hearing</td>

<td><a href="#tone">Environment SPL</a></td>
<td>Microphone</td>
<td>Environment sound pressure level in dBA</td> 
</tr>

<td><a href="#tone">Tone Audiometry</a></td>
<td>AirPods<br>
Headphones</td>
<td>Minimum amplitude for the user 
to recognize the sound</td> 
</tr>

<tr><td><a href="#dBHL">dBHL Tone Audiometry</a></td>
<td>AirPods<br>
Headphones</td>
<td>
Hearing threshold in dB HL scale<br>
User response timestamps
</td>
</tr>

<tr><td>Hand Dexterity</td>
 <td><a href="#nine">9-Hole Peg</td>
 <td>Multi-Touch display</td>
<td>Completion time<br>Move distance
   </td> 
</tr>

<tr><td>Vision</td>
<td><a href="#amsler">Amsler Grid</a></td> 
<td>Multi-Touch display</td> 
<td>Touch activity<br>Eye side<br>Areas of distortions as annotated by the user</td> 
</tr>

</tbody>
</table>

You can disable the instruction or completion steps that are automatically
included in the framework by passing appropriate options when you create an active task. See the
`ORKPredefinedTaskOption` constants for the available options.

You can use options flags to exclude data collection for data types that are not needed for your study. For example, to perform the fitness task without recording heart rate data, use the `ORKPredefinedTaskOptionExcludeHeartRate` option.
 
## Range of Motion<a name="range"></a>
In the range of motion task, participants follow movement instructions while accelerometer and gyroscope data is captured to measure flexed and extended positions for the knee or shoulder. Range of motion steps for the knee are shown in Figure 1.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep2.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep3.png" style="width: 100%;border: solid black 1px;">Specific instructions with an illustration</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep4.png" style="width: 100%;border: solid black 1px; ">Further instructions with an illustration</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep5.png" style="width: 100%;border: solid black 1px;">A touch anywhere step</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep6.png" style="width: 100%;border: solid black 1px;">A further touch anywhere step</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="KneeRangeOfMotionTaskImages/KneeRangeOfMotionStep7.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 1. Range of motion steps for the right knee</center></figcaption>

## Gait and Balance<a name="gait"></a>

In the gait and balance task (see the method [ORKOrderedTask shortWalkTaskWithIdentifier:intendedUseDescription:numberOfStepsPerLeg:restDuration:options]([ORKOrderedTask shortWalkTaskWithIdentifier:intendedUseDescription:numberOfStepsPerLeg:restDuration:options:])),
the user walks for a short distance, which may be indoors. You might
use this semi-controlled task to collect objective measurements that
can be used to estimate stride length, smoothness, sway, and other
aspects of the participant's walking.

Gait and balance steps are shown in Figure 2.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep2.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep3.png" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep4.png" style="width: 100%;border: solid black 1px; ">Asking user to walk</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep5.png" style="width: 100%;border: solid black 1px;">Asking user to walk</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep6.png" style="width: 100%;border: solid black 1px;">Asking user to rest</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep7.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 2. Gait and balance steps</center></figcaption>

## Tapping Speed<a name="tapping"></a>

In the tapping task (see the method [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:handOptions:options]([ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:handOptions:options:])), the user rapidly alternates between tapping two
targets on the touch screen. The resulting touch data can be used to
assess basic motor capabilities such as speed, accuracy, and rhythm.

Touch data, and optionally accelerometer data from CoreMotion in iOS, are
collected using public APIs. No analysis is performed by the ResearchKit framework on the data.

Tapping speed steps are shown in Figure 3.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep1.png" alt="Instruction step introducing the task" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep2.png" style="width: 100%;border: solid black 1px;">Providing instruction for the right hand task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep3.png" style="width: 100%;border: solid black 1px; ">The user rapidly taps on the targets using the right hand</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep4.png" style="width: 100%;border: solid black 1px;">Providing instruction for the left hand task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep5.png" style="width: 100%;border: solid black 1px;">The user rapidly taps on the targets using the left hand</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingStep6.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 3. Tapping speed steps</center></figcaption>

## Fitness<a name="fitness"></a>

In the fitness task (see the method [ORKOrderedTask fitnessCheckTaskWithIdentifier:intendedUseDescription:walkDuration:restDuration:options]([ORKOrderedTask fitnessCheckTaskWithIdentifier:intendedUseDescription:walkDuration:restDuration:options:])), the user walks for a specified duration (usually
several minutes). Sensor data is collected and returned through the
task view controller's delegate. Sensor data can include
accelerometer, device motion, pedometer, location, and heart rate data
where available.

Toward the end of the walk, if heart rate data is available, the user
is asked to sit down and rest for a period. Data collection continues
during the rest period.

Fitness steps are shown in Figure 4.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep2.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep3.png" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task</p>
<p style="clear: both;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep4.png" style="width: 100%;border: solid black 1px; ">Displays distance and heart rate</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep5.png" style="width: 100%;border: solid black 1px;">The rest step, which can be skipped if heart rate data is unavailable</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessTaskImages/FitnessStep6.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 4. Fitness task</center></figcaption>

All of the data is collected from public <a href="https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html">CoreMotion</a> and <a href="https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/">HealthKit</a> APIs on iOS, and serialized to JSON. No analysis is applied to the data by the ResearchKit framework.

## Timed Walk<a name="timed"></a> 

In the timed walk task (see the method [ORKOrderedTask timedWalkTaskWithIdentifier:intendedUseDescription:distanceInMeters:timeLimit:turnAroundLimit:includeAssistiveDeviceForm:options:]([ORKOrderedTask timedWalkTaskWithIdentifier:intendedUseDescription:distanceInMeters:timeLimit:turnAroundLimit:includeAssistiveDeviceForm:options:])), the user is asked to walk quickly and safely for a specific distance. The task is immediately administered again by having the user walk the same distance in the opposite direction. The timed walk task differs from both the fitness and the short walk tasks in that the distance walked by the user is fixed. A timed walk task measures the user's lower-extremity function.
 
The data collected by this task includes accelerometer, device motion, pedometer data, and location of the user. Note that the location is available only if the user agrees to share their location.
Data collected by the task is in the form of an `ORKTimedWalkResult` object. 

Timed walk steps are shown in Figure 5.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep2.png" alt="Gather information about the user's assistive device" style="width: 100%;border: solid black 1px;">Gathers information about the user's assistive device</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep3.png" alt="Instruction to perform the task" style="width: 100%;border: solid black 1px; ">Instructions on how to perform the task</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep4.png" alt="Count down a specified duration to begin the task" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep5.png" alt="Actual task screen" style="width: 100%;border: solid black 1px;">Actual task screen</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep6.png" alt="Instruct the user to turn around" style="width: 100%;border: solid black 1px;">Instruct the user to turn around</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep7.png" alt="Actual task screen" style="width: 100%;border: solid black 1px;">Actual task screen</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TimedWalkTaskImages/TimedWalkStep8.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 5. Timed walk steps</center></figcaption>

## Spatial Memory<a name="spatial"></a>

In the spatial memory task (see the method [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:intendedUseDescription:initialSpan:minimumSpan:maximumSpan:playSpeed:maximumTests:maximumConsecutiveFailures:customTargetImage:customTargetPluralName:requireReversal:options:]([ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:intendedUseDescription:initialSpan:minimumSpan:maximumSpan:playSpeed:maximumTests:maximumConsecutiveFailures:customTargetImage:customTargetPluralName:requireReversal:options:])),
the user is asked to observe and then recall pattern sequences of
increasing length in a game-like environment. The task collects data that
can be used to assess visuospatial memory and executive function.

The span (that is, the length of the pattern sequence) is automatically varied
during the task, increasing after successful completion of a sequence,
and decreasing after failures, in the range from `minimumSpan` to
`maximumSpan`. The `playSpeed` property lets you control the speed of sequence
playback, and the `customTargetImage` property lets you customize the shape of the tap target. The game finishes when either `maxTests` tests have been
completed, or the user has made `maxConsecutiveFailures` errors in a
row.

The results collected are scores derived from the game, the details of
the game, and the touch inputs made by the user.

Spatial memory test steps are shown in Figure 6.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep3.png" alt="Initial sequence playback screen" style="width: 100%;border: solid black 1px;">The flowers light up in sequence</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep4.png" alt="Recall sequence screen" style="width: 100%;border: solid black 1px; ">The user must recall the sequence</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep5.png" alt="Consecutive failure screen" style="width: 100%;border: solid black 1px;">If users make a mistake, they will be offered a new pattern</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep6.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px;">The user is offered a shorter sequence</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep7.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 6. Spatial memory steps</center></figcaption>

## Stroop Test<a name="stroop"></a>
In the Stroop test, the participant is shown a series of words that are displayed in color, and must select the first letter of the color's name. Stroop test steps are shown in Figure 7.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="StroopTaskImages/StroopStep1.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="StroopTaskImages/StroopStep2.png" style="width: 100%;border: solid black 1px;">Further instructions</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="StroopTaskImages/StroopStep3.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="StroopTaskImages/StroopStep4.png" style="width: 100%;border: solid black 1px;">A typical Stroop test; the correct answer is "B" for blue</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="StroopTaskImages/StroopStep5.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 7. Stroop test steps</center></figcaption>

## Trail Making Test<a name="trail"></a>
In the trail making test, the participant connects a series of labelled circles, in order. The time to complete the test is recorded. The circles can be labelled with sequential numbers (1, 2, 3, ...) or with alternating numbers and letters  (1, a, 2, b, 3, c, ...). 

Trail making test steps are shown in Figure 8.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep2.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep3.png" style="width: 100%;border: solid black 1px;">Further instructions</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep5.png" style="width: 100%;border: solid black 1px;">The activity screen, shown mid-task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="TrailMakingTaskImages/TrailMakingStep6.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 8. Trail making test steps</center></figcaption>

## Paced Serial Addition Test (PSAT)<a name="paced"></a>

The Paced Serial Addition Test (PSAT) task (see method [ORKOrderedTask PSATTaskWithIdentifier:intendedUseDescription:presentationMode:interStimulusInterval:stimulusDuration:seriesLength:options]([ORKOrderedTask PSATTaskWithIdentifier:intendedUseDescription:presentationMode:interStimulusInterval:stimulusDuration:seriesLength:options:])) measures the cognitive function that assesses auditory and/or visual information processing speed, flexibility, and the calculation ability of the user.

Single digits are presented every two or three seconds and the user must add each new digit to the one immediately before.

There are three variations of this test:

1. PASAT: Paced Auditory Serial Addition Test - the device speaks the digit every two or three seconds.
2. PVSAT: Paced Visual Serial Addition Test - the device shows the digit on screen.
3. PAVSAT: Paced Auditory and Visual Serial Addition Test - the device speaks the digit and shows it onscreen every two to three seconds.
 
The score for the PSAT task is the total number of correct answers out of the number of possible correct answers. Data collected by the task is in the form of an `ORKPSATResult` object. 

PVSAT steps are shown in Figure 9.

Note that the visual and auditory components of the task are optional. You can choose to include either of them or both.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep3.png" alt="Countdown screen" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep4.png" alt="The user must add each new digit on the screen to the one immediately prior to it" style="width: 100%;border: solid black 1px; ">The user must add each new digit on the screen to the one immediately prior to it</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep5.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 9. PVSAT memory steps</center></figcaption>

## Tower of Hanoi <a name="tower"></a>

In the Tower of Hanoi task (see the method [ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:]([ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:])), the user is asked to solve the classic Tower of Hanoi puzzle in a minimum number of moves. To solve the puzzle, the user must move the entire stack to the highlighted platform in as few moves as possible. This task measures the user's problem solving skills. A Tower of Hanoi task finishes when the user completes the puzzle correctly or concedes that they cannot solve the puzzle.
 
Data collected by this task is in the form of an `ORKTowerOfHanoiResult` object. It contains every move taken by the user and indicates whether the puzzle was successfully completed or not.
 
Tower of Hanoi steps are shown in Figure 10.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep3.png" alt="Actual task screen" style="width: 100%;border: solid black 1px; ">Actual task</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 10. Tower of Hanoi steps</center></figcaption>

## Reaction Time <a name="reaction"></a>

In the reaction time task, the user shakes the device in response to a visual clue on the device's screen. The task is divided into a number of attempts, which you determine. To complete an attempt in a task, the user must shake or move the device with an acceleration that exceeds a threshold value ( `thresholdAcceleration` property) within the given time. The task finishes when the user successfully completes all the attempts as instructed in the task. Use this task to evaluate a user's response to the stimulus and calculate their reaction time. (See the method [ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:option]([ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:options:])).

Data collected by this task is in the form of `ORKReactionTimeResult` objects. Each of these objects contain a timestamp representing the delivery of the stimulus and an `ORKFileResult` object that references the motion data collected during an attempt. To present this task, use an `ORKTaskViewController` object. 

Reaction time steps are shown in Figure 11.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep3.png" alt="Actual task screen" style="width: 100%;border: solid black 1px; ">Actual task</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 11. Reaction time steps</center></figcaption>

## Sustained Phonation<a name="sustained"></a> 

In the sustained phonation task (see the method [ORKOrderedTask audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:checkAudioLevel:options]([ORKOrderedTask audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:checkAudioLevel:options:])), the user makes a sustained sound, and an audio
recording is made. Analysis of the audio data is not included in the
ResearchKit framework, but might naturally involve looking at the power spectrum
and how it relates to the ability to produce certain
sounds. The ResearchKit framework uses the <a href="https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVFoundationFramework/">AVFoundation framework</a> to collect this
data and to present volume indication during recording. No data
analysis is done by ResearchKit; you can define your analysis on this
task according to your own requirements.
Audio steps are shown in Figure 12.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioTaskImages/AudioStep1.png" alt="Welcome Screen"  style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioTaskImages/AudioStep2.png" alt="Instruction Screen" style="width: 100%;border: solid black 1px;">Instruction step describes user action during the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AudioTaskImages/AudioStep3.png" alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioTaskImages/AudioStep4.png" alt="Task Screen" style="width: 100%;border: solid black 1px; ">Displays a graph during audio playback (audio collection step)</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioTaskImages/AudioStep5.png"  alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 12. Audio steps</center></figcaption>

## Speech Recognition<a name="speech_recognition"></a>

Researchers and developers can use ResearchKit to record audio data and produce transcriptions generated by Apple’s speech recognition system. ResearchKit also provides word alignments, confidence scores, and alternative speech recognition hypotheses in the form of an n-best list. Medical researchers and developers can leverage this information to analyze speech and language features like speaking rate, word usage, and pause durations.

The n-best list and the confidence measure detect uncertainty in the speech recognition system's hypothesis in certain cases of unintelligible speech or speech containing word fragments or meaningless words. These conditions are found to be a useful indicator of cognitive decline associated with Alzheimer's disease and related dementias (1, 2), as well as other mental health issues (3). Additionally, researchers and developers can use the raw audio data captured through ResearchKit to investigate and deploy speech indicators for research and system design.

The `ORKSpeechRecognitionStep` class represents a single recording step. In this step, the user's speech is recorded from the microphone.

Speech recognition steps showing capturing and displaying recorded text are in Figure 13.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep1.png" alt="Instruction step introducing the task" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep2.png" alt="Instruct the user to prepare for recording" style="width: 100%;border: solid black 1px;">Instruct the user to prepare for recording</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep3.png" alt="Prompts the user to start the recording" style="width: 100%;border: solid black 1px; ">Prompts the user to start the recording</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep4.png" alt="Records the user's speech" style="width: 100%;border: solid black 1px;">Records the user's speech</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep5.png" alt="Provides the transcription and allows editing" style="width: 100%;border: solid black 1px;">Provides the transcription and allows editing</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechRecognitionImages/SpeechRecognitionStep6.png" alt="Task completion" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 13. Speech recognition steps</center></figcaption>

Once a user completes the recording, they are given the option to edit the transcript generated by the speech recognition engine. The data collected by this task consists of three main components:
<ol>
<li>The raw audio recording of what the user said.</li>
<li>The transcriptino generated by the speech recognition engine returned as an object of type `SFTranscript`.</li>
<li>The edited transcript, if any, by the user.</li>
</ol>

## Speech-in-Noise<a name="speech_in_noise"></a>


Understanding speech in noisy environments depends on both the level of the background noise and the hearing health of the listener. A speech-in-noise test quantifies the difficulty of understanding speech in noisy environments.
 
A speech-in-noise test consists of presenting spoken sentences at different noise levels and asking listeners to repeat what they heard. Based on the sentence and word recognition rate, a metric is calculated. The speech intelligibility metric used in this test is the Speech Reception Threshold (SRT). It represents the SNR at which 50% of the words are correctly repeated by the user. The SRT is calculated using the Tillman-Olsen formula (4).

The `ORKSpeechInNoiseStep` class plays the speech from a file set by the `speechFileNameWithExtension` property mixed with noise from a file set by the `noiseFileNameWithExtension` property. The noise gain is set through the `gainAppliedToNoise` property. Use the `filterFileNameWithExtension` property to specify a ramp-up/ramp-down filter.

Speech-in-noise steps are shown in Figure 14.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep1.png" alt="Instruction step introducing the task" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep2.png" alt="Instructs the user how to proceed with the task" style="width: 100%;border: solid black 1px;">Instructs the user how to proceed with the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep3.png" alt="Prompts the user to play the spoken sentence" style="width: 100%;border: solid black 1px; ">Prompts the user to play the spoken sentence</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep4.png" alt="Plays the spoken sentence with background noise" style="width: 100%;border: solid black 1px;">Plays the spoken sentence with background noise</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep5.png" alt="Prompts the user to record and repeat what they heard" style="width: 100%;border: solid black 1px;">Prompts the user to record and repeat what they heard</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep6.png" alt="Records the user's voice" style="width: 100%;border: solid black 1px;">Records the user's voice</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep7.png" alt="Task completion" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpeechInNoiseImages/SpeechInNoiseStep8.png" alt="Displays spoken text and provides transcript editing" style="width: 100%;border: solid black 1px;">Displays spoken text and provides transcript editing</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 14. Speech-in-noise steps</center></figcaption>

## Environment SPL Meter<a name="spl"></a>

The Environment SPL Meter is not a task, but a single step that detects the sound pressure level in the user's environment. Configure this step with the following properties:

* `thresholdValue` is the maximum permissible value for the environment sound pressure level in dBA.
* `samplingInterval` is the rate at which the `AVAudioPCMBuffer` is queried and A-weighted filter is applied.
* `requiredContiguousSamples` is the number of consecutive samples less than threshold value required for the step to proceed.

The environment SPL meter step is shown in Figure 15.

<center>
<img src="EnvironmentSPLImages/EnvironmentSPL.png" width="25%" style="border: solid black 1px;"  align="middle"/>
<figcaption><center>Figure 15. Environment SPL meter</center></figcaption>
</center>

## Tone Audiometry<a name="tone"></a>

In the tone audiometry task users listen through headphones to a series of tones, and tap left or right buttons on the screen when they hear each tone.  These tones are of different audio frequencies, playing on different channels (left and right), with the volume being progressively increased until the user taps one of the buttons. A tone audiometry task measures different properties of a user's hearing ability, based on their reaction to a wide range of frequencies. (See the method [ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:]([ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:])).

Data collected in this task consists of audio signal amplitude for specific frequencies and channels for each ear. 
 
Tone audiometry steps are shown in Figure 16.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep2.png" style="width: 100%;border: solid black 1px;">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep3.png" style="width: 100%;border: solid black 1px;">Further instructions</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep5.png" style="width: 100%;border: solid black 1px;">The tone test screen with buttons for left and right ears</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryStep6.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 16. Tone audiometry steps</center></figcaption>

## dBHL Tone Audiometry<a name="dBHL"></a>

The dBHL tone audiometry task implements the Hughson-Westlake method of determining hearing threshold. It is similar to the tone audiometry task, except that it utilizes a dB HL scale. (See the method [ORKOrderedTask dBHLToneAudiometryTaskWithIdentifier:intendedUseDescription:options:]([ORKOrderedTask dBHLToneAudiometryTaskWithIdentifier:intendedUseDescription:options:])).

Data collected in this task consists of audio signal amplitude for specific frequencies and channels for each ear. 

dBHL tone audiometry steps are shown in Figure 17.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep2.png" style="width: 100%;border: solid black 1px;">Instruction step allowing the user to select an ear</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep3.png" style="width: 100%;border: solid black 1px;">Further instructions</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the activity</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep5.png" style="width: 100%;border: solid black 1px;">The tone test screen with buttons for the left ear</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep6.png" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the activity</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep7.png" style="width: 100%;border: solid black 1px;">The tone test screen with buttons for the right ear</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="dBHLToneAudiometryTaskImages/dBHLToneAudiometryStep8.png" style="width: 100%;border: solid black 1px;">Confirms task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 17. dBHL tone audiometry steps</center></figcaption>

## 9-Hole Peg Test<a name="nine"></a>

The 9-hole peg test is a two-step test of hand dexterity to measure the <a href="http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/9-Hole-Peg-Test-(9-HPT)">MSFC score in Multiple Sclerosis</a>, or signs of <a href="http://www.rehabmeasures.org/Lists/RehabMeasures/DispForm.aspx?ID=925">Parkinson's disease or stroke</a>. This task is well documented in the scientific literature (see <a href="http://www.ncbi.nlm.nih.gov/pubmed/22020457">Earhart et al., 2011</a>).

The data collected by this task includes the number of pegs, an array of move samples, and the total duration that the user spent taking the test. Practically speaking, this task generates a two-step test in which the participant must put a variable number of pegs in a hole (the place step), and then remove them (the remove step). This task tests both hands.

The `ORKHolePegTestPlaceStep` class represents the place step. In this step, the user uses two fingers to touch the peg and drag it into the hole using their left hand. The `ORKHolePegTestRemoveStep` class represents the remove step. Here, the user moves the peg over a line using two fingers on their right hand.

9-Hole peg test steps are shown in Figure 18.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep1.png" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep2.png"  style="width: 100%;border: solid black 1px;">Describes what the user must do</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep3.png"  style="width: 100%;border: solid black 1px;">Instructs the user to perform the step with the right hand</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep4.png" style="width: 100%;border: solid black 1px; ">Instructs the user to perform the step with the right hand</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep5.png"  style="width: 100%;border: solid black 1px;">Instructs the user to perform the step with the right hand</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep6.png"  style="width: 100%;border: solid black 1px;">Instructs the user to perform the step with the left hand</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegStep7.png"  style="width: 100%;border: solid black 1px;">Task completion</p><p style="clear: both;"></p>
<p style="clear: both;"></p>
<figcaption><center>Figure 18. 9-hole peg test steps</center></figcaption>


## Amsler Grid<a name="amsler"></a>

The Amsler Grid task is a tool used to detect the onset of vision problems such as macular degeneration.

The `ORKAmslerGridStep` class represents a single measurement step. In this step, the user observes the grid while closing one eye for any anomalies and marks the areas that appear distorted, using their finger or a stylus.

Data collected by this task is in the form of an `ORKAmslerGridResult` object for the eye. It contains the eye side (specified by `ORKAmslerGridEyeSide`) and the image of the grid, along with the user's annotations for the corresponding eye.

Amsler grid steps for the left and right eyes are shown in Figure 19.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep1.png" alt="Instruction step introducing the task" style="width: 100%;border: solid black 1px; ">Instruction step introducing the task</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep2.png" alt="Instruct the user how to measure the left eye" style="width: 100%;border: solid black 1px;">Instruct the user how to measure the left eye</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep3.png" alt="Perform the left eye test" style="width: 100%;border: solid black 1px; ">Perform the left eye test</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep4.png" alt="Instruct the user how to measure the right eye" style="width: 100%;border: solid black 1px;">Instruct the user how to measure the right eye</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep5.png" alt="Perform the right eye test" style="width: 100%;border: solid black 1px;">Perform the right eye test</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AmslerGridImages/AmslerGridStep6.png" alt="Task completion" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 19. Amsler grid steps</center></figcaption>

## Collect the Data

The data collected in active tasks is recorded in a hierarchy of `ORKResult` objects in memory. It is up to you to serialize this hierarchy for storage or transmission in a way that’s appropriate for your application.

For high sample rate data, such as from the accelerometer, use the `ORKFileResult` in the hierarchy. This object references a file in the output directory (specified by the `outputDirectory` property of `ORKTaskViewController`) where the data is logged.

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

### Access Health Data

For HealthKit related data, there are two recorder configurations:

* `ORKHealthQuantityTypeRecorderConfiguration` to access quantity data such as heart rate.
* `ORKHealthClinicalTypeRecorderConfiguration` to access health records data. 

Access to health quanity and records data requires explicit permission that the user must grant explicitly. More information about accessing health record data <a href="https://developer.apple.com/documentation/healthkit/health_and_fitness_samples/accessing_health_records?language=objc">can be found here</a>.

## Create Custom Active Tasks

You can build your own custom active tasks by creating custom subclasses of `ORKActiveStep` and
`ORKActiveStepViewController`. Follow the example of active steps in ResearchKit's predefined tasks. (A helpful tutorial on creating active tasks <a href="http://blog.shazino.com/articles/dev/researchkit-new-active-task/">can be found here</a>).

Some steps used in the predefined tasks may be useful as guides for creating your own tasks. For example:

*  `ORKCountdownStep` displays a timer that counts down with animation for the step duration.
*  `ORKCompletionStep` displays a confirmation that the task is completed.

Figure 20 shows examples of custom tasks.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkStep3.png" alt="Countdown step" style="width: 100%;border: solid black 1px; ">Countdown step</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialSpanMemoryStep7.png" alt="Task completion step" style="width: 100%;border: solid black 1px;">Task completion step</p>
<p style="clear: both;"></p>
<figcaption><center>Figure 20. Custom task examples</center></figcaption>

--
### References

1. [Yancheva et. al., 2015] M. Yancheva, K. C. Fraser and F. Rudzicz, “Using linguistic features longitudinally to predict clinical scores for Alzheimer's disease and related dementias,” Proceedings of SLPAT 2015: 6th Workshop on Speech and Language Processing for Assistive Technologies, 2015.

2. [Konig et al., 2015] A. König, A. Satt, A. Sorin, R. Hoory, O. Toledo-Ronen, A. Derreumaux, V. Manera, F. Verhey, P. Aalten, P. H. Robert, and R. David. “Automatic speech analysis for the assessment of patients with predementia and Alzheimer's disease,” Alzheimers Dement (Amst). 2015 Mar; 1(1): 112–124. 

3. [Gong and Poellabauer’ 17] Y. Gong and C. Poellabauer, “Topic Modeling Based Multi-modal Depression Detection,” AVEC@ACM Multimedia, 2017.

4. [T.W. Tillman and W.O. Olsen] "Speech audiometry, Modern Development in Audiology (2nd Edition)," 1972. 
