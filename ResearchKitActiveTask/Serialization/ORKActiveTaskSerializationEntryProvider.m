/*
 Copyright (c) 2024, Apple Inc. All rights reserved.
 
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

#import "ORKActiveTaskSerializationEntryProvider.h"

#import <ResearchKitActiveTask/ResearchKitActiveTask.h>
#import <ResearchKitActiveTask/ResearchKitActiveTask_Private.h>
#import "ResearchKitActiveTask/ResearchKitActiveTask-Swift.h"

#import <ResearchKit/ORKESerialization+Helpers.h>
#import <ResearchKit/ORKRecorder_Private.h>

@implementation ORKActiveTaskSerializationEntryProvider

- (NSMutableDictionary<NSString *,ORKESerializableTableEntry *> *)serializationEncodingTable {
    static NSMutableDictionary<NSString *, ORKESerializableTableEntry *> *internalEncodingTable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        internalEncodingTable =
        [@{
            ENTRY(ORKAudioLevelNavigationRule,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      ORKAudioLevelNavigationRule *rule = [[ORKAudioLevelNavigationRule alloc] initWithAudioLevelStepIdentifier:GETPROP(dict, audioLevelStepIdentifier)                                                                                             destinationStepIdentifier:GETPROP(dict, destinationStepIdentifier)
                                                                                                              recordingSettings:GETPROP(dict, recordingSettings)];
                      return rule;
                  },
                  (@{
                       PROPERTY(audioLevelStepIdentifier, NSString, NSObject, NO, nil, nil),
                       PROPERTY(destinationStepIdentifier, NSString, NSObject, NO, nil, nil),
                       PROPERTY(recordingSettings, NSDictionary, NSObject, NO, nil, nil),
                       })),
            ENTRY(ORKCountdownStep,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKCountdownStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                  },
                  (@{
                     })),
            ENTRY(ORKTouchAnywhereStep,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKTouchAnywhereStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                  },
                  (@{
                     })),
            ENTRY(ORKAccelerometerRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *rollingFileSizeThreshold = GETPROP(dict, rollingFileSizeThreshold);
                      return [[ORKAccelerometerRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                     frequency:((NSNumber *)GETPROP(dict, frequency)).doubleValue
                                                                               outputDirectory:GETPROP(dict, outputDirectory)
                                                                      rollingFileSizeThreshold:rollingFileSizeThreshold.doubleValue];
                  },
                  (@{
                     PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                     PROPERTY(rollingFileSizeThreshold, NSNumber, NSObject, YES, nil, nil),
                     })),
            ENTRY(ORKAudioRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKAudioRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) recorderSettings:GETPROP(dict, recorderSettings)];
                  },
                  (@{
                     PROPERTY(recorderSettings, NSDictionary, NSObject, NO, nil, nil),
                     })),
            ENTRY(ORKAudioStreamerConfiguration,
            ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                return [[ORKAudioStreamerConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)];
            },
                  (@{
                     PROPERTY(bypassAudioEngineStart, NSNumber, NSObject, YES, nil, nil)
                     })),
            ENTRY(ORKDeviceMotionRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *rollingFileSizeThreshold = GETPROP(dict, rollingFileSizeThreshold);
                      return [[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)
                                                                                    frequency:((NSNumber *)GETPROP(dict, frequency)).doubleValue
                                                                              outputDirectory:GETPROP(dict, outputDirectory)
                                                                     rollingFileSizeThreshold:rollingFileSizeThreshold.doubleValue];
                  },
                  (@{
                     PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                     PROPERTY(rollingFileSizeThreshold, NSNumber, NSObject, YES, nil, nil),
                     })),
    #if ORK_FEATURE_CLLOCATIONMANAGER_AUTHORIZATION
           ENTRY(ORKLocationRecorderConfiguration,
                 ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                     return [[ORKLocationRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)];
                 },
                 (@{
                    })),
    #endif
            ENTRY(ORKPedometerRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                NSNumber *rollingFileSizeThreshold = GETPROP(dict, rollingFileSizeThreshold);
                      return [[ORKPedometerRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)
                                                                           outputDirectory:GETPROP(dict, outputDirectory)
                                                                  rollingFileSizeThreshold:rollingFileSizeThreshold.doubleValue];
                  },
                  (@{
                     PROPERTY(rollingFileSizeThreshold, NSNumber, NSObject, YES, nil, nil),
                     })),
            ENTRY(ORKStreamingAudioRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKStreamingAudioRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier)];
                  },
                  (@{
                     })),
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
            ENTRY(ORKHealthQuantityTypeRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKHealthQuantityTypeRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) healthQuantityType:GETPROP(dict, quantityType) unit:GETPROP(dict, unit)];
                  },
                  (@{
                     PROPERTY(quantityType, HKQuantityType, NSObject, NO,
                              ^id(id type, __unused ORKESerializationContext *context) { return [(HKQuantityType *)type identifier]; },
                              ^id(id string, __unused ORKESerializationContext *context) { return [HKQuantityType quantityTypeForIdentifier:string]; }),
                     PROPERTY(unit, HKUnit, NSObject, NO,
                              ^id(id unit, __unused ORKESerializationContext *context) { return [(HKUnit *)unit unitString]; },
                              ^id(id string, __unused ORKESerializationContext *context) { return [HKUnit unitFromString:string]; }),
                     })),
#endif
                   ENTRY(ORKAudioStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKAudioStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(useRecordButton, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKToneAudiometryStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKToneAudiometryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         ((@{
                             PROPERTY(toneDuration, NSNumber, NSObject, YES, nil, nil),
                             PROPERTY(practiceStep, NSNumber, NSObject, YES, nil, nil),
                             }))),
                   ENTRY(ORKdBHLToneAudiometryStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKdBHLToneAudiometryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(toneDuration, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maxRandomPreStimulusDelay, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(postStimulusDelay, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maxNumberOfTransitionsPerFrequency, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(initialdBHLValue, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLStepUpSize, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLStepUpSizeFirstMiss, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLStepUpSizeSecondMiss, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLStepUpSizeThirdMiss, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLStepDownSize, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dBHLMinimumThreshold, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(headphoneType, NSString, NSObject, YES, nil, nil),
                            PROPERTY(earPreference, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(frequencyList, NSArray, NSObject, YES, nil, nil),
                            })),

                   ENTRY(ORKHolePegTestPlaceStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKHolePegTestPlaceStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(rotated, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKHolePegTestRemoveStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKHolePegTestRemoveStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(movingDirection, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(dominantHandTested, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(numberOfPegs, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(threshold, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKSpatialSpanMemoryStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKSpatialSpanMemoryStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(initialSpan, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(minimumSpan, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maximumSpan, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(playSpeed, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maximumTests, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maximumConsecutiveFailures, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(requireReversal, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(customTargetPluralName, NSString, NSObject, YES, nil, nil),
                            IMAGEPROPERTY(customTargetImage, NSObject, YES),
                            })),
                   ENTRY(ORKWalkingTaskStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKWalkingTaskStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(numberOfStepsPerLeg, NSNumber, NSObject, YES, nil, nil),
                            })),

                   ENTRY(ORKTimedWalkStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKTimedWalkStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(distanceInMeters, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKPSATStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKPSATStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(presentationMode, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(interStimulusInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(stimulusDuration, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(seriesLength, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKRangeOfMotionStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKRangeOfMotionStep alloc] initWithIdentifier:GETPROP(dict, identifier) limbOption:(NSUInteger)[GETPROP(dict, identifier) integerValue]];
                         },
                         (@{
                            PROPERTY(limbOption, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKReactionTimeStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKReactionTimeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(maximumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(minimumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(timeout, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(thresholdAcceleration, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(successSound, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(timeoutSound, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(failureSound, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKNormalizedReactionTimeStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKNormalizedReactionTimeStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(maximumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(minimumStimulusInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(timeout, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(thresholdAcceleration, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(successSound, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(timeoutSound, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(failureSound, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(currentInterval, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKNormalizedReactionTimeResult,
                        nil,
                         (@{
                            PROPERTY_TIED_TO_OTHER_PROPERTY(
                                timerStartDate, NSDate, NSObject,
                                timeZone, NSTimeZone, NSObject,
                                YES,
                                ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                                },
                                ^id(id string, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                              dateKey:@"timerStartDate"
                                                                                          timeZoneKey:@"timeZone"];
                                }
                            ),
                            PROPERTY_TIED_TO_OTHER_PROPERTY(
                                timerEndDate, NSDate, NSObject,
                                timeZone, NSTimeZone, NSObject,
                                YES,
                                ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                                },
                                ^id(id string, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                              dateKey:@"timerEndDate"
                                                                                          timeZoneKey:@"timeZone"];
                                }
                            ),
                            PROPERTY_TIED_TO_OTHER_PROPERTY(
                                stimulusStartDate, NSDate, NSObject,
                                timeZone, NSTimeZone, NSObject,
                                YES,
                                ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                                },
                                ^id(id string, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                              dateKey:@"stimulusStartDate"
                                                                                          timeZoneKey:@"timeZone"];
                                }
                            ),
                            PROPERTY_TIED_TO_OTHER_PROPERTY(
                                reactionDate, NSDate, NSObject,
                                timeZone, NSTimeZone, NSObject,
                                YES,
                                ^id(id date, id timeZone, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEStringFromDateISO8601:date timeZone: timeZone];
                                },
                                ^id(id string, __unused ORKESerializationContext *context) {
                                    return [ORKESerializerHelper ORKEDateAndTimeZoneFromStringISO8601:string
                                                                                              dateKey:@"reactionDate"
                                                                                          timeZoneKey:@"timeZone"];
                                }
                            ),
                            PROPERTY(currentInterval, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(fileResults, ORKFileResult, NSArray, NO, nil, nil),
                            })),
                   ENTRY(ORKStroopStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKStroopStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil)})),
                    ENTRY(ORKSwiftStroopStep,
                        ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                            return [[ORKSwiftStroopStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                        },
                        (@{
                            PROPERTY(numberOfAttempts, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(serializedColorChoices, NSString, NSArray, YES, nil, nil),
                            PROPERTY(serializedInterTrialMaskType, NSString, NSObject, YES, nil, nil),
                            PROPERTY(congruentFrequency, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(incongruentFrequency, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(neutralFrequency, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(minimumInterTrialDelay, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(maximumInterTrialDelay, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(recordResults, NSNumber, NSObject, YES, nil, nil),
                        })),
                   ENTRY(ORKAccuracyStroopStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKAccuracyStroopStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                             PROPERTY(isColorMatching, NSNumber, NSObject, YES, nil, nil),
                             PROPERTY(baseDisplayColor, UIColor, NSObject, YES,
                                      ^id(id color, __unused ORKESerializationContext *context) {return [ORKESerializerHelper dictionaryFromColor:color]; },
                                      ^id(id dict, __unused ORKESerializationContext *context) { return  [ORKESerializerHelper colorFromDictionary:dict]; })
                          })),
                   ENTRY(ORKTappingIntervalStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKTappingIntervalStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            })),
                   ENTRY(ORKTrailmakingStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKTrailmakingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(trailType, NSString, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKTowerOfHanoiStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKTowerOfHanoiStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(numberOfDisks, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKSpeechInNoiseStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKSpeechInNoiseStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         ((@{
                             PROPERTY(speechFilePath, NSString, NSObject, YES, nil, nil),
                             PROPERTY(targetSentence, NSString, NSObject, YES, nil, nil),
                             PROPERTY(speechFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                             PROPERTY(noiseFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                             PROPERTY(filterFileNameWithExtension, NSString, NSObject, YES, nil, nil),
                             PROPERTY(gainAppliedToNoise, NSNumber, NSObject, YES, nil, nil),
                             PROPERTY(willAudioLoop, NSNumber, NSObject, YES, nil, nil),
                             PROPERTY(hideGraphView, NSNumber, NSObject, YES, nil, nil),
                             }))),
                   ENTRY(ORKSpeechRecognitionStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKSpeechRecognitionStep alloc] initWithIdentifier:GETPROP(dict, identifier) image:nil text:GETPROP(dict, speechRecognitionText)];
                         },
                         (@{
                            PROPERTY(shouldHideTranscript, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(speechRecognitionText, NSString, NSObject, NO, nil, nil),
                            PROPERTY(speechRecognizerLocale, NSString, NSObject, YES, nil, nil)
                            })),
                   ENTRY(ORKEnvironmentSPLMeterStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKEnvironmentSPLMeterStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(thresholdValue, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(samplingInterval, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(requiredContiguousSamples, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKEnvironmentSPLMeterResult,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKEnvironmentSPLMeterResult alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(sensitivityOffset, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(recordedSPLMeterSamples, NSNumber, NSArray, YES, nil, nil)
                            })),

                   ENTRY(ORKAmslerGridStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKAmslerGridStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(eyeSide, NSNumber, NSObject, YES, nil, nil),
                            })),
                ENTRY(ORKAmslerGridResult,
                     nil,
                      (@{
                         PROPERTY(eyeSide, NSNumber, NSObject, NO, nil, nil),
                         PROPERTY(imageFileResult, ORKFileResult, NSObject, NO, nil, nil),
                         PROPERTY(drawingPathFileResult, ORKFileResult, NSObject, NO, nil, nil),
                         })),
                   ENTRY(ORKFitnessStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKFitnessStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(userInfo, NSDictionary, NSObject, YES, nil, nil)
                            })),

                   ENTRY(ORKVocalCue,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                            return [[ORKVocalCue alloc] initWithTime:((NSNumber *)GETPROP(dict, time)).doubleValue
                                                          spokenText:GETPROP(dict, spokenText)];
                         },
                         (@{
                             PROPERTY(time, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(spokenText, NSString, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKAudioFitnessStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                            return [[ORKAudioFitnessStep alloc]
                                    initWithIdentifier:GETPROP(dict, identifier)
                                    audioAsset:GETPROP(dict, audioAsset)
                                    vocalCues:GETPROP(dict, vocalCues)];
                         },
                         (@{
                             PROPERTY(audioAsset, ORKBundleAsset, NSObject, NO, nil, nil),
                             PROPERTY(vocalCues, ORKVocalCue, NSArray, NO, nil, nil)
                            })),

                   ENTRY(ORKdBHLToneAudiometryOnboardingStep,
                         ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                             return [[ORKdBHLToneAudiometryOnboardingStep alloc] initWithIdentifier:GETPROP(dict, identifier)];
                         },
                         (@{
                            PROPERTY(useCardView, NSNumber, NSObject, YES, nil, nil),
                            })),

            ENTRY(ORKTouchRecorderConfiguration,
                  ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                      return [[ORKTouchRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict,identifier)];
                  },
                  (@{
                     })),

                   ENTRY(ORKTappingSample,
                         nil,
                         (@{
                            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(duration, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(buttonIdentifier, NSNumber, NSObject, NO,
                                     ^id(id numeric, __unused ORKESerializationContext *context) {return [ORKESerializerHelper tableMapForwardWithIndex:((NSNumber *)numeric).integerValue table:[ORKESerializerHelper buttonIdentifierTable]]; },
                                     ^id(id string, __unused ORKESerializationContext *context) {return @([ORKESerializerHelper tableMapReverseWithValue:string table:[ORKESerializerHelper buttonIdentifierTable]]); }),
                            PROPERTY(location, NSValue, NSObject, NO,
                                     ^id(id value, __unused ORKESerializationContext *context) {return value?[ORKESerializerHelper dictionaryFromCGPoint:((NSValue *)value).CGPointValue]:nil; },
                                     ^id(id dict, __unused ORKESerializationContext *context) {
                                return [NSValue valueWithCGPoint:[ORKESerializerHelper pointFromDictionary:dict]]; })
                            })),
                   ENTRY(ORKTappingIntervalResult,
                         nil,
                         (@{
                            PROPERTY(samples, ORKTappingSample, NSArray, NO, nil, nil),
                            PROPERTY(stepViewSize, NSValue, NSObject, NO,
                                     ^id(id value, __unused ORKESerializationContext *context) { return value?[ORKESerializerHelper dictionaryFromCGSize:((NSValue *)value).CGSizeValue]:nil; },
                                     ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGSize:[ORKESerializerHelper sizeFromDictionary:dict]]; }),
                            PROPERTY(buttonRect1, NSValue, NSObject, NO,
                                     ^id(id value, __unused ORKESerializationContext *context) { return value?[ORKESerializerHelper dictionaryFromCGRect:((NSValue *)value).CGRectValue]:nil; },
                                     ^id(id dict, __unused ORKESerializationContext *context) {return [NSValue valueWithCGRect:[ORKESerializerHelper rectFromDictionary:dict]]; }),
                            PROPERTY(buttonRect2, NSValue, NSObject, NO,
                                     ^id(id value, __unused ORKESerializationContext *context) { return value?[ORKESerializerHelper dictionaryFromCGRect:((NSValue *)value).CGRectValue]:nil; },
                                     ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGRect:[ORKESerializerHelper rectFromDictionary:dict]]; })
                            })),
            
                   ENTRY(ORKTrailmakingTap,
                         nil,
                         (@{
                            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(index, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(incorrect, NSNumber, NSObject, NO, nil, nil),
                            })),
                   ENTRY(ORKTrailmakingResult,
                         nil,
                         (@{
                            PROPERTY(taps, ORKTrailmakingTap, NSArray, NO, nil, nil),
                            PROPERTY(numberOfErrors, NSNumber, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKSpatialSpanMemoryGameTouchSample,
                         nil,
                         (@{
                            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(targetIndex, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(correct, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(location, NSValue, NSObject, NO,
                                     ^id(id value, __unused ORKESerializationContext *context) { return value?[ORKESerializerHelper dictionaryFromCGPoint:((NSValue *)value).CGPointValue]:nil; },
                                     ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGPoint:[ORKESerializerHelper pointFromDictionary:dict]]; })
                            })),
                    ENTRY(ORKSpatialSpanMemoryGameRecord,
                          nil,
                          (@{
                             PROPERTY(seed, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(sequence, NSNumber, NSArray, NO, nil, nil),
                             PROPERTY(gameSize, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(gameStatus, NSNumber, NSObject, NO,
                                     ^id(id numeric, __unused ORKESerializationContext *context) {
                                        return [ORKESerializerHelper tableMapForwardWithIndex:((NSNumber *)numeric).integerValue table:[ORKESerializerHelper memoryGameStatusTable]];
                                     },
                                     ^id(id string, __unused ORKESerializationContext *context) {
                                         return @([ORKESerializerHelper tableMapReverseWithValue:string table:[ORKESerializerHelper memoryGameStatusTable]]);
                                     }),
                             PROPERTY(score, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(touchSamples, ORKSpatialSpanMemoryGameTouchSample, NSArray, NO,nil, nil),
                             PROPERTY(targetRects, NSValue, NSArray, NO,
                                      ^id(id value, __unused ORKESerializationContext *context) { return value?[ORKESerializerHelper dictionaryFromCGRect:((NSValue *)value).CGRectValue]:nil; },
                                      ^id(id dict, __unused ORKESerializationContext *context) { return [NSValue valueWithCGRect:[ORKESerializerHelper rectFromDictionary:dict]]; }),
                          })),
                   ENTRY(ORKSpatialSpanMemoryResult,
                         nil,
                         (@{
                            PROPERTY(score, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(numberOfGames, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(numberOfFailures, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(gameRecords, ORKSpatialSpanMemoryGameRecord, NSArray, NO, nil, nil)
                            })),

                   ENTRY(ORKToneAudiometrySample,
                         nil,
                         (@{
                            PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(channel, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(amplitude, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(channelSelected, NSNumber, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKToneAudiometryResult,
                         nil,
                         (@{
                            PROPERTY(outputVolume, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(samples, ORKToneAudiometrySample, NSArray, NO, nil, nil),
                            })),
                   ENTRY(ORKdBHLToneAudiometryUnit,
                         nil,
                         (@{
                            PROPERTY(dBHLValue, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(startOfUnitTimeStamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(preStimulusDelay, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(userTapTimeStamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(timeoutTimeStamp, NSNumber, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKdBHLToneAudiometryFrequencySample,
                         nil,
                         (@{
                            PROPERTY(frequency, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(calculatedThreshold, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(channel, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(units, ORKdBHLToneAudiometryUnit, NSArray, NO, nil, nil)
                            })),
                   ENTRY(ORKdBHLToneAudiometryResult,
                         nil,
                         (@{
                            PROPERTY(outputVolume, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(tonePlaybackDuration, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(postStimulusDelay, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(headphoneType, NSString, NSObject, NO, nil, nil),
                            PROPERTY(samples, ORKdBHLToneAudiometryFrequencySample, NSArray, NO, nil, nil)
                            })),
                   ENTRY(ORKReactionTimeResult,
                         nil,
                         (@{
                            PROPERTY(timestamp, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(isSuccessful, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(fileResults, ORKFileResult, NSArray, NO, nil, nil)
                            })),
                   ENTRY(ORKSpeechInNoiseResult,
                   nil,
                   (@{
                       PROPERTY(filename, NSString, NSObject, NO, nil, nil),
                       PROPERTY(targetSentence, NSString, NSObject, NO, nil, nil)
                      })),
                   ENTRY(ORKSpeechRecognitionResult,
                         nil,
                        [ORKESerializerHelper dictionaryForORKSpeechRecognitionResult]),
                   ENTRY(ORKStroopResult,
                         nil,
                         (@{
                            PROPERTY(startTime, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(endTime, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(color, NSString, NSObject, NO, nil, nil),
                            PROPERTY(text, NSString, NSObject, NO, nil, nil),
                            PROPERTY(colorSelected, NSString, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKAccuracyStroopResult,
                         nil,
                         (@{
                             PROPERTY(didSelectCorrectColor, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(timeTakenToSelect, NSNumber, NSObject, NO, nil, nil),
                             PROPERTY(distanceToClosestCenter, NSNumber, NSObject, NO, nil, nil)
                          })),
                   ENTRY(ORKTimedWalkResult,
                         nil,
                         (@{
                            PROPERTY(distanceInMeters, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(timeLimit, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(duration, NSNumber, NSObject, NO, nil, nil),
                            })),
                   ENTRY(ORKPSATSample,
                         nil,
                         (@{
                            PROPERTY(correct, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(digit, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(answer, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(time, NSNumber, NSObject, NO, nil, nil),
                            })),
                   ENTRY(ORKPSATResult,
                         nil,
                         (@{
                            PROPERTY(presentationMode, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(interStimulusInterval, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(stimulusDuration, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(length, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalCorrect, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalDyad, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalTime, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(initialDigit, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(samples, ORKPSATSample, NSArray, NO, nil, nil),
                            })),
                   ENTRY(ORKRangeOfMotionResult,
                         nil,
                         (@{
                            PROPERTY(start, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(finish, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(minimum, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(maximum, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(range, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(fileResults, ORKFileResult, NSArray, NO, nil, nil),
                            })),
                   ENTRY(ORKTowerOfHanoiResult,
                         nil,
                         (@{
                            PROPERTY(puzzleWasSolved, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(moves, ORKTowerOfHanoiMove, NSArray, YES, nil, nil),
                            })),
                   ENTRY(ORKTowerOfHanoiMove,
                         nil,
                         (@{
                            PROPERTY(timestamp, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(donorTowerIndex, NSNumber, NSObject, YES, nil, nil),
                            PROPERTY(recipientTowerIndex, NSNumber, NSObject, YES, nil, nil),
                            })),
                   ENTRY(ORKHolePegTestSample,
                         nil,
                         (@{
                            PROPERTY(time, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(distance, NSNumber, NSObject, NO, nil, nil)
                            })),
                   ENTRY(ORKHolePegTestResult,
                         nil,
                         (@{
                            PROPERTY(movingDirection, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(dominantHandTested, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(numberOfPegs, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(threshold, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(rotated, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalSuccesses, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalFailures, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalTime, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(totalDistance, NSNumber, NSObject, NO, nil, nil),
                            PROPERTY(samples, ORKHolePegTestSample, NSArray, NO, nil, nil),
                            })),
                   ENTRY(ORK3DModelManager,
                  ^id(__unused NSDictionary *dict, __unused ORKESerializationPropertyGetter getter) {
                       return [[ORK3DModelManager alloc] init];
                   },
                   (@{
                      PROPERTY(allowsSelection, NSNumber, NSObject, YES, nil, nil),
                      PROPERTY(identifiersOfObjectsToHighlight, NSString, NSArray, YES, nil, nil),
                      PROPERTY(highlightColor, UIColor, NSObject, YES,
                               ^id(id color, __unused ORKESerializationContext *context) { return [ORKESerializerHelper dictionaryFromColor:color]; },
                      ^id(id dict, __unused ORKESerializationContext *context) { return [ORKESerializerHelper colorFromDictionary:dict]; })
                      })),
                   ENTRY(ORKUSDZModelManagerResult,
                         nil,
                         (@{
                             PROPERTY(identifiersOfSelectedObjects, NSString, NSArray, YES, nil, nil),
                             PROPERTY(identifierOfObjectSelectedAtClose, NSString, NSObject, YES, nil, nil)
                          })),
                   ENTRY(ORKUSDZModelManager,
                   ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                        return [[ORKUSDZModelManager alloc] initWithUSDZFileName:GETPROP(dict, fileName)];
                    },
                    (@{
                       PROPERTY(enableContinueAfterSelection, NSNumber, NSObject, YES, nil, nil),
                       PROPERTY(fileName, NSString, NSObject, NO, nil, nil),
                       })),
                   ENTRY(ORK3DModelStep,
                   ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                        return [[ORK3DModelStep alloc] initWithIdentifier:GETPROP(dict, identifier) modelManager:GETPROP(dict, modelManager)];
                    },
                    (@{
                       PROPERTY(modelManager, ORK3DModelManager, NSObject, YES, nil, nil),
                       })),
        } mutableCopy];
#if ORK_FEATURE_HEALTHKIT_AUTHORIZATION
        [internalEncodingTable addEntriesFromDictionary:@{ ENTRY(ORKHealthClinicalTypeRecorderConfiguration,
               ^id(NSDictionary *dict, ORKESerializationPropertyGetter getter) {
                   return [[ORKHealthClinicalTypeRecorderConfiguration alloc] initWithIdentifier:GETPROP(dict, identifier) healthClinicalType:GETPROP(dict, healthClinicalType) healthFHIRResourceType:GETPROP(dict, healthFHIRResourceType)];
               },
               (@{
                  PROPERTY(healthClinicalType, HKClinicalType, NSObject, NO,
                  ^id(id type, __unused ORKESerializationContext *context) { return [ORKESerializerHelper identifierFromClinicalType:type]; },
                  ^id(id identifier, __unused ORKESerializationContext *context) { return [ORKESerializerHelper typeFromIdentifier:identifier]; }),
                  PROPERTY(healthFHIRResourceType, NSString, NSObject, NO, nil, nil),
                  })) }];
#endif
    });

    return internalEncodingTable;
}

@end
