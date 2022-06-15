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

static const CGFloat CellPadding = 20.0;
static const CGFloat BulletNumberMaxWidth = 24.0 ;
static const CGFloat BulletNumberToTextPadding = 20.0;


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
    
    [textLabel.topAnchor constraintEqualToAnchor:cell.topAnchor constant:CellPadding].active = YES;
    [cell.bottomAnchor constraintEqualToAnchor:textLabel.bottomAnchor constant:CellPadding].active = YES;
    [textLabel.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-24.0].active = YES;
    
    UIImage *bullet = nil;
    UILabel *numberLabel = nil;

    if (self.bulletType == ORKBulletTypeCircle) {
        if (!_circleBulletImage) {
            _circleBulletImage = [self circleImage];
        }
        bullet = [_circleBulletImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (self.bulletType == ORKBulletTypeImage && _bulletIconNames != nil) {
        if (indexPath.row < self.bulletIconNames.count) {
            NSString *iconName = [self.bulletIconNames objectAtIndex:indexPath.row];
            bullet = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    } else if (self.bulletType == ORKBulletTypeNumber) {
        numberLabel = [[UILabel alloc] init];
        numberLabel.text = [NSString stringWithFormat: @"%ld.", indexPath.row + 1];
        numberLabel.numberOfLines = 0;
        numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:numberLabel];
    }
    
    if (bullet != nil) {
        UIImageView *bulletView = [[UIImageView alloc] initWithImage:bullet];
        bulletView.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:bulletView];
        
        CGFloat size = (self.bulletIconNames && self.bulletType == ORKBulletTypeImage) ? 40.0 : 8.0;
        CGFloat topPadding = self.bulletIconNames != nil ? 20.0 : (20 + (size * .5));
        CGFloat leadingPadding = self.bulletIconNames != nil ? 24.0 : (24 + (size * .5));
        
        [bulletView.topAnchor constraintEqualToAnchor:cell.topAnchor constant:topPadding].active = YES;
        [bulletView.bottomAnchor constraintLessThanOrEqualToAnchor:cell.bottomAnchor constant:-20.0].active = YES;
        [bulletView.heightAnchor constraintEqualToConstant:size].active = YES;
        [bulletView.widthAnchor constraintEqualToConstant:size].active = YES;
        [bulletView.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:leadingPadding].active = YES;
        [textLabel.leadingAnchor constraintEqualToAnchor:bulletView.trailingAnchor constant:20.0].active = YES;
    }
    else if (numberLabel != nil) {
        [numberLabel.topAnchor constraintEqualToAnchor:textLabel.topAnchor constant:0.0].active = YES;
        [numberLabel.widthAnchor constraintEqualToConstant:BulletNumberMaxWidth].active = YES;
        numberLabel.textAlignment = NSTextAlignmentRight;
        [numberLabel.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:0.0].active = YES;
        [textLabel.leadingAnchor constraintEqualToAnchor:numberLabel.trailingAnchor constant:BulletNumberToTextPadding].active = YES;
    } else {
        [textLabel.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:24.0].active = YES;
    }
}

- (UITableViewStyle)customTableViewStyle {
    return [self numberOfSections] > 1 ? UITableViewStyleGrouped : UITableViewStylePlain;
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
    step->_bulletType = _bulletType;
    step->_bulletIconNames = ORKArrayCopyObjects(_bulletIconNames);
    step->_allowsSelection = _allowsSelection;
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
        ORK_DECODE_INTEGER(aDecoder, bulletType);
        ORK_DECODE_OBJ_ARRAY(aDecoder, bulletIconNames, NSString);
        ORK_DECODE_BOOL(aDecoder, allowsSelection);
        ORK_DECODE_BOOL(aDecoder, pinNavigationContainer);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, items);
    ORK_ENCODE_INTEGER(aCoder, bulletType);
    ORK_ENCODE_OBJ(aCoder, bulletIconNames);
    ORK_ENCODE_BOOL(aCoder, allowsSelection);
    ORK_ENCODE_BOOL(aCoder, pinNavigationContainer);
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame
            && ORKEqualObjects(self.items, castObject.items)
            && (self.bulletType == castObject.bulletType)
            && (self.allowsSelection == castObject.allowsSelection)
            && ORKEqualObjects(self.bulletIconNames, castObject.bulletIconNames)
            && self.pinNavigationContainer == castObject.pinNavigationContainer);
}

- (NSUInteger)hash {
    return super.hash ^ self.items.hash ^ self.bulletIconNames.hash ^ (_bulletType ? 0xf : 0x0) ^ (_allowsSelection ? 0xf : 0x0) ^ (_pinNavigationContainer ? 0xf : 0x0);
}

@end
