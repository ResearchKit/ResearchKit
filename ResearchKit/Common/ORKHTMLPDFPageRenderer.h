//
//  ORKHTMLPDFPageRenderer.h
//  ResearchKit
//
//  Created by Ortman, Chris E on 8/10/16.
//  Copyright © 2016 researchkit.org. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#pragma mark - ORKHTMLPDFWriter Interface

@interface ORKHTMLPDFPageRenderer : UIPrintPageRenderer

@property (nonatomic) UIEdgeInsets pageMargins;

@end

