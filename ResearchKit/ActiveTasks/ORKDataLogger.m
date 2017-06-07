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


#import "ORKDataLogger.h"

#import "ORKHelpers_Internal.h"
#import "CMMotionActivity+ORKJSONDictionary.h"
#import "HKSample+ORKJSONDictionary.h"

#include <sys/xattr.h>


static const char *ORKDataLoggerUploadedAttr = "com.apple.ResearchKit.uploaded";

// Default per-logfile settings when a data logger is used in an ORKDataLoggerManager
static const NSTimeInterval ORKDataLoggerManagerDefaultLogFileLifetime = 60 * 60 * 24 * 3; // 3 days
static const unsigned long long ORKDataLoggerManagerDefaultLogFileSize = 1024 * 1024; // 1 MB

static NSString *const ORKDataLoggerManagerConfigurationFilename = @".ORKDataLoggerManagerConfiguration";


@interface ORKDataLogger ()

@property (copy, setter=_setLogName:) NSString *logName;

@property (strong, setter=_setLogFormatter:) ORKLogFormatter *logFormatter;

- (void)fileSizeLimitsDidChange;

- (instancetype)initWithDirectory:(NSURL *)url configuration:(NSDictionary *)configuration delegate:(id<ORKDataLoggerDelegate>)delegate;

- (NSDictionary *)configuration;

@end


@interface ORKObjectObserver : NSObject

- (instancetype)initWithObject:(id)object keys:(NSArray *)keys selector:(SEL)selector;

@property (unsafe_unretained) id object;

- (void)pause;
- (void)resume;

@end


@implementation NSURL (ORKDataLogger)

- (NSString *)ork_logName {
    NSString *lastComponent = [self lastPathComponent];
    NSRange idx = [lastComponent rangeOfString:@"-"];
    if (!idx.length) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not a completed log file" userInfo:@{@"url":self}];
    }

    NSString *logName = [lastComponent substringToIndex:idx.location];
    return logName;
}

- (NSString *)ork_logDateComponent {
    NSString *lastComponent = [self lastPathComponent];
    NSRange idx = [lastComponent rangeOfString:@"-"];
    if (!idx.length) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not a completed log file" userInfo:@{@"url":self}];
    }
    
    NSString *logDateComponent = [lastComponent substringFromIndex:idx.location + 1];
    return logDateComponent;
}

- (BOOL)ork_isUploaded {
    NSData *data = [self ork_dataForAttr:ORKDataLoggerUploadedAttr];
    if (!data) {
        return NO;
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (string.integerValue != 0);
}

- (BOOL)ork_setUploaded:(BOOL)uploaded error:(NSError **)error {
    NSString *value = (uploaded ? @"1" : @"0");
    NSData *encodedString = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self ork_setData:encodedString forAttr:ORKDataLoggerUploadedAttr error:error];
}

- (NSData *)ork_dataForAttr:(const char *)attr {
    const char *path = [self fileSystemRepresentation];
    
    ssize_t length = getxattr(path, attr, NULL, 0, 0, 0);
    
    if (length < 0) {
        return nil;
    }
    
    NSMutableData *data = [NSMutableData dataWithLength:length];
    length = getxattr(path, attr, data.mutableBytes, length, 0, 0);
    if (length <= 0) {
        return nil;
    }
    
    return data;
}

- (BOOL)ork_setData:(NSData *)data forAttr:(const char *)attr error:(NSError **)error {
    const char *path = [self fileSystemRepresentation];
    int rc = setxattr(path, attr, data.bytes, data.length, 0, 0);
    if (rc != 0) {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:rc userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"ERROR_DATALOGGER_SET_ATTRIBUTE", nil)}];
        }
    }
    return (rc == 0);
}

- (NSString *)ork_logNameInDirectory:(NSURL *)directory {
    if (![self isFileURL]) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not a fileURL" userInfo:@{@"url":self}];
    }
    
    NSString *lastComponent = [self lastPathComponent];
    NSRange idx = [lastComponent rangeOfString:@"-"];
    if (!idx.length) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not a completed log file" userInfo:@{@"url":self}];
    }
    
    if (![[self URLByDeletingLastPathComponent] isEqual:directory]) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not in expected directory" userInfo:@{@"url":self}];
    }
    
    NSString *logName = [lastComponent substringToIndex:idx.location];
    return logName;
}

@end


@implementation ORKObjectObserver {
    NSArray *_keys;
    BOOL _observing;
    SEL _selector;
}

static void *ORKObjectObserverContext = &ORKObjectObserverContext;

- (instancetype)initWithObject:(id)object keys:(NSArray *)keys selector:(SEL)selector {
    self = [super init];
    if (self) {
        self.object = object;
        _keys = [keys copy];
        _selector = selector;
        [self resume];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == ORKObjectObserverContext) {
        NSObject *obj = self.object;
        // Avoid -performSelector: warning by explicitly indicating we have a void return
        ((void (*)(id, SEL))[obj methodForSelector:_selector])(obj, _selector);
    }
}

- (void)stopObserving {
    [self pause];
}

- (void)pause {
    if (_observing) {
        _observing = NO;
        for (NSString *key in _keys) {
            [_object removeObserver:self forKeyPath:key];
        }
    }
}

- (void)resume {
    if (!_observing) {
        for (NSString *key in _keys) {
            [_object addObserver:self forKeyPath:key options:(NSKeyValueObservingOptions)0 context:ORKObjectObserverContext];
        }
        _observing = YES;
    }
}

- (void)dealloc {
    [self stopObserving];
}

@end


@interface ORKLogFormatter () {
    unsigned long long _checkpoint;
}

@end


@implementation ORKLogFormatter

- (BOOL)canAcceptLogObjectOfClass:(Class)c {
    return [c isSubclassOfClass:[NSData class]];
}

- (BOOL)canAcceptLogObject:(id)object {
    return [object isKindOfClass:[NSData class]];
}

- (BOOL)beginLogWithFileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    return YES;
}

- (BOOL)writeData:(NSData *)data fileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    BOOL result = YES;
    @try {
        [fileHandle writeData:data];
    }
    @catch (NSException *exception) {
        result = NO;
        if (error) {
            *error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorException userInfo:@{@"exception": exception}];
        }
    }
    return result;
}

- (unsigned long long)checkpointWithFileHandle:(NSFileHandle *)fileHandle {
    return [fileHandle offsetInFile];
}

- (void)rollbackToCheckpoint:(unsigned long long)offset fileHandle:(NSFileHandle *)fileHandle {
    [fileHandle seekToFileOffset:offset];
    [fileHandle truncateFileAtOffset:offset];
}

- (BOOL)appendObject:(id)object fileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    if (![self canAcceptLogObject:object]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"ORKLogFormatter accepts NSData only" userInfo:nil];
    }
    return [self writeData:(NSData *)object fileHandle:fileHandle error:error];
}

- (BOOL)appendObjects:(NSArray *)objects fileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    unsigned long long checkpoint = [self checkpointWithFileHandle:fileHandle];
    
    NSError *errorOut = nil;
    BOOL success = YES;
    for (NSObject *obj in objects) {
        success = [self appendObject:obj fileHandle:fileHandle error:&errorOut];
        if (!success) {
            break;
        }
    }
    
    if (!success) {
        [self rollbackToCheckpoint:checkpoint fileHandle:fileHandle];
        if (error) {
            *error = errorOut;
        }
    }
    
    return success;
}

@end


static NSString *const kJSONLogEmptyLogString = @"{\"items\":[]}";
static NSString *const kJSONLogFooterString = @"]}";  // The part of the log string that comes after the logged objects
static NSString *const kJSONObjectSeparatorString = @",";

static NSInteger _ORKJSON_emptyLogLength = 0;
static NSInteger _ORKJSON_terminatorLength = 0;

@implementation ORKJSONLogFormatter

- (instancetype)init {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _ORKJSON_emptyLogLength = [kJSONLogEmptyLogString dataUsingEncoding:NSUTF8StringEncoding].length;
            _ORKJSON_terminatorLength = [kJSONLogFooterString dataUsingEncoding:NSUTF8StringEncoding].length;
        });
    }
    return self;
}

- (BOOL)canAcceptLogObjectOfClass:(Class)c {
    return [c isSubclassOfClass:[NSDictionary class]];
}

- (BOOL)canAcceptLogObject:(id)object {
    return [object isKindOfClass:[NSDictionary class]] && [NSJSONSerialization isValidJSONObject:object];
}

- (BOOL)beginLogWithFileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    // Write valid JSON containing no objects
    NSData *data = [kJSONLogEmptyLogString dataUsingEncoding:NSUTF8StringEncoding];
    return [self writeData:data fileHandle:fileHandle error:error];
}

- (unsigned long long)checkpointWithFileHandle:(NSFileHandle *)fileHandle {
    unsigned long long offset = [fileHandle seekToEndOfFile];
    return offset;
}

- (void)rollbackToCheckpoint:(unsigned long long)offset fileHandle:(NSFileHandle *)fileHandle {
    [fileHandle seekToFileOffset:offset];
    if (offset > 0) {
        assert(offset >= _ORKJSON_terminatorLength);
        [fileHandle seekToFileOffset:(offset - _ORKJSON_terminatorLength)];
        [self writeData:[kJSONLogFooterString dataUsingEncoding:NSUTF8StringEncoding] fileHandle:fileHandle error:nil];
        [fileHandle truncateFileAtOffset:offset];
    }
}

- (BOOL)appendObject:(id)object fileHandle:(NSFileHandle *)fileHandle error:(NSError **)error {
    return [self appendObjects:@[object] fileHandle:fileHandle error:error];
}

/*
 * Because the log could be written with file protection on, we ensure the log
 * is always valid JSON so we can roll over at any time.
 *
 * When writing, we seek to the end, then seek back past the footer bytes,
 * before writing. When writing, we write a separator (if needed), the JSON
 * object being appended, and the footer bytes.
 */
- (BOOL)appendObjects:(NSArray *)objects fileHandle:(NSFileHandle *)fileHandle error:(NSError * __autoreleasing *)error {
    if (!fileHandle) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Filehandle is nil" userInfo:nil];
    }
    NSInteger numObjects = objects.count;
    if (numObjects == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No objects" userInfo:nil];
    }
    for (NSObject *object in objects) {
        if (![self canAcceptLogObject:object]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"ORKLogFormatter accepts JSON serializable objects only" userInfo:nil];
        }
    }
    
    // Seek to the end of the file; we'll later backtrack
    unsigned long long offset = [fileHandle seekToEndOfFile];
    if (offset == 0) {
        if (![self beginLogWithFileHandle:fileHandle error:error]) {
            return NO;
        }
        offset = [fileHandle offsetInFile];
    }
    
    unsigned long long checkpoint = [self checkpointWithFileHandle:fileHandle];
    
    NSMutableData *outputData = [NSMutableData data];
    NSData *separatorData = [kJSONObjectSeparatorString dataUsingEncoding:NSUTF8StringEncoding];
    if (offset > _ORKJSON_emptyLogLength) {
        [outputData appendData:separatorData];
    }
    
    // Serialize each object separately to the buffer, pending a single write, so the
    // objects form part of a single array.
    __block BOOL success = YES;
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:(NSJSONWritingOptions)0 error:error];
        if (!data) {
            success = NO;
            *stop = YES;
        } else {
            [outputData appendData:data];
            if (idx + 1 < numObjects) {
                [outputData appendData:separatorData];
            }
        }
    }];
    if (!success) {
        return success;
    }
    
    [outputData appendData:[kJSONLogFooterString dataUsingEncoding:NSUTF8StringEncoding]];

    assert(_ORKJSON_terminatorLength < offset);
    [fileHandle seekToFileOffset:(offset - _ORKJSON_terminatorLength)];
    
    success = [self writeData:outputData fileHandle:fileHandle error:error];
    
    if (!success) {
        [self rollbackToCheckpoint:checkpoint fileHandle:fileHandle];
    }
    
    return success;
}

@end


@implementation ORKDataLogger {
    NSURL *_url;
    ORKObjectObserver *_observer;
    
    NSString *_oldLogsPrefix;
    
    NSFileHandle *_currentFileHandle;
    
    dispatch_queue_t _queue;
    dispatch_source_t _directorySource;
    dispatch_group_t _directoryUpdateGroup;
    
    BOOL _directoryDirty;
}

+ (ORKDataLogger *)JSONDataLoggerWithDirectory:(NSURL *)url logName:(NSString *)logName delegate:(id<ORKDataLoggerDelegate>)delegate {
    return [[ORKDataLogger alloc] initWithDirectory:url logName:logName formatter:[ORKJSONLogFormatter new] delegate:delegate];
}

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithDirectory:(NSURL *)url logName:(NSString *)logName formatter:(ORKLogFormatter *)formatter delegate:(id<ORKDataLoggerDelegate>)delegate {
    self = [super init];
    if (self) {
        _url = [url copy];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"directory does not exist" userInfo:nil];
        }
        if ([logName hasSuffix:@"-"]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"logName should not terminate with '-'" userInfo:nil];
        }
        if (!logName.length) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"logName must be non-empty" userInfo:nil];
        }
        
        NSString *queueId = [@"ResearchKit.log." stringByAppendingString:logName];
        _queue = dispatch_queue_create([queueId cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        
        _directoryUpdateGroup = dispatch_group_create();
        
        self.logName = logName;
        self.logFormatter = formatter;
        self.delegate = delegate;
        self.fileProtectionMode = ORKFileProtectionNone;
        _oldLogsPrefix = [_logName stringByAppendingString:@"-"];
        
        _observer = [[ORKObjectObserver alloc] initWithObject:self keys:@[@"maximumCurrentLogFileLifetime", @"maximumCurrentLogFileSize"] selector:@selector(fileSizeLimitsDidChange)];
        
        [self setupDirectorySource];
    }
    return self;
}

- (instancetype)initWithDirectory:(NSURL *)url configuration:(NSDictionary *)configuration delegate:(id<ORKDataLoggerDelegate>)delegate {
    Class formatterClass = NSClassFromString(configuration[@"formatterClass"]);
    if (!formatterClass) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"%@ is not a class", configuration[@"formatterClass"]] userInfo:nil];
    }
    
    self = [self initWithDirectory:url logName:configuration[@"logName"] formatter:[[formatterClass alloc] init] delegate:delegate];
    if (self) {
        // Don't notify about initial setup
        [_observer pause];
        self.maximumCurrentLogFileSize = ((NSNumber *)configuration[@"maximumCurrentLogFileSize"]).unsignedLongValue;
        self.maximumCurrentLogFileLifetime = ((NSNumber *)configuration[@"maximumCurrentLogFileLifetime"]).doubleValue;
        [_observer resume];
    }
    return self;
}

- (NSDictionary *)configuration {
    return @{@"logName": self.logName,
             @"formatterClass": NSStringFromClass([self.logFormatter class]),
             @"fileProtectionMode": @(self.fileProtectionMode),
             @"maximumCurrentLogFileSize": @(self.maximumCurrentLogFileSize),
             @"maximumCurrentLogFileLifetime": @(self.maximumCurrentLogFileLifetime)
             };
}

// The directory source watches for added and removed files in our directory.
// If files are added or removed, we can automatically recalculate our byte counts.
- (void)setupDirectorySource {
    int dirFD = open([_url fileSystemRepresentation], O_EVTONLY);
    if (dirFD < 0) {
        ORK_Log_Warning(@"Could not track directory %s (%d)", [_url fileSystemRepresentation], [[NSFileManager defaultManager] fileExistsAtPath:[_url path]]);
    } else {
        // Dispatch to a concurrent queue, so we don't store up blocks while our
        // queue is working.
        _directorySource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, dirFD, DISPATCH_VNODE_WRITE, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        if (!_directorySource) {
            close(dirFD);
        }
    }
    
    if (_directorySource) {
        dispatch_source_set_cancel_handler(_directorySource, ^{ close(dirFD); });
        ORKWeakTypeOf(self) weakSelf = self;
        dispatch_source_set_event_handler(_directorySource, ^{
            ORKStrongTypeOf(self) strongSelf = weakSelf;
            [strongSelf directoryUpdated];
        });
        dispatch_resume(_directorySource);
    }
}

#pragma mark Primary interface

- (void)fileSizeLimitsDidChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<ORKDataLoggerExtendedDelegate> delegate = (id<ORKDataLoggerExtendedDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(dataLoggerThresholdsDidChange:)]) {
            [delegate dataLoggerThresholdsDidChange:self];
        }
    });
    dispatch_async(_queue, ^{
        [self queue_rolloverIfNeeded];
        
    });
}

- (void)finishCurrentLog {
    dispatch_sync(_queue, ^{
        [self queue_rollover];
    });
}

- (NSURL *)currentLogFileURL {
    return [_url URLByAppendingPathComponent:_logName];
}

- (BOOL)urlMatchesLogName:(NSURL *)url {
    NSString *lastComponent = [url lastPathComponent];
    return ([lastComponent isEqualToString:_logName] || [lastComponent hasPrefix:_oldLogsPrefix]);
}

- (NSFileHandle *)fileHandle {
    return _currentFileHandle;
}

- (BOOL)enumerateLogs:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error {
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Block parameter is required" userInfo:nil];
    }
    
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_enumerateLogs:block error:error];
    });
    return success;
}

- (BOOL)enumerateLogsUploaded:(BOOL)uploaded block:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error {
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Block parameter is required" userInfo:nil];
    }
    
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_enumerateLogsUploaded:uploaded block:block error:error];
    });
    return success;
}

- (BOOL)enumerateLogsNeedingUpload:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError **)error {
    return [self enumerateLogsUploaded:NO block:block error:error];
}

- (BOOL)enumerateLogsAlreadyUploaded:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError **)error {
    return [self enumerateLogsUploaded:YES block:block error:error];
}

- (BOOL)append:(id)object error:(NSError * __autoreleasing *)error {
    if (!object) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Nil object" userInfo:nil];
    }
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_append:object error:error];
    });
    return success;
}

- (BOOL)appendObjects:(NSArray *)objects error:(NSError * __autoreleasing *)error {
    if (!objects.count) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Empty array" userInfo:nil];
    }
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_appendObjects:objects error:error];
    });
    return success;
}

- (BOOL)markFileUploaded:(BOOL)uploaded atURL:(NSURL *)url error:(NSError * __autoreleasing *)error {
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_markFileUploaded:uploaded atURL:url error:error];
    });
    return success;
}

- (BOOL)removeUploadedFiles:(NSArray<NSURL *> *)fileURLs withError:(NSError * __autoreleasing *)error {
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_removeUploadedFiles:fileURLs withError:error];
    });
    return success;
}

- (BOOL)removeAllFilesWithError:(NSError * __autoreleasing *)error {
    __block BOOL success = NO;
    dispatch_sync(_queue, ^{
        success = [self queue_removeAllFilesWithError:error];
    });
    return success;
}

- (BOOL)isFileUploadedAtURL:(NSURL *)url {
    if (![url isFileURL]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"URL must be a file URL" userInfo:nil];
    }
 
    return [url ork_isUploaded];
}

#pragma mark queue methods

- (void)dealloc {
    dispatch_source_cancel(_directorySource);
    _directorySource = nil;
}

- (void)queue_setNeedsUpdateBytes {
    if (!_directoryDirty) {
        _directoryDirty = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), _queue, ^{
            if (!_directoryDirty) {
                return;
            }
            [self queue_updateBytes];
        });
    }
}

- (void)directoryUpdated {
    if (dispatch_group_wait(_directoryUpdateGroup, DISPATCH_TIME_NOW) != 0) {
        // This op is already running or queued; can skip
        return;
    }
    dispatch_group_async(_directoryUpdateGroup, _queue, ^{
        [self queue_setNeedsUpdateBytes];
    });
}

- (BOOL)queue_enumerateLogs:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError **)error {
    static NSArray *keys = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keys = @[NSURLFileSizeKey, NSURLPathKey, NSURLIsRegularFileKey];
    });
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator *enumerator = [manager enumeratorAtURL:_url
                             includingPropertiesForKeys:@[]
                                                options:(NSDirectoryEnumerationOptions)( NSDirectoryEnumerationSkipsSubdirectoryDescendants|
                                NSDirectoryEnumerationSkipsHiddenFiles|
                                NSDirectoryEnumerationSkipsPackageDescendants)
                                           errorHandler:nil];
    
    NSError *errorOut = nil;
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in enumerator) {
        if (![self urlMatchesLogName:url]) {
            continue;
        }
        if ( [[url lastPathComponent] isEqualToString:_logName]) {
            // Don't include the "current" log file
            continue;
        }
        NSDictionary *resources = [url resourceValuesForKeys:keys error:&errorOut];
        if (errorOut) {
            // If there's been an error getting the resource values, give up
            break;
        }
        if (!((NSNumber *)resources[NSURLIsRegularFileKey]).boolValue) {
            continue;
        }
        [urls addObject:url];
    }
    
    if (!errorOut) {
        // Sort the URLs before beginning enumeration for the caller
        [urls sortUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
            // We can assume all relate to files in the same directory
            return [[obj1 lastPathComponent] compare:[obj2 lastPathComponent]];
        }];
        
        for (NSURL *url in urls) {
            BOOL stop = NO;
            block(url, &stop);
            if (stop) {
                break;
            }
        }
    }
    
    if (error) {
        *error = errorOut;
    }
    return (errorOut ? NO : YES);
}

- (BOOL)queue_enumerateLogsUploaded:(BOOL)uploaded block:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError **)error {
    return [self queue_enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        NSError *errorOut = nil;
        BOOL wantUploaded = [logFileUrl ork_isUploaded];
        BOOL isWanted = (wantUploaded && uploaded) || (!wantUploaded && !uploaded);
        if (isWanted) {
            block(logFileUrl, stop);
        }
        if (errorOut) {
            *stop = YES;
        }
    } error:error];
}

- (NSFileHandle *)queue_makeFileHandleWithError:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [self currentLogFileURL];
    
    // If this fails, it's probably because the file doesn't exist
    NSNumber *fileExists = nil;
    [url getResourceValue:&fileExists forKey:NSURLIsRegularFileKey error:nil];
    
    BOOL createNewFile = !fileExists.boolValue;
    
    NSFileHandle *fileHandle = nil;
    if (!createNewFile) {
        fileHandle = [NSFileHandle fileHandleForWritingToURL:url error:error];
        if (!fileHandle) {
            // Assume it's because we can't open the file, perhaps for security reasons.
            // Close and rename the log.
            [self queue_closeAndRenameLog];
            createNewFile = YES;
        }
    }
    
    if (createNewFile) {
        NSString *filePath = [url path];
        BOOL success = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        if (!success) {
            if (error) {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"ERROR_DATALOGGER_CREATE_FILE", nil)}];
            }
            return nil;
        }
        fileHandle = [NSFileHandle fileHandleForWritingToURL:[self currentLogFileURL] error:error];
        if (!fileHandle) {
            [fileManager removeItemAtURL:url error:nil];
            return nil;
        }
    }
    
    if (createNewFile) {
        assert(fileHandle);
        
        // Set file protection after opening the file, so that class B works as expected.
        BOOL success = [fileManager setAttributes:@{NSFileProtectionKey: ORKFileProtectionFromMode(self.fileProtectionMode)} ofItemAtPath:[url path] error:error];
        
        // Allow formatter to initialize the log file with header content
        success = success && [self.logFormatter beginLogWithFileHandle:fileHandle error:error];
        
        if (!success) {
            [fileHandle closeFile];
            [fileManager removeItemAtURL:url error:nil];
            return nil;
        }
    }
    _currentFileHandle = fileHandle;
    return _currentFileHandle;
}

- (NSFileHandle *)queue_fileHandleWithError:(NSError **)error {
    if (!_currentFileHandle) {
        _currentFileHandle = [self queue_makeFileHandleWithError:error];
        
        [_currentFileHandle seekToEndOfFile];
    }
    return _currentFileHandle;
}

+ (NSURL *)nextUrlForDirectoryUrl:(NSURL *)directory logName:(NSString *)logName {
    static NSDateFormatter *dateFromatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFromatter = [NSDateFormatter new];
        [dateFromatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        dateFromatter.dateFormat = @"yyyyMMddHHmmss";
    });
    
    NSString *datedLog = [NSString stringWithFormat:@"%@-%@",logName, [dateFromatter stringFromDate:[NSDate date]]];
    NSURL *destinationUrl = [directory URLByAppendingPathComponent:datedLog];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    int digit = 0;
    while ([fileManager fileExistsAtPath:[destinationUrl path] isDirectory:NULL]) {
        digit ++;
        NSString *lastComponent = [datedLog stringByAppendingFormat:@"-%02d",digit];
        destinationUrl = [directory URLByAppendingPathComponent:lastComponent];
    }

    return destinationUrl;
}

- (void)queue_closeAndRenameLog {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [self currentLogFileURL];
    
    // Close any existing file handle
    if (_currentFileHandle) {
        [_currentFileHandle synchronizeFile];
        [_currentFileHandle closeFile];
        _currentFileHandle = nil;
    }
    
    // Check if a non-empty file exists, and create the file handle if so
    NSDictionary *parameters = [url resourceValuesForKeys:@[NSURLIsRegularFileKey,NSURLFileSizeKey] error:nil];
    
    if (((NSNumber *)parameters[NSURLIsRegularFileKey]).boolValue) {
        if (((NSNumber *)parameters[NSURLFileSizeKey]).intValue > 0) {
            NSURL *destinationUrl = [ORKDataLogger nextUrlForDirectoryUrl:_url logName:_logName];
            ORK_Log_Debug(@"Rollover: %@ to %@", [url lastPathComponent], [destinationUrl lastPathComponent]);
            [fileManager moveItemAtURL:url toURL:destinationUrl error:nil];
            if (self.fileProtectionMode == ORKFileProtectionCompleteUnlessOpen) {
                // Upgrade to complete file protection after roll-over
                NSError *error = nil;
                if (![fileManager setAttributes:@{NSFileProtectionKey: NSFileProtectionComplete}
                                   ofItemAtPath:[destinationUrl path] error:&error]) {
                    ORK_Log_Warning(@"Error setting NSFileProtectionComplete on %@: %@", destinationUrl, error);
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                id<ORKDataLoggerDelegate> delegate = self.delegate;
                [delegate dataLogger:self finishedLogFile:destinationUrl];
            });
        } else {
            // Size zero file is present. Get rid of it.
            [fileManager removeItemAtURL:url error:nil];
        }
    }
}

- (void)queue_rolloverIfNeeded {
    NSURL *url = [self currentLogFileURL];
    NSDictionary *parameters = [url resourceValuesForKeys:@[NSURLIsRegularFileKey, NSURLFileSizeKey, NSURLCreationDateKey] error:nil];
    
    NSInteger fileSize = ((NSNumber *)parameters[NSURLFileSizeKey]).integerValue;
    NSDate *creationDate = parameters[NSURLCreationDateKey];
    
    BOOL exceededSizeThreshold = ( (self.maximumCurrentLogFileSize > 0) && (fileSize >= self.maximumCurrentLogFileSize));
    
    NSDate *earliestAcceptableCreationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maximumCurrentLogFileLifetime];
    
    BOOL exceededAgeThreshold = (self.maximumCurrentLogFileLifetime > 0) && creationDate && ( [earliestAcceptableCreationDate earlierDate:creationDate] == creationDate );
    
    if (exceededAgeThreshold || exceededSizeThreshold) {
        [self queue_rollover];
    }
}

- (void)queue_rollover {
    [self queue_closeAndRenameLog];
}

- (BOOL)queue_append:(id)object error:(NSError **)error {
    [self queue_rolloverIfNeeded];
    
    NSFileHandle *fileHandle = [self queue_fileHandleWithError:error];
    if (!fileHandle) {
        return NO;
    }
    
    BOOL result = [self.logFormatter appendObject:object fileHandle:_currentFileHandle error:error];
    
    // Quick check to see if we've run over the maximum log file size
    if ((self.maximumCurrentLogFileSize > 0) && ([_currentFileHandle offsetInFile] >= self.maximumCurrentLogFileSize)) {
        [self queue_rollover];
    }
    
    return result;
}

- (BOOL)queue_appendObjects:(NSArray *)objects error:(NSError **)error {
    [self queue_rolloverIfNeeded];
    
    NSFileHandle *fileHandle = [self queue_fileHandleWithError:error];
    if (!fileHandle) {
        return NO;
    }
    
    BOOL result = [self.logFormatter appendObjects:objects fileHandle:_currentFileHandle error:error];
    
    // Quick check to see if we've run over the maximum log file size
    if ((self.maximumCurrentLogFileSize > 0) && ([_currentFileHandle offsetInFile] >= self.maximumCurrentLogFileSize)) {
        [self queue_rollover];
    }
    return result;
}

- (BOOL)queue_markFileUploaded:(BOOL)uploaded atURL:(NSURL *)url error:(NSError **)error {
    BOOL success = [url ork_setUploaded:uploaded error:error];
    [self queue_setNeedsUpdateBytes];
    return success;
}

- (BOOL)queue_removeUploadedFiles:(NSArray<NSURL *> *)fileURLs withError:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    __block NSMutableArray *errors = [NSMutableArray array];
    BOOL success = [self queue_enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        if ([fileURLs containsObject:logFileUrl]) {
            NSError *errorOut = nil;
            BOOL uploaded = [logFileUrl ork_isUploaded];
            
            if (uploaded) {
                if (![fileManager removeItemAtURL:logFileUrl error:&errorOut]) {
                    [errors addObject:errorOut];
                }
            } else {
                // File was requested to be removed, but was not marked uploaded
                [errors addObject:[NSError errorWithDomain:ORKErrorDomain
                                                      code:ORKErrorInvalidObject
                                                  userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"ERROR_DATALOGGER_COULD_NOT_MAORK", nil), @"url": logFileUrl}]];
            }
        }
    } error:error];
    
    // Reporting multiple errors
    if (errors.count) {
        if (!success && error && *error) {
            [errors addObject:*error];
            *error = [NSError errorWithDomain:ORKErrorDomain
                                         code:ORKErrorMultipleErrors
                                     userInfo:@{NSLocalizedDescriptionKey: ORKLocalizedString(@"ERROR_DATALOGGER_MULTIPLE", nil), @"errors": errors}];
        }
        success = NO;
    }
    return success;
}

- (BOOL)queue_removeAllFilesWithError:(NSError * __autoreleasing *)error {
    [_currentFileHandle closeFile];
    _currentFileHandle = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:[self currentLogFileURL] error:NULL];
    
    return [self queue_enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        [fileManager removeItemAtURL:logFileUrl error:error];
    } error:error];
}

- (void)queue_updateBytes {
    _directoryDirty = NO;
    
    __block ssize_t pending = 0;
    __block ssize_t uploaded = 0;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self queue_enumerateLogs:^(NSURL *logFileUrl, BOOL *stop) {
        BOOL logWasUploaded = [logFileUrl ork_isUploaded];
        
        NSDictionary *attribs = [fileManager attributesOfItemAtPath:[logFileUrl path] error:nil];
        unsigned long long size = [attribs fileSize];
        
        if (logWasUploaded) {
            uploaded += size;
        } else {
            pending += size;
        }
    } error:nil];
    
    self.pendingBytes = pending;
    self.uploadedBytes = uploaded;
    
    if ([self.delegate respondsToSelector:@selector(dataLoggerByteCountsDidChange:)]) {
        [self.delegate dataLoggerByteCountsDidChange:self];
    }
}

@end


@interface ORKDataLoggerManager () <ORKDataLoggerExtendedDelegate> {
    NSURL *_directory;
    NSMutableDictionary *_records;
    NSMutableDictionary *_observers;
    
    BOOL _pendingUploadDelegateSent;
    BOOL _totalBytesDelegateSent;
    
    dispatch_queue_t _queue;
    
    BOOL _updateBytesPending;
    dispatch_group_t _updateBytesGroup;
    
    ORKObjectObserver *_observer;
}

@end


@implementation ORKDataLoggerManager

+ (instancetype)new {
    ORKThrowMethodUnavailableException();
}

- (instancetype)init {
    ORKThrowMethodUnavailableException();
}

- (instancetype)initWithDirectory:(NSURL *)directory delegate:(id<ORKDataLoggerManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _directory = directory;
        if (![[NSFileManager defaultManager] fileExistsAtPath:[_directory path]]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"directory does not exist" userInfo:nil];
        }
        _delegate = delegate;
        
        _updateBytesGroup = dispatch_group_create();
        
        NSString *queueId = [@"ResearchKit.loggerman." stringByAppendingString:[directory lastPathComponent]];
        _queue = dispatch_queue_create([queueId cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        if (!_queue) {
            return nil;
        }
        
        NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfURL:[_directory URLByAppendingPathComponent:ORKDataLoggerManagerConfigurationFilename]];
        [self loadConfiguration:configuration];
        
        _observer = [[ORKObjectObserver alloc] initWithObject:self keys:@[@"pendingUploadBytesThreshold", @"totalBytesThreshold"] selector:@selector(configurationDidChange)];
        
        [self setNeedsUpdateBytes];
    }
    return self;
}

static NSString *const PendingUploadBytesThresholdKey = @"pendingUploadBytesThreshold";
static NSString *const TotalBytesThresholdKey = @"totalBytesThreshold";
static NSString *const LoggerConfigurationsKey = @"loggers";

- (void)loadConfiguration:(NSDictionary *)configuration {
    self.pendingUploadBytesThreshold = ((NSNumber *)configuration[PendingUploadBytesThresholdKey]).unsignedLongLongValue;
    self.totalBytesThreshold = ((NSNumber *)configuration[TotalBytesThresholdKey]).unsignedLongLongValue;
    
    NSMutableDictionary *records = [NSMutableDictionary dictionary];
    for (NSDictionary *loggerConfiguration in configuration[LoggerConfigurationsKey]) {
        ORKDataLogger *logger = [[ORKDataLogger alloc] initWithDirectory:_directory configuration:loggerConfiguration delegate:self];
        records[logger.logName] = logger;
    }
    _records = records;
}

- (NSDictionary *)queue_configuration {
    NSMutableArray *loggerConfigurations = [_records.allValues valueForKey:@"configuration"];
    
    return @{PendingUploadBytesThresholdKey: @(self.pendingUploadBytesThreshold),
             TotalBytesThresholdKey: @(self.totalBytesThreshold),
             LoggerConfigurationsKey: loggerConfigurations };
}

- (void)queue_synchronizeConfiguration {
    NSDictionary *configuration = [self queue_configuration];
    [configuration writeToURL:[_directory URLByAppendingPathComponent:ORKDataLoggerManagerConfigurationFilename] atomically:YES];
}

- (void)configurationDidChange {
    dispatch_sync(_queue, ^{
        [self queue_synchronizeConfiguration];
    });
}

- (ORKDataLogger *)addJSONDataLoggerForLogName:(NSString *)logName {
    return [self addDataLoggerForLogName:logName formatter:[ORKJSONLogFormatter new]];
}

- (ORKDataLogger *)queue_addDataLoggerForLogName:(NSString *)logName formatter:(ORKLogFormatter *)formatter {
    ORKDataLogger *dataLogger = [[ORKDataLogger alloc] initWithDirectory:_directory logName:logName formatter:formatter delegate:self];
    dataLogger.delegate = nil;
    // Pick suitable defaults for a typical use pattern
    dataLogger.maximumCurrentLogFileLifetime = ORKDataLoggerManagerDefaultLogFileLifetime;
    dataLogger.maximumCurrentLogFileSize = ORKDataLoggerManagerDefaultLogFileSize;
    dataLogger.delegate = self;
    
    _records[logName] = dataLogger;
    [self queue_synchronizeConfiguration];
    
    [self setNeedsUpdateBytes];
    
    return dataLogger;
}

- (ORKDataLogger *)addDataLoggerForLogName:(NSString *)logName formatter:(ORKLogFormatter *)formatter {
    if (_records[logName]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Duplicate logger with log name '%@'",logName] userInfo:nil];
    }
    
    __block ORKDataLogger *dataLogger = nil;
    dispatch_sync(_queue, ^{
        dataLogger = [self queue_addDataLoggerForLogName:logName formatter:formatter];
    });
    return dataLogger;
}

- (void)queue_removeDataLogger:(ORKDataLogger *)logger {
    NSString *logName = logger.logName;
    ORKDataLogger *thisLogger = _records[logName];
    if (thisLogger && (thisLogger != logger)) {
        @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"Logger provided for %@ is not the managed one",logName] userInfo:nil];
    }
    [logger removeAllFilesWithError:nil];
    [_records removeObjectForKey:logName];
    [self queue_synchronizeConfiguration];
}

- (void)removeDataLogger:(ORKDataLogger *)logger {
    dispatch_sync(_queue, ^{
        [self queue_removeDataLogger:logger];
    });
}

- (ORKDataLogger *)dataLoggerForLogName:(NSString *)logName {
    __block ORKDataLogger *dataLogger = nil;
    dispatch_sync(_queue, ^{
        dataLogger = _records[logName];
    });
    return dataLogger;
}

- (NSArray<NSString *> *)logNames {
    __block NSArray<NSString *> *logNames = nil;
    dispatch_sync(_queue, ^{
        logNames = _records.allKeys;
    });
    return logNames;
}

- (BOOL)queue_enumerateLogsNeedingUpload:(void (^)(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop))block error:(NSError **)error {
    BOOL success = YES;
    NSMutableArray *allFiles = [NSMutableArray array];
    // Collect all the log file URLs so we can sort them by date rather than enumerating by logger.
    for (ORKDataLogger *logger in _records.allValues) {
        success = [logger enumerateLogsNeedingUpload:^(NSURL *logFileUrl, BOOL *stop) {
            [allFiles addObject:logFileUrl];
        } error:error];
        
        if (!success) {
            break;
        }
    }
    if (!success) {
        return NO;
    }
    
    // Sort by ascending log file date, as recorded in the timestamp in the filename
    [allFiles sortUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
        NSComparisonResult result = [[obj1 ork_logDateComponent] compare:[obj2 ork_logDateComponent]];
        if (result == NSOrderedSame) {
            result = [[obj1 path] compare:[obj2 path]];
        }
        return result;
    }];
    
    // Enumerate them to the block based API.
    for (NSURL *url in allFiles) {
        __block BOOL shouldStop = NO;
        ORKDataLogger *logger = _records[[url ork_logName]];
        block(logger, url, &shouldStop);
        if (shouldStop) {
            break;
        }
    }
    
    return success;
}

- (BOOL)enumerateLogsNeedingUpload:(void (^)(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error {
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Block argument required" userInfo:nil];
    }
    
    __block BOOL success = YES;
    dispatch_sync(_queue, ^{
        success = [self queue_enumerateLogsNeedingUpload:block error:error];
    });
    return success;
}

- (BOOL)queue_removeUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError **)error {
    BOOL success = YES;
    NSMutableArray *notRemoved = [NSMutableArray array];
    for (NSURL *url in fileURLs) {
        NSString *logName = [url ork_logNameInDirectory:_directory];
        
        if (!_records[logName]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not from a known logger" userInfo:@{@"url":url}];
        }
        
        NSError *errorOut = nil;
        BOOL itemSuccess = [[NSFileManager defaultManager] removeItemAtURL:url error:&errorOut];
        if (!itemSuccess) {
            [notRemoved addObject:url];
            success = NO;
        }
    }
    if (error && notRemoved.count) {
        *error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorMultipleErrors userInfo:@{@"notRemoved":notRemoved}];
    }
    return success;
}

- (BOOL)removeUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError * __autoreleasing *)error {
    
    __block BOOL success = YES;
    dispatch_sync(_queue, ^{
        success = [self queue_removeUploadedFiles:fileURLs error:error];
    });
    return success;
}

- (BOOL)queue_unmarkUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError **)error {
    BOOL success = YES;
    NSMutableArray<NSURL *> *notRemoved = [NSMutableArray array];
    for (NSURL *url in fileURLs) {
        NSString *logName = [url ork_logNameInDirectory:_directory];
        ORKDataLogger *logger = _records[logName];
        if (!logger) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"URL is not from a known logger" userInfo:@{@"url":url}];
        }
        
        NSError *errorOut = nil;
        BOOL itemSuccess = [logger markFileUploaded:NO atURL:url error:&errorOut];
        if (!itemSuccess) {
            [notRemoved addObject:url];
            success = NO;
        }
    }
    if (error && notRemoved.count) {
        *error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorMultipleErrors userInfo:@{@"notRemoved":notRemoved}];
    }
    return success;
}

- (BOOL)unmarkUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError * __autoreleasing *)error {
    __block BOOL success = YES;
    dispatch_sync(_queue, ^{
        success = [self queue_unmarkUploadedFiles:fileURLs error:error];
    });
    return success;
}

- (BOOL)queue_removeOldAndUploadedLogsToThreshold:(unsigned long long)bytes error:(NSError **)error {
    if (bytes == 0) {
        for (ORKDataLogger *logger  in _records) {
            [logger removeAllFilesWithError:nil];
        }
        
        
        return (self.totalBytes == 0);
    }
    
    __block unsigned long long totalBytes = self.totalBytes;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (totalBytes > bytes) {
        for (ORKDataLogger *logger  in _records.allValues) {
            [logger enumerateLogsAlreadyUploaded:^(NSURL *logFileUrl, BOOL *stop) {
                unsigned long long fileSize = [[fileManager attributesOfItemAtPath:[logFileUrl path] error:nil] fileSize];
                if (fileSize > 0) {
                    if ([fileManager removeItemAtURL:logFileUrl error:nil]) {
                        totalBytes -= fileSize;
                    }
                }
                if (totalBytes <= bytes) {
                    *stop = YES;
                }
            } error:nil];
            
            if (totalBytes <= bytes) {
                break;
            }
        }
    }
    
    if (totalBytes > bytes) {
        [self queue_enumerateLogsNeedingUpload:^(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop) {
            unsigned long long fileSize = [[fileManager attributesOfItemAtPath:[logFileUrl path] error:nil] fileSize];
            if (fileSize > 0) {
                if ([fileManager removeItemAtURL:logFileUrl error:nil]) {
                    totalBytes -= fileSize;
                }
            }
            
            if (totalBytes <= bytes) {
                *stop = YES;
            }
            
        } error:nil];
    }
    
    if (error && (totalBytes > bytes)) {
        *error = [NSError errorWithDomain:ORKErrorDomain code:ORKErrorObjectNotFound userInfo:@{NSLocalizedDescriptionKey:ORKLocalizedString(@"ERROR_DATALOGGER_COULD_NOT_FREE_SPACE", nil)}];
    }
    
    return (totalBytes <= bytes);
}

- (BOOL)removeOldAndUploadedLogsToThreshold:(unsigned long long)bytes error:(NSError * __autoreleasing *)error {
    __block BOOL success = YES;
    dispatch_sync(_queue, ^{
        success = [self queue_removeOldAndUploadedLogsToThreshold:bytes error:error];
    });
    return success;
}

- (void)queue_updateBytes {
    unsigned long long pending = 0;
    unsigned long long uploaded = 0;
    for (ORKDataLogger *logger in _records.allValues) {
        pending += logger.pendingBytes;
        uploaded += logger.uploadedBytes;
    }
    
    BOOL exceededPendingThreshold = (self.pendingUploadBytesThreshold > 0) && (pending > self.pendingUploadBytesThreshold);
    BOOL exceededTotalThreshold = (self.totalBytesThreshold > 0) && ( (pending + uploaded) > self.totalBytesThreshold);
    
    self.pendingUploadBytes = pending;
    self.totalBytes = (pending + uploaded);
    
    if (exceededPendingThreshold && !_pendingUploadDelegateSent) {
        [self.delegate dataLoggerManager:self pendingUploadBytesReachedThreshold:pending];
        _pendingUploadDelegateSent = YES;
    } else if (!exceededPendingThreshold) {
        _pendingUploadDelegateSent = NO;
    }
    
    if (exceededTotalThreshold && !_totalBytesDelegateSent) {
        [self.delegate dataLoggerManager:self totalBytesReachedThreshold:(pending + uploaded)];
        _totalBytesDelegateSent = YES;
    } else if (!exceededTotalThreshold) {
        _totalBytesDelegateSent = NO;
    }
}

- (void)setNeedsUpdateBytes {
    // If a request is already pending, ignore this one
    if (dispatch_group_wait(_updateBytesGroup, DISPATCH_TIME_NOW) != 0) {
        return;
    }
    
    dispatch_group_async(_updateBytesGroup, _queue, ^{
        [self queue_updateBytes];
    });
}

#pragma mark ORKDataLoggerDelegate

- (void)dataLogger:(ORKDataLogger *)dataLogger finishedLogFile:(NSURL *)fileUrl {
    // Do nothing; we'll notice what happened when byte counts change
}

- (void)dataLoggerByteCountsDidChange:(ORKDataLogger *)dataLogger {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setNeedsUpdateBytes];
    });
}

- (void)dataLoggerThresholdsDidChange:(ORKDataLogger *)dataLogger {
    [self configurationDidChange];
}

@end
