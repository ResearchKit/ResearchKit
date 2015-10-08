/*
 Copyright (c) 2015, Brandon McQuilkin, Quintiles Inc.
 Copyright (c) 2015, Pavel Kanzelsberger, Quintiles Inc.
 
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


#import "ORKSurveyAnswerCellForLocation.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ORKAnswerTextField.h"
#import "ORKHelpers.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKLocationSelectionView.h"
#import "MKPlacemark+ORKStringConversion.h"


@interface ORKSurveyAnswerCellForLocation () <ORKLocationSelectionViewDelegate>
    
@end


@implementation ORKSurveyAnswerCellForLocation {
    ORKLocationSelectionView *_selectionView;
}

- (BOOL)becomeFirstResponder {
    return [_selectionView becomeFirstResponder];
}

- (void)setStep:(ORKQuestionStep *)step {
    [super setStep:step];
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return 282;
}

- (void)prepareView {
    _selectionView = [[ORKLocationSelectionView alloc] initWithOpenMap:YES];
    _selectionView.delegate = self;
    _selectionView.tintColor = self.tintColor;
    _selectionView.useCurrentLocation = ((ORKLocationAnswerFormat *)self.step.answerFormat).useCurrentLocation;
    [self addSubview:_selectionView];

    [self setUpConstraints];
}

- (void)setUpConstraints {
    NSMutableArray *constraints = [NSMutableArray new];

    NSDictionary *views = NSDictionaryOfVariableBindings(_selectionView);
    ORKEnableAutoLayoutForViews([views allValues]);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_selectionView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_selectionView]|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    
    NSLayoutConstraint *resistsCompressingMapConstraint = [NSLayoutConstraint constraintWithItem:_selectionView
                                                                                       attribute:NSLayoutAttributeWidth
                                                                                       relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                          toItem:nil
                                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                                      multiplier:1.0
                                                                                        constant:20000.0];
    resistsCompressingMapConstraint.priority = UILayoutPriorityDefaultHigh;
    [constraints addObject:resistsCompressingMapConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

- (BOOL)isAnswerValid {
    id answer = self.answer;
    
    if (answer == ORKNullAnswerValue()) {
        return YES;
    }
    
    ORKAnswerFormat *answerFormat = [self.step impliedAnswerFormat];
    ORKLocationAnswerFormat *locationFormat = (ORKLocationAnswerFormat *)answerFormat;
    
    MKPlacemark *placemark = (MKPlacemark *)answer;
    NSString *string = [placemark ork_stringValue];
    
    return [locationFormat isAnswerValidWithString:string];
}

- (BOOL)shouldContinue {
    BOOL isValid = [self isAnswerValid];
    
    if (!isValid) {
        id answer = self.answer;
        MKPlacemark *placemark = (MKPlacemark *)answer;
        NSString *message = [placemark ork_stringValue];
        
        NSString *localizedMessage = [[self.step impliedAnswerFormat] localizedInvalidValueStringWithAnswerString:message];
        
        [self showValidityAlertWithMessage:localizedMessage];
    }
    
    return isValid;
}

- (void)answerDidChange {
    id answer = self.answer;
    
    id displayValue = (answer && answer != ORKNullAnswerValue()) ? answer : nil;
    if ([displayValue isKindOfClass:[MKPlacemark class]]) {
        _selectionView.answer = (MKPlacemark *)answer;
    }
    
    NSString *placeholder = self.step.placeholder? : ORKLocalizedString(@"PLACEHOLDER_TEXT_OR_NUMBER", nil);
    [_selectionView setPlaceholderText:placeholder];
}

- (void)locationSelectionViewDidChange:(ORKLocationSelectionView *)view {
    if (_selectionView.answer != nil) {
        [self ork_setAnswer:_selectionView.answer];
    } else {
        [self ork_setAnswer:ORKNullAnswerValue()];
    }
}

- (void)locationSelectionView:(ORKLocationSelectionView *)view didFailWithError:(NSError *)error {
    [self showValidityAlertWithTitle:ORKLocalizedString(@"LOCATION_ERROR_TITLE", @"") message:error.localizedDescription];
}

- (void)locationSelectionViewDidBeginEditing:(ORKLocationSelectionView *)view {
    
}

- (void)locationSelectionViewDidEndEditing:(ORKLocationSelectionView *)view {
    
}

- (void)locationSelectionViewNeedsResize:(ORKLocationSelectionView *)view {
    
}

@end
