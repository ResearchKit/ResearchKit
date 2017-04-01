/*
 Copyright (c) 2015-2017, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015-2017, Ricardo Sanchez-Saez.
 Copyright (c) 2016-2017, Sage Bionetworks
 
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


#import "TaskFactory.h"

#import "ORKTest-Swift.h"

#import <objc/runtime.h>


// This macro generates a default implementation for CType properties declared inside a class extension.
//
//  Example:
//
//  ORKTypeExtensionProperty_Implementation(myBoolProperty,
//                                          MyBoolProperty,
//                                          BOOL,
//                                          NO);
//
#define ORKTPasteTokens(A,B) A ## B

#define ORKTCTypeExtensionProperty_Implementation(_propertyName,                                        \
                                                 _capitalizedPropertyName,                              \
                                                 _propertyType,                                         \
                                                 _propertyDefaultValue)                                 \
                                                                                                        \
- (void) ORKTPasteTokens(set, _capitalizedPropertyName) :(_propertyType)propertyValue                   \
{                                                                                                       \
    NSValue *value = [NSValue valueWithBytes:&propertyValue objCType:@encode(_propertyType)];           \
    objc_setAssociatedObject(self, @selector(_propertyName), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
}                                                                                                       \
                                                                                                        \
- ( _propertyType ) _propertyName                                                                       \
{                                                                                                       \
    NSValue *value = objc_getAssociatedObject(self, @selector(_propertyName) );                         \
    if (value)                                                                                          \
    {                                                                                                   \
        _propertyType propertyValue; [value getValue:&propertyValue]; return propertyValue;             \
    }                                                                                                   \
    else                                                                                                \
    {                                                                                                   \
        return _propertyDefaultValue ;                                                                  \
    }                                                                                                   \
}                                                                                                       \

#define ORKTCopyExtensionProperty_Implementation(_propertyName,                                         \
                                                 _capitalizedPropertyName,                              \
                                                 _propertyType)                                         \
                                                                                                        \
- (void) ORKTPasteTokens(set, _capitalizedPropertyName) :(_propertyType)propertyValue                   \
{                                                                                                       \
    objc_setAssociatedObject(self,                                                                      \
                             @selector(_propertyName),                                                  \
                             propertyValue,                                                             \
                             OBJC_ASSOCIATION_COPY_NONATOMIC);                                          \
}                                                                                                       \
                                                                                                        \
- ( _propertyType ) _propertyName                                                                       \
{                                                                                                       \
    return objc_getAssociatedObject(self, @selector(_propertyName));                                    \
}                                                                                                       \


@implementation NSObject (TaskFactory)

ORKTCTypeExtensionProperty_Implementation(hidesLearnMoreButtonOnInstructionStep,
                                          HidesLearnMoreButtonOnInstructionStep,
                                          BOOL,
                                          NO);

ORKTCTypeExtensionProperty_Implementation(hidesProgressInNavigationBar,
                                          HidesProgressInNavigationBar,
                                          BOOL,
                                          NO);

ORKTCTypeExtensionProperty_Implementation(isEmbeddedReviewTask,
                                          IsEmbeddedReviewTask,
                                          BOOL,
                                          NO);

ORKTCTypeExtensionProperty_Implementation(triggersStepWillDisappearAction,
                                          TriggersStepWillDisappearAction,
                                          BOOL,
                                          NO);

ORKTCopyExtensionProperty_Implementation(stepViewControllerWillAppearBlock,
                                         StepViewControllerWillAppearBlock,
                                         StepViewControllerWillAppearBlockType);

ORKTCopyExtensionProperty_Implementation(stepViewControllerWillDisappearBlock,
                                         StepViewControllerWillDisappearBlock,
                                         StepViewControllerWillDisappearBlockType);

ORKTCopyExtensionProperty_Implementation(shouldPresentStepBlock,
                                         ShouldPresentStepBlock,
                                         ShouldPresentStepBlockType);

@end


@implementation TaskFactory

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Mapping identifiers to tasks

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier {
    id<ORKTask> task = nil;
    // convert @"SampleTaskIdentifier" into @"makeSampleTaskWithIdentifier:"
    NSString *makeTaskSelectorName = [NSString stringWithFormat:@"make%@WithIdentifier:",
                                      [identifier substringToIndex:identifier.length - 10]];
    SEL makeTaskSelector = NSSelectorFromString(makeTaskSelectorName);
    if ([self respondsToSelector:makeTaskSelector]) {
        // Equivalent to [self peformSelector:buttonSelector], but ARC safe
        IMP imp = [self methodForSelector:makeTaskSelector];
        id<ORKTask> (*func)(id, SEL, NSString *) = (void *)imp;
        task = func(self, makeTaskSelector, identifier);
    }
    return task;
}

/*
 Builds a test consent document.
 */
- (ORKConsentDocument *)buildConsentDocument {
    ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
    
    /*
     If you have HTML review content, you can substitute it for the
     concatenation of sections by doing something like this:
     consent.htmlReviewContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:XXX ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
     */
    
    /*
     Title that will be shown in the generated document.
     */
    consent.title = @"Demo Consent";
    
    
    /*
     Signature page content, used in the generated document above the signatures.
     */
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    /*
     The empty signature that the user will fill in.
     */
    ORKConsentSignature *participantSig = [ORKConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:nil identifier:@"participantSig"];
    [consent addSignature:participantSig];
    
    /*
     Pre-populated investigator's signature.
     */
    ORKConsentSignature *investigatorSig = [ORKConsentSignature signatureForPersonWithTitle:@"Investigator" dateFormatString:nil identifier:@"investigatorSig" givenName:@"Jake" familyName:@"Clemson" signatureImage:[UIImage imageNamed:@"signature"] dateString:@"9/2/14" ];
    [consent addSignature:investigatorSig];
    
    /*
     These are the set of consent sections that have pre-defined animations and
     images.
     
     We will create a section for each of the section types, and then add a custom
     section on the end.
     */
    NSArray *scenes = @[@(ORKConsentSectionTypeOverview),
                        @(ORKConsentSectionTypeDataGathering),
                        @(ORKConsentSectionTypePrivacy),
                        @(ORKConsentSectionTypeDataUse),
                        @(ORKConsentSectionTypeTimeCommitment),
                        @(ORKConsentSectionTypeStudySurvey),
                        @(ORKConsentSectionTypeStudyTasks),
                        @(ORKConsentSectionTypeWithdrawing)];
    
    NSMutableArray *sections = [NSMutableArray new];
    for (NSNumber *type in scenes) {
        NSString *summary = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Et doming eirmod delicata cum. Vel fabellas scribentur neglegentur cu, pro te iudicabit explicari. His alia idque scriptorem ei, quo no nominavi noluisse.";
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:type.integerValue];
        consentSection.summary = summary;
        
        if (type.integerValue == ORKConsentSectionTypeOverview) {
            /*
             Tests HTML content instead of text for Learn More.
             */
            consentSection.htmlContent = @"<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>\
            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p> 研究";
        } else if (type.integerValue == ORKConsentSectionTypeDataGathering) {
            /*
             Tests PDF content instead of text, HTML for Learn More.
             */
            NSString *path = [[NSBundle mainBundle] pathForResource:@"SAMPLE_PDF_TEST" ofType:@"pdf"];
            consentSection.contentURL = [NSURL URLWithString:path];
            
        } else {
            /*
             Tests text Learn More content.
             */
            consentSection.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
            An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
            An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
            An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        }
        
        [sections addObject:consentSection];
    }
    
    {
        /*
         A custom consent scene. This doesn't demo it but you can also set a custom
         animation.
         */
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
        consentSection.summary = @"Custom Scene summary";
        consentSection.title = @"Custom Scene";
        consentSection.customImage = [UIImage imageNamed:@"image_example.png"];
        consentSection.customLearnMoreButtonTitle = @"Learn more about customizing ResearchKit";
        consentSection.content = @"You can customize ResearchKit a lot!";
        [sections addObject:consentSection];
    }
    
    {
        /*
         An "only in document" scene. This is ignored for visual consent, but included in
         the concatenated document for review.
         */
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOnlyInDocument];
        consentSection.summary = @"OnlyInDocument Scene summary";
        consentSection.title = @"OnlyInDocument Scene";
        consentSection.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [sections addObject:consentSection];
    }
    
    consent.sections = [sections copy];
    return consent;
}

/*
 A helper for creating square colored images, which can optionally have a border.
 
 Used for testing the image choices answer format.
 
 @param color   Color to use for the image.
 @param size    Size of image.
 @param border  Boolean value indicating whether to add a black border around the image.
 
 @return An image.
 */
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size border:(BOOL)border {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    view.backgroundColor = color;
    
    if (border) {
        view.layer.borderColor = [[UIColor blackColor] CGColor];
        view.layer.borderWidth = 5.0;
    }
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
