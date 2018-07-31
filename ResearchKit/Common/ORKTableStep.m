/*
 Copyright (c) 2016, Sage Bionetworks
 
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


#import "ORKTableStep.h"

#import "ORKTableStepViewController.h"

#import "ORKHelpers_Internal.h"


ORKDefineStringKey(ORKBasicCellReuseIdentifier);


@implementation ORKTableStep {
    UIImage * _circleBulletImage;
}

+ (Class)stepViewControllerClass {
    return [ORKTableStepViewController class];
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (id <NSObject, NSCopying, NSSecureCoding>)objectForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _items[indexPath.row];
}

- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ORKBasicCellReuseIdentifier;
}

- (void)registerCellsForTableView:(UITableView *)tableView {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ORKBasicCellReuseIdentifier];
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    for (UIView *view in cell.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = [[self objectForRowAtIndexPath:indexPath] description];
    textLabel.numberOfLines = 0;
    textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell addSubview:textLabel];
    
    [textLabel.topAnchor constraintEqualToAnchor:cell.topAnchor constant:20.0].active = YES;
    [textLabel.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-20.0].active = YES;
    [textLabel.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-24.0].active = YES;
    
    UIImage *bullet = nil;
    if (self.isBulleted) {
        if (self.bulletIconNames != nil) {
            if (indexPath.row < self.bulletIconNames.count) {
                NSString *iconName = [self.bulletIconNames objectAtIndex:indexPath.row];
                bullet = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        } else {
            if (!_circleBulletImage) {
                _circleBulletImage = [self circleImage];
            }
            bullet = [_circleBulletImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
    
    if (bullet != nil) {
        UIImageView *bulletView = [[UIImageView alloc] initWithImage:bullet];
        bulletView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:bulletView];
        
        CGFloat size = self.bulletIconNames != nil ? 40.0 : 8.0;
        CGFloat topPadding = self.bulletIconNames != nil ? 20.0 : (20 + (size * .5));
        CGFloat leadingPadding = self.bulletIconNames != nil ? 24.0 : (24 + (size * .5));
        
        [bulletView.topAnchor constraintEqualToAnchor:cell.topAnchor constant:topPadding].active = YES;
        [bulletView.bottomAnchor constraintLessThanOrEqualToAnchor:cell.bottomAnchor constant:-20.0].active = YES;
        [bulletView.heightAnchor constraintEqualToConstant:size].active = YES;
        [bulletView.widthAnchor constraintEqualToConstant:size].active = YES;
        [bulletView.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:leadingPadding].active = YES;
        [textLabel.leadingAnchor constraintEqualToAnchor:bulletView.trailingAnchor constant:20.0].active = YES;
        
    } else {
        [textLabel.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:24.0].active = YES;
    }
}

- (UIImage*)resizeImage:(UIImage*)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)circleImage {
    static UIImage *circleImage = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(8.f, 8.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        
        CGRect rect = CGRectMake(0, 0, 8, 8);
        CGContextSetFillColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        
        CGContextRestoreGState(ctx);
        circleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    });
    
    return circleImage;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKTableStep *step = [super copyWithZone:zone];
    step->_items = ORKArrayCopyObjects(_items);
    return step;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        ORK_DECODE_OBJ_ARRAY(aDecoder, items, NSObject);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, items);
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return isParentSame && ORKEqualObjects(self.items, castObject.items);
}

- (NSUInteger)hash {
    return super.hash ^ self.items.hash;
}

@end
