/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2016, Sam Falconer.

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


@import UIKit;


NS_ASSUME_NONNULL_BEGIN

@class ORKSignatureView;

@protocol ORKSignatureViewDelegate <NSObject>

- (void)signatureViewDidEditImage:(ORKSignatureView *)signatureView;

@end


@interface ORKSignatureView : UIView

@property (nonatomic, strong, nullable) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;

/**
 lineWidthVariation defines the max amount by which the line
 width can vary (default 3pts).

 The exact amount of the variation is determined by the amount
 of force applied on 3D touch capable devices or by the speed
 of the stroke if 3D touch is not available.
 
 If the user is signing with an Apple Pencil, its force will be used.
 */
@property (nonatomic) CGFloat lineWidthVariation;

@property (nonatomic, weak, nullable) id<ORKSignatureViewDelegate> delegate;
@property (nonatomic, strong, nullable) UIGestureRecognizer *signatureGestureRecognizer;
@property (nonatomic, copy, nullable) NSArray <UIBezierPath *> *signaturePath;

- (UIImage *)signatureImage;

@property (nonatomic, readonly) BOOL signatureExists;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
