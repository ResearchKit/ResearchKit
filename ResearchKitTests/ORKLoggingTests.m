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

@import XCTest;
#import <ResearchKit/ORKHelpers_Internal.h>

@interface ORKLoggingTests : XCTestCase

@end

@implementation ORKLoggingTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testDisablingLogging {
    int stderrCopy = dup(STDERR_FILENO);
    int pipefd[2];

    pipe(pipefd);
    dup2(pipefd[1], STDERR_FILENO);
    close(pipefd[1]);

    NSFileHandle *stderrReader = [[NSFileHandle alloc] initWithFileDescriptor:pipefd[0]];

    for (int i = 0; i < 2; ++i) {
        ORK_Log("[$$OK_DEFAULT$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Info("[$$OK_INFO$$], self: %@, aThing: %d", self, 42);
//        ORK_Log_Debug("[$$OK_DEBUG$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Error("[$$OK_ERROR$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Fault("[$$OK_FAULT$$], self: %@, aThing: %d", self, 42);
        ORKLoggingEnabled = NO;
        ORK_Log("[$$NOTOK_DEFAULT$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Info("[$$NOTOK_INFO$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Debug("[$$NOTOK_DEBUG$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Error("[$$NOTOK_ERROR$$], self: %@, aThing: %d", self, 42);
        ORK_Log_Fault("[$$NOTOK_FAULT$$], self: %@, aThing: %d", self, 42);

        NSData *data = [stderrReader availableData];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        XCTAssertTrue([output containsString:@"[$$OK_DEFAULT$$]"]);
        XCTAssertTrue([output containsString:@"[$$OK_INFO$$]"]);
//        XCTAssertTrue([output containsString:@"[$$OK_DEBUG$$]"]);
        XCTAssertTrue([output containsString:@"[$$OK_ERROR$$]"]);
        XCTAssertTrue([output containsString:@"[$$OK_FAULT$$]"]);
        XCTAssertFalse([output containsString:@"[$$NOTOK_DEFAULT$$]"]);
        XCTAssertFalse([output containsString:@"[$$NOTOK_INFO$$]"]);
        XCTAssertFalse([output containsString:@"[$$NOTOK_DEBUG$$]"]);
        XCTAssertFalse([output containsString:@"[$$NOTOK_ERROR$$]"]);
        XCTAssertFalse([output containsString:@"[$$NOTOK_FAULT$$]"]);

        ORKLoggingEnabled = YES;
    }

    close(pipefd[0]);
    [stderrReader closeFile];
    dup2(stderrCopy, STDERR_FILENO);
}


@end
