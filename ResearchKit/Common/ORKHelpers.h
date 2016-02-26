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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ResearchKit/ORKErrors.h>


#if ( defined(ORK_LOG_LEVEL_NONE) && ORK_LOG_LEVEL_NONE )
#  undef ORK_LOG_LEVEL_DEBUG
#  undef ORK_LOG_LEVEL_WARNING
#  undef ORK_LOG_LEVEL_ERROR
#endif

#if ( !defined(ORK_LOG_LEVEL_NONE) && !defined(ORK_LOG_LEVEL_DEBUG) && !defined(ORK_LOG_LEVEL_WARNING) && !defined(ORK_LOG_LEVEL_ERROR) )
#  define ORK_LOG_LEVEL_WARNING 1
#endif

#define _ORK_LogWithLevel(level,fmt,...) NSLog(@"[ResearchKit]["#level"] %s " fmt, __PRETTY_FUNCTION__, ## __VA_ARGS__)

#if ( ORK_LOG_LEVEL_DEBUG )
#  define ORK_Log_Debug(fmt,...) _ORK_LogWithLevel(Debug, fmt, ## __VA_ARGS__)
#else
#  define ORK_Log_Debug(...)
#endif

#if ( ORK_LOG_LEVEL_DEBUG || ORK_LOG_LEVEL_WARNING )
#  define ORK_Log_Warning(fmt,...) _ORK_LogWithLevel(Warning, fmt, ## __VA_ARGS__)
#else
#  define ORK_Log_Warning(...)
#endif

#if ( ORK_LOG_LEVEL_DEBUG || ORK_LOG_LEVEL_WARNING || ORK_LOG_LEVEL_ERROR )
#  define ORK_Log_Error(fmt,...) _ORK_LogWithLevel(Error, fmt, ## __VA_ARGS__)
#else
#  define ORK_Log_Error(...)
#endif


#if !defined(ORK_INLINE)
#  if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#    define ORK_INLINE static inline
#  elif defined(__cplusplus)
#    define ORK_INLINE static inline
#  elif defined(__GNUC__)
#    define ORK_INLINE static __inline__
#  else
#    define ORK_INLINE static
#  endif
#endif

#define ORK_NARG(...) ORK_NARG_(__VA_ARGS__,ORK_RSEQ_N())
#define ORK_NARG_(...)  ORK_ARG_N(__VA_ARGS__)
#define ORK_ARG_N( _1, _2, _3, _4, _5, _6, _7, _8, _9,_10, N, ...) N
#define ORK_RSEQ_N()   10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0

#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)

#define ORK_DECODE_OBJ(d,x)  _ ## x = [d decodeObjectForKey:@STRINGIFY(x)]
#define ORK_ENCODE_OBJ(c,x)  [c encodeObject:_ ## x forKey:@STRINGIFY(x)]
#define ORK_ENCODE_URL(c,x)  [c encodeObject:ORKRelativePathForURL(_ ## x) forKey:@STRINGIFY(x)]
#define ORK_ENCODE_URL_BOOKMARK(c, x) [c encodeObject:ORKBookmarkDataFromURL(_ ## x) forKey:@STRINGIFY(x)]

#define ORK_DECODE_OBJ_CLASS(d,x,cl)  _ ## x = (cl *)[d decodeObjectOfClass:[cl class] forKey:@STRINGIFY(x)]
#define ORK_DECODE_OBJ_ARRAY(d,x,cl)  _ ## x = (NSArray *)[d decodeObjectOfClasses:[NSSet setWithObjects:[NSArray class],[cl class],nil] forKey:@STRINGIFY(x)]
#define ORK_DECODE_OBJ_MUTABLE_ORDERED_SET(d,x,cl)  _ ## x = [(NSOrderedSet *)[d decodeObjectOfClasses:[NSSet setWithObjects:[NSOrderedSet class],[cl class],nil] forKey:@STRINGIFY(x)] mutableCopy]
#define ORK_DECODE_OBJ_MUTABLE_DICTIONARY(d,x,kcl,cl)  _ ## x = [(NSDictionary *)[d decodeObjectOfClasses:[NSSet setWithObjects:[NSDictionary class],[kcl class],[cl class],nil] forKey:@STRINGIFY(x)] mutableCopy]

#define ORK_ENCODE_COND_OBJ(c,x)  [c encodeConditionalObject:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_IMAGE(d,x)  _ ## x = (UIImage *)[d decodeObjectOfClass:[UIImage class] forKey:@STRINGIFY(x)]
#define ORK_ENCODE_IMAGE(c,x)  { if (_ ## x) { UIImage * __ ## x = [UIImage imageWithCGImage:[_ ## x CGImage] scale:[_ ## x scale] orientation:[_ ## x imageOrientation]]; [c encodeObject:__ ## x forKey:@STRINGIFY(x)]; } }

#define ORK_DECODE_URL(d,x) _ ## x = ORKURLForRelativePath((NSString *)[d decodeObjectOfClass:[NSString class] forKey:@STRINGIFY(x)])
#define ORK_DECODE_URL_BOOKMARK(d,x)  _ ## x = ORKURLFromBookmarkData((NSData *)[d decodeObjectOfClass:[NSData class] forKey:@STRINGIFY(x)])

#define ORK_DECODE_BOOL(d,x)  _ ## x = [d decodeBoolForKey:@STRINGIFY(x)]
#define ORK_ENCODE_BOOL(c,x)  [c encodeBool:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_DOUBLE(d,x)  _ ## x = [d decodeDoubleForKey:@STRINGIFY(x)]
#define ORK_ENCODE_DOUBLE(c,x)  [c encodeDouble:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_INTEGER(d,x)  _ ## x = [d decodeIntegerForKey:@STRINGIFY(x)]
#define ORK_ENCODE_INTEGER(c,x)  [c encodeInteger:_ ## x forKey:@STRINGIFY(x)]

#define ORK_ENCODE_UINT32(c,x)  [c encodeObject:[NSNumber numberWithUnsignedLongLong:_ ## x] forKey:@STRINGIFY(x)]
#define ORK_DECODE_UINT32(d,x)  _ ## x = (uint32_t)[(NSNumber *)[d decodeObjectForKey:@STRINGIFY(x)] unsignedLongValue]

#define ORK_DECODE_ENUM(d,x)  _ ## x = (__typeof(_ ## x))[d decodeIntegerForKey:@STRINGIFY(x)]
#define ORK_ENCODE_ENUM(c,x)  [c encodeInteger:(NSInteger)_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_CGRECT(d,x)  _ ## x = (__typeof(_ ## x))[d decodeCGRectForKey:@STRINGIFY(x)]
#define ORK_ENCODE_CGRECT(c,x)  [c encodeCGRect:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_CGSIZE(d,x)  _ ## x = (__typeof(_ ## x))[d decodeCGSizeForKey:@STRINGIFY(x)]
#define ORK_ENCODE_CGSIZE(c,x)  [c encodeCGSize:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_CGPOINT(d,x)  _ ## x = (__typeof(_ ## x))[d decodeCGPointForKey:@STRINGIFY(x)]
#define ORK_ENCODE_CGPOINT(c,x)  [c encodeCGPoint:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_UIEDGEINSETS(d,x)  _ ## x = (__typeof(_ ## x))[d decodeUIEdgeInsetsForKey:@STRINGIFY(x)]
#define ORK_ENCODE_UIEDGEINSETS(c,x)  [c encodeUIEdgeInsets:_ ## x forKey:@STRINGIFY(x)]

#define ORK_DECODE_COORDINATE(d,x)  _ ## x = CLLocationCoordinate2DMake([d decodeDoubleForKey:@STRINGIFY(x.latitude)],[d decodeDoubleForKey:@STRINGIFY(x.longitude)])
#define ORK_ENCODE_COORDINATE(c,x)  [c encodeDouble:_ ## x.latitude forKey:@STRINGIFY(x.latitude)];[c encodeDouble:_ ## x.longitude forKey:@STRINGIFY(x.longitude)];

/*
 * Helpers for completions which call the block only if non-nil
 *
 */
#define BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };

#define DISPATCH_EXEC(queue, block, ...) if (block) { dispatch_async(queue, ^{ block(__VA_ARGS__); } ); }

/*
 * For testing background delivery
 *
 */
#if ORK_BACKGROUND_DELIVERY_TEST
#  define ORK_HEALTH_UPDATE_FREQUENCY HKUpdateFrequencyImmediate
#else
#  define ORK_HEALTH_UPDATE_FREQUENCY HKUpdateFrequencyDaily
#endif

// Find the first object of the specified class, using method as the iterator
#define ORKFirstObjectOfClass(C,p,method) ({ id v = p; while (v != nil) { if ([v isKindOfClass:[C class]]) { break; } else { v = [v method]; } }; v; })

// Bundle for video assets
NSBundle *ORKAssetsBundle(void);
NSBundle *ORKBundle();
NSBundle *ORKDefaultLocaleBundle();

// Pass 0xcccccc and get color #cccccc
UIColor *ORKRGB(uint32_t x);
UIColor *ORKRGBA(uint32_t x, CGFloat alpha);

id findInArrayByKey(NSArray * array, NSString *key, id value);

NSString *ORKStringFromDateISO8601(NSDate *date);
NSDate *ORKDateFromStringISO8601(NSString *string);

NSString *ORKSignatureStringFromDate(NSDate *date);

NSURL *ORKCreateRandomBaseURL();

// Marked extern so it is accessible to unit tests
ORK_EXTERN NSString *ORKFileProtectionFromMode(ORKFileProtectionMode mode);

CGFloat ORKExpectedLabelHeight(UILabel *label);
void ORKAdjustHeightForLabel(UILabel *label);

// build a image with color
UIImage *ORKImageWithColor(UIColor *color);

void ORKEnableAutoLayoutForViews(NSArray *views);

NSDateComponentsFormatter *ORKTimeIntervalLabelFormatter();
NSDateComponentsFormatter *ORKDurationStringFormatter();

NSDateFormatter *ORKTimeOfDayLabelFormatter();
NSCalendar *ORKTimeOfDayReferenceCalendar();

NSDateComponents *ORKTimeOfDayComponentsFromDate(NSDate *date);
NSDate *ORKTimeOfDayDateFromComponents(NSDateComponents *dateComponents);

BOOL ORKCurrentLocalePresentsFamilyNameFirst();

UIFont *ORKTimeFontForSize(CGFloat size);
UIFontDescriptor *ORKFontDescriptorForLightStylisticAlternative(UIFontDescriptor *descriptor);

CGFloat ORKFloorToViewScale(CGFloat value, UIView *view);

ORK_INLINE bool
ORKEqualObjects(id o1, id o2) {
    return (o1 == o2) || (o1 && o2 && [o1 isEqual:o2]);
}

ORK_INLINE BOOL
ORKEqualFileURLs(NSURL *url1, NSURL *url2) {
    return ORKEqualObjects(url1, url2) || ([url1 isFileURL] && [url2 isFileURL] && [[url1 absoluteString] isEqualToString:[url2 absoluteString]]);
}

ORK_INLINE NSArray *
ORKArrayCopyObjects(NSArray *a) {
    if (!a) {
        return nil;
    }
    NSMutableArray *b = [NSMutableArray arrayWithCapacity:a.count];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [b addObject:[obj copy]];
    }];
    return [b copy];
}

ORK_INLINE NSMutableOrderedSet *
ORKMutableOrderedSetCopyObjects(NSOrderedSet *a) {
    if (!a) {
        return nil;
    }
    NSMutableOrderedSet *b = [NSMutableOrderedSet orderedSetWithCapacity:a.count];
    [a enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [b addObject:[obj copy]];
    }];
    return b;
}

ORK_INLINE NSMutableDictionary *
ORKMutableDictionaryCopyObjects(NSDictionary *a) {
    if (!a) {
        return nil;
    }
    NSMutableDictionary *b = [NSMutableDictionary dictionaryWithCapacity:a.count];
    [a enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        b[key] = [obj copy];
    }];
    return b;
}

#define ORKSuppressPerformSelectorWarning(PerformCall) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
PerformCall; \
_Pragma("clang diagnostic pop") \
} while (0)

UIFont *ORKThinFontWithSize(CGFloat size);
UIFont *ORKLightFontWithSize(CGFloat size);
UIFont *ORKMediumFontWithSize(CGFloat size);

NSURL *ORKURLFromBookmarkData(NSData *data);
NSData *ORKBookmarkDataFromURL(NSURL *url);

NSString *ORKPathRelativeToURL(NSURL *url, NSURL *baseURL);
NSURL *ORKURLForRelativePath(NSString *relativePath);
NSString *ORKRelativePathForURL(NSURL *url);

id ORKDynamicCast_(id x, Class objClass);

#define ORKDynamicCast(x, c) ((c *) ORKDynamicCast_(x, [c class]))

const CGFloat ORKScrollToTopAnimationDuration;

ORK_INLINE CGFloat
ORKCGFloatNearlyEqualToFloat(CGFloat f1, CGFloat f2) {
    const CGFloat ORKCGFloatEpsilon = 0.01; // 0.01 should be safe enough when dealing with screen point and pixel values
    return (ABS(f1 - f2) <= ORKCGFloatEpsilon);
}
#define ORKDefineStringKey(x) static NSString *const x = @STRINGIFY(x)

#define ORKThrowMethodUnavailableException()  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"method unavailable" userInfo:nil];
#define ORKThrowInvalidArgumentExceptionIfNil(argument)  if (!argument) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@#argument" cannot be nil." userInfo:nil]; }

void ORKValidateArrayForObjectsOfClass(NSArray *array, Class expectedObjectClass, NSString *exceptionReason);

void ORKRemoveConstraintsForRemovedViews(NSMutableArray *constraints, NSArray *removedViews);

const CGFloat ORKCGFloatInvalidValue;

void ORKAdjustPageViewControllerNavigationDirectionForRTL(UIPageViewControllerNavigationDirection *direction);

NSString *ORKPaddingWithNumberOfSpaces(NSUInteger numberOfPaddingSpaces);
