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


#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>


NS_ASSUME_NONNULL_BEGIN

@class ORKDataLogger;
@class HKUnit;

/**
 The `ORKDataLoggerDelegate` protocol defines methods that the delegate of an `ORKDataLogger` object uses to handle data being logged to disk.
 */
@protocol ORKDataLoggerDelegate <NSObject>

/**
 Tells the delegate when a log file rollover occurs.
 
 @param dataLogger  The data logger providing the notification.
 @param fileUrl The URL of the newly renamed log file.
 */
- (void)dataLogger:(ORKDataLogger *)dataLogger finishedLogFile:(NSURL *)fileUrl;

@optional
/**
 Tells the delegate if the number of bytes in completed logs changes.
 
 When files are removed or added, or marked as uploaded or unmarked, this delegate method is called a short time later. Multiple directory changes
 are rolled up into a single delegate callback.
 
 @param dataLogger  The data logger providing the notification.
 */
- (void)dataLoggerByteCountsDidChange:(ORKDataLogger *)dataLogger;

@end


@class ORKLogFormatter;

/**
 The `ORKDataLogger` class is an internal component used by some `ORKRecorder`
 subclasses for writing data to disk during tasks. An `ORKDataLogger` object manages one log as a set of files in a directory.
 
 The current log file is at `directory/logName`.
 Historic log files are at `directory/logName-(timestamp)-(count)`
 where timestamp is of the form `YYYYMMddHHmmss` (Zulu) and indicates the time
 the log finished (that is, was rolled over). If more than one rollover occurs within
 one second, additional log files may be created with increasing `count`.
 
 The user is responsible for managing the historic log files, but the `ORKDataLogger` class
 provides tools for enumerating them (in sorted order).
 
 The data logger contains a concept of whether a file has been uploaded, which
 is tracked using file attributes. This feature can facilitate a workflow in which
 log files are archived and queued for upload before actually sending them to
 a server. When archived and ready for upload, the files could be marked uploaded
 by the `ORKDataLogger`. When the upload is complete and the data has been handed
 off downstream, the files can then be deleted. If the upload fails, the uploaded
 files can have that flag cleared, to indicate that they should be included
 in the next archiving attempt.
 */
ORK_CLASS_AVAILABLE
@interface ORKDataLogger : NSObject

/**
 Returns a data logger with an `ORKJSONLogFormatter`.
 
 @param url         The URL of the directory in which to place log files.
 @param logName     The prefix on the log file name in an ASCII string. Note that the string must not contain the hyphen character ("-"), because a hyphen is used as a separator in the log naming scheme.
 @param delegate    The initial delegate. May be `nil`.
 */
+ (ORKDataLogger *)JSONDataLoggerWithDirectory:(NSURL *)url logName:(NSString *)logName delegate:(nullable id<ORKDataLoggerDelegate>)delegate;

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized data logger using the specified URL, log name, formatter, and delegate.
 
 @param url         The URL of the directory in which to place log files
 @param logName     The prefix on the log file name in an ASCII string. Note that
 the string must not contain the hyphen character ("-"), because a hyphen is used as a separator in the log naming scheme.
 @param formatter   The type of formatter to use for the log, such as `ORKJSONLogFormatter`.
 @param delegate    The initial delegate. May be `nil`.
 
 @return An initialized data logger.
 */
- (instancetype)initWithDirectory:(NSURL *)url logName:(NSString *)logName formatter:(ORKLogFormatter *)formatter delegate:(nullable id<ORKDataLoggerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// The delegate to be notified when file sizes change or the log rolls over.
@property (weak, nullable) id<ORKDataLoggerDelegate> delegate;

/// The log formatter being used.
@property (strong, readonly) ORKLogFormatter *logFormatter;

/**
 The maximum current log file size.
 
 When the current log reaches this size, it is automatically rolled over.
 */
@property size_t maximumCurrentLogFileSize;

/**
 The maximum current log file lifetime.
 
 When the current log file has been active this long, it is rolled over.
 */
@property NSTimeInterval maximumCurrentLogFileLifetime;

/// The number of bytes of log data that are not marked uploaded, excluding the current file. This value is lazily updated.
@property unsigned long long pendingBytes;

/// The number of bytes of log data that are marked uploaded. This value is lazily updated.
@property unsigned long long uploadedBytes;

/// The file protection mode to use for newly created files.
@property (assign) ORKFileProtectionMode fileProtectionMode;

/// The prefix on the log file names.
@property (copy, readonly) NSString *logName;

/// Forces a roll-over now.
- (void)finishCurrentLog;

/// The current log file's location.
- (NSURL *)currentLogFileURL;

/**
 Enumerates the URLs of completed log files, sorted to put the oldest first.
 
 Takes a snapshot of the current directory's relevant files, sorts them,
 and enumerates them. Errors can occur if changes are being made to the filesystem other
 than through this object.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration.
 
 @return `YES` if the enumeration was successful; otherwise, `NO`.
 */
- (BOOL)enumerateLogs:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Enumerates the URLs of completed log files not yet marked uploaded,
 sorted to put the oldest first.
 
 This method takes a snapshot of the current directory's completed nonuploaded log files, sorts them,
 and then enumerates them. Errors can occur if changes are being made to the filesystem other
 than through this object.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration.
 
 @return `YES` if the enumeration was successful; otherwise, `NO`.
 */
- (BOOL)enumerateLogsNeedingUpload:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Enumerates the URLs of completed log files not already marked uploaded,
 sorted to put the oldest first.
 
 Takes a snapshot of the current directory's completed uploaded log files, sorts them,
 and then enumerates them. Errors can occur if changes are being made to the filesystem other
 than through this object.
 
 @param block   The block to call during enumeration.
 @param error   Any error detected during the enumeration.
 
 @return `YES` if the enumeration was successful; otherwise, `NO`.
 */
- (BOOL)enumerateLogsAlreadyUploaded:(void (^)(NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Appends an object to the log file, which is formatted with `logFormatter`.
 
 The default log formatter expects NSData; call canAcceptLogObjectOfClass: on `logFormatter` to determine if it will accept this object.
 
 Note that the current log file is created and opened lazily when a request to
 log data is made. If an attempt is made to log data and there is no access due
 to file protection, the log is immediately rolled over and a new file created.
 
 @param object Should be an object of a class that is accepted by the logFormatter.
 @param error  Error output, if the append fails.
 
 @return `YES` if appending succeeds; otherwise, `NO`.
 */
- (BOOL)append:(id)object error:(NSError * __autoreleasing *)error;

/**
 Appends multiple objects to the log file.
 
 This method formats and appends all the objects at once. Using this method may have efficiency
 and atomicity gains for error handling, compared to making multiple calls to `append:error`.
 
 @param objects An array of objects of a class that is accepted by the logFormatter.
 @param error  Error output, if the append fails.
 
 @return `YES` if appending succeeds; otherwise, `NO`.
 */
- (BOOL)appendObjects:(NSArray *)objects error:(NSError * _Nullable __autoreleasing *)error;

/**
 Checks whether a file has been marked as uploaded.
 
 @param url     The URL to check.
 
 @return `YES` if the uploaded attribute has been set on the file and the file exists; otherwise,
         `NO`.
 */
- (BOOL)isFileUploadedAtURL:(NSURL *)url;

/**
 Marks or unmarks a file as uploaded.
 
 This method uses an extended attribute on the filesystem to mark a file as uploaded.
 This is intended for book-keeping use only and to track which files have already
 been attached to a pending upload. When the upload is sufficiently complete,
 the file should be removed.
 
 @param uploaded    A Boolean value that indicates whether to mark the file uploaded or not uploaded.
 @param url         The URL to mark.
 @param error       The error that occurred, if the operation fails.
 
 @return `YES` if adding or removing the attribute succeeded; otherwise, `NO`.
 */
- (BOOL)markFileUploaded:(BOOL)uploaded atURL:(NSURL *)url error:(NSError * _Nullable __autoreleasing *)error;

/**
 Removes files if they are marked uploaded.
 
 If a file is in the list, but is no longer marked uploaded, this method does not remove the file. This workflow lets you unmark files selectively if they could not be added
 to the archive, and later call `removeUploadedFiles:withError:` to remove only
 the files that are still marked uploaded.
 
 @param fileURLs    The array of files that should be removed.
 @param error       The error that occurred, if the operation fails.
 
 @return `YES` if removing the files succeeded; otherwise, `NO`.
 */
- (BOOL)removeUploadedFiles:(NSArray<NSURL *> *)fileURLs withError:(NSError * _Nullable __autoreleasing *)error;

/**
 Removes all files managed by this logger (files that have the `logName` prefix).
 
 @param error       The error that occurred, if operation fails.
 
 @return `YES` if removing the files succeeded.; otherwise, `NO`.
 */
- (BOOL)removeAllFilesWithError:(NSError *_Nullable __autoreleasing *)error;

@end


/**
 The `ORKLogFormatter` class represents the base (default) log formatter, which appends data
 blindly to a log file.
 
 A log formatter is used by a data logger to format objects
 for output to the log, and to begin a new log file and end an existing log file.
 `ORKLogFormatter` accepts NSData and has neither a header nor a footer.
 
 A log formatter should ensure that the log is always in a valid state, so that
 even if the app is killed, the log is still readable.
 */
@interface ORKLogFormatter : NSObject

/**
 Returns a Boolean value that indicates whether the log formatter can serialize the specified type of object.
 
 @param c       The class of object to serialize.
 
 @return `YES` if the log formatter can serialize this object class; otherwise, `NO`.
 */
- (BOOL)canAcceptLogObjectOfClass:(Class)c;

/**
 Returns a Boolean value that indicates whether the log formatter can serialize the specified type of object.
 
 @param object       The object to serialize.
 
 @return `YES` if the log formatter can serialize `object`; otherwise, `NO`
 */
- (BOOL)canAcceptLogObject:(id)object;

/**
 Begins a new log file on the specified file handle.
 
 For example, may write a header or opening stanza of a new log file.
 
 @param fileHandle      The file handle to which to write.
 @param error           The error output, on failure.
 
 @return  `YES` if the write succeeds; otherwise, `NO`.
 */
- (BOOL)beginLogWithFileHandle:(NSFileHandle *)fileHandle error:(NSError * _Nullable __autoreleasing *)error;

/**
 Appends the specified object to the log file.
 
 @param object          The object to write.
 @param fileHandle      The file handle to which to write.
 @param error           The error output, on failure.
 
 @return `YES` if the write succeeds; otherwise, `NO`.
 */
- (BOOL)appendObject:(id)object fileHandle:(NSFileHandle *)fileHandle error:(NSError * _Nullable __autoreleasing *)error;

/**
 Appends the specified objects to the log file.
 
 @param objects         The objects to write.
 @param fileHandle      The file handle to which to write.
 @param error           The error output, on failure.
 
 @return  `YES` if the write succeeds; otherwise, `NO`.
 */
- (BOOL)appendObjects:(NSArray *)objects fileHandle:(NSFileHandle *)fileHandle error:(NSError * _Nullable __autoreleasing *)error;

@end


/**
 The `ORKJSONLogFormatter` class represents a log formatter for producing JSON output.
 
 The JSON log formatter accepts `NSDictionary` objects for serialization.
 The JSON output is a dictionary that contains one key, `items`,
 which contains the array of logged items. The log itself does not contain
 any timestamp information, so the items should include such fields,
 if desired.
 */
ORK_CLASS_AVAILABLE
@interface ORKJSONLogFormatter : ORKLogFormatter

@end


@class ORKJSONDataLogger;
@class ORKDataLoggerManager;

/**
 The `ORKDataLoggerManagerDelegate` protocol defines methods a delegate can implement to receive notifications
 when the data loggers managed by a `ORKDataLoggerManager` reach a certain file size threshold.
 */
ORK_CLASS_AVAILABLE
@protocol ORKDataLoggerManagerDelegate <NSObject>

/**
 Called by the data logger manager when the total size of files
 that are not marked uploaded has reached a threshold.
 
 @param dataLoggerManager       The manager that produced the notification.
 @param pendingUploadBytes      The number of bytes managed by all the loggers, which
            have not yet been marked uploaded.
 */
- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLoggerManager pendingUploadBytesReachedThreshold:(unsigned long long)pendingUploadBytes;

/**
 Called by the data logger manager when the total size of files
 managed by any of the loggers has reached a threshold.
 
 @param dataLoggerManager       The manager that produced the notification.
 @param totalBytes              The total number of bytes of all files managed.
 */
- (void)dataLoggerManager:(ORKDataLoggerManager *)dataLoggerManager totalBytesReachedThreshold:(unsigned long long)totalBytes;

@end


/**
 The `ORKDataLoggerManager` class represents a manager for multiple `ORKDataLogger` instances,
 which tracks the total size of log files produced and can notify its delegate
 when file sizes reach configurable thresholds.
 
 The `ORKDataLoggerManager` class is an internal component used by some `ORKRecorder`
 subclasses for writing data to disk during tasks.
 
 This manager can be used to organize the `ORKDataLogger` logs in a directory,
 and keep track of the total number of bytes stored on disk by each logger. The
 delegate can be informed if either the number of bytes pending upload, or the total
 number of bytes, exceeds configurable thresholds.
 
 The configuration of the loggers and their thresholds is persisted in a
 configuration file in the log directory.
 
 If the number of bytes pending upload exceeds the threshold, the natural action is to
 upload them. A block-based enumeration is provided for enumerating all the logs
 pending upload. Use `enumerateLogsNeedingUpload:error:`, and when a log has been
 processed for upload, use the logger to mark it uploaded.
 
 When the upload succeeds (or at least is successfully queued), the uploaded files
 can be removed across all the loggers by calling `removeUploadedFiles:error:`
 
 If the total number of bytes exceeds the threshold, the natural action is to remove log
 files that have been marked uploaded, and then remove old log files until the
 threshold is no longer exceeded. You can do this by calling `removeOldAndUploadedLogsToThreshold:error:`
 */
ORK_CLASS_AVAILABLE
@interface ORKDataLoggerManager : NSObject <ORKDataLoggerDelegate>

- (instancetype)init NS_UNAVAILABLE;

/**
 Returns an initialized data logger manager using the specified directory and delegate.
 
 Designated initializer.
 
 @param directory       The file URL of the directory where the data loggers should coexist.
 @param delegate        The delegate to receive notifications.
 
 @return An initialized data logger manager.
 */
- (instancetype)initWithDirectory:(NSURL *)directory delegate:(nullable id<ORKDataLoggerManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// The delegate of the data logger manager.
@property (weak, nullable) id<ORKDataLoggerManagerDelegate> delegate;

/// The threshold for delegate callback for total bytes not marked uploaded.
@property unsigned long long pendingUploadBytesThreshold;

/// The threshold for delegate callback for total bytes of completed logs.
@property unsigned long long totalBytesThreshold;

/// The total number of bytes of files not marked as pending upload.
@property unsigned long long pendingUploadBytes;

/// The total number of bytes for all the loggers.
@property unsigned long long totalBytes;

/**
 Adds a data logger with a JSON log format to the directory.
 
 This method throws an exception if a logger already exists with the specified log name.
 
 @param logName     The log name prefix for the data logger.
 
 @return The `ORKDataLogger` object that was added.
 */
- (ORKDataLogger *)addJSONDataLoggerForLogName:(NSString *)logName;

/**
 Adds a data logger with a particular formatter to the directory.
 
 @param logName     The log name prefix for the data logger.
 @param formatter   The log formatter instance to use for this logger.
 
 @return The `ORKDataLogger` object that was added, or the existing one if one already existed for
 that log name.
 */
- (ORKDataLogger *)addDataLoggerForLogName:(NSString *)logName formatter:(ORKLogFormatter *)formatter;

/**
 Retrieves the already existing data logger for a log name.
 
 @param logName     The log name prefix for the data logger.
 
 @return The `ORKDataLogger` object that was retrieved, or `nil` if one already existed for that log name.
 */
- (nullable ORKDataLogger *)dataLoggerForLogName:(NSString *)logName;

/**
 Removes a data logger.
 
 @param logger      The logger to remove.
 */
- (void)removeDataLogger:(ORKDataLogger *)logger;

/// Returns the set of log names of the data loggers managed by this object.
- (NSArray<NSString *> *)logNames;

/**
 Enumerates all the logs that need upload across all data loggers, sorted from oldest to first.
 
 Before sorting the logs, this method fetches all the data loggers' logs that need upload.
 
 @param block       The block to call during enumeration.
 @param error       The error, on failure.
 
 @return `YES` if the enumeration succeeds; otherwise, `NO`.
 */
- (BOOL)enumerateLogsNeedingUpload:(void (^)(ORKDataLogger *dataLogger, NSURL *logFileUrl, BOOL *stop))block error:(NSError * __autoreleasing *)error;

/**
 Unmarks the set of uploaded files.
 
 Use this method to indicate that the specified files should no longer be marked uploaded (for example, because
 the upload did not succeed).
 
 @param fileURLs    The array of file URLs that should no longer be marked uploaded.
 @param error       The error, on failure.
 
 @return `YES` if the operation succeeds; otherwise, `NO`.
 */
- (BOOL)unmarkUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError * _Nullable __autoreleasing *)error;

/**
 Removes a set of uploaded files.
 
 This method is analogous to a similar method in `ORKDataLogger`, but it accepts an array of files
 that may relate to any of the data loggers. It is an error to pass a URL which would not
 belong to one of the loggers managed by this manager.
 
 @param fileURLs    The array of file URLs that should be removed.
 @param error       The error, on failure.
 
 @return `YES` if the operation succeeds; otherwise, `NO`.
 */
- (BOOL)removeUploadedFiles:(NSArray<NSURL *> *)fileURLs error:(NSError * _Nullable __autoreleasing *)error;

/**
 Removes old and uploaded logs to bring total bytes down to a threshold.
 
 This method removes uploaded logs first, followed by the oldest log files across
 all of the data loggers, until the total usage falls below a threshold.
 
 @param bytes       The threshold down to which to remove old log files. File removal stops when the total bytes managed by all the data loggers reaches this threshold.
 @param error       The error, on failure.
 
 @return `YES` if the operation succeeds; otherwise, `NO`.
 */
- (BOOL)removeOldAndUploadedLogsToThreshold:(unsigned long long)bytes error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
