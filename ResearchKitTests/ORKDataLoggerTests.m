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


@interface ORKDataLoggerTests : XCTestCase <ORKDataLoggerDelegate> {
    NSURL *_directory;
    NSString *_logName;
    ORKDataLogger *_dataLogger;
    
    NSMutableArray *_finishedLogFiles;
}

@end

@implementation ORKDataLoggerTests

- (void)setUp {
    [super setUp];
    
    _directory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] isDirectory:YES];
    
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:_directory withIntermediateDirectories:YES attributes:nil error:nil];
    XCTAssertTrue(success, @"Create log directory");
    
    _logName = @"test";
    
    _finishedLogFiles = [NSMutableArray array];
    _dataLogger = [ORKDataLogger JSONDataLoggerWithDirectory:_directory logName:_logName delegate:self];
}

- (void)tearDown {
    [super tearDown];
    
    [_dataLogger finishCurrentLog];
    _dataLogger.delegate = nil;
    [_finishedLogFiles removeAllObjects];
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:_directory error:nil];
    XCTAssertTrue(success, @"Remove log directory");
    _directory = nil;
    _logName = nil;
}

- (void)dataLogger:(ORKDataLogger *)dataLogger finishedLogFile:(NSURL *)fileUrl {
    XCTAssertEqual(_dataLogger, dataLogger, @"Should be the same");
    [_finishedLogFiles addObject:fileUrl];
}

- (void)testDoNothing {
    NSURL *url = [_dataLogger currentLogFileURL];
    XCTAssertTrue([[url URLByDeletingLastPathComponent] isEqual:_directory], @"current log file should be in _directory");
    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"File should not be created if we log nothing");
}

- (void)logJsonObject:(NSDictionary *)jsonObject {
    NSError *error = nil;
    BOOL success = [_dataLogger append:jsonObject error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
}

- (void)wait {
    // Let the runloop run once so we get our delegate callback
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
}

- (void)logJsonObjectAndRolloverAndWaitOnce:(NSDictionary *)jsonObject {
    [self logJsonObject:jsonObject];
    
    NSURL *url = [_dataLogger currentLogFileURL];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]]);
    
    [_dataLogger finishCurrentLog];
    
    [self wait];
}

- (void)testJSONFormatting {
    NSDictionary *jsonObject = @{@"test": @[@"a", @"b"], @"blah": @(1) };
    
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    
    XCTAssertEqual(_finishedLogFiles.count, 1);
    
    NSError *error = nil;
    NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:_finishedLogFiles[0]] options:(NSJSONReadingOptions)0 error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(jsonOut[@"items"][0], jsonObject);
}

- (void)testContinuesExistingLog {
    // Test that if you create a logger, and then kill it and create a new logger, the new one
    // continues from the right place without forcing a roll-over
    XCTAssertTrue([_dataLogger append:@{@"val":@(1)} error:nil]);
    
    _dataLogger.delegate = nil;
    
    _dataLogger = [ORKDataLogger JSONDataLoggerWithDirectory:_directory logName:_logName delegate:self];
    
    XCTAssertTrue([_dataLogger append:@{@"val":@(2)} error:nil]);
    
    [_dataLogger finishCurrentLog];
    
    [self wait];
    
    __block int count = 0;
    [_dataLogger enumerateLogsNeedingUpload:^(NSURL *logFileUrl, BOOL *stop) {
        count ++;
    } error:nil];
    XCTAssertEqual(count, 1);
    
    NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:_finishedLogFiles.lastObject] options:(NSJSONReadingOptions)0 error:nil];
    XCTAssertEqualObjects(jsonOut[@"items"][0][@"val"], @(1));
    XCTAssertEqualObjects(jsonOut[@"items"][1][@"val"], @(2));
}

- (void)testRemoveAllFiles {
    NSDictionary *jsonObject = @{@"test": @(1) };
    NSDictionary *jsonObject2 = @{@"test": @(2) };
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject2];
    
    XCTAssertEqual(_finishedLogFiles.count, 2);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager fileExistsAtPath:[(NSURL *)_finishedLogFiles[0] path]]);
    XCTAssertTrue([fileManager fileExistsAtPath:[(NSURL *)_finishedLogFiles[1] path]]);
    
    NSError *error = nil;
    XCTAssertTrue([_dataLogger removeAllFilesWithError:&error]);
    XCTAssertNil(error);
    
    XCTAssertFalse([fileManager fileExistsAtPath:[(NSURL *)_finishedLogFiles[0] path]]);
    XCTAssertFalse([fileManager fileExistsAtPath:[(NSURL *)_finishedLogFiles[1] path]]);
    
    NSArray *logs = [self allLogsWithError:&error];
    XCTAssertNil(error);
    XCTAssertEqual(logs.count, 0);
}

- (void)testMarkFileUploaded {
    NSDictionary *jsonObject = @{@"test": @(1) };
    NSDictionary *jsonObject2 = @{@"test": @(2) };
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject2];
    
    XCTAssertFalse([_dataLogger isFileUploadedAtURL:_finishedLogFiles[0]]);
    
    // Test direct attribute set/unset using underlying category
    XCTAssertFalse([_finishedLogFiles[0] ork_isUploaded]);
    XCTAssertTrue([_finishedLogFiles[0] ork_setUploaded:YES error:nil]);
    XCTAssertTrue([_finishedLogFiles[0] ork_isUploaded]);
    XCTAssertTrue([_dataLogger isFileUploadedAtURL:_finishedLogFiles[0]]);
    XCTAssertTrue([_finishedLogFiles[0] ork_setUploaded:NO error:nil]);
    XCTAssertFalse([_finishedLogFiles[0] ork_isUploaded]);
    
    XCTAssertFalse([_dataLogger isFileUploadedAtURL:_finishedLogFiles[0]]);
    
    // Test setting uploaded through the data logger
    NSError *error = nil;
    XCTAssertTrue([_dataLogger markFileUploaded:YES atURL:_finishedLogFiles[0] error:&error]);
    XCTAssertNil(error);
    
    XCTAssertTrue([_dataLogger isFileUploadedAtURL:_finishedLogFiles[0]]);
    XCTAssertFalse([_dataLogger isFileUploadedAtURL:_finishedLogFiles[1]]);
}

- (NSArray *)allLogsWithError:(NSError **)error {
    NSMutableArray *logs = [NSMutableArray array];
    [_dataLogger enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        [logs addObject:logFileUrl];
    } error:error];
    return logs;
}

- (NSArray *)logsUploaded:(BOOL)uploaded withError:(NSError **)error {
    NSMutableArray *logs = [NSMutableArray array];
    if (uploaded) {
        [_dataLogger enumerateLogsAlreadyUploaded:^(NSURL *logFileUrl, BOOL *stop) {
            [logs addObject:logFileUrl];
        } error:error];
    } else {
        [_dataLogger enumerateLogsNeedingUpload:^(NSURL *logFileUrl, BOOL *stop) {
            [logs addObject:logFileUrl];
        } error:error];
    }
    return logs;
}

- (void)testFileEnumerators {
    NSDictionary *jsonObject = @{@"test": @(1) };
    NSDictionary *jsonObject2 = @{@"test": @(2) };
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject2];
    
    XCTAssertEqual(_finishedLogFiles.count, 2);
    {
        NSError *error = nil;
        NSArray *uploaded = [self logsUploaded:YES withError:&error];
        XCTAssertNil(error);
        XCTAssertEqual(uploaded.count, 0);
        
        NSArray *needUpload = [self logsUploaded:NO withError:&error];
        XCTAssertNil(error);
        XCTAssertEqual(needUpload.count, 2);
    }
    
    {
        NSError *error = nil;
        XCTAssertTrue([_dataLogger markFileUploaded:YES atURL:_finishedLogFiles[0] error:&error]);
        XCTAssertNil(error);
        
        NSArray *uploaded = [self logsUploaded:YES withError:&error];
        XCTAssertNil(error);
        XCTAssertEqual(uploaded.count, 1);
        XCTAssertEqualObjects(uploaded, @[_finishedLogFiles[0]]);
        
        NSArray *needUpload = [self logsUploaded:NO withError:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(needUpload, @[_finishedLogFiles[1]]);
    }
}

- (void)testDataProtection {
    _dataLogger.fileProtectionMode = ORKFileProtectionComplete;
    
    NSDictionary *jsonObject = @{@"test": @(1) };
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    NSError *error = nil;
    XCTAssertTrue([_dataLogger append:jsonObject error:&error]);
    XCTAssertNil(error);
    
    NSArray *logs= [self allLogsWithError:&error];
    XCTAssertNil(error);
    XCTAssertEqual(logs.count, 1);
    
    NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:logs[0]] options:(NSJSONReadingOptions)0 error:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(jsonOut[@"items"][0], jsonObject);
    
#if !TARGET_IPHONE_SIMULATOR
    {
        NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[[_dataLogger currentLogFileURL] path] error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(attribs[NSFileProtectionKey], ORKFileProtectionFromMode(_dataLogger.fileProtectionMode));
    }
    {
        NSDictionary *attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[(NSURL *)logs[0] path] error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(attribs[NSFileProtectionKey], ORKFileProtectionFromMode(_dataLogger.fileProtectionMode));
    }
#endif
}

- (void)testFileSizeLimitTriggersRollover {
    _dataLogger.maximumCurrentLogFileSize = 50;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDictionary *jsonObject = @{@"x": @"1234567890"};
    [self logJsonObject:jsonObject];
    [self logJsonObject:jsonObject];
    
    [self wait];
    
    XCTAssertTrue([[fileManager attributesOfItemAtPath:[[_dataLogger currentLogFileURL] path] error:nil] fileSize] < 50);
    XCTAssertEqual(_finishedLogFiles.count, 0);
    
    [self logJsonObject:jsonObject];
    [self wait];
    XCTAssertTrue([[fileManager attributesOfItemAtPath:[[_dataLogger currentLogFileURL] path] error:nil] fileSize] < 50);
    XCTAssertEqual(_finishedLogFiles.count, 1);
    
    XCTAssertTrue([[fileManager attributesOfItemAtPath:[(NSURL *)_finishedLogFiles[0] path] error:nil] fileSize] >= 50);
    XCTAssertTrue([[fileManager attributesOfItemAtPath:[[_dataLogger currentLogFileURL] path] error:nil] fileSize] < 50);
}

- (void)testFirstWriteOpensFilehandle {
    XCTAssertNil([_dataLogger fileHandle]);
    NSDictionary *jsonObject = @{@"x": @"1234567890"};
    [self logJsonObject:jsonObject];
    XCTAssertNotNil([_dataLogger fileHandle]);
}

- (void)testExplicitRolloverBeforeHandleOpened {
    XCTAssertNil([_dataLogger fileHandle]);
    [_dataLogger finishCurrentLog];
    XCTAssertNil([_dataLogger fileHandle]);
    [self wait];
    XCTAssertEqual(_finishedLogFiles.count, 0);
}

- (void)testExplicitRolloverWithZeroLengthFile {
    XCTAssertNil([_dataLogger fileHandle]);
    NSDictionary *jsonObject = @{};
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    XCTAssertNil([_dataLogger fileHandle]);
    XCTAssertEqual(_finishedLogFiles.count, 1);
    [self logJsonObjectAndRolloverAndWaitOnce:jsonObject];
    XCTAssertEqual(_finishedLogFiles.count, 2);
}

- (void)testCurrentLogFileAlwaysHasValidJson {
    NSDictionary *jsonObject = @{@"x": @"1234567890"};
    [self logJsonObject:jsonObject];
    {
        NSError *error = nil;
        NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[_dataLogger currentLogFileURL]] options:(NSJSONReadingOptions)0 error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(jsonOut[@"items"][0], jsonObject);
    }
    [self logJsonObject:jsonObject];
    {
        NSError *error = nil;
        NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[_dataLogger currentLogFileURL]] options:(NSJSONReadingOptions)0 error:&error];
        XCTAssertNil(error);
        XCTAssertEqualObjects(jsonOut[@"items"][1], jsonObject);
    }
}

- (void)testArrayWrite {
    NSMutableArray *a = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        [a addObject:@{@"val": @(i)}];
    }
    
    NSError *error = nil;
    BOOL success = [_dataLogger appendObjects:a error:&error];
    XCTAssertTrue(success);
    XCTAssertNil(error);
    
    {
        NSError *error = nil;
        NSDictionary *jsonOut = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:[_dataLogger currentLogFileURL]] options:(NSJSONReadingOptions)0 error:&error];
        XCTAssertNil(error);
        for (int i = 0; i < 100; i++) {
            XCTAssertEqualObjects(jsonOut[@"items"][i], @{@"val": @(i)});
        }
    }
}

@end
