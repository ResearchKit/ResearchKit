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


#import "ORKAnswerTextView.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@implementation ORKAnswerTextView {
    UITextView *_placeholderTextView;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero textContainer:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame textContainer:nil];
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppearance)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(textViewTextDidChange:)
                                                  name:UITextViewTextDidChangeNotification
                                                object:self];

    _placeholderTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _placeholderTextView.textColor = [UIColor ork_midGrayTintColor];
    _placeholderTextView.userInteractionEnabled = NO;
    _placeholderTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:_placeholderTextView atIndex:0];
    
    [self setUpConstraints];
    
    [self updateAppearance];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Setting the frame directly causes a layout error on a form step (it looks like an iOS bug, as setting the frame should produce the same effect as setting the bounds and the center)
    CGRect answerTextViewBounds = self.bounds;
    _placeholderTextView.bounds = answerTextViewBounds;
    _placeholderTextView.center = CGPointMake(answerTextViewBounds.size.width / 2, answerTextViewBounds.size.height / 2);
}

- (void)setUpConstraints {
    // This shouldn't be needed, as we're directly setting the _placeholderTextView bounds and center, but it is needed, otherwise it diplays incorrectly in form steps
    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *views = @{@"placeholderTextView": _placeholderTextView};
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[placeholderTextView]|"
                                             options:NSLayoutFormatDirectionLeftToRight
                                             metrics:nil
                                               views:views]];
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[placeholderTextView]|"
                                             options:(NSLayoutFormatOptions)0
                                             metrics:nil
                                               views:views]];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (void)textViewTextDidChange:(NSNotification *)notification {
    [self ork_updatePlaceholder];
}

- (void)ork_updatePlaceholder {
    _placeholderTextView.hidden = (self.text.length > 0);
}

- (void)updateAppearance {
    self.font = [[self class] defaultFont];
    [self invalidateIntrinsicContentSize];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    _placeholderTextView.font = font;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    _placeholderTextView.textContainerInset = textContainerInset;
}

- (void)setLayoutMargins:(UIEdgeInsets)layoutMargins {
    [super setLayoutMargins:layoutMargins];
    _placeholderTextView.layoutMargins = layoutMargins;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder ? : ORKLocalizedString(@"PLACEHOLDER_LONG_TEXT", nil);
    _placeholderTextView.text = _placeholder;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self ork_updatePlaceholder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    return [UIFont systemFontOfSize:((NSNumber *)[descriptor objectForKey:UIFontDescriptorSizeAttribute]).doubleValue + 2.0];
}

@end
