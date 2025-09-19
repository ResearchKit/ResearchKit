# Understanding Active Tasks

Learn more about the Active Tasks provided by ResearchKit™.

## Overview

Active tasks invite users to perform activities under partially
controlled conditions while iPhone sensors are used to collect data.
For example, an active task for analyzing gait and balance might ask
the user to walk a short distance, while collecting accelerometer data on the device.

## Predefined Active Tasks

ResearchKit includes a number of predefined tasks, which fall into seven categories: motor activities, fitness, cognition, speech, hearing, hand dexterity, and vision. The table below summarizes each task and describes the data it generates.

Category     | Task                         | Sensor                                        | Data Collected                          
-------------|------------------------------|-----------------------------------------------|---------------- 
Motor Skills | Range of Motion              | Accelerometer, Gyroscope                      | Device Motion
^            | Gait and Balance             | Accelerometer, Gyroscope                      | Device Motion, Pedometer
^            | Tapping Speed                | Multi-Touch display, Accelerometer (optional) | Touch Activity
Fitness      | Fitness                      | GPS, Gyroscope                                | Device motion, Pedometer, Location, Heart rate
^            | Timed Walk                   | GPS, Gyroscope                                | Device motion, Pedometer, Location, Heart rate
Cognition    | Spatial Memory               | Multi-Touch display, Accelerometer (optional) | Touch Activity, Actual sequences
^            | Stroop Test                  | Multi-Touch display                           | User selection, Completion time 
^            | Trail Making Test            | Multi-Touch display                           | Completion time, Touch activity
^            | Paced Serial Addition (PSAT) | Multi-Touch display                           | Addition results from user
^            | Tower of Hanoi               | Multi-Touch display                           | Every move taken by user
^            | Reaction Time                | Accelerometer, Gyroscope                      | Device motion
Speech       | Sustained Phonation          | Microphone                                    | Uncompressed audio
^            | Speech Recognition           | Microphone                                    | Raw audio, Transcription, Edited transcript
^            | Speech-in-Noise              | Microphone            | Raw audio, Transcription, Edited transcript, Reception Threshold (SRT)
Hearing      | Environment SPL              | Microphone                                    | Environment sound pressure level in dBA
^            | Tone Audiometry              | AirPods Headphones                            | Minimum amplitude recognized by the user
^            | DBHL Tone Audiometry         | AirPods Headphones                            | Hearing threshold in dB HL scale
Hand Dexterity | 9-Hole Peg                 | Multi-Touch display                           | Completion time, Move distance
Vision       | Amsler Grid                  | Multi-Touch display       | Touch activity, Eye side, Areas of distortion annotated by the user 


You can disable the instruction or completion steps that are automatically
included in the framework by passing appropriate options when you create an active task. See the
`ORKPredefinedTaskOption` constants for the available options.

You can use options flags to exclude data collection for data types that are not needed for your study. For example, to perform the fitness task without recording heart rate data, use the `ORKPredefinedTaskOptionExcludeHeartRate` option.
 
## Range of Motion
In the range of motion task, participants follow movement instructions while accelerometer and gyroscope data is captured to measure flexed and extended positions for the knee or shoulder. Range of motion steps for the knee are shown in Figure 1.


|                                                                  |                                                     |
|------------------------------------------------------------------|-----------------------------------------------------|
| ![Instruction step introducing the task](knee-range-of-motion-1) | ![A touch anywhere step](knee-range-of-motion-2)    |
| ![A further touch anywhere step](knee-range-of-motion-3)         | ![Confirms task completion](knee-range-of-motion-4) |

Figure 1. Range of motion steps for the right knee

## Gait and Balance

In the gait and balance task,
the user walks for a short distance, which may be indoors. You might
use this semi-controlled task to collect objective measurements that
can be used to estimate stride length, smoothness, sway, and other
aspects of the participant's walking.

Gait and balance steps are shown in Figure 2.

|                                                                     |                                                             |
|---------------------------------------------------------------------|-------------------------------------------------------------|
| ![Instruction step introducing the task](short-walk-task-1)         | ![Instruction step introducing the task](short-walk-task-2) |
| ![Count down a specified duration into the task](short-walk-task-3) | ![Asking user to walk](short-walk-task-4)                   |
| ![Asking user to walk](short-walk-task-5)                           | ![Asking user to rest](short-walk-task-6)                   |
| ![Confirms task completion](short-walk-task-7)      


Figure 2. Gait and balance steps

## Tapping Speed

In the tapping task, the user rapidly alternates between tapping two
targets on the touch screen. The resulting touch data can be used to
assess basic motor capabilities such as speed, accuracy, and rhythm.

Touch data, and optionally accelerometer data from CoreMotion in iOS, are
collected using public APIs. No analysis is performed by the ResearchKit framework on the data.

Tapping speed steps are shown in Figure 3.

|                                                                                         |                                                                             |
|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| ![Instruction step introducing the task](two-finger-tapping-task-1)                     | ![Providing instruction for the right hand task](two-finger-tapping-task-2) |
| ![The user rapidly taps on the targets using the right hand](two-finger-tapping-task-3) | ![Providing instruction for the left hand task](two-finger-tapping-task-4)  |
| ![The user rapidly taps on the targets using the left hand](two-finger-tapping-task-5)  | ![Confirms task completion](two-finger-tapping-task-6)                      |


Figure 3. Tapping speed steps

## Fitness

In the fitness task, the user walks for a specified duration (usually
several minutes). Sensor data is collected and returned through the
task view controller's delegate. Sensor data can include
accelerometer, device motion, pedometer, location, and heart rate data
where available.

Toward the end of the walk, if heart rate data is available, the user
is asked to sit down and rest for a period. Data collection continues
during the rest period.

Fitness steps are shown in Figure 4.

|                                                          |                                                                                         |
|----------------------------------------------------------|-----------------------------------------------------------------------------------------|
| ![Instruction step introducing the task](fitness-task-1) | ![Instruction step introducing the task](fitness-task-2)                                |
| ![Health access alert](fitness-task-3)                   | ![Count down a specified duration to begin the task](fitness-task-4)                    | 
| ![Displays distance and heart rate](fitness-task-5)      | ![The rest step, which can be skipped if heart rate data is unavailable](fitness-task-6)|
| ![Confirms task completion](fitness-task-7)                      

Figure 4. Fitness task

All of the data is collected from public [CoreMotion](https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CoreMotion_Reference/index.html) and [HealthKit](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/) APIs on iOS, and serialized to JSON. No analysis is applied to the data by the ResearchKit framework.

## Timed Walk
In the timed walk task, the user is asked to walk quickly and safely for a specific distance. The task is immediately administered again by having the user walk the same distance in the opposite direction. The timed walk task differs from both the fitness and the short walk tasks in that the distance walked by the user is fixed. A timed walk task measures the user's lower-extremity function.
 
The data collected by this task includes accelerometer, device motion, pedometer data, and location of the user. Note that the location is available only if the user agrees to share their location.
Data collected by the task is in the form of an `ORKTimedWalkResult` object. 

Timed walk steps are shown in Figure 5.

|                                                               |                                                                             |
|---------------------------------------------------------------|-----------------------------------------------------------------------------|
| ![Instruction step introducing the task](timed-walk-task-1)   | ![Gathers information about the user’s assistive device](timed-walk-task-2) |
| ![Instructions on how to perform the task](timed-walk-task-3) | ![Count down a specified duration to begin the task](timed-walk-task-4)     | 
| ![Actual task screen](timed-walk-task-5)                      | ![Instruct the user to turn around](timed-walk-task-6)                      |
| ![Actual task screen](timed-walk-task-7)                      | ![Task completion](timed-walk-task-8)                                       |

Figure 5. Timed walk steps

## Spatial Memory

In the spatial memory task,
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

|                                                                        |                                                                |
|------------------------------------------------------------------------|----------------------------------------------------------------|
| ![Instruction step introducing the task](spatial-span-memory-task-1)   | ![Describes what the user must do](spatial-span-memory-task-2) |
| ![The user must recall the sequence](spatial-span-memory-task-3)       | ![Confirms task completion](spatial-span-memory-task-4)        | 

Figure 6. Spatial memory steps

## Stroop Test
In the Stroop test, the participant is shown a series of words that are displayed in color, and must select the first letter of the color's name. Stroop test steps are shown in Figure 7.

|                                                                         |                                                                              |
|-------------------------------------------------------------------------|------------------------------------------------------------------------------|
| ![Instruction step introducing the task](stroop-task-1)                 | ![Further instructions](stroop-task-2)                                       |
| ![Count down a specified duration to begin the activity](stroop-task-3) | ![A typical Stroop test; the correct answer is “Y” for yellow](stroop-task-4)|
| ![Confirms task completion](stroop-task-5)

Figure 7. Stroop test steps

## Trail Making Test
In the trail making test, the participant connects a series of labelled circles, in order. The time to complete the test is recorded. The circles can be labelled with sequential numbers (1, 2, 3, ...) or with alternating numbers and letters  (1, a, 2, b, 3, c, ...). 

Trail making test steps are shown in Figure 8.

|                                                               |                                                                               |
|---------------------------------------------------------------|-------------------------------------------------------------------------------|
| ![Instruction step introducing the task](trail-making-task-1) | ![Instruction step introducing the task](trail-making-task-2)                 |
| ![Further instructions](trail-making-task-3)                  | ![Count down a specified duration to begin the activity](trail-making-task-4) |
| ![The activity screen, shown mid-task](trail-making-task-5)   | ![Confirms task completion](trail-making-task-6)                              |

Figure 8. Trail making test steps

## Paced Serial Addition Test (PSAT)

The Paced Serial Addition Test (PSAT) task measures the cognitive function that assesses auditory and/or visual information processing speed, flexibility, and the calculation ability of the user.

Single digits are presented every two or three seconds and the user must add each new digit to the one immediately before.

There are three variations of this test:

1. PASAT: Paced Auditory Serial Addition Test - the device speaks the digit every two or three seconds.
2. PVSAT: Paced Visual Serial Addition Test - the device shows the digit on screen.
3. PAVSAT: Paced Auditory and Visual Serial Addition Test - the device speaks the digit and shows it onscreen every two to three seconds.
 
The score for the PSAT task is the total number of correct answers out of the number of possible correct answers. Data collected by the task is in the form of an `ORKPSATResult` object. 

PVSAT steps are shown in Figure 9.

Note that the visual and auditory components of the task are optional. You can choose to include either of them or both.

|                                                               |                                                                                                   |
|---------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| ![Instruction step introducing the task](psat-task-1)         | ![Describes what the user must do](psat-task-2)                                                   |
| ![Count down a specified duration into the task](psat-task-3) | ![The user must add each new digit on the screen to the one immediately prior to it](psat-task-4) |
| ![Confirms task completion](psat-task-5)   

Figure 9. PVSAT memory steps

## Tower of Hanoi

In the Tower of Hanoi task, the user is asked to solve the classic Tower of Hanoi puzzle in a minimum number of moves. To solve the puzzle, the user must move the entire stack to the highlighted platform in as few moves as possible. This task measures the user's problem solving skills. A Tower of Hanoi task finishes when the user completes the puzzle correctly or concedes that they cannot solve the puzzle.
 
Data collected by this task is in the form of an `ORKTowerOfHanoiResult` object. It contains every move taken by the user and indicates whether the puzzle was successfully completed or not.
 
Tower of Hanoi steps are shown in Figure 10.

|                                                            |                                                      |
|------------------------------------------------------------|------------------------------------------------------|
| ![Instruction step introducing the task](tower-of-hanoi-1) | ![Describes what the user must do](tower-of-hanoi-2) |
| ![Actual task](tower-of-hanoi-3)                           | ![Confirms task completion](tower-of-hanoi-4)        |

Figure 10. Tower of Hanoi steps

## Reaction Time

In the reaction time task, the user shakes the device in response to a visual cue on the device's screen. The task is divided into a number of attempts, which you determine. To complete an attempt in a task, the user must shake or move the device with an acceleration that exceeds a threshold value ( `thresholdAcceleration` property) within the given time. The task finishes when the user successfully completes all the attempts as instructed in the task. Use this task to evaluate a user's response to the stimulus and calculate their reaction time.

Data collected by this task is in the form of `ORKReactionTimeResult` objects. Each of these objects contain a timestamp representing the delivery of the stimulus and an `ORKFileResult` object that references the motion data collected during an attempt. To present this task, use an `ORKTaskViewController` object. 

Reaction time steps are shown in Figure 11.

|                                                                |                                                          |
|----------------------------------------------------------------|----------------------------------------------------------|
| ![Instruction step introducing the task](reaction-time-task-1) | ![Describes what the user must do](reaction-time-task-2) |
| ![Actual task](reaction-time-task-3)                           | ![Confirms task completion](reaction-time-task-4)        |

Figure 11. Reaction time steps

## Sustained Phonation

In the sustained phonation task, the user makes a sustained sound, and an audio
recording is made. The ResearchKit framework uses the [AVFoundation](https://developer.apple.com/library/ios/documentation/AVFoundation/Reference/AVFoundationFramework/) framework to collect this
data and to present volume indication during recording. Analysis of the audio data is not included in the
ResearchKit framework, but might naturally involve looking at the power spectrum
and how it relates to the ability to produce certain
sounds. You can define your analysis on this
task according to your own requirements.
Audio steps are shown in Figure 12.

|                                                                    |                                                                                 |
|--------------------------------------------------------------------|---------------------------------------------------------------------------------|
| ![Instruction step introducing the task](audio-task-1)             | ![Instruction step describes user action during the task](audio-task-2)         |
| ![Count down a specified duration to begin the task](audio-task-3) | ![Displays a graph during audio playback (audio collection step)](audio-task-4) |
| ![Confirms task completion](audio-task-5)

Figure 12. Audio steps

## Speech Recognition

Researchers and developers can use ResearchKit to record audio data and produce transcriptions generated by Apple’s speech recognition system. ResearchKit also provides word alignments, confidence scores, and alternative speech recognition hypotheses in the form of an n-best list. Medical researchers and developers can leverage this information to analyze speech and language features like speaking rate, word usage, and pause durations.

The n-best list and the confidence measure detect uncertainty in the speech recognition system's hypothesis in certain cases of unintelligible speech or speech containing word fragments or meaningless words. These conditions are found to be a useful indicator of cognitive decline associated with Alzheimer's disease and related dementias (1, 2), as well as other mental health issues (3). Additionally, researchers and developers can use the raw audio data captured through ResearchKit to investigate and deploy speech indicators for research and system design.

The `ORKSpeechRecognitionStep` class represents a single recording step. In this step, the user's speech is recorded from the microphone.

Speech recognition steps showing capturing and displaying recorded text are in Figure 13.

|                                                                     |                                                                             |
|---------------------------------------------------------------------|-----------------------------------------------------------------------------|
| ![Instruction step introducing the task](speech-recognition-task-1) | ![Instruct the user to prepare for recording](speech-recognition-task-2)    |
| ![Records the user’s speech](speech-recognition-task-3)             | ![Provides the transcription and allows editing](speech-recognition-task-4) |
| ![Task completion](speech-recognition-task-5)

Figure 13. Speech recognition steps

Once a user completes the recording, they are given the option to edit the transcript generated by the speech recognition engine. The data collected by this task consists of three main components:

1. The raw audio recording of what the user said.
2. The transcription generated by the speech recognition engine returned as an object of type `SFTranscript`.
3. The edited transcript, if any, by the user.

## Speech-in-Noise

Understanding speech in noisy environments depends on both the level of the background noise and the hearing health of the listener. A speech-in-noise test quantifies the difficulty of understanding speech in noisy environments.
 
A speech-in-noise test consists of presenting spoken sentences at different noise levels and asking listeners to repeat what they heard. Based on the sentence and word recognition rate, a metric is calculated. The speech intelligibility metric used in this test is the Speech Reception Threshold (SRT). It represents the SNR at which 50% of the words are correctly repeated by the user. The SRT is calculated using the Tillman-Olsen formula (4).

The `ORKSpeechInNoiseStep` class plays the speech from a file set by the `speechFileNameWithExtension` property mixed with noise from a file set by the `noiseFileNameWithExtension` property. The noise gain is set through the `gainAppliedToNoise` property. Use the `filterFileNameWithExtension` property to specify a ramp-up/ramp-down filter.

Speech-in-noise steps are shown in Figure 14.

|                                                                            |                                                                       |
|----------------------------------------------------------------------------|-----------------------------------------------------------------------|
| ![Instruction step introducing the task](speech-in-noise-1)                | ![Instructs the user how to proceed with the task](speech-in-noise-2) |
| ![Plays the spoken sentence with background noise](speech-in-noise-3)      | ![Records the user’s voice](speech-in-noise-4)                        |
| ![Displays spoken text and provides transcript editing](speech-in-noise-5) | ![Task completion](speech-in-noise-6)                                 |

Figure 14. Speech-in-noise steps

## Environment SPL Meter

The Environment SPL Meter is not a task, but a single step that detects the sound pressure level in the user's environment. Configure this step with the following properties:

- `thresholdValue` is the maximum permissible value for the environment sound pressure level in dBA.
- `samplingInterval` is the rate at which the `AVAudioPCMBuffer` is queried and A-weighted filter is applied.
- `requiredContiguousSamples` is the number of consecutive samples less than threshold value required for the step to proceed.

|                                                        |                                                                    |
|--------------------------------------------------------|--------------------------------------------------------------------|
| ![Prompt the user if environment is too loud](spl-meter-1) | ![Task collects required samples under the threshold](spl-meter-2) |
| ![Step is complete](spl-meter-3)  

The environment SPL meter step is shown in Figure 15.

## Tone Audiometry

In the tone audiometry task, users listen through headphones to a series of tones, and tap left or right buttons on the screen when they hear each tone.  These tones are of different audio frequencies, playing on different channels (left and right), with the volume being progressively increased until the user taps one of the buttons. A tone audiometry task measures different properties of a user's hearing ability, based on their reaction to a wide range of frequencies.

Data collected in this task consists of audio signal amplitude for specific frequencies and channels for each ear. 
 
Tone audiometry steps are shown in Figure 16.

|                                                                                      |                                                                                  |
|--------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| ![Instruction step introducing the task](tone-audiometry-task-1)                     | ![Instruction step introducing the task](tone-audiometry-task-2)                 |
| ![Further instructions](tone-audiometry-task-3)                                      | ![Count down a specified duration to begin the activity](tone-audiometry-task-4) |
| ![The tone test screen with buttons for left and right ears](tone-audiometry-task-5) | ![Confirms task completion](speech-in-noise-6)                                   |

Figure 16. Tone audiometry steps

## dBHL Tone Audiometry

The dBHL tone audiometry task implements the Hughson-Westlake method of determining hearing threshold. It is similar to the tone audiometry task, except that it utilizes a dB HL scale.

Data collected in this task consists of audio signal amplitude for specific frequencies and channels for each ear. 

dBHL tone audiometry steps are shown in Figure 17.

|                                                                                                      |                                                                                     |
|------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| ![Instruction step introducing the task](dbhl-tone-audiometry-task-1)                                | ![Instruction step introducing the task](dbhl-tone-audiometry-task-2)               |
| ![Further instructions](dbhl-tone-audiometry-task-3)                                                 | ![Check noise levels](dbhl-tone-audiometry-task-4)                                  |
| ![Instruction step displaying which ear the user will hear sounds from](dbhl-tone-audiometry-task-5) | ![The tone test screen with buttons for the right ear](dbhl-tone-audiometry-task-6) |
| ![Instruction step displaying which ear the user will hear sounds from](dbhl-tone-audiometry-task-7) | ![The tone test screen with buttons for the left ear](dbhl-tone-audiometry-task-8)  |
| ![Confirms task completion](dbhl-tone-audiometry-task-9)

Figure 17. dBHL tone audiometry steps

## 9-Hole Peg Test

The 9-hole peg test is a two-step test of hand dexterity to measure the [MSFC score in Multiple Sclerosis](http://www.nationalmssociety.org/For-Professionals/Researchers/Resources-for-Researchers/Clinical-Study-Measures/9-Hole-Peg-Test-(9-HPT)), or signs of [Parkinson's disease or stroke](http://www.rehabmeasures.org/Lists/RehabMeasures/DispForm.aspx?ID=925). This task is well documented in the scientific literature (see [Earhart et al., 2011](http://www.ncbi.nlm.nih.gov/pubmed/22020457)).

The data collected by this task includes the number of pegs, an array of move samples, and the total duration that the user spent taking the test. Practically speaking, this task generates a two-step test in which the participant must put a variable number of pegs in a hole (the place step), and then remove them (the remove step). This task tests both hands.

The `ORKHolePegTestPlaceStep` class represents the place step. In this step, the user uses two fingers to touch the peg and drag it into the hole using their left hand. The `ORKHolePegTestRemoveStep` class represents the remove step. Here, the user moves the peg over a line using two fingers on their right hand.

9-Hole peg test steps are shown in Figure 18.

|                                                                                |                                                                                |
|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| ![Instruction step introducing the task](hole-peg-task-1)                      | ![Describes what the user must do](hole-peg-task-2)                            |
| ![Instructs the user to perform the step with the right hand](hole-peg-task-3) | ![Instructs the user to perform the step with the right hand](hole-peg-task-4) |
| ![Instructs the user to perform the step with the left hand](hole-peg-task-5)  | ![Instructs the user to perform the step with the left hand](hole-peg-task-6)  |
| ![Task completion](hole-peg-task-7)                                            |

Figure 18. 9-hole peg test steps


## Amsler Grid

The Amsler Grid task is a tool used to detect the onset of vision problems such as macular degeneration.

The `ORKAmslerGridStep` class represents a single measurement step. In this step, the user observes the grid while closing one eye for any anomalies and marks the areas that appear distorted, using their finger or a stylus.

Data collected by this task is in the form of an `ORKAmslerGridResult` object for the eye. It contains the eye side (specified by `ORKAmslerGridEyeSide`) and the image of the grid, along with the user's annotations for the corresponding eye.

Amsler grid steps for the left and right eyes are shown in Figure 19.

|                                                                                                                            |             |
|---------------------------------------------------------|------------------------------------------------------------------|
| ![Instruction step introducing the task](amsler-grid-1) | ![Instruct the user how to measure the left eye](amsler-grid-2)  |
| ![Perform the left eye test](amsler-grid-3)             | ![Instruct the user how to measure the right eye](amsler-grid-4) |
| ![Perform the right eye test](amsler-grid-5)            | ![Task completion](amsler-grid-6)                                |

Figure 19. Amsler grid steps

## Collect the Data

The data collected in active tasks is recorded in a hierarchy of `ORKResult` objects in memory. It is up to you to serialize this hierarchy for storage or transmission in a way that’s appropriate for your application.

For high sample rate data, such as from the accelerometer, use the `ORKFileResult` in the hierarchy. This object references a file in the output directory (specified by the `outputDirectory` property of `ORKTaskViewController`) where the data is logged.

The recommended approach for handling file-based output is to create a new directory per task and to remove it after you have processed the results of the task.

Active steps support attaching recorder configurations
(`ORKRecorderConfiguration`). A recorder configuration defines a type of
data that should be collected for the duration of the step from a sensor or
a database on the device. For example:

- The pedometer sensor returns a `CMPedometerData` object that provides step counts computed by the motion coprocessor on supported devices.
- The accelerometer sensor returns a `CMAccelerometerData` object that provides raw accelerometer samples indicating the forces on the device.
- A `CMDeviceMotion` object provides information about the orientation and movement of the device by combining data collected from the accelerometer, gyroscope, and magnetometer.
- HealthKit returns sample types, such as heart rate.
- CoreLocation returns location data (combined from GPS, Wi-Fi and cell tower information).

The recorders used by ResearchKit's predefined active tasks always use
`NSFileProtectionCompleteUnlessOpen` while writing data to disk, and
then change the file protection level on any files generated to
`NSFileProtectionComplete` when recording is finished.

### Access Health Data

For HealthKit related data, there are two recorder configurations:

- `ORKHealthQuantityTypeRecorderConfiguration` to access quantity data such as heart rate.
- `ORKHealthClinicalTypeRecorderConfiguration` to access health records data. 

Access to health quantity data and health records requires explicit permission that the user must grant explicitly. More information about accessing health records [can be found here](https://developer.apple.com/documentation/healthkit/health_and_fitness_samples/accessing_health_records?language=objc).

--
### References

1. [Yancheva et. al., 2015] M. Yancheva, K. C. Fraser and F. Rudzicz, “Using linguistic features longitudinally to predict clinical scores for Alzheimer's disease and related dementias,” Proceedings of SLPAT 2015: 6th Workshop on Speech and Language Processing for Assistive Technologies, 2015.

2. [Konig et al., 2015] A. König, A. Satt, A. Sorin, R. Hoory, O. Toledo-Ronen, A. Derreumaux, V. Manera, F. Verhey, P. Aalten, P. H. Robert, and R. David. “Automatic speech analysis for the assessment of patients with predementia and Alzheimer's disease,” Alzheimers Dement (Amst). 2015 Mar; 1(1): 112–124. 

3. [Gong and Poellabauer’ 17] Y. Gong and C. Poellabauer, “Topic Modeling Based Multi-modal Depression Detection,” AVEC@ACM Multimedia, 2017.

4. [T.W. Tillman and W.O. Olsen] "Speech audiometry, Modern Development in Audiology (2nd Edition)," 1972. 
