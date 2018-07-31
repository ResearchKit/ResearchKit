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


#import "ORKBorderedButton.h"
#import "ORKTextButton_Internal.h"


@implementation ORKBorderedButton {

    BOOL _appearsAsTextButton;
    BOOL _useBoldFont;
}

- (void)init_ORKTextButton {
    [super init_ORKTextButton];
    [self setLayerAndFadeDelay];
    [self setEnabled:YES];
    [self setDefaultTintColors];
}

- (void)setLayerAndFadeDelay {
    self.layer.borderWidth = 0.0f;
    self.layer.cornerRadius = 10.0f;
    self.fadeDelay = 0.0;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (!_appearsAsTextButton) {
        [self setLayerAndFadeDelay];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        
    }
    else {
        [self setTitleColor:_normalTintColor forState:UIControlStateNormal];
        [self setTitleColor:_normalHighlightOrSelectTintColor forState:UIControlStateHighlighted];
        [self setTitleColor:_normalHighlightOrSelectTintColor forState:UIControlStateSelected];
        [self setTitleColor:_disableTintColor forState:UIControlStateDisabled];
    }
    [self updateBackgroundColor];

}

- (void)setDefaultTintColors {
    _normalTintColor = [[self tintColor] colorWithAlphaComponent:0.7f];
    _normalHighlightOrSelectTintColor = [_normalTintColor colorWithAlphaComponent:1.0f];
    _disableTintColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.3f];
}

- (void)setNormalTintColor:(UIColor *)normalTintColor {
    _normalTintColor = normalTintColor;
    _normalHighlightOrSelectTintColor = [normalTintColor colorWithAlphaComponent:1.0f];
    [self updateBackgroundColor];
}

- (void)setNormalHighlightOrSelectTintColor:(UIColor *)normalHighlightOrSelectTintColor {
    _normalHighlightOrSelectTintColor = normalHighlightOrSelectTintColor;
    [self updateBackgroundColor];
}

- (void)setDisableTintColor:(UIColor *)disableTintColor {
    _disableTintColor = disableTintColor;
    [self updateBackgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self updateBackgroundColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateBackgroundColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [self updateBackgroundColor];
}

- (void)fadeHighlightOrSelectColor {
    // Ignore if it's a race condition
    if (self.enabled && !(self.highlighted || self.selected)) {
        self.backgroundColor = _normalTintColor;
        self.layer.borderColor = [_normalTintColor CGColor];
    }
}

- (void)updateBackgroundColor {
    if (!_appearsAsTextButton) {
        if (self.enabled && (self.highlighted || self.selected)) {
            self.backgroundColor = _normalHighlightOrSelectTintColor;
            self.layer.borderColor = [_normalHighlightOrSelectTintColor CGColor]; // move
        } else if(self.enabled && !(self.highlighted || self.selected)) {
            if (self.fadeDelay > 0) {
                [self performSelector:@selector(fadeHighlightOrSelectColor) withObject:nil afterDelay:self.fadeDelay];
            } else {
                [self fadeHighlightOrSelectColor];
            }
        } else {
            self.backgroundColor = _disableTintColor;
            self.layer.borderColor = [_disableTintColor CGColor];
        }
        self.titleLabel.font = [[self class] defaultFont];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.titleLabel.font = _useBoldFont ? [[self class] defaultBoldTextFont] : [ORKTextButton defaultFont];
    }
}

+ (UIFont *)defaultFont {
    // bold, 17
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    return [UIFont boldSystemFontOfSize:[[descriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue] + 1.0];
}

+ (UIFont *)defaultBoldTextFont {
    // bold, 16
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleCaption1];
    return [UIFont boldSystemFontOfSize:((NSNumber *)[descriptor objectForKey: UIFontDescriptorSizeAttribute]).doubleValue + 4.0];
}

- (void)setAppearanceAsTextButton {
    _appearsAsTextButton = YES;
    _useBoldFont = NO;
    [self tintColorDidChange];
}

- (void)setAppearanceAsBoldTextButton {
    _appearsAsTextButton = YES;
    _useBoldFont = YES;
    [self tintColorDidChange];
}

- (void)resetAppearanceAsBorderedButton {
    _appearsAsTextButton = NO;
    _useBoldFont = NO;
    [self setDefaultTintColors];
    [self tintColorDidChange];
}

@end
