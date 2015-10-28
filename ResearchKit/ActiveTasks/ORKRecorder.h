/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <ResearchKit/ORKDefines.h>
#import <ResearchKit/ORKStep.h>
#import <HealthKit/HealthKit.h>
#import <ResearchKit/ORKResult.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKRecorder;

/**
 The `ORKRecorderConfiguration` class is the abstract base class for recorder configurations
 that can be attached to an active step (`ORKActiveStep`).
 
 Recorder configurations provide an easy way to collect CoreMotion
 or other sensor data into a serialized format during the duration of an active step.
 If you want to filter or process the data in real time, it is better to
 use the existing APIs directly.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 
 To add a new recorder, subclass both `ORKRecorderConfiguration` and `ORKRecorder`,
 and add the new `ORKRecorderConfiguration` subclass to an `ORKActiveStep` object.
 */
ORK_CLASS_AVAILABLE
@interface ORKRecorderConfiguration : NSObject <NSSecureCoding>

/*
 The `init` and `new` methods are unavailable outside the framework on `ORKRecorderConfiguration`,
 because it is an abstract class.
 
 `ORKRecorderConfiguration` classes should be initialized with custom designated
 initializers on each subclass.
 */
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 A short string that uniquely identifies the recorder configuration within the step.
 
 The identifier is reproduced in the results of a recorder created from this configuration. In fact, the only way to link a result
 (an `ORKFileResult` object) to the recorder that generated it is to look at the value of
 `identifier`. To accurately identify recorder results, you need to ensure that recorder identifiers
 are unique within each step.
 
 In some cases, it can be useful to link the recorder identifier to a unique identifier in a
 database; in other cases, it can make sense to make the identifier human
 readable.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 Returns a recorder instance using this configuration.
 
 @param step                The step for which this recorder is being created.
 @param outputDirectory     The directory in which all output file data should be written (if producing `ORKFileResult` instances).
 
 @return A configured recorder instance.
 */
- (nullable ORKRecorder *)recorderForStep:(nullable ORKStep *)step outputDirectory:(nullable NSURL *)outputDirectory;

/**
 Returns the HealthKit types for which this recorder requires read access in a set of `HKSampleType` objects.
 
 Typically, the task view controller automatically collects
 and collates the types of HealthKit data requested by each of the active steps in a task,
 and requests access to them at the end of the initial instruction
 steps in the task.
 
 If your recorder requires or would benefit from read access to HealthKit at
 runtime during the task, return the appropriate set of `HKSampleType` objects.
 */
- (nullable NSSet<HKObjectType *> *)requestedHealthKitTypesForReading;

@end


/**
 The `ORKAccelerometerRecorderConfiguration` subclass configures
 the collection of accelerometer data during an active step.
 
 Accelerometer data is serialized to JSON and returned as an `ORKFileResult` object.
 For details on the format, see `CMAccelerometerData+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKAccelerometerRecorderConfiguration : ORKRecorderConfiguration

/**
 The frequency of accelerometer data collection in samples per second (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 Returns an initialized accelerometer recorder configuration using the specified frequency.
 
 This method is the designated initializer.
 
 @param identifier  The unique identifier of the recorder configuration.
 @param frequency   The frequency of accelerometer data collection in samples per second (Hz).
 
 @return An initialized accelerometer recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier frequency:(double)frequency NS_DESIGNATED_INITIALIZER;

/**
 Returns a new accelerometer recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the accelerometer recorder configuration.
 
 @return A new accelerometer recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKAudioRecorderConfiguration` class represents a configuration that records
 audio data during an active step.
 
 An `ORKAudioRecorderConfiguration` generates an `ORKAudioRecorder` object.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKAudioRecorderConfiguration : ORKRecorderConfiguration

/**
 The audio format settings for the recorder.
 
 Pass the settings for the recording session to the `AVAudioRecorder` method `initWithURL:settings:error:`.
 For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants" in
 the AVFoundation documentation.
 
 The results are returned as an `ORKFileResult` object, which points to an audio file.
 */
@property (nonatomic, readonly, nullable) NSDictionary *recorderSettings;

/**
 Returns an initialized audio recorder configuration using the specified settings.
 
 This method is the designated initializer.
 
 For information on the settings available for an audio recorder, see "AV Foundation Audio Settings Constants".
 
 @param identifier          The unique identifier of the recorder configuration.
 @param recorderSettings    The settings for the recording session.
 
 @return An initialized audio recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier recorderSettings:(NSDictionary *)recorderSettings NS_DESIGNATED_INITIALIZER;

/**
 Returns a new audio recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the audio recorder configuration.
 
 @return A new audio recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKDeviceMotionRecorderConfiguration` class represents a configuration
 that records device motion data during an active step.
 
 Device motion data is the processed motion data provided by CoreMotion and obtained
 from a `CMMotionManager` object. The data can include measures of the overall device orientation
 obtained from combining accelerometer, magnetometer, and gyroscope data.
 
 Device motion data is serialized to JSON and returned as an `ORKFileResult` object.
 For details on the format, see `CMDeviceMotion+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKDeviceMotionRecorderConfiguration : ORKRecorderConfiguration

/**
 The frequency of motion data collection in samples per second (Hz).
 */
@property (nonatomic, readonly) double frequency;

/**
 Returns an initialized device motion recorder configuration using the specified frequency.
 
 This method is the designated initializer.
 
 @param identifier  The unique identifier of the recorder configuration.
 @param frequency   Motion data collection frequency in samples per second (Hz).
 
 @return An initialized device motion recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier frequency:(double)frequency NS_DESIGNATED_INITIALIZER;

/**
 Returns a new device motion recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the device motion recorder configuration.
 
 @return A new device motion recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKPedometerRecorderConfiguration` class represents a configuration
 that records pedometer data during an active step.
 
 Pedometer data consists of information about the processed steps provided by CoreMotion, obtained
 from a `CMPedometer` object. The pedometer object essentially reports the total number of steps taken since the
 start of recording, updating the value every time a significant number of steps have
 been detected.
 
 Pedometer data is serialized to JSON and returned as an `ORKFileResult` object.
 For details on the format, see `CMPedometerData+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKPedometerRecorderConfiguration : ORKRecorderConfiguration

/**
 Returns an initialized pedometer recorder configuration.

 The recorder instantiates a `CMPedometer` object, so no additional parameters besides
 the identifier are required.

 This method is the designated initializer.

 @param identifier   The unique identifier of the recorder configuration.
 
 @return An initialized pedometer recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new pedometer recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the pedometer recorder configuration.
 
 @return A new pedometer recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKLocationRecorderConfiguration` class represents a configuration
 that records location data during an active step.
 
 The location data reported is the location provided by CoreLocation.
 
 If this configuration is included in an active step in a task, the task
 view controller requests access to location data at the end of the
 initial instruction steps in the task.
 
 Location data is serialized to JSON and returned as an `ORKFileResult` object.
 For details on the format, see `CLLocation+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 
 No additional parameters besides the identifier are required.
 */
ORK_CLASS_AVAILABLE
@interface ORKLocationRecorderConfiguration : ORKRecorderConfiguration

/**
 Returns an initialized location recorder configuration.
 
 This method is the designated initializer.

 @param identifier   The unique identifier of the recorder configuration.
 
 @return An initialized location recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

/**
 Returns a new location recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the location recorder configuration.
 
 @return A new location recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end


/**
 The `ORKHealthQuantityTypeRecorderConfiguration` class represents a configuration
 that records data from a HealthKit quantity type during an active step.
 
 Before you can use this configuration, you must use Xcode to enable the appropriate HealthKit entitlement
 for your app.
 
 HealthKit quantity type data is serialized to JSON and returned as an `ORKFileResult` object.
 For details on the format, see `HKSample+ORKJSONDictionary`.
 
 To use a recorder, include its configuration in the `recorderConfigurations` property
 of an `ORKActiveStep` object, include that step in a task, and present it with
 a task view controller.
 */
ORK_CLASS_AVAILABLE
@interface ORKHealthQuantityTypeRecorderConfiguration : ORKRecorderConfiguration

/**
 Returns an initialized health quantity type recorder configuration using the specified quantity type and unit designation.
 
 This method is the designated initializer.
 
 @param identifier      The unique identifier of the recorder configuration.
 @param quantityType    The quantity type that should be collected during the active task.
 @param unit            The unit for the data that should be collected and serialized.
 
 @return An initialized health quantity type recorder configuration.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier healthQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit NS_DESIGNATED_INITIALIZER;

/**
 Returns a new health quantity type recorder configuration initialized from data in the given unarchiver.
 
 @param aDecoder    Coder from which to initialize the health quantity type recorder configuration.
 
 @return A new health quantity type recorder configuration.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 The quantity type to be collected from HealthKit. (read-only)
 */
@property (nonatomic, readonly, copy) HKQuantityType *quantityType;

/**
 The unit in which to serialize the data from HealthKit. (read-only)
 */
@property (nonatomic, readonly, copy) HKUnit *unit;

@end


/**
 The `ORKRecorderDelegate` protocol defines methods that the delegate of an `ORKRecorder` object should use to handle errors and log the
 completed results.
 
 This protocol is implemented by `ORKActiveStepViewController`; your app should not
need to implement it.
 */
@protocol ORKRecorderDelegate <NSObject>

/**
 Tells the delegate that the recorder has completed with the specified result.
 
 Typically, this method is called once when recording is stopped.
 
 @param recorder        The generating recorder object.
 @param result          The generated result.
 */
- (void)recorder:(ORKRecorder *)recorder didCompleteWithResult:(nullable ORKResult *)result;

/**
 Tells the delegate that recording failed.
 
 Typically, this method is called once when the error occurred.
 
 @param recorder        The generating recorder object.
 @param error           The error that occurred.
 */
- (void)recorder:(ORKRecorder *)recorder didFailWithError:(NSError *)error;

@end


/**
 A recorder is the runtime companion to an `ORKRecorderConfiguration` object, and is
 usually generated by one.
 
 During active tasks, it is often useful to collect one or more pieces of data
 from sensors on the device. In research tasks, it's not always
 necessary to display that data, but it's important to record it in a controlled manner.
 
 An active step (`ORKActiveStep`) has an array of recorder configurations
 (`ORKRecorderConfiguration`) that identify the types of data it needs to record
 for the duration of the step. When a step starts, the active step view controller
 instantiates a recorder for each of the step's recorder configurations.
 The step view controller starts the recorder when the active step is started, and stops the
 recorder when the active step is finished.
 
 The results of recording are typically written to a file specified by the value of the `outputDirectory` property.
 
 Usually, the `ORKActiveStepViewController` object is the recorder's delegate, and it
 receives callbacks when errors occur or when recording is complete.
 */
ORK_CLASS_AVAILABLE
@interface ORKRecorder : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/// @name Configuration

@property (nonatomic, weak, nullable) id<ORKRecorderDelegate> delegate;

/**
 A short string that uniquely identifies the recorder (usually assigned by the recorder configuration).
 
 The identifier is reproduced in the results of a recorder created from this configuration. In fact, the only way to link a result
 (an `ORKFileResult` object) to the recorder that generated it is to look at the value of
 `identifier`. To accurately identify recorder results, you need to ensure that recorder identifiers
 are unique within each step.
 
 In some cases, it can be useful to link the recorder identifier to a unique identifier in a
 database; in other cases, it can make sense to make the identifier human
 readable.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 The step that produced this recorder, configured during initialization.
 */
@property (nonatomic, strong, readonly, nullable) ORKStep *step;

/**
 The configuration that produced this recorder.
 */
@property (nonatomic, strong, readonly, nullable) ORKRecorderConfiguration *configuration;

/**
 The file URL of the output directory configured during initialization.
 
 Typically, you set the `outputDirectory` property for the `ORKTaskViewController` object
 before presenting the task.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *outputDirectory;

/**
 Returns the log prefix for the log file.
 */
- (nullable NSString *)logName;

/// @name Runtime Life Cycle

/**
 Starts data recording.
 
 If an error occurs when recording starts, it is returned through the delegate.
 */
- (void)start NS_REQUIRES_SUPER;

/**
 Stops data recording, which generally triggers the return of results.
 
 If an error occurs when stopping the recorder, it is returned through the delegate.
 Subclasses should call `finishRecordingWithError:` rather than calling super.
 */
- (void)stop NS_REQUIRES_SUPER;

/**
 A Boolean value indicating whether the recorder is currently recording.
 
 @return `YES` if the recorder is recording; otherwise, `NO`.
 */
@property (nonatomic, readonly, getter=isRecording) BOOL recording;

@end

NS_ASSUME_NONNULL_END
