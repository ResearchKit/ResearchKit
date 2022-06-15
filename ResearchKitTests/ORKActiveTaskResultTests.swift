/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

import XCTest
@testable import ResearchKit

class ORKAmslerGridResultTests: XCTestCase {
    var result: ORKAmslerGridResult!
    var identifier: String!
    var image: UIImage!
    var path: UIBezierPath!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        let bundle = Bundle(identifier: "org.researchkit.ResearchKit")
        image = UIImage(named: "amslerGrid", in: bundle, compatibleWith: nil)
        path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 50, height: 50))
        result = ORKAmslerGridResult(identifier: identifier, image: image, path: [path], eyeSide: .left)
    }
    
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.image, image)
        XCTAssertEqual(result.path, [path])
        XCTAssertEqual(result.eyeSide, ORKAmslerGridEyeSide.left)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date

        let newResult = ORKAmslerGridResult(identifier: identifier, image: image, path: [path], eyeSide: .left)
        newResult.startDate = date
        newResult.endDate = date
        XCTAssert(result.isEqual(newResult))
    }
}


class ORKHolePegTestResultTests: XCTestCase {
    var result: ORKHolePegTestResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKHolePegTestResult(identifier: identifier)
        
        result.movingDirection = ORKBodySagittal(rawValue: 2)!
        result.isDominantHandTested = true
        result.numberOfPegs = 2
        result.threshold = 2.0
        result.isRotated = false
        result.totalSuccesses = 10
        result.totalFailures = 5
        result.totalTime = 5.0
        result.totalDistance = 10.0
        result.samples = [2, 4]
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.movingDirection, ORKBodySagittal(rawValue: 2))
        XCTAssertEqual(result.isDominantHandTested, true)
        XCTAssertEqual(result.numberOfPegs, 2)
        XCTAssertEqual(result.threshold, 2.0)
        XCTAssertEqual(result.isRotated, false)
        XCTAssertEqual(result.totalSuccesses, 10)
        XCTAssertEqual(result.totalFailures, 5)
        XCTAssertEqual(result.totalTime, 5.0)
        XCTAssertEqual(result.totalDistance, 10.0)
        guard let samples = result.samples as? [Int] else {
            XCTFail("unable to cast samples array to array of int")
            return
        }
        XCTAssertEqual(samples, [2, 4])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKHolePegTestResult(identifier: identifier)
        newResult.movingDirection = .left
        newResult.isDominantHandTested = true
        newResult.numberOfPegs = 5
        newResult.movingDirection = ORKBodySagittal(rawValue: 2)!
        newResult.isDominantHandTested = true
        newResult.numberOfPegs = 2
        newResult.threshold = 2.0
        newResult.isRotated = false
        newResult.totalSuccesses = 10
        newResult.totalFailures = 5
        newResult.totalTime = 5.0
        newResult.totalDistance = 10.0
        newResult.samples = [2, 4]
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKPSATResultTests: XCTestCase {
    var result: ORKPSATResult!
    var identifier: String!
    var sample: ORKPSATSample!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "TESTS"
        result = ORKPSATResult(identifier: identifier)
        
        result.presentationMode = .auditory
        result.interStimulusInterval = 2
        result.stimulusDuration = 3
        result.length = 4
        result.totalCorrect = 5
        result.totalDyad = 2
        result.totalTime = 20
        result.initialDigit = 20
        sample = ORKPSATSample()
        sample.answer = 20
        result.samples = [sample]
    }
    
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.presentationMode, ORKPSATPresentationMode.auditory)
        XCTAssertEqual(result.interStimulusInterval, 2)
        XCTAssertEqual(result.stimulusDuration, 3)
        XCTAssertEqual(result.length, 4)
        XCTAssertEqual(result.totalCorrect, 5)
        XCTAssertEqual(result.totalDyad, 2)
        XCTAssertEqual(result.totalTime, 20)
        XCTAssertEqual(result.initialDigit, 20)
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKPSATResult(identifier: identifier)
        newResult.presentationMode = .auditory
        newResult.interStimulusInterval = 2
        newResult.stimulusDuration = 3
        newResult.length = 4
        newResult.totalCorrect = 5
        newResult.totalDyad = 2
        newResult.totalTime = 20
        newResult.initialDigit = 20
        newResult.samples = [sample]
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKRangeOfMotionResultTests: XCTestCase {
    var result: ORKRangeOfMotionResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKRangeOfMotionResult(identifier: identifier)
        
        result.start = 0
        result.finish = 50
        result.minimum = 10
        result.maximum = 50
        result.range = 10
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.start, 0)
        XCTAssertEqual(result.finish, 50)
        XCTAssertEqual(result.minimum, 10)
        XCTAssertEqual(result.maximum, 50)
        XCTAssertEqual(result.range, 10)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKRangeOfMotionResult(identifier: identifier)
        newResult.start = 0
        newResult.finish = 50
        newResult.minimum = 10
        newResult.maximum = 50
        newResult.range = 10
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKReactionTimeResultTests: XCTestCase {
    var result: ORKReactionTimeResult!
    var identifier: String!
    var fileResult: ORKFileResult!
    var url: URL!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKReactionTimeResult(identifier: identifier)
        
        result.timestamp = 10
        fileResult = ORKFileResult()
        url = URL(fileURLWithPath: "FILEURL")
        fileResult.fileURL = url
        result.fileResult = fileResult
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.timestamp, 10)
        XCTAssertEqual(result.fileResult, fileResult)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKReactionTimeResult(identifier: identifier)
        newResult.timestamp = 10
        newResult.fileResult = fileResult
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKSpatialSpanMemoryResultTests: XCTestCase {
    var result: ORKSpatialSpanMemoryResult!
    var identifier: String!
    var gameRecord: ORKSpatialSpanMemoryGameRecord!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKSpatialSpanMemoryResult(identifier: identifier)
        
        result.score = 0
        result.numberOfGames = 20
        result.numberOfFailures = 20
        gameRecord = ORKSpatialSpanMemoryGameRecord()
        gameRecord.score = 10
        result.gameRecords = [gameRecord]
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.score, 0)
        XCTAssertEqual(result.numberOfGames, 20)
        XCTAssertEqual(result.numberOfFailures, 20)
        XCTAssertEqual(result.gameRecords, [gameRecord])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKSpatialSpanMemoryResult(identifier: identifier)
        newResult.score = 0
        newResult.numberOfGames = 20
        newResult.numberOfFailures = 20
        newResult.gameRecords = [gameRecord]
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKSpeechRecognitionResultTests: XCTestCase {
    var result: ORKSpeechRecognitionResult!
    var identifier: String!
    var transcription: SFTranscription!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "Result"
        result = ORKSpeechRecognitionResult(identifier: identifier)
        
        transcription = SFTranscription()
        result.transcription = transcription
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.transcription, transcription)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKSpeechRecognitionResult(identifier: identifier)
        newResult.transcription = transcription
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKStroopResultTests: XCTestCase {
    var result: ORKStroopResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKStroopResult(identifier: identifier)
        
        result.startTime = 0
        result.endTime = 100
        result.color = "BLUE"
        result.text = "TEXT"
        result.colorSelected = "RED"
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.startTime, 0)
        XCTAssertEqual(result.endTime, 100)
        XCTAssertEqual(result.color, "BLUE")
        XCTAssertEqual(result.text, "TEXT")
        XCTAssertEqual(result.colorSelected, "RED")
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKStroopResult(identifier: identifier)
        newResult.startTime = 0
        newResult.endTime = 100
        newResult.color = "BLUE"
        newResult.text = "TEXT"
        newResult.colorSelected = "RED"
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKTappingIntervalResultTests: XCTestCase {
    var result: ORKTappingIntervalResult!
    var identifier: String!
    var sample: ORKTappingSample!
    var stepViewSize: CGSize!
    var buttonRect1: CGRect!
    var buttonRect2: CGRect!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKTappingIntervalResult(identifier: identifier)
        
        sample = ORKTappingSample()
        sample.duration = 20
        stepViewSize = CGSize(width: 50, height: 50)
        buttonRect1 = CGRect(x: 0, y: 0, width: 50, height: 50)
        buttonRect2 = CGRect(x: 100, y: 100, width: 50, height: 50)
        result.samples = [sample]
        result.stepViewSize = stepViewSize
        result.buttonRect1 = buttonRect1
        result.buttonRect2 = buttonRect2
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.samples, [sample])
        XCTAssertEqual(result.stepViewSize, stepViewSize)
        XCTAssertEqual(result.buttonRect1, buttonRect1)
        XCTAssertEqual(result.buttonRect2, buttonRect2)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKTappingIntervalResult(identifier: identifier)
        newResult.samples = [sample]
        newResult.stepViewSize = stepViewSize
        newResult.buttonRect1 = buttonRect1
        newResult.buttonRect2 = buttonRect2
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKTimedWalkResultTests: XCTestCase {
    var result: ORKTimedWalkResult!
    var identifier: String!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKTimedWalkResult(identifier: identifier)
        
        result.distanceInMeters = 100
        result.timeLimit = 100
        result.duration = 20
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.distanceInMeters, 100)
        XCTAssertEqual(result.timeLimit, 100)
        XCTAssertEqual(result.duration, 20)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKTimedWalkResult(identifier: identifier)
        newResult.distanceInMeters = 100
        newResult.timeLimit = 100
        newResult.duration = 20
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKToneAudiometryResultTests: XCTestCase {
    var result: ORKToneAudiometryResult!
    var identifier: String!
    var sample: ORKToneAudiometrySample!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKToneAudiometryResult(identifier: identifier)
        
        result.outputVolume = 100
        sample = ORKToneAudiometrySample()
        sample.amplitude = 100
        sample.frequency = 100
        result.samples = [sample]
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.outputVolume, 100)
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKToneAudiometryResult(identifier: identifier)
        newResult.outputVolume = 100
        newResult.samples = [sample]
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKdBHLToneAudiometryResultTests: XCTestCase {
    var result: ORKdBHLToneAudiometryResult!
    var identifier: String!
    var sample: ORKdBHLToneAudiometryFrequencySample!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKdBHLToneAudiometryResult(identifier: identifier)
        
        result.outputVolume = 100
        result.tonePlaybackDuration = 360
        result.postStimulusDelay = 10
        result.headphoneType = ORKHeadphoneTypeIdentifier.airPods
        sample = ORKdBHLToneAudiometryFrequencySample()
        sample.frequency = 100
        result.samples = [sample]
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.outputVolume, 100)
        XCTAssertEqual(result.tonePlaybackDuration, 360)
        XCTAssertEqual(result.postStimulusDelay, 10)
        XCTAssertEqual(result.headphoneType, ORKHeadphoneTypeIdentifier.airPods)
        XCTAssertEqual(result.samples, [sample])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKdBHLToneAudiometryResult(identifier: identifier)
        newResult.outputVolume = 100
        newResult.tonePlaybackDuration = 360
        newResult.postStimulusDelay = 10
        newResult.headphoneType = ORKHeadphoneTypeIdentifier.airPods
        newResult.samples = [sample]
        newResult.startDate = date
        newResult.endDate = date
        
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKTowerOfHanoiResultTests: XCTestCase {
    var result: ORKTowerOfHanoiResult!
    var identifier: String!
    var moveOne: ORKTowerOfHanoiMove!
    var moveTwo: ORKTowerOfHanoiMove!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKTowerOfHanoiResult(identifier: identifier)
        
        result.puzzleWasSolved = false
        moveOne = ORKTowerOfHanoiMove()
        moveOne.donorTowerIndex = 0
        moveOne.recipientTowerIndex = 1
        moveTwo = ORKTowerOfHanoiMove()
        moveTwo.donorTowerIndex = 4
        moveTwo.recipientTowerIndex = 2
        result.moves = [moveOne, moveTwo]
    }
 
    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.puzzleWasSolved, false)
        XCTAssertEqual(result.moves, [moveOne, moveTwo])
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKTowerOfHanoiResult(identifier: identifier)
        newResult.startDate = date
        newResult.endDate = date
        newResult.puzzleWasSolved = false
        newResult.moves = [moveOne, moveTwo]
        XCTAssert(result.isEqual(newResult))
    }
}

class ORKTrailmakingResultTests: XCTestCase {
    
    var result: ORKTrailmakingResult!
    var identifier: String!
    var tap: ORKTrailmakingTap!
    let date = Date()
    
    override func setUp() {
        super.setUp()
        identifier = "RESULT"
        result = ORKTrailmakingResult(identifier: identifier)
        
        tap = ORKTrailmakingTap()
        tap.incorrect = false
        result.taps = [tap]
        result.numberOfErrors = 1
    }

    func testProperties() {
        XCTAssertEqual(result.identifier, identifier)
        XCTAssertEqual(result.taps, [tap])
        XCTAssertEqual(result.numberOfErrors, 1)
    }
    
    func testIsEqual() {
        result.startDate = date
        result.endDate = date
        
        let newResult = ORKTrailmakingResult(identifier: identifier)
        newResult.startDate = date
        newResult.endDate = date
        newResult.taps = [tap]
        newResult.numberOfErrors = 1
        
        XCTAssert(result.isEqual(newResult))
    }
}
