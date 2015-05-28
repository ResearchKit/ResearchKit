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

 
#import "ORKAxisView.h"


@interface ORKAxisView ()

@property (nonatomic, strong) NSMutableArray *titleLabels;

@property (nonatomic) ORKGraphAxisType axisType;

@end


@implementation ORKAxisView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    _titleLabels = [NSMutableArray new];
    _leftOffset = 0;
}

- (void)layoutSubviews {
    CGFloat segmentWidth = (CGFloat)CGRectGetWidth(self.bounds)/(self.titleLabels.count - 1);
    CGFloat labelWidth = segmentWidth;
    
    CGFloat labelHeight = (self.axisType == ORKGraphAxisTypeX) ? CGRectGetHeight(self.bounds)*0.77 : 20;
    
    for (NSUInteger i=0; i<self.titleLabels.count; i++) {
        
        CGFloat positionX = (self.axisType == ORKGraphAxisTypeX) ? (self.leftOffset + i*segmentWidth) : 0;
        
        if (i==0) {
            //Shift the first label to acoomodate the month text.
            positionX -= self.leftOffset;
        }
        
        UILabel *label = (UILabel *)self.titleLabels[i];
        
        if (label.text) {
            labelWidth = [label.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, labelHeight) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:label.font} context:nil].size.width;
            labelWidth = MAX(labelWidth, 15);
            labelWidth += self.landscapeMode ? 14 : 8; //padding
        }
        
        if (i==0) {
            label.frame  = CGRectMake(positionX, (CGRectGetHeight(self.bounds) - labelHeight)/2, labelWidth, labelHeight);
        } else {
            label.frame  = CGRectMake(positionX - labelWidth/2, (CGRectGetHeight(self.bounds) - labelHeight)/2, labelWidth, labelHeight);
        }
        
        if (i == self.titleLabels.count - 1) {
            //Last label
            
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = self.tintColor;
            label.layer.cornerRadius = CGRectGetHeight(label.frame)/2;
            label.layer.masksToBounds = YES;
        }
    }
}

- (void)setupLabels:(NSArray *)titles forAxisType:(ORKGraphAxisType)type {
    self.axisType = type;
    
    for (NSUInteger i=0; i<titles.count; i++) {
        
        UILabel *label = [UILabel new];
        label.text = titles[i];
        label.font = self.isLandscapeMode ? [UIFont fontWithName:@"Helvetica-Light" size:19.0] : [UIFont fontWithName:@"Helvetica-Light" size:12.0];
        label.numberOfLines = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.7;
        label.textColor = self.tintColor;
        [self addSubview:label];
        
        [self.titleLabels addObject:label];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    for (UILabel *label in self.titleLabels) {
        label.textColor = tintColor;
    }
}

@end
