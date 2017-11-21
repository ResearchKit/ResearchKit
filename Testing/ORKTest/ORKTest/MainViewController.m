/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015 - 2016, Ricardo Sanchez-Saez.
 Copyright (c) 2016, Sage Bionetworks.
 Copyright (c) 2017, Macro Yau.

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


#import "MainViewController.h"

#import "AppDelegate.h"
#import "DynamicTask.h"
#import "TaskFactory.h"

#import "ORKTest-Swift.h"

@import ResearchKit;

@import AVFoundation;


NSArray<NSDictionary<NSString *, NSArray<NSString *> *> *> *TestButtonTable()
{
    return @[
             @{ @"Active Tasks":
                    @[
                        @"Active Step",
                        @"Audio",
                        @"Fitness",
                        @"GAIT",
                        @"Hand Tremor",
                        @"Hand (Right) Tremor",
                        @"Hole Peg Test",
                        @"Memory Game",
                        @"PSAT",
                        @"Reaction Time",
                        @"Stroop",
                        @"Timed Walk",
                        @"Tone Audiometry",
                        @"Tower Of Hanoi",
                        @"Trail Making",
                        @"Two Finger Tapping",
                        @"Walk And Turn",
                        ]},
             @{ @"Forms":
                    @[
                        @"Confirmation Form Item",
                        @"Mini Form",
                        @"Optional Form",
                        ]},
             @{ @"Onboarding":
                    @[
                        @"Consent",
                        @"Consent Review",
                        @"Eligibility Form",
                        @"Eligibility Survey",
                        @"Login",
                        @"Registration",
                        @"Verification",
                        ]},
             @{ @"Passcode Management":
                    @[
                        @"Authenticate Passcode",
                        @"Create Passcode",
                        @"Edit Passcode",
                        @"Remove Passcode",
                        ]},
             @{ @"Question Steps":
                    @[
                        @"Date Pickers",
                        @"Image Capture",
                        @"Image Choice",
                        @"Location",
                        @"Scale",
                        @"Scale (Color Gradient)",
                        @"Selection Survey",
                        @"Video Capture",
                        ]},
             @{ @"Task Customization":
                    @[
                        @"Custom View Controller",
                        @"Dynamic",
                        @"Interruptible",
                        @"Navigable Ordered",
                        @"Navigable Ordered Loop",
                        @"Step Will Appear",
                        @"Step Will Disappear",
                        ]},
             @{ @"Task Review":
                    @[
                        @"Embedded Review",
                        @"Standalone Review",
                        ]},
             @{ @"Utility Steps":
                    @[
                        @"Auxiliary Image Step",
                        @"Completion Step",
                        @"Footnote Step",
                        @"Icon Image Step",
                        @"Page Step",
                        @"Predicate Tests",
                        @"Signature Step",
                        @"Table Step",
                        @"Video Instruction Step",
                        @"Wait Step",
                        ]},
             @{ @"Miscellaneous":
                    @[
                        @"Continue Button",
                        @"Test Charts",
                        @"Test Charts Performance",
                        @"Toggle Tint Color",
                        ]},
             ];
}

DefineStringKey(ConsentTaskIdentifier);
DefineStringKey(ConsentReviewTaskIdentifier);
DefineStringKey(EligibilityFormTaskIdentifier);
DefineStringKey(EligibilitySurveyTaskIdentifier);
DefineStringKey(LoginTaskIdentifier);
DefineStringKey(RegistrationTaskIdentifier);
DefineStringKey(VerificationTaskIdentifier);

DefineStringKey(CompletionStepTaskIdentifier);
DefineStringKey(DatePickingTaskIdentifier);
DefineStringKey(ImageCaptureTaskIdentifier);
DefineStringKey(VideoCaptureTaskIdentifier);
DefineStringKey(ImageChoicesTaskIdentifier);
DefineStringKey(InstantiateCustomVCTaskIdentifier);
DefineStringKey(LocationTaskIdentifier);
DefineStringKey(ScalesTaskIdentifier);
DefineStringKey(ColorScalesTaskIdentifier);
DefineStringKey(MiniFormTaskIdentifier);
DefineStringKey(OptionalFormTaskIdentifier);
DefineStringKey(SelectionSurveyTaskIdentifier);
DefineStringKey(PredicateTestsTaskIdentifier);

DefineStringKey(ActiveStepTaskIdentifier);
DefineStringKey(AudioTaskIdentifier);
DefineStringKey(AuxillaryImageTaskIdentifier);
DefineStringKey(FitnessTaskIdentifier);
DefineStringKey(FootnoteTaskIdentifier);
DefineStringKey(GaitTaskIdentifier);
DefineStringKey(IconImageTaskIdentifier);
DefineStringKey(HolePegTestTaskIdentifier);
DefineStringKey(MemoryTaskIdentifier);
DefineStringKey(PSATTaskIdentifier);
DefineStringKey(ReactionTimeTaskIdentifier);
DefineStringKey(TrailMakingTaskIdentifier);
DefineStringKey(TwoFingerTapTaskIdentifier);
DefineStringKey(TimedWalkTaskIdentifier);
DefineStringKey(ToneAudiometryTaskIdentifier);
DefineStringKey(TowerOfHanoiTaskIdentifier);
DefineStringKey(TremorTaskIdentifier);
DefineStringKey(TremorRightHandTaskIdentifier);
DefineStringKey(WalkBackAndForthTaskIdentifier);

DefineStringKey(CreatePasscodeTaskIdentifier);

DefineStringKey(CustomNavigationItemTaskIdentifier);
DefineStringKey(DynamicTaskIdentifier);
DefineStringKey(InterruptibleTaskIdentifier);
DefineStringKey(NavigableOrderedTaskIdentifier);
DefineStringKey(NavigableLoopTaskIdentifier);
DefineStringKey(WaitTaskIdentifier);

DefineStringKey(CollectionViewHeaderReuseIdentifier);
DefineStringKey(CollectionViewCellReuseIdentifier);

DefineStringKey(EmbeddedReviewTaskIdentifier);
DefineStringKey(StandaloneReviewTaskIdentifier);
DefineStringKey(ConfirmationFormTaskIdentifier);

DefineStringKey(StepWillDisappearTaskIdentifier);
DefineStringKey(StepWillDisappearFirstStepIdentifier);

DefineStringKey(TableStepTaskIdentifier);
DefineStringKey(SignatureStepTaskIdentifier);
DefineStringKey(VideoInstructionStepTaskIdentifier);
DefineStringKey(PageStepTaskIdentifier);

@interface SectionHeader: UICollectionReusableView

- (void)configureHeaderWithTitle:(NSString *)title;

@end


@implementation SectionHeader {
    UILabel *_title;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
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

static UIColor *HeaderColor() {
    return [UIColor colorWithWhite:0.97 alpha:1.0];
}

static const CGFloat HeaderSideLayoutMargin = 16.0;

- (void)sharedInit {
    self.layoutMargins = UIEdgeInsetsMake(0, HeaderSideLayoutMargin, 0, HeaderSideLayoutMargin);
    self.backgroundColor = HeaderColor();
    _title = [UILabel new];
    _title.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold]; // Table view header font
    [self addSubview:_title];
    
    _title.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"title": _title};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[title]-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (void)configureHeaderWithTitle:(NSString *)title {
    _title.text = title;
}

@end


@interface ButtonCell: UICollectionViewCell

- (void)configureButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;

@end


@implementation ButtonCell {
    UIButton *_button;
}

- (void)setUpButton {
    [_button removeFromSuperview];
    _button = [UIButton buttonWithType:UIButtonTypeSystem];
    _button.titleLabel.adjustsFontSizeToFitWidth = YES;
    _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _button.contentEdgeInsets = UIEdgeInsetsMake(0.0, HeaderSideLayoutMargin, 0.0, 0.0);
    [self.contentView addSubview:_button];
    
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"button": _button};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]|"
                                                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
}

- (void)configureButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector {
    [self setUpButton];
    [_button setTitle:title forState:UIControlStateNormal];
    [_button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end


#define ORKTDefineStringKey(x) static NSString *const x = @#x

ORKTDefineStringKey(CollectionViewHeaderReuseIdentifier);
ORKTDefineStringKey(CollectionViewCellReuseIdentifier);

@interface MainViewController () <ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ORKPasscodeDelegate>

@end


@implementation MainViewController {
    ORKTaskViewController *_taskViewController;
    id<ORKTaskResultSource> _lastRouteResult;
    
    NSMutableDictionary<NSString *, NSData *> *_savedViewControllers;     // Maps task identifiers to task view controller restoration data
    
    UICollectionView *_collectionView;
    NSArray<NSDictionary<NSString *, NSArray<NSString *> *> *> *_buttonSections;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.restorationIdentifier = @"main";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _savedViewControllers = [NSMutableDictionary new];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[SectionHeader class]
        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
               withReuseIdentifier:CollectionViewHeaderReuseIdentifier];
    [_collectionView registerClass:[ButtonCell class]
        forCellWithReuseIdentifier:CollectionViewCellReuseIdentifier];
    
    UIView *statusBarBackground = [UIView new];
    statusBarBackground.backgroundColor = HeaderColor();
    [self.view addSubview:statusBarBackground];

    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    statusBarBackground.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = @{@"collectionView": _collectionView,
                            @"statusBarBackground": statusBarBackground,
                            @"topLayoutGuide": self.topLayoutGuide};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[statusBarBackground]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[statusBarBackground]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:statusBarBackground
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|"
                                                                      options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide][collectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    _buttonSectionNames = @[
                            @"Onboarding",
                            @"Question Steps",
                            @"Active Tasks",
                            @"Passcode",
                            @"Review Step",
                            @"Miscellaneous",
                            ];
    _buttonTitles = @[ @[ // Onboarding
                           @"Consent",
                           @"Consent Review",
                           @"Eligibility Form",
                           @"Eligibility Survey",
                           @"Login",
                           @"Registration",
                           @"Verification",
                           ],
                       @[ // Question Steps
                           @"Date Pickers",
                           @"Image Capture",
                           @"Video Capture",
                           @"Image Choices",
                           @"Location",
                           @"Scale",
                           @"Scale Color Gradient",
                           @"Mini Form",
                           @"Optional Form",
                           @"Selection Survey",
                           ],
                       @[ // Active Tasks
                           @"Active Step Task",
                           @"Audio Task",
                           @"Fitness Task",
                           @"GAIT Task",
                           @"Hole Peg Test Task",
                           @"Memory Game Task",
                           @"PSAT Task",
                           @"Reaction Time Task",
                           @"Trail Making Task",
                           @"Timed Walk Task",
                           @"Tone Audiometry Task",
                           @"Tower Of Hanoi Task",
                           @"Two Finger Tapping Task",
                           @"Walk And Turn Task",
                           @"Hand Tremor Task",
                           @"Right Hand Tremor Task",
                           ],
                       @[ // Passcode
                           @"Authenticate Passcode",
                           @"Create Passcode",
                           @"Edit Passcode",
                           @"Remove Passcode",
                           ],
                       @[ // Review Step
                           @"Embedded Review Task",
                           @"Standalone Review Task",
                           ],
                       @[ // Miscellaneous
                           @"Custom Navigation Item",
                           @"Dynamic Task",
                           @"Interruptible Task",
                           @"Navigable Ordered Task",
                           @"Navigable Loop Task",
                           @"Predicate Tests",
                           @"Test Charts",
                           @"Test Charts Performance",
                           @"Toggle Tint Color",
                           @"Wait Task",
                           @"Step Will Disappear",
                           @"Confirmation Form Item",
                           @"Continue Button",
                           @"Instantiate Custom VC",
                           @"Table Step",
                           @"Signature Step",
                           @"Auxillary Image",
                           @"Video Instruction Step",
                           @"Icon Image",
                           @"Completion Step",
                           @"Page Step",
                           @"Footnote",
                           ],
                       ];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [_collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 22.0);  // Table view header height
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat viewWidth = self.view.bounds.size.width;
    NSUInteger numberOfColums = 2;
    if (viewWidth >= 667.0) {
        numberOfColums = 3;
    }
    CGFloat width = viewWidth / numberOfColums;
    return CGSizeMake(width, 44.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _buttonSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _buttonSections[section].allValues[0].count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionViewHeaderReuseIdentifier forIndexPath:indexPath];
    NSString *title = _buttonSections[indexPath.section].allKeys[0];
    [sectionHeader configureHeaderWithTitle:title];
    return sectionHeader;
}

NSString *RemoveParenthesisAndCapitalizeString(NSString *string) {
    // "THIS (FOO) baR title" is converted to the "This Foo Bar Title"
    NSMutableString *mutableString = [string mutableCopy];
    [mutableString replaceOccurrencesOfString:@"(" withString:@"" options:0 range:NSMakeRange(0, mutableString.length)];
    [mutableString replaceOccurrencesOfString:@")" withString:@"" options:0 range:NSMakeRange(0, mutableString.length)];
    return mutableString.capitalizedString;
}

- (SEL)selectorFromButtonTitle:(NSString *)buttonTitle {
    // "THIS (FOO) baR title" is converted to the "thisFooBarTitleButtonTapped:" selector
    buttonTitle = RemoveParenthesisAndCapitalizeString(buttonTitle);
    NSMutableArray *titleTokens = [[buttonTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    titleTokens[0] = ((NSString *)titleTokens[0]).lowercaseString;
    NSString *selectorString = [NSString stringWithFormat:@"%@ButtonTapped:", [titleTokens componentsJoinedByString:@""]];
    return NSSelectorFromString(selectorString);
}

- (NSString *)taskIdentifierFromButtonTitle:(NSString *)buttonTitle {
    // "THIS (FOO) baR title" is converted to the "ThisFooBarTitleTaskIdentifier" selector
    buttonTitle = RemoveParenthesisAndCapitalizeString(buttonTitle);
    NSMutableArray *titleTokens = [[buttonTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    NSString *taskIdentifier = [NSString stringWithFormat:@"%@TaskIdentifier", [titleTokens componentsJoinedByString:@""]];
    return taskIdentifier;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseIdentifier forIndexPath:indexPath];
    NSString *buttonTitle = _buttonSections[indexPath.section].allValues[0][indexPath.row];
    [buttonCell configureButtonWithTitle:buttonTitle target:self selector:@selector(buttonTapped:)];
    return buttonCell;
}

#pragma mark - Mapping identifiers to tasks

- (id<ORKTask>)makeTaskWithIdentifier:(NSString *)identifier {
    if ([identifier isEqualToString:DatePickingTaskIdentifier]) {
        return [self makeDatePickingTask];
    } else if ([identifier isEqualToString:SelectionSurveyTaskIdentifier]) {
        return [self makeSelectionSurveyTask];
    } else if ([identifier isEqualToString:ActiveStepTaskIdentifier]) {
        return [self makeActiveStepTask];
    } else if ([identifier isEqualToString:ConsentReviewTaskIdentifier]) {
        return [self makeConsentReviewTask];
    } else if ([identifier isEqualToString:ConsentTaskIdentifier]) {
        return [self makeConsentTask];
    } else if ([identifier isEqualToString:EligibilityFormTaskIdentifier]) {
        return [self makeEligibilityFormTask];
    } else if ([identifier isEqualToString:EligibilitySurveyTaskIdentifier]) {
        return [self makeEligibilitySurveyTask];
    } else if ([identifier isEqualToString:LoginTaskIdentifier]) {
        return [self makeLoginTask];
    } else if ([identifier isEqualToString:RegistrationTaskIdentifier]) {
        return [self makeRegistrationTask];
    } else if ([identifier isEqualToString:VerificationTaskIdentifier]) {
        return [self makeVerificationTask];
    } else if ([identifier isEqualToString:AudioTaskIdentifier]) {
        id<ORKTask> task = [ORKOrderedTask audioTaskWithIdentifier:AudioTaskIdentifier
                                            intendedUseDescription:nil
                                                 speechInstruction:nil
                                            shortSpeechInstruction:nil
                                                          duration:10
                                                 recordingSettings:nil
                                                   checkAudioLevel:YES
                                                           options:(ORKPredefinedTaskOption)0];
        return task;
    } else if ([identifier isEqualToString:ToneAudiometryTaskIdentifier]) {
        id<ORKTask> task = [ORKOrderedTask toneAudiometryTaskWithIdentifier:ToneAudiometryTaskIdentifier
                                                     intendedUseDescription:nil
                                                          speechInstruction:nil
                                                     shortSpeechInstruction:nil
                                                               toneDuration:20
                                                                    options:(ORKPredefinedTaskOption)0];
        return task;
    } else if ([identifier isEqualToString:MiniFormTaskIdentifier]) {
        return [self makeMiniFormTask];
    } else if ([identifier isEqualToString:OptionalFormTaskIdentifier]) {
        return [self makeOptionalFormTask];
    } else if ([identifier isEqualToString:PredicateTestsTaskIdentifier]) {
        return [self makePredicateTestsTask];
    } else if ([identifier isEqualToString:FitnessTaskIdentifier]) {
        return [ORKOrderedTask fitnessCheckTaskWithIdentifier:FitnessTaskIdentifier
                                       intendedUseDescription:nil
                                                 walkDuration:360
                                                 restDuration:180
                                                      options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:GaitTaskIdentifier]) {
        return [ORKOrderedTask shortWalkTaskWithIdentifier:GaitTaskIdentifier
                                    intendedUseDescription:nil
                                       numberOfStepsPerLeg:20
                                              restDuration:30
                                                   options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:MemoryTaskIdentifier]) {
        return [ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:MemoryTaskIdentifier
                                            intendedUseDescription:nil
                                                       initialSpan:3
                                                       minimumSpan:2
                                                       maximumSpan:15
                                                         playSpeed:1
                                                      maximumTests:5
                                        maximumConsecutiveFailures:3
                                                 customTargetImage:nil
                                            customTargetPluralName:nil
                                                   requireReversal:NO
                                                           options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:DynamicTaskIdentifier]) {
        return [DynamicTask new];
    } else if ([identifier isEqualToString:InterruptibleTaskIdentifier]) {
        return [self makeInterruptibleTask];
    } else if ([identifier isEqualToString:ScalesTaskIdentifier]) {
        return [self makeScalesTask];
    } else if ([identifier isEqualToString:ColorScalesTaskIdentifier]) {
        return [self makeColorScalesTask];
    } else if ([identifier isEqualToString:ImageChoicesTaskIdentifier]) {
        return [self makeImageChoicesTask];
    } else if ([identifier isEqualToString:ImageCaptureTaskIdentifier]) {
        return [self makeImageCaptureTask];
    } else if ([identifier isEqualToString:VideoCaptureTaskIdentifier]) {
        return [self makeVideoCaptureTask];
    } else if ([identifier isEqualToString:TwoFingerTapTaskIdentifier]) {
        return [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:TwoFingerTapTaskIdentifier
                                                   intendedUseDescription:nil
                                                                 duration:20.0
                                                              handOptions:ORKPredefinedTaskHandOptionBoth
                                                                  options:(ORKPredefinedTaskOption)0];
    } else if ([identifier isEqualToString:ReactionTimeTaskIdentifier]) {
        return [ORKOrderedTask reactionTimeTaskWithIdentifier:ReactionTimeTaskIdentifier
                                       intendedUseDescription:nil
                                      maximumStimulusInterval:8
                                      minimumStimulusInterval:4
                                        thresholdAcceleration:0.5
                                             numberOfAttempts:3
                                                      timeout:10
                                                 successSound:0
                                                 timeoutSound:0
                                                 failureSound:0
                                                      options:0];
    } else if ([identifier isEqualToString:TowerOfHanoiTaskIdentifier]) {
        return [ORKOrderedTask towerOfHanoiTaskWithIdentifier:TowerOfHanoiTaskIdentifier
                                       intendedUseDescription:nil
                                                numberOfDisks:5
                                                      options:0];
    } else if ([identifier isEqualToString:PSATTaskIdentifier]) {
        return [ORKOrderedTask PSATTaskWithIdentifier:PSATTaskIdentifier
                               intendedUseDescription:nil
                                     presentationMode:(ORKPSATPresentationModeAuditory | ORKPSATPresentationModeVisual)
                                interStimulusInterval:3.0
                                     stimulusDuration:1.0
                                         seriesLength:60
                                              options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:TimedWalkTaskIdentifier]) {
        return [ORKOrderedTask timedWalkTaskWithIdentifier:TimedWalkTaskIdentifier
                                    intendedUseDescription:nil
                                          distanceInMeters:100
                                                 timeLimit:180
                                       turnAroundTimeLimit:60
                                includeAssistiveDeviceForm:YES
                                                   options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:HolePegTestTaskIdentifier]) {
        return [ORKNavigableOrderedTask holePegTestTaskWithIdentifier:HolePegTestTaskIdentifier
                                               intendedUseDescription:nil
                                                         dominantHand:ORKBodySagittalRight
                                                         numberOfPegs:9
                                                            threshold:0.2
                                                              rotated:NO
                                                            timeLimit:300.0
                                                              options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:NavigableOrderedTaskIdentifier]) {
        return [TaskFactory makeNavigableOrderedTask:NavigableOrderedTaskIdentifier];
    } else if ([identifier isEqualToString:NavigableLoopTaskIdentifier]) {
        return [self makeNavigableLoopTask];
    } else if ([identifier isEqualToString:CustomNavigationItemTaskIdentifier]) {
        return [self makeCustomNavigationItemTask];
    } else if ([identifier isEqualToString:CreatePasscodeTaskIdentifier]) {
        return [self makeCreatePasscodeTask];
    } else if ([identifier isEqualToString:EmbeddedReviewTaskIdentifier]) {
        return [self makeEmbeddedReviewTask];
    } else if ([identifier isEqualToString:StandaloneReviewTaskIdentifier]) {
        return [self makeStandaloneReviewTask];
    } else if ([identifier isEqualToString:WaitTaskIdentifier]) {
        return [self makeWaitingTask];
    } else if ([identifier isEqualToString:LocationTaskIdentifier]) {
        return [self makeLocationTask];
    } else if ([identifier isEqualToString:StepWillDisappearTaskIdentifier]) {
        return [self makeStepWillDisappearTask];
    } else if ([identifier isEqualToString:ConfirmationFormTaskIdentifier]) {
        return [self makeConfirmationFormTask];
    } else if ([identifier isEqualToString:InstantiateCustomVCTaskIdentifier]) {
        return [self makeInstantiateCustomVCTask];
    } else if ([identifier isEqualToString:WalkBackAndForthTaskIdentifier]) {
        return [ORKOrderedTask walkBackAndForthTaskWithIdentifier:WalkBackAndForthTaskIdentifier
                                           intendedUseDescription:nil
                                                     walkDuration:30
                                                     restDuration:30
                                                          options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:TableStepTaskIdentifier]) {
        return [self makeTableStepTask];
    } else if ([identifier isEqualToString:SignatureStepTaskIdentifier]) {
        return [self makeSignatureStepTask];
    } else if ([identifier isEqualToString:TremorTaskIdentifier]) {
        return [ORKOrderedTask tremorTestTaskWithIdentifier:TremorTaskIdentifier
                                     intendedUseDescription:nil
                                         activeStepDuration:10
                                          activeTaskOptions:
                ORKTremorActiveTaskOptionExcludeHandAtShoulderHeight |
                ORKTremorActiveTaskOptionExcludeHandAtShoulderHeightElbowBent |
                ORKTremorActiveTaskOptionExcludeHandToNose
                                                handOptions:ORKPredefinedTaskHandOptionBoth
                                                    options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:TremorRightHandTaskIdentifier]) {
        return [ORKOrderedTask tremorTestTaskWithIdentifier:TremorRightHandTaskIdentifier
                                     intendedUseDescription:nil
                                         activeStepDuration:10
                                          activeTaskOptions:0
                                                handOptions:ORKPredefinedTaskHandOptionRight
                                                    options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:AuxillaryImageTaskIdentifier]) {
        return [self makeAuxillaryImageTask];
    } else if ([identifier isEqualToString:IconImageTaskIdentifier]) {
        return [self makeIconImageTask];
    } else if ([identifier isEqualToString:TrailMakingTaskIdentifier]) {
        return [ORKOrderedTask trailmakingTaskWithIdentifier:TrailMakingTaskIdentifier
                                      intendedUseDescription:nil
                                      trailmakingInstruction:nil
                                                   trailType:ORKTrailMakingTypeIdentifierA
                                                     options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:PageStepTaskIdentifier]) {
        return [self makePageStepTask];
    } else if ([identifier isEqualToString:FootnoteTaskIdentifier]) {
        return [self makeFootnoteTask];
    }
    else if ([identifier isEqualToString:VideoInstructionStepTaskIdentifier]) {
        return [self makeVideoInstructionStepTask];
    }
    
    return nil;
}

/*
 Creates a task and presents it with a task view controller.
 */
- (void)beginTaskWithIdentifier:(NSString *)identifier {
    /*
     This is our implementation of restoration after saving during a task.
     If the user saved their work on a previous run of a task with the same
     identifier, we attempt to restore the view controller here.
     
     Since unarchiving can throw an exception, in a real application we would
     need to attempt to catch that exception here.
     */

    id<ORKTask> task = [[TaskFactory sharedInstance] makeTaskWithIdentifier:identifier];
    NSParameterAssert(task != nil);
    
    if (_savedViewControllers[identifier]) {
        NSData *data = _savedViewControllers[identifier];
        _taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:data delegate:self];
    } else {
        // No saved data, just create the task and the corresponding task view controller.
        _taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    }
    
    // If we have stored data then data will contain the stored data.
    // If we don't, data will be nil (and the task will be opened up as a 'new' task.
    NSData *data = _savedViewControllers[identifier];
    _taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:data delegate:self];
    
    [self beginTask];
}

/*
 Actually presents the task view controller.
 */
- (void)beginTask {
    NSObject<ORKTask> *task = _taskViewController.task;
    _taskViewController.delegate = self;
    
    if (_taskViewController.outputDirectory == nil) {
        // Sets an output directory in Documents, using the `taskRunUUID` in the path.
        NSURL *documents =  [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *outputDir = [documents URLByAppendingPathComponent:_taskViewController.taskRunUUID.UUIDString];
        [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
        _taskViewController.outputDirectory = outputDir;
    }
    
    /*
     For the dynamic task, we remember the last result and use it as a source
     of default values for any optional questions.
     */
    if ([task isKindOfClass:[DynamicTask class]]) {
        _taskViewController.defaultResultSource = _lastRouteResult;
    }
    
    /*
     We set a restoration identifier so that UI state restoration is enabled
     for the task view controller. We don't need to do anything else to prepare
     for state restoration of a ResearchKit framework task VC.
     */
    _taskViewController.restorationIdentifier = task.identifier;
    
    [self presentViewController:_taskViewController animated:YES completion:nil];
}

#pragma mark - Custom Button Actions

// Passcode management
- (void)authenticatePasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        ORKPasscodeViewController *viewController = [ORKPasscodeViewController
                                                     passcodeAuthenticationViewControllerWithText:@"Authenticate your passcode in order to proceed."
                                                     delegate:self];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:@"A passcode must be created before you can authenticate it."];
    }
}

- (void)editPasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        ORKPasscodeViewController *viewController = [ORKPasscodeViewController passcodeEditingViewControllerWithText:nil
                                                                                                            delegate:self
                                                                                                        passcodeType:ORKPasscodeType6Digit];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:@"A passcode must be created before you can edit it."];
    }
}

- (void)removePasscodeButtonTapped:(id)sender {
    if ([ORKPasscodeViewController isPasscodeStoredInKeychain]) {
        if ([ORKPasscodeViewController removePasscodeFromKeychain]) {
            [self showAlertWithTitle:@"Success" message:@"Passcode removed."];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Passcode could not be removed."];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:@"There is no passcode stored in the keychain."];
    }
}

// Task Review
- (IBAction)standaloneReviewButtonTapped:(UIButton *)button {
    if ([TaskFactory sharedInstance].embeddedReviewTaskResult != nil) {
        NSString *buttonTitle = button.titleLabel.text;
        [self beginTaskWithIdentifier:[self taskIdentifierFromButtonTitle:buttonTitle]];
    } else {
        [self showAlertWithTitle:@"Alert" message:@"Please run embedded review task first"];
    }
}

// Miscellaneous
- (IBAction)continueButtonButtonTapped:(UIButton *)button {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContinueButtonExample" bundle:nil];
    UIViewController *viewcController = [storyboard instantiateInitialViewController];
    [self presentViewController:viewcController animated:YES completion:nil];
}

- (void)toggleTintColorButtonTapped:(UIButton *)button {
    static UIColor *defaultTintColor = nil;
    if (!defaultTintColor) {
        defaultTintColor = self.view.tintColor;
    }
    if ([[UIView appearance].tintColor isEqual:[UIColor redColor]]) {
        [UIView appearance].tintColor = defaultTintColor;
    } else {
        [UIView appearance].tintColor = [UIColor redColor];
    }
    // Update appearance
    UIView *superview = self.view.superview;
    [self.view removeFromSuperview];
    [superview addSubview:self.view];
}

#pragma mark - Passcode delegate

- (void)passcodeViewControllerDidFailAuthentication:(UIViewController *)viewController {
    NSLog(@"Passcode authentication failed.");
    [self showAlertWithTitle:@"Error" message:@"Passcode authentication failed"];
}

- (void)passcodeViewControllerDidFinishWithSuccess:(UIViewController *)viewController {
    NSLog(@"New passcode saved.");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)passcodeViewControllerDidCancel:(UIViewController *)viewController {
    NSLog(@"User tapped the cancel button.");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)passcodeViewControllerForgotPasscodeTapped:(UIViewController *)viewController {
    NSLog(@"Forgot Passcode tapped.");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Forgot Passcode"
                                                                   message:@"Forgot Passcode tapped."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [viewController presentViewController:alert animated:YES completion:nil];
}

- (void)testChartsButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

- (void)testChartsPerformanceButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartPerformanceListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

#pragma mark - Helpers

/*
 Shows an alert.
 
 Used to display an alert with the provided title and message.
 
 @param title       The title text for the alert.
 @param message     The message text for the alert.
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Managing the task view controller

/*
 Dismisses the task view controller.
 */
- (void)dismissTaskViewController:(ORKTaskViewController *)taskViewController removeOutputDirectory:(BOOL)removeOutputDirectory {
    [TaskFactory sharedInstance].currentConsentDocument = nil;
    
    NSURL *outputDirectoryURL = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (outputDirectoryURL && removeOutputDirectory)
        {
            /*
             We attempt to clean up the output directory.
             
             This is only useful for a test app, where we don't care about the
             data after the test is complete. In a real application, only
             delete your data when you've processed it or sent it to a server.
             */
            NSError *err = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:outputDirectoryURL error:&err]) {
                NSLog(@"Error removing %@: %@", outputDirectoryURL, err);
            }
        }
    }];
}

#pragma mark - ORKTaskViewControllerDelegate

/*
 Any step can have "Learn More" content.
 
 For testing, we return YES only for instruction steps, except on the active
 tasks.
 */
- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController hasLearnMoreForStep:(ORKStep *)step {
    NSObject<ORKTask> *task = taskViewController.task;

    return ([step isKindOfClass:[ORKInstructionStep class]]
            && !task.hidesLearnMoreButtonOnInstructionStep);
}

/*
 When the user taps on "Learn More" on a step, respond on this delegate callback.
 In this test app, we just print to the console.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    NSLog(@"Learn more tapped for step %@", stepViewController.step.identifier);
}

- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step {
    BOOL shouldPresentStep = YES;
    if (step.shouldPresentStepBlock) {
        shouldPresentStep = step.shouldPresentStepBlock(taskViewController, step);
    }
    return shouldPresentStep;
}

/*
 In `stepViewControllerWillAppear:`, it is possible to significantly customize
 the behavior of the step view controller. In this test app, we do a few funny
 things to push the limits of this customization.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController
stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    ORKStep *step = stepViewController.step;
    if (step.stepViewControllerWillAppearBlock) {
        step.stepViewControllerWillAppearBlock(taskViewController, stepViewController);
    }
}

- (void)taskViewController:(ORKTaskViewController *)taskViewController stepViewControllerWillDisappear:(ORKStepViewController *)stepViewController navigationDirection:(ORKStepViewControllerNavigationDirection)direction {
    ORKStep *step = stepViewController.step;
    if (step.stepViewControllerWillDisappearBlock) {
        step.stepViewControllerWillDisappearBlock(taskViewController, stepViewController, direction);
    }
}

/*
 We support save and restore on all of the tasks in this test app.
 
 In a real app, not all tasks necessarily ought to support saving -- for example,
 active tasks that can't usefully be restarted after a significant time gap
 should not support save at all.
 */
- (BOOL)taskViewControllerSupportsSaveAndRestore:(ORKTaskViewController *)taskViewController {
    return YES;
}

/*
 In almost all cases, we want to dismiss the task view controller.
 
 In this test app, we don't dismiss on a fail (we just log it).
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController didFinishWithReason:(ORKTaskViewControllerFinishReason)reason error:(NSError *)error {
    switch (reason) {
        case ORKTaskViewControllerFinishReasonCompleted:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = taskViewController.result;
            }
            [self taskViewControllerDidComplete:taskViewController];
        }
            break;
        case ORKTaskViewControllerFinishReasonFailed:
        {
            NSLog(@"Error on step %@: %@", taskViewController.currentStepViewController.step, error);
        }
            break;
        case ORKTaskViewControllerFinishReasonDiscarded:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = nil;
            }
            [self dismissTaskViewController:taskViewController removeOutputDirectory:YES];
        }
            break;
        case ORKTaskViewControllerFinishReasonSaved:
        {
            NSObject<ORKTask> *task = taskViewController.task;
            if (task.isEmbeddedReviewTask) {
                [TaskFactory sharedInstance].embeddedReviewTaskResult = taskViewController.result;
            }
            /*
             Save the restoration data, dismiss the task VC, and do an early return
             so we don't clear the restoration data.
             */
            _savedViewControllers[task.identifier] = taskViewController.restorationData;
            [self dismissTaskViewController:taskViewController removeOutputDirectory:NO];
            return;
        }
            break;
            
        default:
            break;
    }
    
    [_savedViewControllers removeObjectForKey:taskViewController.task.identifier];
    _taskViewController = nil;
}

/*
 When a task completes, we pretty-print the result to the console.
 
 This is ok for testing, but if what you want to do is see the results of a task,
 the `ORKCatalog` Swift sample app might be a better choice, since it lets
 you navigate through the result structure.
 */
- (void)taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController {
    
    NSLog(@"[ORKTest] task results: %@", taskViewController.result);
    
    // Validate the results
    NSArray *results = taskViewController.result.results;
    if (results) {
        NSSet *uniqueResults = [NSSet setWithArray:results];
        BOOL allResultsUnique = (results.count == uniqueResults.count);
        NSAssert(allResultsUnique, @"The returned results have duplicates of the same object.");
    }
    
    if ([TaskFactory sharedInstance].currentConsentDocument) {
        /*
         This demonstrates how to take a signature result, apply it to a document,
         and then generate a PDF From the document that includes the signature.
         */
        
        // Search for the review step.
        NSArray *steps = [(ORKOrderedTask *)taskViewController.task steps];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"self isKindOfClass: %@", [ORKConsentReviewStep class]];
        ORKStep *reviewStep = [[steps filteredArrayUsingPredicate:predicate] firstObject];
        ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:reviewStep.identifier] firstResult];
        
        [signatureResult applyToDocument:[TaskFactory sharedInstance].currentConsentDocument];
        
        [[TaskFactory sharedInstance].currentConsentDocument makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
            NSLog(@"Created PDF of size %lu (error = %@)", (unsigned long)pdfData.length, error);
            
            if (!error) {
                NSURL *documents = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
                NSURL *outputUrl = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", taskViewController.taskRunUUID.UUIDString]];
                
                [pdfData writeToURL:outputUrl atomically:YES];
                NSLog(@"Wrote PDF to %@", [outputUrl path]);
            }
        }];
        
        [TaskFactory sharedInstance].currentConsentDocument = nil;
    }
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            NSError *err = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
            }
        }
    }];
}

/**
  When a task has completed it calls this method to post the result of the task to the delegate.
*/
- (void)taskViewController:(ORKTaskViewController *)taskViewController didChangeResult:(ORKTaskResult *)result {
    /*
     Upon creation of a Passcode by a user, the results of their creation
     are returned by getting it from ORKPasscodeResult in this delegate call.
     This is triggered upon completion/failure/or cancel
     */
    ORKStepResult *stepResult = (ORKStepResult *)[[result results] firstObject];
    if ([[[stepResult results] firstObject] isKindOfClass:[ORKPasscodeResult class]]) {
        ORKPasscodeResult *passcodeResult = (ORKPasscodeResult *)[[stepResult results] firstObject];
        NSLog(@"passcode saved: %d , Touch ID Enabled: %d", passcodeResult.passcodeSaved, passcodeResult.touchIdEnabled);

    }
}

#pragma mark - UI state restoration

/*
 UI state restoration code for the MainViewController.
 
 The MainViewController needs to be able to re-create the exact task that
 was being done, in order for the task view controller to restore correctly.
 
 In a real app implementation, this might mean that you would also need to save
 and restore the actual task; here, since we know the tasks don't change during
 testing, we just re-create the task.
 */
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_taskViewController forKey:@"taskVC"];
    [coder encodeObject:_lastRouteResult forKey:@"lastRouteResult"];
    [coder encodeObject:[TaskFactory sharedInstance].embeddedReviewTaskResult forKey:@"embeddedReviewTaskResult"];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _taskViewController = [coder decodeObjectOfClass:[UIViewController class] forKey:@"taskVC"];
    _lastRouteResult = [coder decodeObjectForKey:@"lastRouteResult"];
    
    // Need to give the task VC back a copy of its task, so it can restore itself.
    
    // Could save and restore the task's identifier separately, but the VC's
    // restoration identifier defaults to the task's identifier.
    id<ORKTask> taskForTaskViewController = [[TaskFactory sharedInstance] makeTaskWithIdentifier:_taskViewController.restorationIdentifier];
    
    _taskViewController.task = taskForTaskViewController;
    if ([_taskViewController.restorationIdentifier isEqualToString:@"DynamicTask01"])
    {
        _taskViewController.defaultResultSource = _lastRouteResult;
    }
    _taskViewController.delegate = self;
}

#pragma mark - Charts

- (void)testChartsButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

- (void)testChartsPerformanceButtonTapped:(id)sender {
    UIStoryboard *chartStoryboard = [UIStoryboard storyboardWithName:@"Charts" bundle:nil];
    UIViewController *chartListViewController = [chartStoryboard instantiateViewControllerWithIdentifier:@"ChartPerformanceListViewController"];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

#pragma mark - Wait Task

- (ORKOrderedTask *)makeWaitingTask {
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    /*
     To properly use the wait steps, one needs to implement the "" method of ORKTaskViewControllerDelegate to start their background action when the wait task begins, and then call the "finish" method on the ORKWaitTaskViewController when the background task has been completed.
     */
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"waitTask.step1"];
    step1.title = @"Setup";
    step1.detailText = @"ORKTest needs to set up some things before you begin, once the setup is complete you will be able to continue.";
    [steps addObject:step1];
    
    // Interterminate wait step.
    ORKWaitStep *step2 = [[ORKWaitStep alloc] initWithIdentifier:@"waitTask.step2"];
    step2.title = @"Getting Ready";
    step2.text = @"Please wait while the setup completes.";
    [steps addObject:step2];
    
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"waitTask.step3"];
    step3.title = @"Account Setup";
    step3.detailText = @"The information you entered will be sent to the secure server to complete your account setup.";
    [steps addObject:step3];
    
    // Determinate wait step.
    ORKWaitStep *step4 = [[ORKWaitStep alloc] initWithIdentifier:@"waitTask.step4"];
    step4.title = @"Syncing Account";
    step4.text = @"Please wait while the data is uploaded.";
    step4.indicatorType = ORKProgressIndicatorTypeProgressBar;
    [steps addObject:step4];
    
    ORKCompletionStep *step5 = [[ORKCompletionStep alloc] initWithIdentifier:@"waitTask.step5"];
    step5.title = @"Setup Complete";
    [steps addObject:step5];

    ORKOrderedTask *waitTask = [[ORKOrderedTask alloc] initWithIdentifier:WaitTaskIdentifier steps:steps];
    return waitTask;
}

- (void)updateProgress:(CGFloat)progress waitStepViewController:(ORKWaitStepViewController *)waitStepviewController {
    if (progress <= 1.0) {
        [waitStepviewController setProgress:progress animated:true];
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self updateProgress:(progress + 0.01) waitStepViewController:waitStepviewController];
            if (progress > 0.495 && progress < 0.505) {
                NSString *newText = @"Please wait while the data is downloaded.";
                [waitStepviewController updateText:newText];
            }
        });
    } else {
        [waitStepviewController goForward];
    }
}

#pragma mark - Location Task

- (IBAction)locationButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:LocationTaskIdentifier];
}

- (ORKOrderedTask *)makeLocationTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"locationTask.step1"];
    step1.title = @"Location Survey";
    [steps addObject:step1];
    
    // Location question with current location observing on
    ORKQuestionStep *step2 = [[ORKQuestionStep alloc] initWithIdentifier:@"locationTask.step2"];
    step2.title = @"Where are you right now?";
    step2.answerFormat = [[ORKLocationAnswerFormat alloc] init];
    [steps addObject:step2];
    
    // Location question with current location observing off
    ORKQuestionStep *step3 = [[ORKQuestionStep alloc] initWithIdentifier:@"locationTask.step3"];
    step3.title = @"Where is your home?";
    ORKLocationAnswerFormat *locationAnswerFormat  = [[ORKLocationAnswerFormat alloc] init];
    locationAnswerFormat.useCurrentLocation= NO;
    step3.answerFormat = locationAnswerFormat;
    [steps addObject:step3];
    
    ORKCompletionStep *step4 = [[ORKCompletionStep alloc] initWithIdentifier:@"locationTask.step4"];
    step4.title = @"Survey Complete";
    [steps addObject:step4];
    
    ORKOrderedTask *locationTask = [[ORKOrderedTask alloc] initWithIdentifier:LocationTaskIdentifier steps:steps];
    return locationTask;
}

#pragma mark - Step Will Disappear Task Delegate example

- (IBAction)stepWillDisappearButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:StepWillDisappearTaskIdentifier];
}

- (ORKOrderedTask *)makeStepWillDisappearTask {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:StepWillDisappearFirstStepIdentifier];
    step1.title = @"Step Will Disappear Delegate Example";
    step1.text = @"The tint color of the task view controller is changed to magenta in the `stepViewControllerWillDisappear:` method.";
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"stepLast"];
    stepLast.title = @"Survey Complete";
    
    ORKOrderedTask *locationTask = [[ORKOrderedTask alloc] initWithIdentifier:StepWillDisappearTaskIdentifier steps:@[step1, stepLast]];
    return locationTask;
}

#pragma mark - Confirmation Form Item

- (IBAction)confirmationFormItemButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ConfirmationFormTaskIdentifier];
}

- (ORKOrderedTask *)makeConfirmationFormTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"confirmationForm.step1"];
    step1.title = @"Confirmation Form Items Survey";
    [steps addObject:step1];
    
    // Create a step for entering password with confirmation
    ORKFormStep *step2 = [[ORKFormStep alloc] initWithIdentifier:@"confirmationForm.step2" title:@"Password" text:nil];
    [steps addObject:step2];
    
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.secureTextEntry = YES;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeNone;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"password"
                                                               text:@"Password"
                                                       answerFormat:answerFormat
                                                           optional:NO];
        item.placeholder = @"Enter password";

        ORKFormItem *confirmationItem = [item confirmationAnswerFormItemWithIdentifier:@"password.confirmation"
                                                                                  text:@"Confirm"
                                                                          errorMessage:@"Passwords do not match"];
        confirmationItem.placeholder = @"Enter password again";
        
        step2.formItems = @[item, confirmationItem];
    }
    
    // Create a step for entering participant id
    ORKFormStep *step3 = [[ORKFormStep alloc] initWithIdentifier:@"confirmationForm.step3" title:@"Participant ID" text:nil];
    [steps addObject:step3];
    
    {
        ORKTextAnswerFormat *answerFormat = [ORKAnswerFormat textAnswerFormat];
        answerFormat.multipleLines = NO;
        answerFormat.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        answerFormat.autocorrectionType = UITextAutocorrectionTypeNo;
        answerFormat.spellCheckingType = UITextSpellCheckingTypeNo;
        
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"participantID"
                                                               text:@"Participant ID"
                                                       answerFormat:answerFormat
                                                           optional:YES];
        item.placeholder = @"Enter Participant ID";
        
        ORKFormItem *confirmationItem = [item confirmationAnswerFormItemWithIdentifier:@"participantID.confirmation"
                                                                                  text:@"Confirm"
                                                                          errorMessage:@"IDs do not match"];
        confirmationItem.placeholder = @"Enter ID again";
        
        step3.formItems = @[item, confirmationItem];
    }
    
    ORKCompletionStep *step4 = [[ORKCompletionStep alloc] initWithIdentifier:@"confirmationForm.lastStep"];
    step4.title = @"Survey Complete";
    [steps addObject:step4];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:ConfirmationFormTaskIdentifier steps:steps];
}

#pragma mark - Continue button

- (IBAction)continueButtonButtonTapped:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ContinueButtonExample" bundle:nil];
    UIViewController *vc = [storyboard instantiateInitialViewController];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Instantiate Custom Step View Controller Example

- (IBAction)instantiateCustomVcButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:InstantiateCustomVCTaskIdentifier];
}

- (ORKOrderedTask *)makeInstantiateCustomVCTask {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"locationTask.step1"];
    step1.title = @"Instantiate Custom View Controller";
    step1.text = @"The next step uses a custom subclass of an ORKFormStepViewController.";
    
    DragonPokerStep *dragonStep = [[DragonPokerStep alloc] initWithIdentifier:@"dragonStep"];
    
    ORKStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"done"];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:InstantiateCustomVCTaskIdentifier steps:@[step1, dragonStep, lastStep]];
}

#pragma mark - Step Table

- (IBAction)tableStepButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:TableStepTaskIdentifier];
}

- (ORKOrderedTask *)makeTableStepTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.text = @"Example of an ORKTableStepViewController";
    [steps addObject:step1];
    
    ORKTableStep *tableStep = [[ORKTableStep alloc] initWithIdentifier:@"tableStep"];
    tableStep.items = @[@"Item 1", @"Item 2", @"Item 3"];
    [steps addObject:tableStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:TableStepTaskIdentifier steps:steps];
}

#pragma mark - Signature Table

- (IBAction)signatureStepButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:SignatureStepTaskIdentifier];
}

- (ORKOrderedTask *)makeSignatureStepTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.text = @"Example of an ORKSignatureStep";
    [steps addObject:step1];
    
    ORKSignatureStep *signatureStep = [[ORKSignatureStep alloc] initWithIdentifier:@"signatureStep"];
    [steps addObject:signatureStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:SignatureStepTaskIdentifier steps:steps];
}

#pragma mark - Auxillary Image

- (IBAction)auxillaryImageButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:AuxillaryImageTaskIdentifier];
}

- (ORKOrderedTask *)makeAuxillaryImageTask {
    
    ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:AuxillaryImageTaskIdentifier];
    step.title = @"Title";
    step.text = @"This is description text.";
    step.detailText = @"This is detail text.";
    step.image = [UIImage imageNamed:@"tremortest3a" inBundle:[NSBundle bundleForClass:[ORKOrderedTask class]] compatibleWithTraitCollection:nil];
    step.auxiliaryImage = [UIImage imageNamed:@"tremortest3b" inBundle:[NSBundle bundleForClass:[ORKOrderedTask class]] compatibleWithTraitCollection:nil];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:SignatureStepTaskIdentifier steps:@[step]];
}

#pragma mark - Video Instruction Task

- (IBAction)videoInstructionStepButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:VideoInstructionStepTaskIdentifier];
}

- (ORKOrderedTask *)makeVideoInstructionStepTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *firstStep = [[ORKInstructionStep alloc] initWithIdentifier:@"firstStep"];
    firstStep.text = @"Example of an ORKVideoInstructionStep";
    [steps addObject:firstStep];
    
    ORKVideoInstructionStep *videoInstructionStep = [[ORKVideoInstructionStep alloc] initWithIdentifier:@"videoInstructionStep"];
    videoInstructionStep.text = @"Video Instruction";
    videoInstructionStep.videoURL = [[NSURL alloc] initWithString:@"https://www.apple.com/media/us/researchkit/2016/a63aa7d4_e6fd_483f_a59d_d962016c8093/films/carekit/researchkit-carekit-cc-us-20160321_r848-9dwc.mov"];
    
    [steps addObject:videoInstructionStep];
    
    ORKCompletionStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Task Complete";
    [steps addObject:lastStep];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:SignatureStepTaskIdentifier steps:steps];
}

#pragma mark - Icon Image

- (IBAction)iconImageButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:IconImageTaskIdentifier];
}

- (ORKOrderedTask *)makeIconImageTask {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Title";
    step1.text = @"This is an example of a step with an icon image.";

    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    step1.iconImage = [UIImage imageNamed:icon];
    
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"step2"];
    step2.text = @"This is an example of a step with an icon image and no title.";
    step2.iconImage = [UIImage imageNamed:icon];
    
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Title";
    step3.text = @"This is an example of a step with an icon image that is very big.";
    step3.iconImage = [UIImage imageNamed:@"Poppies"];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:IconImageTaskIdentifier steps:@[step1, step2, step3]];
}

#pragma mark - Trail Making Task

- (IBAction)trailMakingTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:TrailMakingTaskIdentifier];
}

#pragma mark - Completion Step Continue Button

- (IBAction)completionStepButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:CompletionStepTaskIdentifier];
}

- (ORKOrderedTask *)makeCompletionStepTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKCompletionStep *step1 = [[ORKCompletionStep alloc] initWithIdentifier:@"completionStepWithDoneButton"];
    step1.text = @"Example of a step view controller with the continue button in the standard location below the checkmark.";
    [steps addObject:step1];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Example of an step view controller with the continue button in the upper right.";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:CompletionStepTaskIdentifier steps:steps];
}

#pragma mark - Page Step

- (IBAction)pageStepButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:PageStepTaskIdentifier];
}

- (ORKOrderedTask *)makePageStepTask {
    
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.text = @"Example of an ORKPageStep";
    [steps addObject:step1];
    
    NSMutableArray<ORKTextChoice *> *textChoices = [[NSMutableArray alloc] init];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Good" detailText:@"" value:[NSNumber numberWithInt:0] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Average" detailText:@"" value:[NSNumber numberWithInt:1] exclusive:NO]];
    [textChoices addObject:[[ORKTextChoice alloc] initWithText:@"Poor" detailText:@"" value:[NSNumber numberWithInt:2] exclusive:NO]];
    ORKAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:textChoices];
    ORKFormItem *formItem = [[ORKFormItem alloc] initWithIdentifier:@"choice" text:nil answerFormat:answerFormat];
    ORKFormStep *groupStep1 = [[ORKFormStep alloc] initWithIdentifier:@"step1" title:nil text:@"How do you feel today?"];
    groupStep1.formItems = @[formItem];
    
    NSMutableArray<ORKImageChoice *> *imageChoices = [[NSMutableArray alloc] init];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"left_hand_outline"] selectedImage:[UIImage imageNamed:@"left_hand_solid"] text:@"Left hand" value:[NSNumber numberWithInt:1]]];
    [imageChoices addObject:[[ORKImageChoice alloc] initWithNormalImage:[UIImage imageNamed:@"right_hand_outline"] selectedImage:[UIImage imageNamed:@"right_hand_solid"] text:@"Right hand" value:[NSNumber numberWithInt:0]]];
    ORKQuestionStep *groupStep2 = [ORKQuestionStep questionStepWithIdentifier:@"step2" title:@"Which hand was injured?" answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:imageChoices]];
    
    ORKSignatureStep *groupStep3 = [[ORKSignatureStep alloc] initWithIdentifier:@"step3"];
    
    ORKStep *groupStep4 = [[ORKConsentReviewStep alloc] initWithIdentifier:@"groupStep4" signature:nil inDocument:[self buildConsentDocument]];
    
    ORKPageStep *pageStep = [[ORKPageStep alloc] initWithIdentifier:@"pageStep" steps:@[groupStep1, groupStep2, groupStep3, groupStep4]];
    [steps addObject:pageStep];
    
    ORKOrderedTask *audioTask = [ORKOrderedTask audioTaskWithIdentifier:@"audioTask"
                                                 intendedUseDescription:nil
                                                      speechInstruction:nil
                                                 shortSpeechInstruction:nil
                                                               duration:10
                                                      recordingSettings:nil
                                                        checkAudioLevel:YES
                                                                options:
                                 ORKPredefinedTaskOptionExcludeInstructions |
                                 ORKPredefinedTaskOptionExcludeConclusion];
    ORKPageStep *audioStep = [[ORKNavigablePageStep alloc] initWithIdentifier:@"audioStep" pageTask:audioTask];
    [steps addObject:audioStep];
    
    ORKCompletionStep *stepLast = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    stepLast.title = @"Task Complete";
    [steps addObject:stepLast];
    
    return [[ORKOrderedTask alloc] initWithIdentifier:PageStepTaskIdentifier steps:steps];
    
}


#pragma mark - Footnote

- (IBAction)footnoteButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:FootnoteTaskIdentifier];
}

- (ORKOrderedTask *)makeFootnoteTask {
    
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"step1"];
    step1.title = @"Footnote example";
    step1.text = @"This is an instruction step with a footnote.";
    step1.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"step2"];
    step2.title = @"Image and No Footnote";
    step2.text = @"This is an instruction step with an image and NO footnote.";
    step2.image = [UIImage imageNamed:@"image_example"];
    
    ORKInstructionStep *step3 = [[ORKInstructionStep alloc] initWithIdentifier:@"step3"];
    step3.title = @"Image and Footnote";
    step3.text = @"This is an instruction step with an image and a footnote.";
    step3.image = [UIImage imageNamed:@"image_example"];
    step3.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";
    
    ORKFormStep *step4 = [[ORKFormStep alloc] initWithIdentifier:@"step4" title:@"Form Step with skip" text:@"This is a form step with a skip button."];
    step4.formItems = @[[[ORKFormItem alloc] initWithIdentifier:@"form_item_1"
                                                           text:@"Are you over 18 years of age?"
                                                   answerFormat:[ORKAnswerFormat booleanAnswerFormat]]];
    step4.optional = YES;
    
    ORKFormStep *step5 = [[ORKFormStep alloc] initWithIdentifier:@"step5" title:@"Form Step with Footnote" text:@"This is a form step with a skip button and footnote."];
    step5.formItems = @[[[ORKFormItem alloc] initWithIdentifier:@"form_item_1"
                                                           text:@"Are you over 18 years of age?"
                                                   answerFormat:[ORKAnswerFormat booleanAnswerFormat]]];
    step5.optional = YES;
    step5.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";

    ORKCompletionStep *lastStep = [[ORKCompletionStep alloc] initWithIdentifier:@"lastStep"];
    lastStep.title = @"Last step.";
    lastStep.text = @"This is a completion step with a footnote.";
    lastStep.footnote = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce dignissim tortor eget orci placerat, eu congue diam tempor. In hac.";

    return [[ORKOrderedTask alloc] initWithIdentifier:FootnoteTaskIdentifier steps:@[step1, step2, step3, step4, step5, lastStep]];
}


@end
