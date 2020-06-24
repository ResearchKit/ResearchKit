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

#import "ORKTaskReviewViewController.h"
#import "ORKStepView_Private.h"
#import "ORKTableContainerView.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepContentView_Private.h"
#import "ORKStep.h"
#import "ORKFormStep.h"
#import "ORKQuestionStep.h"
#import "ORKCollectionResult.h"
#import "ORKQuestionResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKSurveyCardHeaderView.h"
#import "ORKChoiceViewCell_Internal.h"
#import "ORKSkin.h"
#import "ORKHelpers_Internal.h"

static const float ReviewCellTopBottomPadding = 15.0;
static const float EditAnswerButtonTopBottomPadding = 10.0;
static const float ReviewCardBottomPadding = 10.0;
static const float ReviewQuestionAnswerPadding = 2.0;

@implementation ORKReviewItem
@end

@implementation ORKReviewSection
@end

@implementation ORKReviewCell {
    NSString *_question;
    NSString *_answer;
    
    UILabel *_questionLabel;
    UILabel *_answerLabel;
    
    UIView *_containerView;
    CAShapeLayer *_contentMaskLayer;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContainerView];
        [self setupLabels];
        [self setupConstraints];
        [self setBackgroundColor:UIColor.clearColor];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self setMaskLayers];
}

- (void)setQuestion:(NSString *)question {
    _question = question;
    _questionLabel.text = _question;
}

- (void)setAnswer:(NSString *)answer {
    _answer = answer;
    if (@available(iOS 13.0, *)) {
        _answerLabel.textColor = _answer ? UIColor.secondaryLabelColor : UIColor.tertiaryLabelColor;
    } else {
        _answerLabel.textColor = _answer ? UIColor.blackColor : UIColor.lightGrayColor;
    }
    _answerLabel.text = _answer ? : ORKLocalizedString(@"REVIEW_SKIPPED_ANSWER", nil);
}

- (void)setMaskLayers {
    if (_contentMaskLayer) {
        for (CALayer *sublayer in [_contentMaskLayer.sublayers mutableCopy]) {
            [sublayer removeFromSuperlayer];
        }
        [_contentMaskLayer removeFromSuperlayer];
        _contentMaskLayer = nil;
    }
    _contentMaskLayer = [[CAShapeLayer alloc] init];
    UIColor *fillColor;
    UIColor *borderColor;
    if (@available(iOS 13.0, *)) {
        fillColor = [UIColor secondarySystemGroupedBackgroundColor];
        borderColor = UIColor.separatorColor;
    } else {
        fillColor = [UIColor ork_borderGrayColor];
        borderColor = [UIColor ork_midGrayTintColor];
    }
    [_contentMaskLayer setFillColor:[fillColor CGColor]];
    CAShapeLayer *foreLayer = [CAShapeLayer layer];
    [foreLayer setFillColor:[fillColor CGColor]];
    foreLayer.zPosition = 0.0f;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    
    CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, 0, _containerView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, _containerView.bounds.size.height);
    foreLayer.path = [UIBezierPath bezierPathWithRect:foreLayerBounds].CGPath;
    _contentMaskLayer.path = [UIBezierPath bezierPathWithRect:_containerView.bounds].CGPath;
    CGFloat leftRightMargin = ORKCardLeftRightMarginForWindow(self.window);
    CGRect lineBounds = CGRectMake(leftRightMargin, _containerView.bounds.size.height - 1.0, _containerView.bounds.size.width - leftRightMargin, 0.5);
    lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
    lineLayer.zPosition = 0.0f;
        
    lineLayer.fillColor = _isLastCell ? UIColor.clearColor.CGColor : borderColor.CGColor;
    _contentMaskLayer.fillColor = borderColor.CGColor;
    [_contentMaskLayer addSublayer:foreLayer];
    [_contentMaskLayer addSublayer:lineLayer];
    [_containerView.layer insertSublayer:_contentMaskLayer atIndex:0];
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    if (@available(iOS 13.0, *)) {
        _containerView.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        _containerView.backgroundColor = UIColor.whiteColor;
    }
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_containerView];
}

- (void)setupLabels {
    if (!_questionLabel) {
        _questionLabel = [UILabel new];
    }
    if (!_answerLabel) {
        _answerLabel = [UILabel new];
    }
    if (@available(iOS 13.0, *)) {
        _questionLabel.textColor = [UIColor labelColor];
    } else {
        _questionLabel.textColor = [UIColor blackColor];
    }
    _questionLabel.numberOfLines = 0;
    _questionLabel.textAlignment = NSTextAlignmentLeft;
    _questionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    _answerLabel.numberOfLines = 0;
    _answerLabel.textAlignment = NSTextAlignmentLeft;
    _answerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
    
    [_containerView addSubview:_questionLabel];
    [_containerView addSubview:_answerLabel];
    
    _questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _answerLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupConstraints {
    [[_containerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:1.0 / [UIScreen mainScreen].scale] setActive:YES];
    [[_containerView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    [[_containerView.rightAnchor constraintEqualToAnchor:self.contentView.rightAnchor constant:-ORKCardLeftRightMarginForWindow(self.window)] setActive:YES];
    
    [[_questionLabel.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:ReviewCellTopBottomPadding] setActive:YES];
    [[_questionLabel.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_questionLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];

    [[_answerLabel.topAnchor constraintEqualToAnchor:_questionLabel.bottomAnchor constant:ReviewQuestionAnswerPadding] setActive:YES];
    [[_answerLabel.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor constant:-ORKSurveyItemMargin] setActive:YES];
    [[_answerLabel.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor constant:ORKSurveyItemMargin] setActive:YES];
    [[_answerLabel.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor constant:-ReviewCellTopBottomPadding] setActive:YES];
    
    [[self.contentView.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor] setActive:YES];
}

@end

@implementation ORKReviewSectionFooter {
    UIView *_containerView;
    CAShapeLayer *_contentLayer;
    UIView *_separator;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupContainerView];
        [self setupButton];
        [self setupConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_contentLayer) {
        _contentLayer = [CAShapeLayer layer];
    }
    
    for (CALayer *sublayer in [_contentLayer.sublayers mutableCopy]) {
        [sublayer removeFromSuperlayer];
    }
    
    [_contentLayer removeFromSuperlayer];
    CGRect contentBounds = _containerView.bounds;
    
    _contentLayer.path = [UIBezierPath bezierPathWithRoundedRect: contentBounds
                                               byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                     cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
    
    CAShapeLayer *foreLayer = [CAShapeLayer layer];
    UIColor *fillColor;
    UIColor *borderColor;
    
    if (@available(iOS 13.0, *)) {
        fillColor = [UIColor secondarySystemGroupedBackgroundColor];
        borderColor = UIColor.separatorColor;
    } else {
        fillColor = [UIColor whiteColor];
        borderColor = [UIColor ork_midGrayTintColor];
    }
    [foreLayer setFillColor:[fillColor CGColor]];
    
    CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
    
    CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, contentBounds.size.width - 2 * ORKCardDefaultBorderWidth, contentBounds.size.height - 2 * ORKCardDefaultBorderWidth);
    
    foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds
                                           byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                 cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
    foreLayer.zPosition = 0.0f;
    foreLayer.borderWidth = ORKCardDefaultBorderWidth;
    [_contentLayer addSublayer:foreLayer];
    [_contentLayer setFillColor:[borderColor CGColor]];
    [_containerView.layer insertSublayer:_contentLayer atIndex:0];
}

- (void)setupContainerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    [_containerView setBackgroundColor:[UIColor clearColor]];
    
    _separator = [UIView new];
    if (@available(iOS 13.0, *)) {
        _separator.backgroundColor = UIColor.separatorColor;
    } else {
        _separator.backgroundColor = UIColor.lightGrayColor;
    }
    [_containerView addSubview:_separator];
    
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    _separator.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_containerView];
}

- (void)setupButton {
    if(!_button) {
        _button = [[UIButton alloc] init];
    }
    [_button setTitle:ORKLocalizedString(@"REVIEW_EDIT_ANSWER", nil) forState:UIControlStateNormal];
    [_button setTitleColor:self.tintColor forState:UIControlStateNormal];
    
    UIFontDescriptor *buttonDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    [_button.titleLabel setFont:[UIFont fontWithDescriptor:buttonDescriptor size:[[buttonDescriptor objectForKey: UIFontDescriptorSizeAttribute] doubleValue]]];
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    [_containerView addSubview:_button];
}

- (void)setupConstraints {
    //    TODO: replace padding constants
    
    CGFloat leftRightPadding = ORKCardLeftRightMarginForWindow(self.window);
    
    [[_containerView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0.0] setActive:YES];
    [[_containerView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:leftRightPadding] setActive:YES];
    [[_containerView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-leftRightPadding] setActive:YES];
    [[_button.topAnchor constraintEqualToAnchor:_containerView.topAnchor constant:EditAnswerButtonTopBottomPadding] setActive:YES];
    [[_button.centerXAnchor constraintEqualToAnchor:_containerView.centerXAnchor] setActive:YES];
    [[_containerView.bottomAnchor constraintEqualToAnchor:_button.bottomAnchor constant:EditAnswerButtonTopBottomPadding] setActive:YES];
    
    [_separator.heightAnchor constraintEqualToConstant:1.0 / [UIScreen mainScreen].scale].active = YES;
    [_separator.leadingAnchor constraintEqualToAnchor:_containerView.leadingAnchor].active = YES;
    [_separator.trailingAnchor constraintEqualToAnchor:_containerView.trailingAnchor].active = YES;
    [_separator.topAnchor constraintEqualToAnchor:_containerView.topAnchor].active = YES;
    
    [[self.bottomAnchor constraintEqualToAnchor:_containerView.bottomAnchor constant:ReviewCardBottomPadding] setActive:YES];
}

@end

@interface ORKTaskReviewViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, nonnull) ORKTableContainerView *tableContainerView;
@property (nonatomic) NSMutableArray<ORKReviewSection *> *reviewSections;
@property (nonatomic) id<ORKTaskResultSource> resultSource;
@property (nonatomic, nonnull) NSArray<ORKStep *> *steps;

@end

@implementation ORKTaskReviewViewController {
    ORKNavigationContainerView *_navigationFooterView;
    ORKStep *_reviewInstructionStep;
}

- (instancetype)initWithResultSource:(id<ORKTaskResultSource>)resultSource forSteps:(NSArray<ORKStep *> *)steps withContentFrom:(ORKInstructionStep *)reviewInstructionStep {
    self = [super init];
    if (self) {
        _steps = steps;
        _resultSource = resultSource;
        _reviewInstructionStep = (ORKStep *)reviewInstructionStep;
        [self createReviewSectionsWithDefaultResultSource:resultSource];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableContainerView];
    [self setupNavigationFooterView];
    if (_reviewInstructionStep) {
        _tableContainerView.stepTitle = _reviewInstructionStep.title;
        _tableContainerView.stepText = _reviewInstructionStep.text;
        _tableContainerView.stepDetailText = _reviewInstructionStep.detailText;
        _tableContainerView.titleIconImage = _reviewInstructionStep.iconImage;
        _tableContainerView.stepTopContentImage = _reviewInstructionStep.image;
        _tableContainerView.bodyItems = _reviewInstructionStep.bodyItems;
    }
    [_tableContainerView setNeedsLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_tableContainerView sizeHeaderToFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableContainerView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableContainerView sizeHeaderToFit];
    [_tableContainerView.tableView reloadData];
    [self.view layoutSubviews];
}

- (void)setupTableContainerView {
    if (!_tableContainerView) {
        _tableContainerView = [[ORKTableContainerView alloc] initWithStyle:UITableViewStyleGrouped pinNavigationContainer:NO];
        _tableContainerView.tableView.dataSource = self;
        _tableContainerView.tableView.delegate = self;
        _tableContainerView.tableView.clipsToBounds = YES;
        _tableContainerView.tableView.rowHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
        _tableContainerView.tableView.estimatedRowHeight = ORKGetMetricForWindow(ORKScreenMetricTableCellDefaultHeight, self.view.window);
        _tableContainerView.tableView.estimatedSectionHeaderHeight = 30.0;
        _tableContainerView.tableView.estimatedSectionFooterHeight = 30.0;
        _tableContainerView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    }
    [self.view addSubview:_tableContainerView];
    _tableContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [[_tableContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[_tableContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[_tableContainerView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor] setActive:YES];
    [[_tableContainerView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor] setActive:YES];
}

- (void)setupNavigationFooterView {
    _navigationFooterView = _tableContainerView.navigationFooterView;
    [_navigationFooterView removeStyling];
    _navigationFooterView.skipButtonItem = nil;
    _navigationFooterView.continueEnabled = YES;
    _navigationFooterView.continueButtonItem = [[UIBarButtonItem alloc] initWithTitle:ORKLocalizedString(@"BUTTON_DONE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];
}

- (void)createReviewSectionsWithDefaultResultSource:(id<ORKTaskResultSource>)defaultResultSource {
    _reviewSections = nil;
    _reviewSections = [[NSMutableArray alloc] init];
    for (ORKStep *step in _steps) {
        if ([step isKindOfClass:[ORKFormStep class]]) {
            ORKFormStep *formStep = (ORKFormStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:formStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForFormStep:formStep withResult:result]];
            }
        }
        else if ([step isKindOfClass:[ORKQuestionStep class]]) {
            ORKQuestionStep *questionStep = (ORKQuestionStep *)step;
            ORKStepResult *result = [defaultResultSource stepResultForStepIdentifier:questionStep.identifier];
            if (result) {
                [_reviewSections addObject:[self reviewSectionForQuestionStep:questionStep withResult:result]];
            }
        }
    }
}

- (ORKReviewSection *)reviewSectionForFormStep:(ORKFormStep *)formStep withResult:(ORKStepResult *)result {
    if (formStep && formStep.formItems && result) {
        NSMutableArray <ORKReviewItem *> *formReviewItems = [[NSMutableArray alloc] init];
        for (ORKFormItem *formItem in formStep.formItems) {
            if (formItem.answerFormat) {
                ORKResult *formItemResult = [result resultForIdentifier:formItem.identifier];
                ORKReviewItem *formReviewItem = [[ORKReviewItem alloc] init];
                formReviewItem.question = formItem.text;
                formReviewItem.answer = [self answerStringForFormItem:formItem withFormItemResult:formItemResult];
                [formReviewItems addObject:formReviewItem];
            }
            else {
                // Use this for grouping form items without answer formats.
            }
        }
        ORKReviewSection *section = [[ORKReviewSection alloc] init];
        section.title = formStep.title;
        section.text = formStep.text;
        section.stepIdentifier = formStep.identifier;
        section.items = [formReviewItems copy];
        
        return section;
    }
    return nil;
}

- (NSString *)answerStringForFormItem:(ORKFormItem *)formItem withFormItemResult:(ORKResult *)formItemResult {
    NSString *answerString = nil;
    if (formItem && formItemResult && [formItemResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)formItemResult;
        if (formItem.answerFormat && [questionResult isKindOfClass:formItem.answerFormat.questionResultClass] && questionResult.answer) {
            if ([questionResult.answer isKindOfClass:[ORKDontKnowAnswer class]]) {
                answerString = formItem.answerFormat.customDontKnowButtonText;
            } else {
                answerString = [formItem.answerFormat stringForAnswer:questionResult.answer];
            }
        }
    }
    return answerString;
}

- (ORKReviewSection *)reviewSectionForQuestionStep:(ORKQuestionStep *)questionStep withResult:(ORKStepResult *)result {
    ORKReviewItem *item = [[ORKReviewItem alloc] init];
    item.question = questionStep.question;
    if (result.firstResult && [result.firstResult isKindOfClass:[ORKQuestionResult class]]) {
        ORKQuestionResult *questionResult = (ORKQuestionResult *)result.firstResult;
        item.answer = [self answerStringForQuestionStep:questionStep withQuestionResult:questionResult];
    }
    ORKReviewSection *section = [[ORKReviewSection alloc] init];
    section.title = questionStep.title;
    section.text = questionStep.text;
    section.stepIdentifier = questionStep.identifier;
    section.items = @[item];
    
    return section;
    
}

- (NSString *)answerStringForQuestionStep:(ORKQuestionStep *)questionStep withQuestionResult:(ORKQuestionResult *)questionResult {
    NSString *answerString = nil;
    if (questionStep && questionResult && questionStep.answerFormat && [questionResult isKindOfClass:questionStep.answerFormat.questionResultClass] && questionResult.answer) {
        if ([questionResult.answer isKindOfClass:[ORKDontKnowAnswer class]]) {
            answerString = questionStep.answerFormat.customDontKnowButtonText;
        } else {
            answerString = [questionStep.answerFormat stringForAnswer:questionResult.answer];
        }
    }
    return answerString;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _reviewSections ? _reviewSections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _reviewSections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        ORKReviewCell *reviewCell = [[ORKReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell = reviewCell;
    }
    ORKReviewCell *reviewCell = (ORKReviewCell *)cell;
    reviewCell.question = _reviewSections[indexPath.section].items[indexPath.row].question;
                                     reviewCell.answer = _reviewSections[indexPath.section].items[indexPath.row].answer;
    reviewCell.isLastCell = _reviewSections[indexPath.section].items.count - 1 == indexPath.row;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ORKSurveyCardHeaderView *cardHeaderView = (ORKSurveyCardHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@(section).stringValue];
    
    if (cardHeaderView == nil) {
        ORKReviewSection *reviewSection = _reviewSections[section];
        cardHeaderView = [[ORKSurveyCardHeaderView alloc] initWithTitle:reviewSection.title detailText:reviewSection.text learnMoreView:nil progressText:[NSString stringWithFormat:@"%@ %@", ORKLocalizedString(@"REVIEW_STEP_PAGE", nil), ORKLocalizedStringFromNumber(@(section + 1))] tagText:nil showBorder:YES hasMultipleChoiceItem:NO];
    }
    
    return cardHeaderView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ORKReviewSectionFooter *sectionFooter = (ORKReviewSectionFooter *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:[NSString stringWithFormat:@"Footer%@", @(section).stringValue]];
    if (!sectionFooter) {
        sectionFooter = [ORKReviewSectionFooter new];
        sectionFooter.button.tag = section;
        [sectionFooter.button addTarget:self action:@selector(footerButtonTappedForSection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return sectionFooter;
}

- (nullable ORKStep *)stepForIdentifier:(NSString *)identifier {
    for (ORKStep *step in _steps) {
        return [step.identifier isEqualToString:identifier] ? step : nil;
    }
    return nil;
}

- (void)footerButtonTappedForSection:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(editAnswerTappedForStepWithIdentifier:)]) {
        [self.delegate editAnswerTappedForStepWithIdentifier:_reviewSections[button.tag].stepIdentifier];
    }
}

- (void)doneButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneButtonTappedWithResultSource:)]) {
        [self.delegate doneButtonTappedWithResultSource:_resultSource];
    }
}

#pragma mark - UItableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
