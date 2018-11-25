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


#import "ORKHelpers_Internal.h"

#import "ORKStep.h"

#import "ORKSkin.h"
#import "ORKTypes.h"

#import <CoreText/CoreText.h>


NSURL *ORKCreateRandomBaseURL() {
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://researchkit.%@/", [NSUUID UUID].UUIDString]];
}

NSBundle *ORKAssetsBundle(void) {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[ORKStep class]];
    });
    return bundle;
}

ORK_INLINE CGFloat ORKCGFloor(CGFloat value) {
    if (sizeof(value) == sizeof(float)) {
        return (CGFloat)floorf((float)value);
    } else {
        return (CGFloat)floor((double)value);
    }
}

ORK_INLINE CGFloat ORKAdjustToScale(CGFloat (adjustFunction)(CGFloat), CGFloat value, CGFloat scale) {
    if (scale == 0) {
        static CGFloat screenScale = 1.0;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            screenScale = [UIScreen mainScreen].scale;
        });
        scale = screenScale;
    }
    if (scale == 1.0) {
        return adjustFunction(value);
    } else {
        return adjustFunction(value * scale) / scale;
    }
}

CGFloat ORKFloorToViewScale(CGFloat value, UIView *view) {
    return ORKAdjustToScale(ORKCGFloor, value, view.contentScaleFactor);
}

id findInArrayByKey(NSArray * array, NSString *key, id value) {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    NSArray *matches = [array filteredArrayUsingPredicate:pred];
    if (matches.count) {
        return matches[0];
    }
    return nil;
}

NSString *ORKStringFromDateISO8601(NSDate *date) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter stringFromDate:date];
}

NSDate *ORKDateFromStringISO8601(NSString *string) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return [formatter dateFromString:string];
}

NSString *ORKSignatureStringFromDate(NSDate *date) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    });
    return [formatter stringFromDate:date];
}

UIColor *ORKRGBA(uint32_t x, CGFloat alpha) {
    CGFloat b = (x & 0xff) / 255.0f; x >>= 8;
    CGFloat g = (x & 0xff) / 255.0f; x >>= 8;
    CGFloat r = (x & 0xff) / 255.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

UIColor *ORKRGB(uint32_t x) {
    return ORKRGBA(x, 1.0f);
}

UIFontDescriptor *ORKFontDescriptorForLightStylisticAlternative(UIFontDescriptor *descriptor) {
    UIFontDescriptor *fontDescriptor = [descriptor
                      fontDescriptorByAddingAttributes:
                      @{ UIFontDescriptorFeatureSettingsAttribute: @[
                                 @{ UIFontFeatureTypeIdentifierKey: @(kCharacterAlternativesType),
                                    UIFontFeatureSelectorIdentifierKey: @(1) }]}];
    return fontDescriptor;
}


UIFont *ORKTimeFontForSize(CGFloat size) {
    UIFontDescriptor *fontDescriptor = [ORKLightFontWithSize(size) fontDescriptor];
    fontDescriptor = ORKFontDescriptorForLightStylisticAlternative(fontDescriptor);
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:0];
    return font;
}

NSString *ORKFileProtectionFromMode(ORKFileProtectionMode mode) {
    switch (mode) {
        case ORKFileProtectionComplete:
            return NSFileProtectionComplete;
        case ORKFileProtectionCompleteUnlessOpen:
            return NSFileProtectionCompleteUnlessOpen;
        case ORKFileProtectionCompleteUntilFirstUserAuthentication:
            return NSFileProtectionCompleteUntilFirstUserAuthentication;
        case ORKFileProtectionNone:
            return NSFileProtectionNone;
    }
    //assert(0);
    return NSFileProtectionNone;
}

CGFloat ORKExpectedLabelHeight(UILabel *label) {
    CGSize expectedLabelSize = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{ NSFontAttributeName : label.font }
                                                        context:nil].size;
    return expectedLabelSize.height;
}

void ORKAdjustHeightForLabel(UILabel *label) {
    CGRect rect = label.frame;
    rect.size.height = ORKExpectedLabelHeight(label);
    label.frame = rect;
}

UIImage *ORKImageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

void ORKEnableAutoLayoutForViews(NSArray *views) {
    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView *)obj setTranslatesAutoresizingMaskIntoConstraints:NO];
    }];
}

NSDateFormatter *ORKResultDateTimeFormatter() {
    static NSDateFormatter *dateTimeformatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeformatter = [[NSDateFormatter alloc] init];
        [dateTimeformatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        dateTimeformatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return dateTimeformatter;
}

NSDateFormatter *ORKResultTimeFormatter() {
    static NSDateFormatter *timeformatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeformatter = [[NSDateFormatter alloc] init];
        [timeformatter setDateFormat:@"HH:mm"];
        timeformatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return timeformatter;
}

NSDateFormatter *ORKResultDateFormatter() {
    static NSDateFormatter *dateformatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy-MM-dd"];
        dateformatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return dateformatter;
}

NSDateFormatter *ORKTimeOfDayLabelFormatter() {
    static NSDateFormatter *timeformatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeformatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hma" options:0 locale:[NSLocale currentLocale]];
        [timeformatter setDateFormat:dateFormat];
        timeformatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return timeformatter;
}

NSBundle *ORKBundle() {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[ORKStep class]];
    });
    return bundle;
}

NSBundle *ORKDefaultLocaleBundle() {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [ORKBundle() pathForResource:[ORKBundle() objectForInfoDictionaryKey:@"CFBundleDevelopmentRegion"] ofType:@"lproj"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

NSDateComponentsFormatter *ORKTimeIntervalLabelFormatter() {
    static NSDateComponentsFormatter *durationFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        durationFormatter = [[NSDateComponentsFormatter alloc] init];
        [durationFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStyleFull];
        [durationFormatter setAllowedUnits:NSCalendarUnitHour | NSCalendarUnitMinute];
        [durationFormatter setFormattingContext:NSFormattingContextStandalone];
        [durationFormatter setMaximumUnitCount: 2];
    });
    return durationFormatter;
}

NSDateComponentsFormatter *ORKDurationStringFormatter() {
    static NSDateComponentsFormatter *durationFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        durationFormatter = [[NSDateComponentsFormatter alloc] init];
        [durationFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStyleFull];
        [durationFormatter setAllowedUnits: NSCalendarUnitMinute | NSCalendarUnitSecond];
        [durationFormatter setFormattingContext:NSFormattingContextStandalone];
        [durationFormatter setMaximumUnitCount: 2];
    });
    return durationFormatter;
}

NSCalendar *ORKTimeOfDayReferenceCalendar() {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return calendar;
}

NSString *ORKTimeOfDayStringFromComponents(NSDateComponents *dateComponents) {
    static NSDateComponentsFormatter *timeOfDayFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeOfDayFormatter = [[NSDateComponentsFormatter alloc] init];
        [timeOfDayFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStylePositional];
        [timeOfDayFormatter setAllowedUnits:NSCalendarUnitHour | NSCalendarUnitMinute];
        [timeOfDayFormatter setZeroFormattingBehavior:NSDateComponentsFormatterZeroFormattingBehaviorPad];
    });
    return [timeOfDayFormatter stringFromDateComponents:dateComponents];
}

NSDateComponents *ORKTimeOfDayComponentsFromString(NSString *string) {
    // NSDateComponentsFormatter don't support parsing, this is a work around.
    static NSDateFormatter *timeformatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeformatter = [[NSDateFormatter alloc] init];
        [timeformatter setDateFormat:@"HH:mm"];
        timeformatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    NSDate *date = [timeformatter dateFromString:string];
    return [ORKTimeOfDayReferenceCalendar() components:(NSCalendarUnitMinute |NSCalendarUnitHour) fromDate:date];
}

NSDateComponents *ORKTimeOfDayComponentsFromDate(NSDate *date) {
    if (date == nil) {
        return nil;
    }
    return [ORKTimeOfDayReferenceCalendar() components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
}

NSDate *ORKTimeOfDayDateFromComponents(NSDateComponents *dateComponents) {
    return [ORKTimeOfDayReferenceCalendar() dateFromComponents:dateComponents];
}

BOOL ORKCurrentLocalePresentsFamilyNameFirst() {
    NSString *language = [[NSLocale preferredLanguages].firstObject substringToIndex:2];
    static dispatch_once_t onceToken;
    static NSArray *familyNameFirstLanguages = nil;
    dispatch_once(&onceToken, ^{
        familyNameFirstLanguages = @[@"zh", @"ko", @"ja", @"vi"];
    });
    return (language != nil) && [familyNameFirstLanguages containsObject:language];
}

#define ORK_LAYOUT_MARGIN_WIDTH_THIN_BEZEL_REGULAR 20.0
#define ORK_LAYOUT_MARGIN_WIDTH_THIN_BEZEL_COMPACT 16.0
#define ORK_LAYOUT_MARGIN_WIDTH_REGULAR_BEZEL 15.0

UIFont *ORKThinFontWithSize(CGFloat size) {
    UIFont *font = nil;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) {
        font = [UIFont systemFontOfSize:size weight:UIFontWeightThin];
    } else {
        font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:size];
        if (!font) {
            font = [UIFont systemFontOfSize:size];
        }
    }
    return font;
}

UIFont *ORKMediumFontWithSize(CGFloat size) {
    UIFont *font = nil;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) {
        font = [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    } else {
        font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
        if (!font) {
            font = [UIFont systemFontOfSize:size];
        }
    }
    return font;
}

UIFont *ORKLightFontWithSize(CGFloat size) {
    UIFont *font = nil;
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 8, .minorVersion = 2, .patchVersion = 0}]) {
        font = [UIFont systemFontOfSize:size weight:UIFontWeightLight];
    } else {
        font = [UIFont fontWithName:@".HelveticaNeueInterface-Light" size:size];
        if (!font) {
            font = [UIFont systemFontOfSize:size];
        }
    }
    return font;
}

NSURL *ORKURLFromBookmarkData(NSData *data) {
    if (data == nil) {
        return nil;
    }
    
    BOOL bookmarkIsStale = NO;
    NSError *bookmarkError = nil;
    NSURL *bookmarkURL = [NSURL URLByResolvingBookmarkData:data
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&bookmarkError];
    if (!bookmarkURL) {
        ORK_Log_Warning(@"Error loading URL from bookmark: %@", bookmarkError);
    }
    
    return bookmarkURL;
}

NSData *ORKBookmarkDataFromURL(NSURL *url) {
    if (!url) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&error];
    if (!bookmark) {
        ORK_Log_Warning(@"Error converting URL to bookmark: %@", error);
    }
    return bookmark;
}

NSString *ORKPathRelativeToURL(NSURL *url, NSURL *baseURL) {
    NSURL *standardizedURL = [url URLByStandardizingPath];
    NSURL *standardizedBaseURL = [baseURL URLByStandardizingPath];
    
    NSString *path = [standardizedURL absoluteString];
    NSString *basePath = [standardizedBaseURL absoluteString];
    
    if ([path hasPrefix:basePath]) {
        NSString *relativePath = [path substringFromIndex:basePath.length];
        if ([relativePath hasPrefix:@"/"]) {
            relativePath = [relativePath substringFromIndex:1];
        }
        return relativePath;
    } else {
        return path;
    }
}

static NSURL *ORKHomeDirectoryURL() {
    static NSURL *homeDirectoryURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        homeDirectoryURL = [NSURL fileURLWithPath:NSHomeDirectory()];
    });
    return homeDirectoryURL;
}

NSURL *ORKURLForRelativePath(NSString *relativePath) {
    if (!relativePath) {
        return nil;
    }
    
    NSURL *homeDirectoryURL = ORKHomeDirectoryURL();
    NSURL *url = [NSURL fileURLWithFileSystemRepresentation:relativePath.fileSystemRepresentation isDirectory:NO relativeToURL:homeDirectoryURL];
    
    if (url != nil) {
        BOOL isDirectory = NO;;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory];
        if (fileExists && isDirectory) {
            url = [NSURL fileURLWithFileSystemRepresentation:relativePath.fileSystemRepresentation isDirectory:YES relativeToURL:homeDirectoryURL];
        }
    }
    return url;
}
NSString *ORKRelativePathForURL(NSURL *url) {
    if (!url) {
        return nil;
    }
    
    return ORKPathRelativeToURL(url, ORKHomeDirectoryURL());
}

id ORKDynamicCast_(id x, Class objClass) {
    return [x isKindOfClass:objClass] ? x : nil;
}

const CGFloat ORKScrollToTopAnimationDuration = 0.2;

void ORKValidateArrayForObjectsOfClass(NSArray *array, Class expectedObjectClass, NSString *exceptionReason) {
    NSCParameterAssert(array);
    NSCParameterAssert(expectedObjectClass);
    NSCParameterAssert(exceptionReason);

    for (id object in array) {
        if (![object isKindOfClass:expectedObjectClass]) {
            @throw [NSException exceptionWithName:NSGenericException reason:exceptionReason userInfo:nil];
        }
    }
}

void ORKRemoveConstraintsForRemovedViews(NSMutableArray *constraints, NSArray *removedViews) {
    for (NSLayoutConstraint *constraint in [constraints copy]) {
        for (UIView *view in removedViews) {
            if (constraint.firstItem == view || constraint.secondItem == view) {
                [constraints removeObject:constraint];
            }
        }
    }
}

const double ORKDoubleInvalidValue = DBL_MAX;

const CGFloat ORKCGFloatInvalidValue = CGFLOAT_MAX;

void ORKAdjustPageViewControllerNavigationDirectionForRTL(UIPageViewControllerNavigationDirection *direction) {
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        *direction = (*direction == UIPageViewControllerNavigationDirectionForward) ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    }
}

NSString *ORKPaddingWithNumberOfSpaces(NSUInteger numberOfPaddingSpaces) {
    return [@"" stringByPaddingToLength:numberOfPaddingSpaces withString:@" " startingAtIndex:0];
}

NSNumberFormatter *ORKDecimalNumberFormatter() {
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = NSDecimalNoScale;
    numberFormatter.usesGroupingSeparator = NO;
    return numberFormatter;
}
