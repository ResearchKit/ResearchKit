//
//  BRKPopover.h
//  Pods
//
//  Created by User on 11/2/17.
//

@import UIKit;
#import "ORKTextFieldView.h"
#import "ORKContinueButton.h"
#import "ORKAnswerFormat.h"

NS_ASSUME_NONNULL_BEGIN

@class BRKPopoverViewController;
@class BRKTextFieldPopoverViewController;

@protocol BRKPopoverViewControllerDelegate

@required

- (void)popoverViewController:(BRKPopoverViewController *)popoverViewContoller didChangedResult:(NSString *)result;

@end

ORK_CLASS_AVAILABLE
@interface BRKPopoverViewController : UIViewController <UIPopoverPresentationControllerDelegate>

- (instancetype)initWithSourceView:(UIView *)sourceView;

@property (weak, nullable) id<BRKPopoverViewControllerDelegate> delegate;
@property (nonatomic) CGFloat popoverOffset;
@property (nonatomic) CGFloat popoverWidth;
@property (nonatomic, weak) UIView *sourceView;

@end

ORK_CLASS_AVAILABLE
@interface BRKTextFieldPopoverViewController : BRKPopoverViewController

- (instancetype)initWithSourceView:(UIView *)sourceView;
- (instancetype)initWithSourceView:(UIView *)sourceView format:(ORKTextAnswerFormat *)format;

@property (nonatomic, strong) NSMutableArray *variableConstraints;
@property (nonatomic, strong) ORKTextFieldView *textFieldView;
@property (nonatomic, strong) ORKContinueButton *continueButton;
@property (nonatomic, strong, readonly) ORKTextAnswerFormat *answerFormat;

@end

NS_ASSUME_NONNULL_END
