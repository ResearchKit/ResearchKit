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


#import "ORKTextButton.h"


@implementation ORKTextButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    assert(buttonType == UIButtonTypeCustom);
    return [super buttonWithType:buttonType];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self init_ORKTextButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self init_ORKTextButton];
    }
    return self;
}

- (void)init_ORKTextButton {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppearance)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    [self updateAppearance];
    [self tintColorDidChange];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self setTitleColor:[self tintColor] forState:UIControlStateNormal];
    [self setTitleColor:[[self tintColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
}

- (void)updateContentInsets:(NSDirectionalEdgeInsets)contentInsets {
    UIButtonConfiguration *buttonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    [buttonConfiguration setContentInsets:contentInsets];
    [self setConfiguration:buttonConfiguration];
}

- (void)updateAppearance {
    
    self.titleLabel.font = [[self class] defaultFont];
    [self invalidateIntrinsicContentSize];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (UIFont *)defaultFont {
    // regular, 14
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
    return [UIFont systemFontOfSize:((NSNumber *)[descriptor objectForKey: UIFontDescriptorSizeAttribute]).doubleValue + 2.0];
}

- (UIAccessibilityTraits)accessibilityTraits {
    // prevent VoiceOver from speaking "dimmed" when transitioning between pages
    if (self.isInTransition) {
        return [super accessibilityTraits] & ~UIAccessibilityTraitNotEnabled;
    }
    return [super accessibilityTraits];
}

@end
