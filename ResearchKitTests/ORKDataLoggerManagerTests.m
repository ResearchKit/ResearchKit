/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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
@import ResearchKit.Private;


@interface ORKDataLoggerManagerTests : XCTestCase <ORKDataLoggerManagerDelegate> {
    NSURL *_directory;
    ORKDataLoggerManager *_manager;
    
    NSInteger _pendingUploadBytesReachedCounter;
    unsigned long long _lastPendingUploadBytes;
    NSInteger _totalBytesReachedCounter;
    unsigned long long _lastTotalBytes;
}

@end


@implementation ORKDataLoggerManagerTests

- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLogger pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes {
    _pendingUploadBytesReachedCounter ++;
    _lastPendingUploadBytes = pendingUploadBytes;
}

- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLogger totalBytesReachedThreshold:(unsigned long long)totalBytes {
    _totalBytesReachedCounter ++;
    _lastTotalBytes = totalBytes;
}

- (void)setUp {
    [super setUp];
    
    _directory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] isDirectory:YES];
    
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_directory withIntermediateDirectories:YES attributes:nil error:nil];
    XCTAssertTrue(success, @"Create log directory");
    _pendingUploadBytesReachedCounter = 0;
    _totalBytesReachedCounter = 0;
    _lastPendingUploadBytes = 0;
    _lastTotalBytes = 0;
    _manager = [[ORKDataLoggerManager alloc] initWithDirectory:_directory delegate:self];
    XCTAssertNotNil(_manager);
}

- (void)tearDown {
    [super tearDown];
    _manager.delegate = nil;
    _manager = nil;
    _pendingUploadBytesReachedCounter = 0;
    _totalBytesReachedCounter = 0;
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:_directory error:nil];
    XCTAssertTrue(success, @"Remove log directory");
    _directory = nil;
    
}

- (void)addLoggers123 {
    [_manager addJSONDataLoggerForLogName:@"test1"];
    [_manager addJSONDataLoggerForLogName:@"test2"];
    [_manager addJSONDataLoggerForLogName:@"test3"];
    
    XCTAssertEqual([_manager logNames].count, 3);
}

- (void)testPreservesParameters {
    _manager.totalBytesThreshold = 10;
    _manager.pendingUploadBytesThreshold = 12;
    _manager.delegate = nil;
    _manager = nil;
    
    _manager = [[ORKDataLoggerManager alloc] initWithDirectory:_directory delegate:self];
    XCTAssertNotNil(_manager);
    
    XCTAssertEqual(_manager.totalBytesThreshold, 10);
    XCTAssertEqual(_manager.pendingUploadBytesThreshold, 12);
    
}

- (void)testAddingLoggers {
    [self addLoggers123];
    XCTAssertEqualObjects([_manager dataLoggerForLogName:@"test1"].logName, @"test1");
    XCTAssertEqualObjects([_manager dataLoggerForLogName:@"test2"].logName, @"test2");
    XCTAssertEqualObjects([_manager dataLoggerForLogName:@"test3"].logName, @"test3");
}

- (void)testEnumerationSortOrder {
    [self addLoggers123];
    
    ORKDataLogger *dm3 = [_manager dataLoggerForLogName:@"test3"];
    ORKDataLogger *dm2 = [_manager dataLoggerForLogName:@"test2"];
    ORKDataLogger *dm1 = [_manager dataLoggerForLogName:@"test1"];
    
    NSDictionary *jsonObject = @{@"test": @"1234"};
    
    NSError *error = nil;
    XCTAssertTrue([dm3 append:jsonObject error:&error]);
    XCTAssertNil(error);
    [dm3 finishCurrentLog];
    
    XCTAssertTrue([dm3 append:jsonObject error:&error]);
    XCTAssertNil(error);
    [dm3 finishCurrentLog];
    // Always wait 1.1 seconds, because the string we sort on only changes with time after 1 sec
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    
    XCTAssertTrue([dm1 append:jsonObject error:&error]);
    XCTAssertNil(error);
    [dm1 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    
    XCTAssertTrue([dm2 append:jsonObject error:&error]);
    XCTAssertNil(error);
    [dm2 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    
    XCTAssertTrue([dm1 append:jsonObject error:&error]);
    XCTAssertNil(error);
    [dm1 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.1]];
    
    NSMutableArray *dataLoggers = [NSMutableArray array];
    BOOL success = [_manager enumerateLogsNeedingUpload:^(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop) {
        [dataLoggers addObject:dataLogger];
    } error:&error];
    
    XCTAssertTrue(success);
    XCTAssertNil(error);
    
    NSArray *a = @[dm3, dm3, dm1, dm2, dm1];
    // Data loggers should be referenced in the order that their files were added (with repeats where appropriate)
    XCTAssertEqualObjects(dataLoggers, a);
    
}

- (void)testRemoveOldLogs {
    [self addLoggers123];
    
    _manager.totalBytesThreshold = 10;
    
    const NSTimeInterval filesystemSettleTime = 0.5;
    
    ORKDataLogger *dm3 = [_manager dataLoggerForLogName:@"test3"];
    ORKDataLogger *dm2 = [_manager dataLoggerForLogName:@"test2"];
    ORKDataLogger *dm1 = [_manager dataLoggerForLogName:@"test1"];
    
    XCTAssertTrue([dm3 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm2 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm1 append:@{@"test":@"blah"} error:nil]);
    [dm3 finishCurrentLog];
    [dm2 finishCurrentLog];
    [dm1 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:filesystemSettleTime]];
    
    unsigned long long bytes = _manager.totalBytes;

    // Check we got the delegate callback appropriately
    XCTAssertGreaterThan(bytes, _manager.totalBytesThreshold);
    XCTAssertEqual(_totalBytesReachedCounter, 1);
    XCTAssertEqual(_pendingUploadBytesReachedCounter, 0);
    
    NSError *error = nil;
    XCTAssertTrue([_manager removeOldAndUploadedLogsToThreshold:9 error:&error]);
    XCTAssertNil(error);
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:filesystemSettleTime]];
    XCTAssertTrue(_manager.totalBytes <= 10);
    
    XCTAssertTrue([dm3 append:@{@"test":@"blah"} error:nil]);
    [dm3 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:filesystemSettleTime]];
    
    bytes = _manager.totalBytes;
    XCTAssertGreaterThan(bytes, _manager.totalBytesThreshold);
    XCTAssertTrue(bytes > _manager.totalBytesThreshold);
    XCTAssertEqual(_totalBytesReachedCounter, 2);
    XCTAssertEqual(_pendingUploadBytesReachedCounter, 0);
}

- (void)testDelegateThresholds {
    [self addLoggers123];
    
    _manager.pendingUploadBytesThreshold = 10;
    
    ORKDataLogger *dm3 = [_manager dataLoggerForLogName:@"test3"];
    ORKDataLogger *dm2 = [_manager dataLoggerForLogName:@"test2"];
    ORKDataLogger *dm1 = [_manager dataLoggerForLogName:@"test1"];
    
    XCTAssertTrue([dm3 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm2 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm1 append:@{@"test":@"blah"} error:nil]);
    [dm3 finishCurrentLog];
    [dm2 finishCurrentLog];
    [dm1 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    unsigned long long bytes = _manager.pendingUploadBytes;
    XCTAssertTrue(bytes > _manager.pendingUploadBytesThreshold);
    XCTAssertEqual(_totalBytesReachedCounter, 0);
    XCTAssertEqual(_pendingUploadBytesReachedCounter, 1);
    
    // Mark all the files uploaded, then create some more files. Check we get another delegate call
    BOOL success = [_manager enumerateLogsNeedingUpload:^(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop) {
        XCTAssertTrue([dataLogger markFileUploaded:YES atURL:logFileUrl error:nil]);
    } error:nil];
    XCTAssertTrue(success);
    
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    bytes = _manager.pendingUploadBytes;
    XCTAssertTrue(bytes < _manager.pendingUploadBytesThreshold);
    
    XCTAssertTrue([dm3 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm2 append:@{@"test":@"blah"} error:nil]);
    XCTAssertTrue([dm1 append:@{@"test":@"blah"} error:nil]);
    [dm3 finishCurrentLog];
    [dm2 finishCurrentLog];
    [dm1 finishCurrentLog];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    bytes = _manager.pendingUploadBytes;
    XCTAssertTrue(bytes > _manager.pendingUploadBytesThreshold);
    XCTAssertEqual(_totalBytesReachedCounter, 0);
    XCTAssertEqual(_pendingUploadBytesReachedCounter, 2);
}

@end
