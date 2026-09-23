# Understanding Recorders

Collect sensor and device data during active steps using recorder configurations.

## Overview

Recorders let an active step continuously capture data from the device's sensors and system frameworks for the duration of that step. Each recorder is defined by a configuration object (`ORKRecorderConfiguration`) attached to an `ORKActiveStep`. When the step begins, the framework instantiates and starts the corresponding `ORKRecorder`; when the step ends, the recorder stops and delivers its results as one or more `ORKFileResult` objects.

You never create `ORKRecorder` instances directly. Instead, you add one or more `ORKRecorderConfiguration` objects to the `recorderConfigurations` property of an `ORKActiveStep`. The framework creates, starts, and stops the recorders for you.

## Available Recorder Configurations

ResearchKit provides recorder configurations for several data sources.

### Motion

- `ORKAccelerometerRecorderConfiguration` - Records raw accelerometer samples from CoreMotion at a fixed frequency. Each sample is a `CMAccelerometerData` object indicating the forces on the device along three axes.
- `ORKDeviceMotionRecorderConfiguration` - Records processed device motion data from CoreMotion. Fuses accelerometer, gyroscope, and magnetometer to produce orientation and movement estimates.
- `ORKPedometerRecorderConfiguration` - Records step count and distance from the CoreMotion pedometer, which uses the motion coprocessor on supported devices.

### Audio

- `ORKAudioRecorderConfiguration` - Records audio using `AVAudioRecorder` with configurable `AVAudioSession` settings. Produces a compressed or uncompressed audio file.
- `ORKStreamingAudioRecorderConfiguration` - Records audio via `AVAudioEngine` and continues recording when the app moves to the background.

### Health

- `ORKHealthQuantityTypeRecorderConfiguration` - Records real-time HealthKit quantity samples (for example, heart rate) as they arrive during the step. Requires explicit user permission.
- `ORKHealthClinicalTypeRecorderConfiguration` - Records FHIR clinical record data from HealthKit. Requires explicit user permission.

### Location

- `ORKLocationRecorderConfiguration` - Records the device's location from CoreLocation, combining GPS, Wi-Fi, and cell tower data.

The following example attaches accelerometer and device motion configurations to an `ORKWalkingTaskStep`. The pedometer configuration is added automatically by the framework - no need to include it explicitly.

```swift
let accelerometerConfiguration = ORKAccelerometerRecorderConfiguration(
    identifier: "accelerometerRecorder",
    frequency: 100
)
let deviceMotionConfiguration = ORKDeviceMotionRecorderConfiguration(
    identifier: "deviceMotionRecorder",
    frequency: 100
)

let walkingStep = ORKWalkingTaskStep(identifier: "walkingStep")
walkingStep.numberOfStepsPerLeg = 20
walkingStep.title = "Walking Task"
walkingStep.text = "Walk 20 steps in a straight line."
walkingStep.recorderConfigurations = [
    accelerometerConfiguration,
    deviceMotionConfiguration
]
```

## File Output and Protection

All recorders write their data to the output directory specified by `ORKTaskViewController.outputDirectory`. Recorder output files are protected with `NSFileProtectionComplete` by default. Results are returned as `ORKFileResult` objects referencing those files.

For high-frequency data like accelerometer or device motion, using file-based output is the expected pattern. Create a new output directory per task and remove it after you have processed the results.

## The prepareRecorders Method

Before the step view controller checks permissions, it calls `prepareRecorders` on the active step. The base `ORKActiveStep` implementation does nothing. Several step subclasses override this method to enforce recorder requirements, which has important implications when you attach custom configurations.

There are two patterns:

- **Inject-if-missing** - the step adds a required configuration when none is present, guaranteeing the recorder runs.
- **Filter** - the step removes incompatible configurations, silently discarding any you attached that do not match what the step supports.

Some steps combine both patterns.

### ORKAudioStep

Combines inject-if-missing with filtering:

- If no `ORKAudioRecorderConfiguration` is present, a default one is added using `ORKAudioRecorder.defaultRecorderSettings`.
- Any configuration that is not an `ORKAudioRecorderConfiguration` is removed.

Attaching a motion or health recorder configuration to an `ORKAudioStep` has no effect - those configurations are silently dropped before recording begins. If you need to collect additional data alongside audio, use a different step type or a custom `ORKActiveStep` subclass.

The following example shows the correct way to configure an `ORKAudioStep` with custom recording settings. Only `ORKAudioRecorderConfiguration` is attached, so `prepareRecorders` leaves the configuration array unchanged.

```swift
let recordingSettings: [String: Any] = [
    AVFormatIDKey: kAudioFormatAppleLossless,
    AVNumberOfChannelsKey: 2,
    AVSampleRateKey: 44100.0
]

let audioStep = ORKAudioStep(identifier: "audioStep")
audioStep.title = "Record a Sound"
audioStep.text = "Speak or make a sound while recording is active."
audioStep.stepDuration = 20
audioStep.useRecordButton = true
audioStep.shouldContinueOnFinish = true
audioStep.recorderConfigurations = [
    ORKAudioRecorderConfiguration(
        identifier: "audioRecorder",
        recorderSettings: recordingSettings
    )
]
```

### ORKWalkingTaskStep

Inject-if-missing only. If no `ORKPedometerRecorderConfiguration` is present, the framework adds one automatically. Other configurations you attach are left in place. You do not need to add a pedometer configuration manually for this step, but you also cannot suppress it.

### ORKRangeOfMotionStep

Inject-if-missing only. If no `ORKDeviceMotionRecorderConfiguration` is present, the framework adds one at 100 Hz. Other configurations are left in place.

### ORKReactionTimeStep

Combines inject-if-missing with filtering:

- If no `ORKDeviceMotionRecorderConfiguration` is present, a default one is added at 100 Hz.
- Any configuration that is not an `ORKDeviceMotionRecorderConfiguration` is removed.

### ORKNormalizedReactionTimeStep

Identical behavior to `ORKReactionTimeStep` - injects a default `ORKDeviceMotionRecorderConfiguration` at 100 Hz if missing, then filters out all non-device-motion configurations.

### ORKToneAudiometryStep

Filter only. Any `ORKAudioRecorderConfiguration` or `ORKStreamingAudioRecorderConfiguration` attached to this step is removed. The step manages its own audio session internally, so standard audio recorder configurations are incompatible with it.

### ORKdBHLToneAudiometryStep

Identical filtering behavior to `ORKToneAudiometryStep` - removes any `ORKAudioRecorderConfiguration` or `ORKStreamingAudioRecorderConfiguration` from `recorderConfigurations`.

### ORKSpeechRecognitionStep

Inject-if-missing only. If no `ORKStreamingAudioRecorderConfiguration` is present, a default one is added. Other configurations are left in place.

### Custom Active Steps

If you subclass `ORKActiveStep` and override `prepareRecorders`, call `super.prepareRecorders()` unless you have a specific reason not to. The `prepareRecorders` override is the right place to inject a required default configuration or filter out incompatible types.

## Requesting Permissions

Each recorder configuration declares the permissions it requires. The step view controller reads these declarations and presents the permission prompts before the step starts. You can inspect the aggregate permissions for a step via `ORKActiveStep.requestedPermissions`.

For HealthKit configurations, you must also declare the `HKObjectType` values your configurations will read by passing them to `ORKHealthQuantityTypeRecorderConfiguration.quantityType` or `ORKHealthClinicalTypeRecorderConfiguration.healthClinicalType`. The framework requests authorization for these types automatically.

Always place an `ORKInstructionStep` immediately before any active step in your task. The instruction step gives the framework an opportunity to surface permission prompts before the active step begins, so recording starts without interruption. It also prepares the participant for what the step involves - what sensors will be used, what actions are required, and roughly how long the step lasts. An active step that appears without any preamble risks surprising the participant and may start recording before the necessary permissions have been granted.

```swift
let instructionStep = ORKInstructionStep(identifier: "walkingInstructionStep")
instructionStep.title = "Walking Task"
instructionStep.text = "Walk in a straight line for 20 steps, then turn around and walk back."

let walkingStep = ORKWalkingTaskStep(identifier: "walkingStep")
walkingStep.numberOfStepsPerLeg = 20
walkingStep.title = "Walking Task"
walkingStep.text = "Walk 20 steps in a straight line."
walkingStep.recorderConfigurations = [
    ORKAccelerometerRecorderConfiguration(identifier: "accelerometerRecorder", frequency: 100),
    ORKDeviceMotionRecorderConfiguration(identifier: "deviceMotionRecorder", frequency: 100)
]

let task = ORKNavigableOrderedTask(
    identifier: "walkingTask",
    steps: [instructionStep, walkingStep]
)
```
