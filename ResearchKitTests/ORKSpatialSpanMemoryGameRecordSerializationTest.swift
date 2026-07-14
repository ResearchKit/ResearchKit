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

import ResearchKitActiveTask
import Testing

@Suite(.tags(.serialization))
struct ORKSpatialSpanMemoryGameRecordSerializationTests {
    @Test
    func testORKSpatialSpanMemoryGameRecord() throws {
        let touchSample1 = ORKSpatialSpanMemoryGameTouchSample()
        touchSample1.isCorrect = true
        touchSample1.location = CGPoint(
            x: 335,
            y: 330
        )
        touchSample1.targetIndex = 6
        touchSample1.timestamp = 1.0373990833177231
        
        let touchSample2 = ORKSpatialSpanMemoryGameTouchSample()
        touchSample2.isCorrect = true
        touchSample2.location = CGPoint(
            x: 334,
            y: 410.66665649414062
        )
        touchSample2.targetIndex = 7
        touchSample2.timestamp = 1.270191750023514
      
        let instance = ORKSpatialSpanMemoryGameRecord()
        instance.seed = 45
        instance.sequence = [
            1,
            2,
            3
        ]
        instance.gameSize = 5
        instance.gameStatus = .timeout
        instance.score = 50
        instance.touchSamples = [touchSample1, touchSample2]
        instance.targetRects = [
            NSValue(
              cgRect: CGRect(
                x: 44,
                y: 256.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 44,
                y: 370.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 44,
                y: 484.66666666666669,
                width: 114.00000000000006,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 158,
                y: 256.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 158,
                y: 370.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 158,
                y: 484.66666666666669,
                width: 114.00000000000006,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 272,
                y: 256.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 272,
                y: 370.66666666666669,
                width: 114,
                height: 114
              )
            ),
            NSValue(
              cgRect: CGRect(
                x: 272,
                y: 484.66666666666669,
                width: 114.00000000000006,
                height: 114
              )
            )
        ]
        
        let expectation = """
        {
          "_class" : "ORKSpatialSpanMemoryGameRecord",
          "gameSize" : 5,
          "gameStatus" : "timeout",
          "score" : 50,
          "seed" : 45,
          "sequence" : [
            1,
            2,
            3
          ],
          "targetRects" : [
            {
              "origin" : {
                "x" : 44,
                "y" : 256.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 44,
                "y" : 370.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 44,
                "y" : 484.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114.00000000000006
              }
            },
            {
              "origin" : {
                "x" : 158,
                "y" : 256.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 158,
                "y" : 370.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 158,
                "y" : 484.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114.00000000000006
              }
            },
            {
              "origin" : {
                "x" : 272,
                "y" : 256.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 272,
                "y" : 370.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114
              }
            },
            {
              "origin" : {
                "x" : 272,
                "y" : 484.66666666666669
              },
              "size" : {
                "h" : 114,
                "w" : 114.00000000000006
              }
            }
          ],
          "touchSamples" : [
            {
              "_class" : "ORKSpatialSpanMemoryGameTouchSample",
              "correct" : true,
              "location" : {
                "x" : 335,
                "y" : 330
              },
              "targetIndex" : 6,
              "timestamp" : 1.0373990833177231
            },
            {
              "_class" : "ORKSpatialSpanMemoryGameTouchSample",
              "correct" : true,
              "location" : {
                "x" : 334,
                "y" : 410.66665649414062
              },
              "targetIndex" : 7,
              "timestamp" : 1.270191750023514
            }
          ]
        }
        """
        
        try SerializationTestHelper.assertEquality(instance, expectation)
    }
}
