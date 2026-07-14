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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An enumeration for body item style options.
 */

typedef NS_ENUM(NSInteger, ORKBodyItemStyle) {
    /**
     text style body item
     */
    ORKBodyItemStyleText,
    
    /**
     bullet style body item
     */
    ORKBodyItemStyleBulletPoint,
    
    /**
     image style body item
     */
    ORKBodyItemStyleImage,
    
    /**
     horizontal rule
     */
    ORKBodyItemStyleHorizontalRule,
    
    /**
     tag label
     */
    ORKBodyItemStyleTag,

    /**
     header style body item — bold text with primary label color, suitable for section headers
     */
    ORKBodyItemStyleHeader
} ORK_ENUM_AVAILABLE;

@class ORKLearnMoreItem;

/**
 An object that represents textual information to
 attach to a step.
 */

ORK_CLASS_AVAILABLE
@interface ORKBodyItem : NSObject <NSSecureCoding, NSCopying>

/// Returns an initialized body item with the specified content.
///
/// - Parameters:
///   - text: Primary text to display.
///   - detailText: Secondary text to display below the primary text.
///   - image: An image to display alongside the text.
///   - learnMoreItem: A learn more item to attach additional information.
///   - bodyItemStyle: The visual style of the body item.
///
/// - Returns: An initialized ``ORKBodyItem``.
- (instancetype)initWithText:(nullable NSString *)text
                  detailText:(nullable NSString *)detailText
                       image:(nullable UIImage *)image
               learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem
               bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle;

/// Returns an initialized body item with the specified content and card style option.
///
/// - Parameters:
///   - text: Primary text to display.
///   - detailText: Secondary text to display below the primary text.
///   - image: An image to display alongside the text.
///   - learnMoreItem: A learn more item to attach additional information.
///   - bodyItemStyle: The visual style of the body item.
///   - useCardStyle: Whether this item is rendered inside a card-styled container.
///
/// - Returns: An initialized ``ORKBodyItem``.
- (instancetype)initWithText:(nullable NSString *)text
                  detailText:(nullable NSString *)detailText
                       image:(nullable UIImage *)image
               learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem
               bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle
                useCardStyle:(BOOL)useCardStyle;

/// Returns an initialized body item with the specified content, card style option, and image alignment.
///
/// - Parameters:
///   - text: Primary text to display.
///   - detailText: Secondary text to display below the primary text.
///   - image: An image to display alongside the text.
///   - learnMoreItem: A learn more item to attach additional information.
///   - bodyItemStyle: The visual style of the body item.
///   - useCardStyle: Whether this item is rendered inside a card-styled container.
///   - alignImageToTop: Whether the image aligns to the top of the row instead of centering.
///
/// - Returns: An initialized ``ORKBodyItem``.
- (instancetype)initWithText:(nullable NSString *)text
                  detailText:(nullable NSString *)detailText
                       image:(nullable UIImage *)image
               learnMoreItem:(nullable ORKLearnMoreItem *)learnMoreItem
               bodyItemStyle:(ORKBodyItemStyle)bodyItemStyle
                useCardStyle:(BOOL)useCardStyle
             alignImageToTop:(BOOL)alignImageToTop;

/// Returns a body item that renders as a full-width horizontal rule.
///
/// Use this initializer to insert visual dividers between groups of body items.
///
/// - Returns: An initialized ``ORKBodyItem`` with ``ORKBodyItemStyleHorizontalRule`` style.
- (instancetype)initWithHorizontalRule;

@property (nonatomic, nullable) NSString *text;

@property (nonatomic, nullable) NSString *detailText;

@property (nonatomic, nullable) UIImage *image;

@property (nonatomic, nullable) ORKLearnMoreItem *learnMoreItem;

@property (nonatomic, nullable) NSString *accessibilityIdentifier;

@property (nonatomic) ORKBodyItemStyle bodyItemStyle;

@property (nonatomic) BOOL useCardStyle;

@property (nonatomic) BOOL useSecondaryColor;

@property (nonatomic) BOOL alignImageToTop;

@end

NS_ASSUME_NONNULL_END
