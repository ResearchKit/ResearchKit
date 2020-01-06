/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

#import "ORKReviewIncompleteCell.h"
#import "ORKSkin.h"

static const CGFloat topPadding = 8.0;
static const CGFloat horizontalPadding = 16.0;
static const CGFloat verticalPadding = 10.0;

@implementation ORKReviewIncompleteCell {
    UIView *cardView;
    UILabel *label;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:UIColor.clearColor];
        
        [self setupView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupView {
    cardView = [[UIView alloc] init];
    cardView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        cardView.backgroundColor = [UIColor whiteColor];
    }
    cardView.layer.cornerRadius = ORKCardDefaultCornerRadii;
    [self.contentView addSubview:cardView];
    
    label = [[UILabel alloc] init];
    label.textColor = [UIColor systemBlueColor];
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [cardView addSubview:label];
}

- (void)setupConstraints {
    CGFloat leftRightPadding = ORKStepContainerLeftRightPaddingForWindow(self.window);
    
    [cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:topPadding].active = YES;
    [cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:leftRightPadding].active = YES;
    [cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-leftRightPadding].active = YES;
    [cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    
    [label.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:verticalPadding].active = YES;
    [label.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:horizontalPadding].active = YES;
    [label.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-horizontalPadding].active = YES;
    [label.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-verticalPadding].active = YES;
}

- (void)setText:(NSString *)text {
    _text = text;
    label.text = text;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted == YES) {
        if (@available(iOS 13.0, *)) {
            cardView.backgroundColor = [UIColor systemGray5Color];
        } else {
            cardView.backgroundColor = [UIColor grayColor];
        }
    } else {
        if (@available(iOS 13.0, *)) {
            cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        } else {
            cardView.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
