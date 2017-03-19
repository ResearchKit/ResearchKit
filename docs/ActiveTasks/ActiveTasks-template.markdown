# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Active Tasks

Active tasks invite users to perform activities under partially
controlled conditions while iPhone sensors are used to collect data.
For example, an active task for analyzing gait and balance might ask
the user to walk a short distance, while collecting accelerometer data on the device.

##Predefined Active Tasks

The ResearchKit™ framework includes a number of predefined tasks, which fall into six categories: motor activities, fitness, cognition, voice, audio, and hole peg. The table below summarizes each task and describes the data it generates.

<table>
<caption>Active tasks in ResearchKit</caption>
<thead>
    <tr>
        <td>Category</td>
        <td>Task</td>
        <td>Sensor</td>
        <td>Data collected</td>
    </tr>
</thead>
<tbody>
 <tr><td rowspan = 2>Motor activities</td> 
     <td>Gait and balance</td>
     <td>Accelerometer<br>
  Gyroscope</td> 
  <td>Device motion<br>Pedometer</td> 
 </tr>
<tr><td>Tapping speed</td> 
<td>Multi-Touch display <br>
Accelerometer (optional)
</td> 
  <td>Touch activity<br/>
  </td> 
</tr>
<tr><td rowspan = 2>Fitness</td>
 <td>Fitness</td>
 <td>GPS<br>Gyroscope</td>
<td>Device motion<br>Pedometer<br>Location<br>Heart rate
   </td> 
</tr>
<tr><td>Timed walk</td>
  <td>GPS<br>Gyroscope</td>
<td>Device motion<br>Pedometer<br>Location
   </td> 
</tr>
<tr><td rowspan = 4>Cognition</td>
<td>Spatial memory</td>
<td>Multi-Touch display <br>
Accelerometer (optional)</td>
<td>
Touch activity<br>Correct answer<br> Actual sequences
</td>
</tr>
<tr><td>Paced Serial Addition Test (PSAT)</td> 
<td>Multi-Touch display
</td> 
  <td>Addition results 
from user
  </td> 
</tr>
<tr><td>Tower of Hanoi</td> 
<td>Multi-Touch display
</td> 
  <td>Every move taken by the user
  </td> 
</tr>
<tr><td>Reaction time</td> 
<td>Accelerometer<br>Gyroscope
</td> 
  <td>Device motion 
  </td> 

</tr>
<tr><td>Voice</td>
<td>Sustained phonation</td>
    <td>Microphone</td>
    <td>Uncompressed audio</td>
</tr>
<tr><td>Audio</td>
 <td>Tone audiometry</td>
 <td>N/A</td>
<td>Minimum amplitude for the user 
to recognize the sound<br>
   </td> 
</tr>
<tr><td>Hole Peg</td>
 <td>Hand dexterity</td>
 <td>Multi-Touch display</td>
<td>Completion time<br>Move distance
   </td> 
</tr>
</tbody>
</table>

#### Options for Predefined Tasks

You can disable the instruction or completion steps that are automatically
included in the framework by passing an appropriate combination of the
`ORKPredefinedTaskOption` constants when you instantiate one of the predefined
active tasks.

Options flags can also be used to exclude certain types of data
collection if they are not needed for your study. For example, if you
want the user to perform the fitness task but do not need heart rate
data, use `ORKPredefinedTaskOptionExcludeHeartrate`.


#### Fitness

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
<p style="clear: both;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskWalkStep.png" style="width: 100%;border: solid black 1px; ">Displays distance and heart rate.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskRestStep.png" style="width: 100%;border: solid black 1px;">The rest step. This step is skipped if heart rate data is unavailable.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskCompletionStep.png" style="width: 100%;border: solid black 1px;">Confirms completion.</p>
<p style="clear: both;"></p>

All of the data is collected from public <a href="https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html">CoreMotion</a> and <a href="https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/">HealthKit</a> APIs on iOS, and serialized to JSON. No analysis is applied to the data by the ResearchKit framework.

#### Audio 

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
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskStep.png" alt="Task Screen" style="width: 100%;border: solid black 1px; ">Displays a graph during audio playback (Audio collection step).</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskCompletionStep.png"  alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Confirms completion.</p>
<p style="clear: both;"></p>

#### Gait and Balance

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
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep7.png" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

####  Tapping Speed

In the tapping task (see the method [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:options]([ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:options:])), the user rapidly alternates between tapping two
targets on the touch screen. The resulting touch data can be used to
assess basic motor capabilities such as speed, accuracy, and rhythm.

Touch data, and optionally accelerometer data from CoreMotion in iOS, are
collected using public APIs. No analysis is performed by the ResearchKit framework on the data.

The screenshots below show an example of a tapping speed task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Motivation for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep2.png" style="width: 100%;border: solid black 1px;">Providing instruction for the task.</p><p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep3.png" style="width: 100%;border: solid black 1px; ">The user rapidly taps on the targets.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep4.png" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

#### Spatial Memory

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
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep4.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

#### Paced Serial Addition Test (PSAT)

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
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep4.png" alt="The user must add each new digit on the screen to the one immediately prior to it." style="width: 100%;border: solid black 1px; ">The user must add each new digit on the screen to the one immediately prior to it.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="PsatTaskImages/PSATStep5.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>


#### Reaction Time 

In the reaction time task (see the method [ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:option]([ORKOrderedTask reactionTimeTaskWithIdentifier:intendedUseDescription:maximumStimulusInterval:minimumStimulusInterval:thresholdAcceleration:numberOfAttempts:timeout:successSound:timeoutSound:failureSound:options:])),
the user is asked to shake the device in response to a visual clue on the device's screen. The task is divided into a few attempts (you can decide the number of attempts). To complete an attempt in a task, the user must shake or move the device with an acceleration that is greater than the value of the `thresholdAcceleration` property within the given time. The task finishes when the user successfully completes all the attempts as instructed in the task. Use this task to evaluate a user's response to the stimulus and calculate their reaction time. 

Data collected by this task is in the form of `ORKReactionTimeResult` objects. Each of these objects contain a timestamp representing the delivery of the stimulus and an `ORKFileResult` object that references the motion data collected during an attempt. To present this task, use an `ORKTaskViewController` object. 

The screenshots below show an example of a reaction time task.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep3.png" alt="Actual task screen." style="width: 100%;border: solid black 1px; ">Actual task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ReactionTimeTaskImages/ReactionTimeStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

#### Tone Audiometry 

In the tone audiometry task (see the method [ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:]([ORKOrderedTask toneAudiometryTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:toneDuration:options:])),
users are asked to listen to a series of tones (using headphones connected to the device running the task) and to tap the button on the screen when they hear each tone. These tones are of different audio frequencies, playing on different channels (left and right), with the volume being progressively increased until the user taps the button. A tone audiometry task measures different properties of a user's hearing ability, based on their reaction to a wide range of frequencies.

Data collected in this task consists of audio signal amplitude for specific frequencies and channels. 
 
The screenshots below show an example of a tone audiometry task.
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep1.png" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep2.png" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep3.png" style="width: 100%;border: solid black 1px;">Preparing user for the task.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep4.png" style="width: 100%;border: solid black 1px; ">Count down a specified duration to begin the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep5.png" style="width: 100%;border: solid black 1px;">Actual task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ToneAudiometryTaskImages/ToneAudiometryTaskStep6.png" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

#### Tower Of Hanoi 

In the Tower of Hanoi task (see the method [ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:]([ORKOrderedTask towerOfHanoiTaskWithIdentifier:intendedUseDescription:numberOfDisks:options:])), the user is asked to solve the classic Tower of Hanoi puzzle in a minimum number of moves. To solve the puzzle, the user must move the entire stack to the highlighted platform in as few moves as possible. This task measures the user's problem solving skills. A Tower of Hanoi task finishes when the user completes the puzzle correctly or concedes that they cannot solve the puzzle.
 
Data collected by this task is in the form of an `ORKTowerOfHanoiResult` object. It contains every move taken by the user and indicates whether the puzzle was successfully completed or not.
 
The screenshots below show an example of a Tower of Hanoi task.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p>
<p style="clear: both;"></p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep3.png" alt="Actual task screen." style="width: 100%;border: solid black 1px; ">Actual task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TOHTaskImages/TOHStep4.png" alt="Task completion screen" style="width: 100%;border: solid black 1px;">Task completion.</p>
<p style="clear: both;"></p>

#### Timed Walk 

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

#### 9-Hole Peg Test

The 9-hole peg test is a two step test of hand dexterity to measure the <a href="http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/9-Hole-Peg-Test-(9-HPT)">MSFC score in Multiple Sclerosis</a>, <a href="http://www.rehabmeasures.org/Lists/RehabMeasures/DispForm.aspx?ID=925">Parkinson's disease, or stroke</a>. This task is well documented in the scientific literature (see <a href="http://www.ncbi.nlm.nih.gov/pubmed/22020457">Earhart et al., 2011</a>).

The data collected by this task includes the number of pegs, an array of move samples, and the total duration that the user spent taking the test.

Practically speaking, this task generates a two step test in which the participant must put a variable number of pegs in a hole (the place step), and then remove them (the remove step). This task tests both hands.

The `ORKHolePegTestPlaceStep` class represents the place step. In this step, the user uses two fingers to touch the peg and drag it into the hole using their left hand.

The `ORKHolePegTestRemoveStep` class represents the remove step. Here, the user moves the peg over a line using two fingers on their right hand.

The screenshots below show an example of both place and remove tasks.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegPlaceStep.png" style="width: 100%;border: solid black 1px; ">The peg place task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="HolePegTaskImages/HolePegRemoveStep.png"  style="width: 100%;border: solid black 1px;">The peg remove step.</p><p style="clear: both;"></p>

### Getting the Data

The data collected in active tasks is recorded in a hierarchy of
`ORKResult` objects in memory. It is up to you to serialize this
hierarchy for storage or transmission in a way that’s appropriate for your application.

If the data collected is too large for in-memory delivery, an
`ORKFileResult` object is included in the hierarchy instead. The file result
references a file in the output directory (specified by the
`outputDirectory` property of `ORKTaskViewController`). For example,
recorders that log at high sample rates, such as the accelerometer,
log directly to a file like this.

The recommended approach for handling file-based output is to create a
new directory per task and to remove it after you have processed the
results of the task.

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

## Creating New Active Tasks

You can also build your own custom active tasks by creating your own
custom subclasses of `ORKActiveStep` and
`ORKActiveStepViewController`. In doing this, you can follow the example of
the active steps in the predefined tasks that are already in the ResearchKit framework. (A helpful tutorial on creating active tasks <a href="http://blog.shazino.com/articles/dev/researchkit-new-active-task/">can be found here</a>).



Some of the steps used in the predefined tasks may also be useful as guides
when you create your own tasks. For example, the `ORKCountdownStep` displays a timer that counts
down with animation for the step duration. To give another example,
the `ORKCompletionStep` object displays a confirmation that the task
is completed.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep3.png" alt="Countdown step" style="width: 100%;border: solid black 1px; ">Example of a  countdown step.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep4.png" alt="Completion step" style="width: 100%;border: solid black 1px;">Example of a task completion step.</p>
<p style="clear: both;"></p>


