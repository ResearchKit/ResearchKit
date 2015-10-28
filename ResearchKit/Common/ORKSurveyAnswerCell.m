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


#import "ORKSurveyAnswerCell.h"
#import "ORKHelpers.h"
#import "ORKSkin.h"


@interface ORKSurveyAnswerCell ()

// Handle keyboard
@property (nonatomic) UIEdgeInsets cachedContentInsets;
@property (nonatomic) UIEdgeInsets cachedScrollIndicatorInsets;

@end


@implementation ORKSurveyAnswerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                         step:(ORKQuestionStep *)step
                       answer:(id)answer
                     delegate:(id<ORKSurveyAnswerCellDelegate>)delegate {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _delegate = delegate;
        // Set _answer first to resolve the dependency loop between setStep and setAnswer.
        _answer = answer;
        self.step  = step;
        self.answer = answer;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setStep:(ORKQuestionStep *)step {
    _step = step;
    [self prepareView];
}

- (void)prepareView {
    if (self.textField != nil || self.textView != nil) {
        [self registerForKeyboardNotifications];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UITextField *)textField {
    return nil;
}

- (BOOL)shouldContinue {
    return YES;
}

- (UITextView *)textView {
    return nil;
}

- (void)answerDidChange {
    
}

+ (BOOL)shouldDisplayWithSeparators {
    return NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ork_setAnswer:(id)answer {
    _answer = [answer copy];
    [_delegate answerCell:self answerDidChangeTo:answer dueUserAction:YES];
}

- (void)setAnswer:(id)answer {
    _answer = [answer copy];
    [self answerDidChange];
}

- (void)showValidityAlertWithMessage:(NSString *)text {
    [self.delegate answerCell:self invalidInputAlertWithMessage:text];
}

- (void)showValidityAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self.delegate answerCell:self invalidInputAlertWithTitle:title message:message];
}

#pragma mark - KeyboardNotifications

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillAppear:(NSNotification *)aNotification {
    UIView *inputView = self.textView == nil ? self.textField : self.textView;
    
    if (inputView == nil) {
        return;
    }
    
    UITableViewCell *cell = ORKFirstObjectOfClass(UITableViewCell, inputView, superview);
    UITableView *tableView = ORKFirstObjectOfClass(UITableView, cell, superview);
    
    _cachedContentInsets = tableView.contentInset;
    _cachedScrollIndicatorInsets = tableView.scrollIndicatorInsets;
    
    NSDictionary *userInfo = aNotification.userInfo;
    CGSize keyboardSize = ((NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size;
    keyboardSize.height = keyboardSize.height - 44;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    
    tableView.contentInset = contentInsets;
    tableView.scrollIndicatorInsets = contentInsets;
    
    CGRect cellFrame = cell.frame;
    CGPoint desiredOffset = cellFrame.origin;
    
    CGRect availableFrame = tableView.frame;
    availableFrame.size.height -= keyboardSize.height;
    
    desiredOffset.y = cellFrame.origin.y - (availableFrame.size.height / 2);
    
    if (availableFrame.size.height > cellFrame.size.height) {
        desiredOffset.y = cellFrame.origin.y - (availableFrame.size.height - cellFrame.size.height) - (cellFrame.size.height - 55);
    }
    desiredOffset.y = MAX(desiredOffset.y, 0);

    [tableView setContentOffset:desiredOffset animated:NO];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillHide:(NSNotification *)aNotification {
    UIView *inputView = self.textView == nil ? self.textField : self.textView;
    
    if (inputView == nil) {
        return;
    }
    
    UITableView *tableView = ORKFirstObjectOfClass(UITableView, inputView, superview);
    
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         if (UIEdgeInsetsEqualToEdgeInsets(tableView.contentInset, _cachedContentInsets) == NO) {
                             tableView.contentInset = _cachedContentInsets;
                         }
                         
                         if (UIEdgeInsetsEqualToEdgeInsets(tableView.scrollIndicatorInsets, _cachedScrollIndicatorInsets) == NO) {
                             tableView.scrollIndicatorInsets = _cachedScrollIndicatorInsets;
                         }
                     }
                     completion:^(BOOL finished) {
                         //tableView.scrollEnabled = NO;
                     }];
    
}

- (NSArray *)suggestedCellHeightConstraintsForView:(UIView *)view {
    return @[[NSLayoutConstraint constraintWithItem:self
                                          attribute:NSLayoutAttributeHeight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:nil
                                          attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                           constant:[[self class] suggestedCellHeightForView:view]]];
}

+ (CGFloat)suggestedCellHeightForView:(UIView *)view {
    return ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, view.window);
}

@end
