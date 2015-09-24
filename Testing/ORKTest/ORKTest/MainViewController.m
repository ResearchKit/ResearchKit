/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Bruce Duncan.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.

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
#import <ResearchKit/ResearchKit_Private.h>
#import <AVFoundation/AVFoundation.h>
#import "DynamicTask.h"
#import "AppDelegate.h"
#import "ORKTest-Swift.h"


#define DefineStringKey(x) static NSString *const x = @#x

DefineStringKey(ConsentTaskIdentifier);
DefineStringKey(ConsentReviewTaskIdentifier);

DefineStringKey(DatePickingTaskIdentifier);
DefineStringKey(ImageCaptureTaskIdentifier);
DefineStringKey(ImageChoicesTaskIdentifier);
DefineStringKey(ScalesTaskIdentifier);
DefineStringKey(MiniFormTaskIdentifier);
DefineStringKey(OptionalFormTaskIdentifier);
DefineStringKey(SelectionSurveyTaskIdentifier);

DefineStringKey(ActiveStepTaskIdentifier);
DefineStringKey(AudioTaskIdentifier);
DefineStringKey(FitnessTaskIdentifier);
DefineStringKey(GaitTaskIdentifier);
DefineStringKey(MemoryTaskIdentifier);
DefineStringKey(PSATTaskIdentifier);
DefineStringKey(ReactionTimeTaskIdentifier);
DefineStringKey(ScreeningTaskIdentifier);
DefineStringKey(TimedWalkTaskIdentifier);
DefineStringKey(ToneAudiometryTaskIdentifier);
DefineStringKey(TowerOfHanoiTaskIdentifier);
DefineStringKey(TwoFingerTapTaskIdentifier);

DefineStringKey(CustomNavigationItemTaskIdentifier);
DefineStringKey(DynamicTaskIdentifier);
DefineStringKey(StepNavigationTaskIdentifier);

DefineStringKey(CollectionViewHeaderReuseIdentifier);
DefineStringKey(CollectionViewCellReuseIdentifier);


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


@interface MainViewController () <ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    id<ORKTaskResultSource> _lastRouteResult;
    ORKConsentDocument *_currentDocument;
    
    NSMutableDictionary<NSString *, NSData *> *_savedTasks;               // Maps task identifiers to archived task data
    NSMutableDictionary<NSString *, NSData *> *_savedViewControllers;     // Maps task identifiers to task view controller restoration data
    
    UICollectionView *_collectionView;
    NSArray<NSString *> *_buttonSectionNames;
    NSArray<NSArray<NSString *> *> *_buttonTitles;
}

@property (nonatomic, strong) ORKTaskViewController *taskViewController;

@end


@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.restorationIdentifier = @"main";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _savedTasks = [NSMutableDictionary new];
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
                            @"Consent",
                            @"Question Steps",
                            @"Active Tasks",
                            @"Miscellaneous",
                            ];
    _buttonTitles = @[ @[ // Consent
                           @"Consent",
                           @"Consent Review",
                           ],
                       @[ // Question Steps
                           @"Date Pickers",
                           @"Image Capture",
                           @"Image Choices",
                           @"Scale",
                           @"Mini Form",
                           @"Optional Form",
                           @"Selection Survey",
                           ],
                       @[ // Active Tasks
                           @"Active Step Task",
                           @"Audio Task",
                           @"Fitness Task",
                           @"GAIT Task",
                           @"Memory Game Task",
                           @"PSAT Task",
                           @"Reaction Time Task",
                           @"Timed Walk Task",
                           @"Tone Audiometry Task",
                           @"Tower Of Hanoi Task",
                           @"Two Finger Tapping Task",
                           ],
                       @[ // Miscellaneous
                           @"Custom Navigation Item",
                           @"Dynamic Task",
                           @"Interruptible Task",
                           @"Navigable Ordered Task",
                           @"Test Charts",
                           @"Toggle Tint Color",
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
    return _buttonSectionNames.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSArray *)_buttonTitles[section]).count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeader *sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionViewHeaderReuseIdentifier forIndexPath:indexPath];
    [sectionHeader configureHeaderWithTitle:_buttonSectionNames[indexPath.section]];
    return sectionHeader;
}

- (SEL)selectorFromButtonTitle:(NSString *)buttonTitle {
    // "THIS FOO baR title" is converted to the "thisFooBarTitleButtonTapped:" selector
    buttonTitle = buttonTitle.capitalizedString;
    NSMutableArray *titleTokens = [[buttonTitle componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    titleTokens[0] = ((NSString *)titleTokens[0]).lowercaseString;
    NSString *selectorString = [NSString stringWithFormat:@"%@ButtonTapped:", [titleTokens componentsJoinedByString:@""]];
    return NSSelectorFromString(selectorString);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ButtonCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellReuseIdentifier forIndexPath:indexPath];
    NSString *buttonTitle = _buttonTitles[indexPath.section][indexPath.row];
    SEL buttonSelector = [self selectorFromButtonTitle:buttonTitle];
    [buttonCell configureButtonWithTitle:buttonTitle target:self selector:buttonSelector];
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
    } else if ([identifier isEqualToString:AudioTaskIdentifier]) {
        id<ORKTask> task = [ORKOrderedTask audioTaskWithIdentifier:AudioTaskIdentifier
                                            intendedUseDescription:nil
                                                 speechInstruction:nil
                                            shortSpeechInstruction:nil
                                                          duration:10
                                                 recordingSettings:nil
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
                                                          maxTests:5
                                            maxConsecutiveFailures:3
                                                 customTargetImage:nil
                                            customTargetPluralName:nil
                                                   requireReversal:NO
                                                           options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:DynamicTaskIdentifier]) {
        return [DynamicTask new];
    } else if ([identifier isEqualToString:ScreeningTaskIdentifier]) {
        return [self makeScreeningTask];
    } else if ([identifier isEqualToString:ScalesTaskIdentifier]) {
        return [self makeScalesTask];
    } else if ([identifier isEqualToString:ImageChoicesTaskIdentifier]) {
        return [self makeImageChoicesTask];
    } else if ([identifier isEqualToString:ImageCaptureTaskIdentifier]) {
        return [self makeImageCaptureTask];
    } else if ([identifier isEqualToString:TwoFingerTapTaskIdentifier]) {
        return [ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:TwoFingerTapTaskIdentifier
                                                   intendedUseDescription:nil
                                                                 duration:20.0
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
    } else if ([identifier isEqualToString:TimedWalkTaskIdentifier]) {
        return [ORKOrderedTask timedWalkTaskWithIdentifier:TimedWalkTaskIdentifier
                                    intendedUseDescription:nil
                                          distanceInMeters:100
                                                 timeLimit:180
                                                   options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:PSATTaskIdentifier]) {
        return [ORKOrderedTask PSATTaskWithIdentifier:PSATTaskIdentifier
                               intendedUseDescription:nil
                                     presentationMode:(ORKPSATPresentationModeAuditory | ORKPSATPresentationModeVisual)
                                interStimulusInterval:3.0
                                     stimulusDuration:1.0
                                         seriesLength:60
                                              options:ORKPredefinedTaskOptionNone];
    } else if ([identifier isEqualToString:StepNavigationTaskIdentifier]) {
        return [self makeNavigableOrderedTask];
    } else if ([identifier isEqualToString:CustomNavigationItemTaskIdentifier]) {
        return [self makeCustomNavigationItemTask];
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
     
     We also attempt to restore the task when data for an archived task is found. Task restoration
     is not always possible nor desirable. Some objects implementing the ORKTask
     protocol can chose not to adopt NSSecureCoding (such as this project's DynamicTask).
     Task archival and restoration is recommended for ORKNavigableOrderedTask, since
     that preserves the navigation stack (which allows you to navigate steps backwards).
     
     Since unarchiving can throw an exception, in a real application we would
     need to attempt to catch that exception here.
     */

    id<ORKTask> task = nil;
    NSData *taskData = _savedTasks[identifier];
    if (taskData)
    {
        /*
         We assume any restored task is of the ORKNavigableOrderedTask since that's the only kind
         we're archiving in this example. You have to make sure your are unarchiving a task of the proper class.
         */
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:taskData];
        task = [unarchiver decodeObjectOfClass:[ORKNavigableOrderedTask class] forKey:NSKeyedArchiveRootObjectKey];
    } else {
        /*
         No task was previously stored
         */
        task = [self makeTaskWithIdentifier:identifier];
    }
    
    if (_savedViewControllers[identifier])
    {
        NSData *data = _savedViewControllers[identifier];
        self.taskViewController = [[ORKTaskViewController alloc] initWithTask:task restorationData:data delegate:self];
    } else {
        // No saved data, just create the task and the corresponding task view controller.
        self.taskViewController = [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:[NSUUID UUID]];
    }
    
    [self beginTask];
}

/*
 Actually presents the task view controller.
 */
- (void)beginTask {
    id<ORKTask> task = self.taskViewController.task;
    self.taskViewController.delegate = self;
    
    if (_taskViewController.outputDirectory == nil) {
        // Sets an output directory in Documents, using the `taskRunUUID` in the path.
        NSURL *documents =  [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *outputDir = [documents URLByAppendingPathComponent:self.taskViewController.taskRunUUID.UUIDString];
        [[NSFileManager defaultManager] createDirectoryAtURL:outputDir withIntermediateDirectories:YES attributes:nil error:nil];
        self.taskViewController.outputDirectory = outputDir;
    }
    
    /*
     For the dynamic task, we remember the last result and use it as a source
     of default values for any optional questions.
     */
    if ([task isKindOfClass:[DynamicTask class]])
    {
        self.taskViewController.defaultResultSource = _lastRouteResult;
    }
    
    /*
     We set a restoration identifier so that UI state restoration is enabled
     for the task view controller. We don't need to do anything else to prepare
     for state restoration of a ResearchKit framework task VC.
     */
    _taskViewController.restorationIdentifier = [task identifier];
    
    if ([[task identifier] isEqualToString:CustomNavigationItemTaskIdentifier]) {
        _taskViewController.showsProgressInNavigationBar = NO;
    }
    
    [self presentViewController:_taskViewController animated:YES completion:nil];
}

#pragma mark - Date picking

/*
 This task presents several questions which exercise functionality based on
 `UIDatePicker`.
 */
- (ORKOrderedTask *)makeDatePickingTask {
    NSMutableArray *steps = [NSMutableArray new];
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Date Survey";
        step.detailText = @"date pickers";
        [steps addObject:step];
    }

    /*
     A time interval question with no default set.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeInterval_001"
                                                                      title:@"How long did it take to fall asleep last night?"
                                                                     answer:[ORKAnswerFormat timeIntervalAnswerFormat]];
        [steps addObject:step];
    }
    
    
    /*
     A time interval question specifying a default and a step size.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeInterval_default_002"
                                                                      title:@"How long did it take to fall asleep last night?"
                                                                     answer:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:5]];
        [steps addObject:step];
    }
    
    /*
     A date answer format question, specifying a specific calendar.
     If no calendar were specified, the user's preferred calendar would be used.
     */
    {
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:nil minimumDate:nil maximumDate:nil calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierHebrew]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_date_001"
                                                                      title:@"When is your birthday?"
                                                                     answer:dateAnswer];
        [steps addObject:step];
    }
    
    /*
     A date question with a minimum, maximum, and default.
     Also specifically requires the Gregorian calendar.
     */
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKDateAnswerFormat *dateAnswer = [ORKDateAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                   minimumDate:minDate
                                                                                   maximumDate:maxDate
                                                                                      calendar: [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_date_default_002"
                                                                      title:@"What day are you available?"
                                                                     answer:dateAnswer];
        [steps addObject:step];
    }
    
    /*
     A time of day question with no default.
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_001"
                                                                 title:@"What time do you get up?"
                                                                   answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormat]];
        [steps addObject:step];
    }
    
    /*
     A time of day question with a default of 8:15 AM.
     */
    {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.hour = 8;
        dateComponents.minute = 15;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_timeOfDay_default_001"
                                                                      title:@"What time do you get up?"
                                                                     answer:[ORKTimeOfDayAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:dateComponents]];
        [steps addObject:step];
    }
    
    /*
     A date-time question with default parameters (no min, no max, default to now).
     */
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_dateTime_001"
                                                                      title:@"When is your next meeting?"
                                                                     answer:[ORKDateAnswerFormat dateTimeAnswerFormat]];
        [steps addObject:step];
    }
    
    /*
     A date-time question with specified min, max, default date, and calendar.
     */
    {
        NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:8 toDate:[NSDate date] options:(NSCalendarOptions)0];
        NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:12 toDate:[NSDate date] options:(NSCalendarOptions)0];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_dateTime_default_002"
                                                                      title:@"When is your next meeting?"
                                                                     answer:[ORKDateAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate minimumDate:minDate  maximumDate:maxDate calendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]]];
        [steps addObject:step];
        
    }
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:DatePickingTaskIdentifier steps:steps];
    return task;
}

- (IBAction)datePickersButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:DatePickingTaskIdentifier];
}

#pragma mark - Selection survey

/*
 The selection survey task is just a collection of various styles of survey questions.
 */
- (ORKOrderedTask *)makeSelectionSurveyTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Selection Survey";
        [steps addObject:step];
    }
    
    {
        /*
         A numeric question requiring integer answers in a fixed range, with no default.
         */
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(0);
        format.maximum = @(199);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001"
                                                                      title:@"How old are you?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A boolean question.
         */
        ORKBooleanAnswerFormat *format = [ORKBooleanAnswerFormat new];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_001b"
                                                                      title:@"Do you consent to a background check?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A single-choice question presented in the tableview format.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Less than seven"
                                                                             value:@(7)],
                                                     [ORKTextChoice choiceWithText:@"Between seven and eight"
                                                                             value:@(8)],
                                                     [ORKTextChoice choiceWithText:@"More than eight"
                                                                             value:@(9)]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_003"
                                                                      title:@"How many hours did you sleep last night?"
                                                                     answer:answerFormat];
        
        step.optional = NO;
        [steps addObject:step];
    }
    
    {
        /*
         A multiple-choice question presented in the tableview format.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Cough"
                                                                             value:@"cough"],
                                                     [ORKTextChoice choiceWithText:@"Fever"
                                                                             value:@"fever"],
                                                     [ORKTextChoice choiceWithText:@"Headaches"
                                                                             value:@"headache"],
                                                     [ORKTextChoice choiceWithText:@"None of the above"
                                                                        detailText:nil
                                                                             value:@"none"
                                                                          exclusive:YES]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_004a"
                                                                      title:@"Which symptoms do you have?"
                                                                     answer:answerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         A multiple-choice question with text choices that have detail text.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
            @[
              [ORKTextChoice choiceWithText:@"Cough"
                                 detailText:@"A cough and/or sore throat"
                                      value:@"cough"
                                  exclusive:NO],
              [ORKTextChoice choiceWithText:@"Fever"
                                 detailText:@"A 100F or higher fever or feeling feverish"
                                      value:@"fever"
                                  exclusive:NO],
              [ORKTextChoice choiceWithText:@"Headaches"
                                 detailText:@"Headaches and/or body aches"
                                      value:@"headache"
                                  exclusive:NO]
              ]];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_004"
                                                                      title:@"Which symptoms do you have?"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    {
        /*
         A text question with the default multiple-line text entry.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005"
                                                                      title:@"How did you feel last night?"
                                                                     answer:[ORKAnswerFormat textAnswerFormat]];
        [steps addObject:step];
    }
    
    {
        /*
         A text question with single-line text entry, with autocapitalization on
         for words, and autocorrection, and spellchecking turned off.
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormat];
        format.multipleLines = NO;
        format.autocapitalizationType = UITextAutocapitalizationTypeWords;
        format.autocorrectionType = UITextAutocorrectionTypeNo;
        format.spellCheckingType = UITextSpellCheckingTypeNo;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005a"
                                                                      title:@"What is your name?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A text question with a length limit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005b"
                                                                      title:@"How did you feel last night?"
                                                                     answer:[ORKTextAnswerFormat textAnswerFormatWithMaximumLength:20]];
        [steps addObject:step];
    }
    
    
    {
        /*
         A text question with single-line text entry and a URL keyboard.
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormat];
        format.multipleLines = NO;
        format.keyboardType = UIKeyboardTypeURL;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005c"
                                                                      title:@"What is your website?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         An email question with single-line text entry.
         */
        ORKEmailAnswerFormat *format = [ORKAnswerFormat emailAnswerFormat];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005d"
                                                                      title:@"What is your email?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A text question demos secureTextEntry feature
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:10];
        format.secureTextEntry = YES;
        format.multipleLines = NO;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005sec"
                                                                      title:@"What is your passcode?"
                                                                     answer:format];
        step.placeholder = @"Tap your passcode here";
        [steps addObject:step];
    }
    
    {
        /*
         A text question with single-line text entry and a length limit.
         */
        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:20];
        format.multipleLines = NO;
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_005e"
                                                                      title:@"What is your name?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        /*
         A single-select value-picker question. Rather than seeing the items in a tableview,
         the user sees them in a picker wheel. This is suitable where the list
         of items can be long, and the text describing the options can be kept short.
         */
        ORKValuePickerAnswerFormat *answerFormat = [ORKAnswerFormat valuePickerAnswerFormatWithTextChoices:
                                                    @[
                                                      [ORKTextChoice choiceWithText:@"Cough"
                                                                              value:@"cough"],
                                                      [ORKTextChoice choiceWithText:@"Fever"
                                                                              value:@"fever"],
                                                      [ORKTextChoice choiceWithText:@"Headaches"
                                                                              value:@"headache"]
                                                      ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_081"
                                                                      title:@"Select a symptom"
                                                                     answer:answerFormat];
        
        [steps addObject:step];
    }
    
    {
        /*
         A continuous slider question.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_010"
                                                                      title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue:10 minimumValue:1 defaultValue:NSIntegerMax maximumFractionDigits:1]];
        [steps addObject:step];
    }
    
    {
        /*
         The same as the previous question, but now using a discrete slider.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_010a"
                                                                      title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                     answer:[ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                                                  minimumValue:1
                                                                                                                  defaultValue:NSIntegerMax
                                                                                                                          step:1
                                                                                                                      vertical:NO
                                                                                                       maximumValueDescription:@"High value"
                                                                                                       minimumValueDescription:@"Low value"]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for gender.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_biologicalSex"
                                                                      title:@"What is your gender"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for blood type.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_bloodType"
                                                                      title:@"What is your blood type?"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for date of birth.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_dob"
                                                                      title:@"What is your date of birth?"
                                                                     answer:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
        [steps addObject:step];
    }
    
    {
        /*
         A HealthKit answer format question for weight.
         The default value is read from HealthKit when the step is being presented,
         but the user's answer is not written back to HealthKit.
         */
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"fqid_health_weight"
                                                                      title:@"How much do you weigh?"
                                                                     answer:[ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                                                                          unit:nil
                                                                                                                                         style:ORKNumericAnswerStyleDecimal]];
        [steps addObject:step];
    }
    
    {
        /*
         A multiple choice question where the items are mis-formatted.
         This question is used for verifying correct layout of the table view
         cells when the content is mixed or very long.
         */
        ORKTextChoiceAnswerFormat *answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleMultipleChoice textChoices:
                                                   @[
                                                     [ORKTextChoice choiceWithText:@"Cough, A cough and/or sore throat, A cough and/or sore throat"
                                                                        detailText:@"A cough and/or sore throat, A cough and/or sore throat, A cough and/or sore throat"
                                                                             value:@"cough"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@"Fever, A 100F or higher fever or feeling feverish"
                                                                        detailText:nil
                                                                             value:@"fever"
                                                                         exclusive:NO],
                                                     [ORKTextChoice choiceWithText:@""
                                                                        detailText:@"Headaches, Headaches and/or body aches"
                                                                             value:@"headache"
                                                                         exclusive:NO]
                                                     ]];
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"qid_000a"
                                                                      title:@"(Misused) Which symptoms do you have?"
                                                                     answer:answerFormat];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:SelectionSurveyTaskIdentifier steps:steps];
    return task;
}

- (IBAction)selectionSurveyButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:SelectionSurveyTaskIdentifier];
}

#pragma mark - Active step task

/*
 This task demonstrates direct use of active steps, which is not particularly
 well-supported by the framework. The intended use of `ORKActiveStep` is as a
 base class for creating new types of active step, with matching view
 controllers appropriate to the particular task that uses them.
 
 Nonetheless, this functions as a test-bed for basic active task functonality.
 */
- (ORKOrderedTask *)makeActiveStepTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        /*
         Example of a fully-fledged instruction step.
         The text of this step is not appropriate to the rest of the task, but
         is helpful for verifying layout.
         */
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"iid_001"];
        step.title = @"Demo Study";
        step.text = @"This 12-step walkthrough will explain the study and the impact it will have on your life.";
        step.detailText = @"You must complete the walkthough to participate in the study.";
        [steps addObject:step];
    }
    
    {
        /*
         Audio-recording active step, configured directly using `ORKActiveStep`.
         
         Not a recommended way of doing audio recording with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001d"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording audio";
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc] initWithIdentifier:@"aid_001d.audio" recorderSettings:@{}]];
        step.shouldUseNextAsSkipButton = YES;
        [steps addObject:step];
    }
    
    {
        /*
         Audio-recording active step with lossless audio, configured directly
         using `ORKActiveStep`.
         
         Not a recommended way of doing audio recording with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001e"];
        step.title = @"Audio";
        step.stepDuration = 10.0;
        step.text = @"An active test recording lossless audio";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKAudioRecorderConfiguration alloc]
                                         initWithIdentifier:@"aid_001e.audio" recorderSettings:@{AVFormatIDKey : @(kAudioFormatAppleLossless),
                                                                                                 AVNumberOfChannelsKey : @(2),
                                                                                                 AVSampleRateKey: @(44100.0)
                                                                                                 }]];
        [steps addObject:step];
    }
    
    {
        /*
         Touch recorder active step. This should record touches on the primary
         view for a 30 second period.
         
         Not a recommended way of collecting touch data with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001a"];
        step.title = @"Touch";
        step.text = @"An active test, touch collection";
        step.shouldStartTimerAutomatically = NO;
        step.stepDuration = 30.0;
        step.spokenInstruction = @"An active test, touch collection";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKTouchRecorderConfiguration alloc] initWithIdentifier:@"aid_001a.touch"]];
        [steps addObject:step];
    }
        
    {
        /*
         Test for device motion recorder directly on an active step.
         
         Not a recommended way of customizing active steps with the ResearchKit framework.
         */
        ORKActiveStep *step = [[ORKActiveStep alloc] initWithIdentifier:@"aid_001c"];
        step.title = @"Motion";
        step.text = @"An active test collecting device motion data";
        step.shouldUseNextAsSkipButton = YES;
        step.recorderConfigurations = @[[[ORKDeviceMotionRecorderConfiguration alloc] initWithIdentifier:@"aid_001c.deviceMotion" frequency:100.0]];
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ActiveStepTaskIdentifier steps:steps];
    return task;
}

- (IBAction)activeStepTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ActiveStepTaskIdentifier];
}

#pragma mark - Consent review task

/*
 The consent review task is used to quickly verify the layout of the consent
 sharing step and the consent review step.
 
 In a real consent process, you would substitute the text of your consent document
 for the various placeholders.
 */
- (ORKOrderedTask *)makeConsentReviewTask {
    /*
     Tests layout of the consent sharing step.
     
     This step is used when you want to obtain permission to share the data
     collected with other researchers for uses beyond the present study.
     */
    ORKConsentSharingStep *sharingStep =
    [[ORKConsentSharingStep alloc] initWithIdentifier:@"consent_sharing"
                         investigatorShortDescription:@"MyInstitution"
                          investigatorLongDescription:@"MyInstitution and its partners"
                        localizedLearnMoreHTMLContent:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."];
    
    /*
     Tests layout of the consent review step.
     
     In the consent review step, the user reviews the consent document and
     optionally enters their name and/or scribbles a signature.
     */
    ORKConsentDocument *doc = [self buildConsentDocument];
    ORKConsentSignature *participantSig = doc.signatures[0];
    [participantSig setSignatureDateFormatString:@"yyyy-MM-dd 'at' HH:mm"];
    _currentDocument = [doc copy];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:participantSig inDocument:doc];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ConsentReviewTaskIdentifier steps:@[sharingStep,reviewStep]];
    return task;
}

- (IBAction)consentReviewButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ConsentReviewTaskIdentifier];
}

#pragma mark - Consent task
/*
 This consent task demonstrates visual consent, followed by a consent review step.
 
 In a real consent process, you would substitute the text of your consent document
 for the various placeholders.
 */
- (ORKOrderedTask *)makeConsentTask {
    /*
     Most of the configuration of what pages will appear in the visual consent step,
     and what content will be displayed in the consent review step, it in the
     consent document itself.
     */
    ORKConsentDocument *consentDocument = [self buildConsentDocument];
    _currentDocument = [consentDocument copy];
    
    ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual_consent" document:consentDocument];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:consentDocument.signatures[0] inDocument:consentDocument];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ConsentTaskIdentifier steps:@[step,reviewStep]];
    
    return task;
}

- (IBAction)consentButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ConsentTaskIdentifier];
}

#pragma mark - Mini form task

/*
 The mini form task is used to test survey forms functionality (`ORKFormStep`).
 */
- (id<ORKTask>)makeMiniFormTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"mini_form_001"];
        step.title = @"Mini Form";
        [steps addObject:step];
    }
    
    {
        /*
         A short form for testing behavior when loading multiple HealthKit
         default values on the same form.
         */
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_000" title:@"Mini Form" text:@"Mini form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight1"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:ORKNumericAnswerStyleDecimal]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight2"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                             unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                            style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight3"
                                                                   text:@"Weight"
                                                           answerFormat:
                                 [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                               unit:[HKUnit unitFromMassFormatterUnit:NSMassFormatterUnitPound]
                                                                                              style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Input your body weight here. Really long text.";
            [items addObject:item];
        }
        
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight4"
                                                                   text:@"Weight"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input your body weight here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        /*
         A long "kitchen-sink" form with all the different types of supported
         answer formats.
         */
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Mini Form" text:@"Mini form groups multi-entry in one page"];
        NSMutableArray *items = [NSMutableArray new];
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_biologicalSex" text:@"Gender" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Pre1"];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Basic Information"];
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_bloodType" text:@"Blood Type" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]]];
            item.placeholder = @"Choose a type";
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_dob" text:@"Date of Birth" answerFormat:[ORKHealthKitCharacteristicTypeAnswerFormat answerFormatWithCharacteristicType:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]]];
            item.placeholder = @"DOB";
            [items addObject:item];
        }
        
        {
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_health_weight"
                                                                 text:@"Weight"
                                                         answerFormat:
                                [ORKHealthKitQuantityTypeAnswerFormat answerFormatWithQuantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]
                                                                                    unit:nil
                                                                                   style:ORKNumericAnswerStyleDecimal]];
            item.placeholder = @"Add weight";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_001" text:@"Have headache?" answerFormat:[ORKBooleanAnswerFormat new]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_002" text:@"Which fruit do you like most? Please pick one from below."
                                                         answerFormat:[ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice textChoices:@[@"Apple", @"Orange", @"Banana"]
                                                                                                              ]];
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_003" text:@"Message"
                                                         answerFormat:[ORKAnswerFormat textAnswerFormat]];
            item.placeholder = @"Your message";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004a" text:@"BP Diastolic"
                                                         answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_004b" text:@"BP Systolic"
                                                         answerFormat:[ORKAnswerFormat integerAnswerFormatWithUnit:@"mm Hg"]];
            item.placeholder = @"Enter value";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_005" text:@"Email"
                                                           answerFormat:[ORKAnswerFormat emailAnswerFormat]];
            item.placeholder = @"Enter Email";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_006" text:@"Message"
                                                           answerFormat:[ORKAnswerFormat textAnswerFormatWithMaximumLength:20]];
            item.placeholder = @"Your message (limit 20 characters).";
            [items addObject:item];
        }
        
        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
            format.secureTextEntry = YES;
            format.multipleLines = NO;
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_007" text:@"Passcode"
                                                           answerFormat:format];
            item.placeholder = @"Enter Passcode";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_001" text:@"Birthdate"
                                                         answerFormat:[ORKAnswerFormat dateAnswerFormat]];
            item.placeholder = @"Pick a date";
            [items addObject:item];
        }
        
        {
            
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-30 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:-150 toDate:[NSDate date] options:(NSCalendarOptions)0];

            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_date_002" text:@"Birthdate"
                                                         answerFormat:[ORKAnswerFormat dateAnswerFormatWithDefaultDate:defaultDate
                                                                                                        minimumDate:minDate
                                                                                                        maximumDate:[NSDate date]
                                                                                                           calendar:nil]];
            item.placeholder = @"Pick a date (with default)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_001" text:@"Today sunset time?"
                                                         answerFormat:[ORKAnswerFormat timeOfDayAnswerFormat]];
            item.placeholder = @"No default time";
            [items addObject:item];
        }
        
        {
            NSDateComponents *defaultDC = [[NSDateComponents alloc] init];
            defaultDC.hour = 14;
            defaultDC.minute = 23;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeOfDay_002" text:@"Today sunset time?"
                                                         answerFormat:[ORKAnswerFormat timeOfDayAnswerFormatWithDefaultComponents:defaultDC]];
            item.placeholder = @"Default time 14:23";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_001" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[ORKAnswerFormat dateTimeAnswerFormat]];
            
            item.placeholder = @"No default date and range";
            [items addObject:item];
        }
        
        {
            
            NSDate *defaultDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:3 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *minDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:0 toDate:[NSDate date] options:(NSCalendarOptions)0];
            NSDate *maxDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:10 toDate:[NSDate date] options:(NSCalendarOptions)0];
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_dateTime_002" text:@"Next eclipse visible in Cupertino?"
                                                         answerFormat:[ORKAnswerFormat dateTimeAnswerFormatWithDefaultDate:defaultDate
                                                                                                            minimumDate:minDate
                                                                                                            maximumDate:maxDate
                                                                                                               calendar:nil]];
            
            item.placeholder = @"Default date in 3 days and range(0, 10)";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_001" text:@"Wake up interval"
                                                           answerFormat:[ORKAnswerFormat timeIntervalAnswerFormat]];
            item.placeholder = @"No default Interval and step size";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_timeInterval_002" text:@"Wake up interval"
                                                           answerFormat:[ORKAnswerFormat timeIntervalAnswerFormatWithDefaultInterval:300 step:3]];
            
            item.placeholder = @"Default Interval 300 and step size 3";
            [items addObject:item];
        }
        
        {
            /*
             Testbed for image choice.
             
             In a real application, you would use real images rather than square
             colored boxes.
             */
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:CGSizeMake(360, 360) border:YES]
                                                                       text:@"Yellow" value:@"yellow"];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:@"fqid_009_3" text:@"What is your favorite color?"
                                                          answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3]]];
            [items addObject:item3];
        }
        
        {
            // Discrete scale
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_001" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:NSIntegerMax step:10]];
            [items addObject:item];
        }
        
        {
            // Discrete scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_002" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:20 step:10]];
            [items addObject:item];
        }
        
        {
            // Continuous scale
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_003" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:NSIntegerMax maximumFractionDigits:2]];
            [items addObject:item];
        }
        
        {
            // Continuous scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_004" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:87.34 maximumFractionDigits:2]];
            [items addObject:item];
        }
        
        {
            // Vertical Discrete scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_005" text:@"Pick an integer" answerFormat:[[ORKScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:90 step:10 vertical:YES]];
            [items addObject:item];
        }
        
        {
            // Vertical Continuous scale, with default value
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_006" text:@"Pick a decimal" answerFormat:[[ORKContinuousScaleAnswerFormat alloc] initWithMaximumValue: 100 minimumValue: 0 defaultValue:12.75 maximumFractionDigits:2 vertical:YES]];
            [items addObject:item];
        }
        
        {
            ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
            ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
            ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
            ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
            ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
            
            NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
            
            ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                                   defaultIndex:NSIntegerMax
                                                                                                       vertical:NO];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_007"
                                                                   text:@"How are you feeling today?"
                                                           answerFormat:scaleAnswerFormat];
            [items addObject:item];
        }
        
        {
            ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
            ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
            ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
            ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
            ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
            
            NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
            
            ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                                   defaultIndex:NSIntegerMax
                                                                                                       vertical:YES];
            
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_scale_008"
                                                                   text:@"How are you feeling today?"
                                                           answerFormat:scaleAnswerFormat];
            [items addObject:item];
        }
        
        [step setFormItems:items];
        [steps addObject:step];
    }
    
    {
        
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_002" title:@"Required form step" text:nil];
        ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_001"
                                                               text:@"Value"
                                                       answerFormat:[ORKNumericAnswerFormat valuePickerAnswerFormatWithTextChoices:@[@"1", @"2", @"3"]]];
        item.placeholder = @"Pick a value";
        [step setFormItems:@[item]];
        step.optional = NO;
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"aid_001"];
        step.title = @"Thanks";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)miniFormButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:MiniFormTaskIdentifier];
}

#pragma mark - Mini form task

/*
 The optional form task is used to test form items' optional functionality (`ORKFormStep`, `ORKFormItem`).
 */
- (id<ORKTask>)makeOptionalFormTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_000" title:@"Optional Form Items" text:@"Optional form with no required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }

        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
            format.multipleLines = NO;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_001" title:@"Optional Form Items" text:@"Optional form with some required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }

        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }

        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }

    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_002" title:@"Optional Form Items" text:@"Optional form with all items required"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }

        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
    }

    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_003" title:@"Optional Form Items" text:@"Required form with no required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }

        {
            ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:6];
            format.multipleLines = NO;
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text"
                                                           answerFormat:format];
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }
    
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_004" title:@"Optional Form Items" text:@"Required form with some required items"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Optional"];
            [items addObject:item];
        }

        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }

        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input your text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }

    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:@"fid_005" title:@"Optional Form Items" text:@"Required form with all items required"];
        NSMutableArray *items = [NSMutableArray new];
        [steps addObject:step];
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithSectionTitle:@"Required"];
            [items addObject:item];
        }

        ORKTextAnswerFormat *format = [ORKAnswerFormat textAnswerFormatWithMaximumLength:12];
        format.multipleLines = NO;
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text1"
                                                                   text:@"Text A"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text2"
                                                                   text:@"Text B"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text3"
                                                                   text:@"Text C"
                                                           answerFormat:format];
            item.optional = NO;
            item.placeholder = @"Input any text here.";
            [items addObject:item];
        }
        
        {
            ORKFormItem *item = [[ORKFormItem alloc] initWithIdentifier:@"fqid_text4"
                                                                   text:@"Number"
                                                           answerFormat:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:nil]];
            item.optional = NO;
            item.placeholder = @"Input any number here.";
            [items addObject:item];
        }
        
        [step setFormItems:items];
        step.optional = NO;
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:MiniFormTaskIdentifier steps:steps];
    
    return task;
}

- (IBAction)optionalFormButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:OptionalFormTaskIdentifier];
}

#pragma mark - Active tasks

- (IBAction)fitnessTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:FitnessTaskIdentifier];
}

- (IBAction)gaitTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:GaitTaskIdentifier];
}

- (IBAction)memoryGameTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:MemoryTaskIdentifier];
}

- (IBAction)audioTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:AudioTaskIdentifier];
}

- (IBAction)toneAudiometryTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ToneAudiometryTaskIdentifier];
}

- (IBAction)twoFingerTappingTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:TwoFingerTapTaskIdentifier];
}

- (IBAction)reactionTimeTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ReactionTimeTaskIdentifier];
}

- (IBAction)towerOfHanoiTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:TowerOfHanoiTaskIdentifier];
}

- (IBAction)timedWalkTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:TimedWalkTaskIdentifier];
}

- (IBAction)psatTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:PSATTaskIdentifier];
}

#pragma mark - Dynamic task

/*
 See the `DynamicTask` class for a definition of this task.
 */
- (IBAction)dynamicTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:DynamicTaskIdentifier];
}

#pragma mark - Screening task

/*
 This demonstrates a task where if the user enters a value that is too low for
 the first question (say, under 18), the task view controller delegate API can
 be used to reject the answer and prevent forward navigation.
 
 See the implementation of the task view controller delegate methods for specific
 handling of this task.
 */
- (id<ORKTask>)makeScreeningTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    {
        ORKNumericAnswerFormat *format = [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
        format.minimum = @(5);
        format.maximum = @(90);
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_001"
                                                                      title:@"How old are you?"
                                                                     answer:format];
        [steps addObject:step];
    }
    
    {
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"itid_002"
                                                                      title:@"How much did you pay for your car?"
                                                                     answer:[ORKNumericAnswerFormat decimalAnswerFormatWithUnit:@"USD"]];
        [steps addObject:step];
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"itid_003"];
        step.title = @"Thank you for completing this task.";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ScreeningTaskIdentifier steps:steps];
    return task;
}

- (IBAction)interruptibleTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ScreeningTaskIdentifier];
}

#pragma mark - Scales task

/*
 This task is used to test various uses of discrete and continuous, horizontal and vertical valued sliders.
 */
- (id<ORKTask>)makeScalesTask {

    NSMutableArray *steps = [NSMutableArray array];
    
    {
        /*
         Continuous scale with two decimal places.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:NSIntegerMax
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:NO
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_01"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, no default.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:300
                                                                                         minimumValue:100
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:50
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_02"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, with a default.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:5
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_03"
                                                                    title:@"On a scale of 1 to 10, how much pain do you feel?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale, with a default that is not on a step boundary.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:300
                                                                                         minimumValue:100
                                                                                         defaultValue:174
                                                                                                 step:50
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_04"
                                                                    title:@"How much money do you need?"
                                                                   answer:scaleAnswerFormat];
        [steps addObject:step];
    }

    {
        /*
         Vertical continuous scale with three decimal places and a default.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:8.725
                                                                                                    maximumFractionDigits:3
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_05"
                                                                      title:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }

    {
        /*
         Vertical discrete scale, with a default on a step boundary.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:5
                                                                                                 step:1
                                                                                             vertical:YES
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_06"
                                                                      title:@"How was your mood yesterday?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical discrete scale, with min and max labels.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:YES
                                                                              maximumValueDescription:@"A lot"
                                                                              minimumValueDescription:@"Not at all"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_07"
                                                                      title:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale, with min and max labels.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:99
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:@"High value"
                                                                                                  minimumValueDescription:@"Low value"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_08"
                                                                      title:@"How would you measure your mood improvement?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical discrete scale, with min and max labels.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:@"A lot"
                                                                              minimumValueDescription:@"Not at all"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_09"
                                                                      title:@"On a scale of 1 to 10, what is your mood?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Vertical continuous scale, with min and max labels.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:99
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:NO
                                                                                                  maximumValueDescription:@"High value"
                                                                                                  minimumValueDescription:@"Low value"];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_10"
                                                                      title:@"How would you measure your mood improvement?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }

    {
        /*
         Vertical continuous scale with three decimal places, a default, and a format style.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:1.0
                                                                                                             minimumValue:0.0
                                                                                                             defaultValue:0.8725
                                                                                                    maximumFractionDigits:0
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:nil
                                                                                                  minimumValueDescription:nil];

        scaleAnswerFormat.numberStyle = ORKNumberFormattingStylePercent;
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_11"
                                                                      title:@"How much has your mood improved?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Continuous scale with images.
         */
        ORKContinuousScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat continuousScaleAnswerFormatWithMaximumValue:10
                                                                                                             minimumValue:1
                                                                                                             defaultValue:NSIntegerMax
                                                                                                    maximumFractionDigits:2
                                                                                                                 vertical:YES
                                                                                                  maximumValueDescription:@"Hot"
                                                                                                  minimumValueDescription:@"Warm"];
        
        scaleAnswerFormat.minimumImage = [self imageWithColor:[UIColor yellowColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.maximumImage = [self imageWithColor:[UIColor redColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.minimumImage.accessibilityHint = @"A yellow colored square to represent warmness.";
        scaleAnswerFormat.maximumImage.accessibilityHint = @"A red colored square to represent hot.";
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_12"
                                                                      title:@"On a scale of 1 to 10, how warm do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        /*
         Discrete scale with images.
         */
        ORKScaleAnswerFormat *scaleAnswerFormat =  [ORKAnswerFormat scaleAnswerFormatWithMaximumValue:10
                                                                                         minimumValue:1
                                                                                         defaultValue:NSIntegerMax
                                                                                                 step:1
                                                                                             vertical:NO
                                                                              maximumValueDescription:nil
                                                                              minimumValueDescription:nil];
        
        scaleAnswerFormat.minimumImage = [self imageWithColor:[UIColor yellowColor] size:CGSizeMake(30, 30) border:NO];
        scaleAnswerFormat.maximumImage = [self imageWithColor:[UIColor redColor] size:CGSizeMake(30, 30) border:NO];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_13"
                                                                      title:@"On a scale of 1 to 10, how warm do you feel?"
                                                                     answer:scaleAnswerFormat];
        [steps addObject:step];
    }
    
    {
        ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
        ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
        ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
        ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
        ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
        
        NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
        
        ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                               defaultIndex:NSIntegerMax
                                                                                                   vertical:NO];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_14"
                                                                      title:@"How are you feeling today?"
                                                                     answer:scaleAnswerFormat];
        
        [steps addObject:step];
    }
    
    {
        ORKTextChoice *textChoice1 = [ORKTextChoice choiceWithText:@"Poor" value:@(1)];
        ORKTextChoice *textChoice2 = [ORKTextChoice choiceWithText:@"Fair" value:@(2)];
        ORKTextChoice *textChoice3 = [ORKTextChoice choiceWithText:@"Good" value:@(3)];
        ORKTextChoice *textChoice4 = [ORKTextChoice choiceWithText:@"Above Average" value:@(4)];
        ORKTextChoice *textChoice5 = [ORKTextChoice choiceWithText:@"Excellent" value:@(5)];
        
        NSArray *textChoices = @[textChoice1, textChoice2, textChoice3, textChoice4, textChoice5];
        
        ORKTextScaleAnswerFormat *scaleAnswerFormat = [ORKAnswerFormat textScaleAnswerFormatWithTextChoices:textChoices
                                                                                               defaultIndex:NSIntegerMax
                                                                                                   vertical:YES];
        
        ORKQuestionStep *step = [ORKQuestionStep questionStepWithIdentifier:@"scale_15"
                                                                      title:@"How are you feeling today?"
                                                                     answer:scaleAnswerFormat];
        
        [steps addObject:step];
    }

    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ScalesTaskIdentifier steps:steps];
    return task;
    
}

- (IBAction)scaleButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ScalesTaskIdentifier];
}

#pragma mark - Image choice task

/*
 Tests various uses of image choices.
 
 All these tests use square colored images to test layout correctness. In a real
 application you would use images to convey an image scale.
 
 Tests image choices both in form items, and in question steps.
 */
- (id<ORKTask>)makeImageChoicesTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    for (NSValue *ratio in @[[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(2.0, 1.0)], [NSValue valueWithCGPoint:CGPointMake(1.0, 2.0)]])
    {
        ORKFormStep *step = [[ORKFormStep alloc] initWithIdentifier:[NSString stringWithFormat:@"form_step_%@",NSStringFromCGPoint(ratio.CGPointValue)] title:@"Image Choices Form" text:@"Testing image choices in a form layout."];
        
        NSMutableArray *items = [NSMutableArray new];
        
        for (NSNumber *dimension in @[@(360), @(60)])
        {
            CGSize size1 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.x, dimension.floatValue * ratio.CGPointValue.y);
            CGSize size2 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.y, dimension.floatValue * ratio.CGPointValue.x);
            
            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                       text:@"Red" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                       text:nil value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                       text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                       text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                       text:nil value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                       text:@"Cyan" value:@"cyanColor"];
            
            
            ORKFormItem *item1 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_1" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color."
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [items addObject:item1];
            
            ORKFormItem *item2 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_2" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color."
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [items addObject:item2];
            
            ORKFormItem *item3 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_3" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color."
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [items addObject:item3];
            
            ORKFormItem *item6 = [[ORKFormItem alloc] initWithIdentifier:[@"fqid_009_6" stringByAppendingFormat:@"%@",dimension] text:@"Pick a color."
                                                            answerFormat:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6] ]];
            [items addObject:item6];
        }
        
        [step setFormItems:items];
        [steps addObject:step];
        
        for (NSNumber *dimension in @[@(360), @(60), @(20)]) {
            CGSize size1 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.x, dimension.floatValue * ratio.CGPointValue.y);
            CGSize size2 = CGSizeMake(dimension.floatValue * ratio.CGPointValue.y, dimension.floatValue * ratio.CGPointValue.x);

            ORKImageChoice *option1 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor redColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor redColor] size:size1 border:YES]
                                                                       text:@"Red\nRed\nRed\nRed" value:@"red"];
            ORKImageChoice *option2 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor orangeColor] size:size1 border:YES]
                                                                       text:@"Orange" value:@"orange"];
            ORKImageChoice *option3 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor yellowColor] size:size1 border:YES]
                                                                       text:@"Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow Yellow" value:@"yellow"];
            ORKImageChoice *option4 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor greenColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor greenColor] size:size2 border:YES]
                                                                       text:@"Green" value:@"green"];
            ORKImageChoice *option5 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor blueColor] size:size1 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor blueColor] size:size1 border:YES]
                                                                       text:@"Blue" value:@"blue"];
            ORKImageChoice *option6 = [ORKImageChoice choiceWithNormalImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:NO]
                                                              selectedImage:[self imageWithColor:[UIColor cyanColor] size:size2 border:YES]
                                                                       text:@"Cyan" value:@"cyanColor"];
            
            ORKQuestionStep *step1 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color1_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Pick a color."
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1] ]];
            [steps addObject:step1];
            
            ORKQuestionStep *step2 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color2_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Pick a color."
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2] ]];
            [steps addObject:step2];
            
            ORKQuestionStep *step3 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color3_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Pick a color."
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3] ]];
            [steps addObject:step3];
            
            ORKQuestionStep *step6 = [ORKQuestionStep questionStepWithIdentifier:[NSString stringWithFormat:@"qid_color6_%@_%@", NSStringFromCGPoint(ratio.CGPointValue), dimension]
                                                                           title:@"Pick a color."
                                                                          answer:[ORKAnswerFormat choiceAnswerFormatWithImageChoices:@[option1, option2, option3, option4, option5, option6]]];
            [steps addObject:step6];
        }
    }
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
        step.title = @"Image Choices End";
        [steps addObject:step];
    }
    
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ImageChoicesTaskIdentifier steps:steps];
    return task;
    
}

- (IBAction)imageChoicesButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ImageChoicesTaskIdentifier];
}

# pragma mark - Image Capture
- (id<ORKTask>)makeImageCaptureTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    /*
     If implementing an image capture task like this one, remember that people will
     take your instructions literally. So, be cautious. Make sure your template image
     is high contrast and very visible against a variety of backgrounds.
     */
     
    
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"begin"];
        step.title = @"Hands";
        step.image = [[UIImage imageNamed:@"hands_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"In this step we will capture images of both of your hands";
        [steps addObject:step];
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right1"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Let's start by capturing an image of your right hand";
        [steps addObject:step];
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"right2"];
        step.title = @"Right Hand";
        step.image = [[UIImage imageNamed:@"right_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your right hand with the on-screen outline and capture the image.  Be sure to place your hand over a contrasting background.  You can re-capture the image as many times as you need.";
        [steps addObject:step];
    }
    {
        ORKImageCaptureStep *step = [[ORKImageCaptureStep alloc] initWithIdentifier:@"right3"];
        step.templateImage = [UIImage imageNamed:@"right_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.accessibilityInstructions = @"Extend your right hand, palm side down, one foot in front of your device. Tap the Capture Image button, or two-finger double tap the preview to capture the image";
        step.accessibilityHint = @"Captures the image visible in the preview";
        [steps addObject:step];
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left1"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_solid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Now let's capture an image of your left hand";
        [steps addObject:step];
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"left2"];
        step.title = @"Left Hand";
        step.image = [[UIImage imageNamed:@"left_hand_outline"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        step.detailText = @"Align your left hand with the on-screen outline and capture the image.  Be sure to place your hand over a contrasting background.  You can re-capture the image as many times as you need.";
        [steps addObject:step];
    }
    {
        ORKImageCaptureStep *step = [[ORKImageCaptureStep alloc] initWithIdentifier:@"left3"];
        step.templateImage = [UIImage imageNamed:@"left_hand_outline_big"];
        step.templateImageInsets = UIEdgeInsetsMake(0.05, 0.05, 0.05, 0.05);
        step.accessibilityInstructions = @"Extend your left hand, palm side down, one foot in front of your device. Tap the Capture Image button, or two-finger double tap the preview to capture the image";
        step.accessibilityHint = @"Captures the image visible in the preview";
        [steps addObject:step];
    }
    {
        ORKInstructionStep *step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
        step.title = @"Complete";
        step.detailText = @"Hand image capture complete";
        [steps addObject:step];
    }
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ImageCaptureTaskIdentifier steps:steps];
    return task;
    
}
- (IBAction)imageCaptureButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:ImageCaptureTaskIdentifier];
}
- (IBAction)navigableOrderedTaskButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:StepNavigationTaskIdentifier];
}

- (IBAction)toggleTintColorButtonTapped:(id)sender {
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

#pragma mark - Navigable Ordered Task

- (id<ORKTask>)makeNavigableOrderedTask {
    NSMutableArray *steps = [NSMutableArray new];
    
    ORKAnswerFormat *answerFormat = nil;
    ORKStep *step = nil;
    NSArray *textChoices = nil;
    
    // Form step
    textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Good" value:@"good"],
      [ORKTextChoice choiceWithText:@"Bad" value:@"bad"]
      ];

    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    
    ORKFormItem *formItemFeeling = [[ORKFormItem alloc] initWithIdentifier:@"formFeeling" text:@"How do you feel" answerFormat:answerFormat];
    ORKFormItem *formItemMood = [[ORKFormItem alloc] initWithIdentifier:@"formMood" text:@"How is your mood" answerFormat:answerFormat];
    
    ORKFormStep *formStep = [[ORKFormStep alloc] initWithIdentifier:@"introForm"];
    formStep.optional = NO;
    formStep.formItems = @[ formItemFeeling, formItemMood ];
    [steps addObject:formStep];

    // Question steps
    textChoices =
    @[
      [ORKTextChoice choiceWithText:@"Headache" value:@"headache"],
      [ORKTextChoice choiceWithText:@"Dizziness" value:@"dizziness"],
      [ORKTextChoice choiceWithText:@"Nausea" value:@"nausea"]
      ];
    
    answerFormat = [ORKAnswerFormat choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                                                    textChoices:textChoices];
    step = [ORKQuestionStep questionStepWithIdentifier:@"symptom" title:@"Which is your most severe symptom?" answer:answerFormat];
    step.optional = NO;
    [steps addObject:step];

    answerFormat = [ORKAnswerFormat booleanAnswerFormat];
    step = [ORKQuestionStep questionStepWithIdentifier:@"severity" title:@"Does your symptom interfere with your daily life?" answer:answerFormat];
    step.optional = NO;
    [steps addObject:step];

    // Instruction steps
    step = [[ORKInstructionStep alloc] initWithIdentifier:@"blank"];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"severe_headache"];
    step.title = @"You have a severe headache";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"light_headache"];
    step.title = @"You have a light headache";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"other_symptom"];
    step.title = @"Your symptom is not a headache";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"survey_skipped"];
    step.title = @"Please come back to this survey when you don't feel good or your mood is low.";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"end"];
    step.title = @"You have finished the task";
    [steps addObject:step];

    step = [[ORKInstructionStep alloc] initWithIdentifier:@"blankB"];
    step.title = @"This step is intentionally left blank (you should not see it)";
    [steps addObject:step];

    ORKNavigableOrderedTask *task = [[ORKNavigableOrderedTask alloc] initWithIdentifier:StepNavigationTaskIdentifier
                                                                                  steps:steps];
    
    // Build navigation rules
    ORKPredicateStepNavigationRule *predicateRule = nil;
    ORKResultSelector *resultSelector = nil;
    
    // From the feel/mood form step, skip the survey if the user is feeling okay and has a good mood
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"introForm"
                                                                        resultIdentifier:@"formFeeling"];
    NSPredicate *predicateGoodFeeling = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector
                                                                                           expectedAnswerValue:@"good"];
    
    resultSelector = [ORKResultSelector selectorWithStepIdentifier:@"introForm"
                                                                        resultIdentifier:@"formMood"];
    NSPredicate *predicateGoodMood = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector
                                                                                        expectedAnswerValue:@"good"];
    NSPredicate *predicateGoodMoodAndFeeling = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateGoodFeeling, predicateGoodMood]];
    
    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicateGoodMoodAndFeeling ]
                                                          destinationStepIdentifiers:@[ @"survey_skipped" ] ];
    
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"introForm"];

    
    // From the "symptom" step, go to "other_symptom" is user didn't chose headache.
    // Otherwise, default to going to next step (the regular ORKOrderedTask order applies
    //  when the defaultStepIdentifier argument is omitted).
    
    // User chose headache at the symptom step
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'symptom' \
    //                     AND SUBQUERY($x.answer, $y, $y like 'headache').@count > 0).@count > 0"];
    resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"symptom"];
    NSPredicate *predicateHeadache = [ORKResultPredicate predicateForChoiceQuestionResultWithResultSelector:resultSelector
                                                                                        expectedAnswerValue:@"headache"];
    
    // User didn't chose headache at the symptom step
    NSPredicate *predicateNotHeadache = [NSCompoundPredicate notPredicateWithSubpredicate:predicateHeadache];

    predicateRule = [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicateNotHeadache ]
                                                          destinationStepIdentifiers:@[ @"other_symptom" ] ];
    
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"symptom"];

    
    // From the "severity" step, go to "severe_headache" or "light_headache" depending on the user answer
    
    // User chose YES at the severity step
    // Equivalent to:
    //      [NSPredicate predicateWithFormat:
    //          @"SUBQUERY(SELF, $x, $x.identifier like 'severity' AND $x.answer == YES).@count > 0"];
    resultSelector = [ORKResultSelector selectorWithResultIdentifier:@"severity"];
    NSPredicate *predicateSevereYes = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector
                                                                                               expectedAnswer:YES];
    
    // User chose NO at the severity step
    NSPredicate *predicateSevereNo = [ORKResultPredicate predicateForBooleanQuestionResultWithResultSelector:resultSelector
                                                                                              expectedAnswer:NO];

    NSPredicate *predicateSevereHeadache = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereYes]];

    NSPredicate *predicateLightHeadache = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateHeadache, predicateSevereNo]];
    
    predicateRule =
    [[ORKPredicateStepNavigationRule alloc] initWithResultPredicates:@[ predicateSevereHeadache,
                                                                        predicateLightHeadache ]
                                          destinationStepIdentifiers:@[ @"severe_headache",
                                                                        @"light_headache" ] ];
    
    [task setNavigationRule:predicateRule forTriggerStepIdentifier:@"severity"];
    
    
    // Add end direct rules to skip unneeded steps
    ORKDirectStepNavigationRule *directRule = nil;
    
    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:@"end"];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"severe_headache"];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"light_headache"];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"other_symptom"];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"survey_skipped"];

    directRule = [[ORKDirectStepNavigationRule alloc] initWithDestinationStepIdentifier:ORKNullStepIdentifier];
    [task setNavigationRule:directRule forTriggerStepIdentifier:@"end"];
    
    return task;
}

#pragma mark - Custom navigation item task

- (id<ORKTask>)makeCustomNavigationItemTask {
    NSMutableArray *steps = [[NSMutableArray alloc] init];
    ORKInstructionStep *step1 = [[ORKInstructionStep alloc] initWithIdentifier:@"customNavigationItemTask.step1"];
    step1.title = @"Custom Navigation Item Title";
    ORKInstructionStep *step2 = [[ORKInstructionStep alloc] initWithIdentifier:@"customNavigationItemTask.step2"];
    step2.title = @"Custom Navigation Item Title View";
    [steps addObject: step1];
    [steps addObject: step2];
    return [[ORKOrderedTask alloc] initWithIdentifier: CustomNavigationItemTaskIdentifier steps:steps];
}

- (IBAction)customNavigationItemButtonTapped:(id)sender {
    [self beginTaskWithIdentifier:CustomNavigationItemTaskIdentifier];
}

#pragma mark - Helpers

/*
 Builds a test consent document.
 */
- (ORKConsentDocument *)buildConsentDocument {
    ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
    
    /*
     If you have HTML review content, you can substitute it for the
     concatenation of sections by doing something like this:
     consent.htmlReviewContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:XXX ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
     */
    
    /*
     Title that will be shown in the generated document.
     */
    consent.title = @"Demo Consent";
    
    
    /*
     Signature page content, used in the generated document above the signatures.
     */
    consent.signaturePageTitle = @"Consent";
    consent.signaturePageContent = @"I agree  to participate in this research Study.";
    
    /*
     The empty signature that the user will fill in.
     */
    ORKConsentSignature *participantSig = [ORKConsentSignature signatureForPersonWithTitle:@"Participant" dateFormatString:nil identifier:@"participantSig"];
    [consent addSignature:participantSig];
    
    /*
     Pre-populated investigator's signature.
     */
    ORKConsentSignature *investigatorSig = [ORKConsentSignature signatureForPersonWithTitle:@"Investigator" dateFormatString:nil identifier:@"investigatorSig" givenName:@"Jake" familyName:@"Clemson" signatureImage:[UIImage imageNamed:@"signature"] dateString:@"9/2/14" ];
    [consent addSignature:investigatorSig];
    
    /*
     These are the set of consent sections that have pre-defined animations and
     images.
     
     We will create a section for each of the section types, and then add a custom
     section on the end.
     */
    NSArray *scenes = @[@(ORKConsentSectionTypeOverview),
                        @(ORKConsentSectionTypeDataGathering),
                        @(ORKConsentSectionTypePrivacy),
                        @(ORKConsentSectionTypeDataUse),
                        @(ORKConsentSectionTypeTimeCommitment),
                        @(ORKConsentSectionTypeStudySurvey),
                        @(ORKConsentSectionTypeStudyTasks),
                        @(ORKConsentSectionTypeWithdrawing)];
    
    NSMutableArray *sections = [NSMutableArray new];
    for (NSNumber *type in scenes) {
        NSString *summary = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Et doming eirmod delicata cum. Vel fabellas scribentur neglegentur cu, pro te iudicabit explicari. His alia idque scriptorem ei, quo no nominavi noluisse.";
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:type.integerValue];
        consentSection.summary = summary;
        
        if (type.integerValue == ORKConsentSectionTypeOverview) {
            /*
             Tests HTML content instead of text for Learn More.
             */
            consentSection.htmlContent = @"<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>\
                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p> 研究";
        } else if (type.integerValue == ORKConsentSectionTypeDataGathering) {
            /*
             Tests PDF content instead of text, HTML for Learn More.
             */
            NSString *path = [[NSBundle mainBundle] pathForResource:@"SAMPLE_PDF_TEST" ofType:@"pdf"];
            consentSection.contentURL = [NSURL URLWithString:path];

        } else {
            /*
             Tests text Learn More content.
             */
            consentSection.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo? Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?\
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?\
                An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        }
        
        [sections addObject:consentSection];
    }
    
    {
        /*
         A custom consent scene. This doesn't demo it but you can also set a custom
         animation.
         */
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeCustom];
        consentSection.summary = @"Custom Scene summary";
        consentSection.title = @"Custom Scene";
        consentSection.customImage = [UIImage imageNamed:@"image_example.png"];
        consentSection.customLearnMoreButtonTitle = @"Learn more about customizing ResearchKit";
        consentSection.content = @"You can customize ResearchKit a lot!";
        [sections addObject:consentSection];
    }
    
    {
        /*
         An "only in document" scene. This is ignored for visual consent, but included in
         the concatenated document for review.
         */
        ORKConsentSection *consentSection = [[ORKConsentSection alloc] initWithType:ORKConsentSectionTypeOnlyInDocument];
        consentSection.summary = @"OnlyInDocument Scene summary";
        consentSection.title = @"OnlyInDocument Scene";
        consentSection.content = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?";
        [sections addObject:consentSection];
    }
    
    consent.sections = [sections copy];
    return consent;
}

/*
 A helper for creating square colored images, which can optionally have a border.
 
 Used for testing the image choices answer format.
 
 @param color   Color to use for the image.
 @param size    Size of image.
 @param border  Boolean value indicating whether to add a black border around the image.
 
 @return An image.
 */
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size border:(BOOL)border {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    view.backgroundColor = color;
    
    if (border) {
        view.layer.borderColor = [[UIColor blackColor] CGColor];
        view.layer.borderWidth = 5.0;
    }

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - Managing the task view controller

/*
 Dismisses the task view controller.
 */
- (void)dismissTaskViewController:(ORKTaskViewController *)taskViewController {
    _currentDocument = nil;
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            /*
             We attempt to clean up the output directory.
             
             This is only useful for a test app, where we don't care about the
             data after the test is complete. In a real application, only
             delete your data when you've processed it or sent it to a server.
             */
            NSError *err = nil;
            if (! [[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
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
    NSString *task_identifier = taskViewController.task.identifier;

    return ([step isKindOfClass:[ORKInstructionStep class]]
            && NO == [@[AudioTaskIdentifier, FitnessTaskIdentifier, GaitTaskIdentifier, TwoFingerTapTaskIdentifier, StepNavigationTaskIdentifier] containsObject:task_identifier]);
}

/*
 When the user taps on "Learn More" on a step, respond on this delegate callback.
 In this test app, we just print to the console.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController learnMoreForStep:(ORKStepViewController *)stepViewController {
    NSLog(@"Learn more tapped for step %@", stepViewController.step.identifier);
}

- (BOOL)taskViewController:(ORKTaskViewController *)taskViewController shouldPresentStep:(ORKStep *)step {
    if ([ step.identifier isEqualToString:@"itid_002"]) {
        /*
         Tests interrupting navigation from the task view controller delegate.
         
         This is an example of preventing a user from proceeding if they don't
         enter a valid answer.
         */
        
        ORKQuestionResult *questionResult = (ORKQuestionResult *)[[[taskViewController result] stepResultForStepIdentifier:@"itid_001"] firstResult];
        if (questionResult == nil || [(NSNumber *)questionResult.answer integerValue] < 18) {
            UIAlertController *alertViewController =
            [UIAlertController alertControllerWithTitle:@"Warning"
                                                message:@"You can't participate if you are under 18."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alertViewController dismissViewControllerAnimated:YES completion:nil];
                                 }];
            
            
            [alertViewController addAction:ok];
            
            [taskViewController presentViewController:alertViewController animated:NO completion:nil];
            return NO;
        }
    }
    return YES;
}

/*
 In `stepViewControllerWillAppear:`, it is possible to significantly customize
 the behavior of the step view controller. In this test app, we do a few funny
 things to push the limits of this customization.
 */
- (void)taskViewController:(ORKTaskViewController *)taskViewController
stepViewControllerWillAppear:(ORKStepViewController *)stepViewController {
    
    if ([stepViewController.step.identifier isEqualToString:@"aid_001c"]) {
        /*
         Tests adding a custom view to a view controller for an active step, without
         subclassing.
         
         This is possible, but not recommended. A better choice would be to create
         a custom active step subclass and a matching active step view controller
         subclass, so you completely own the view controller and its appearance.
         */
        
        UIView *customView = [UIView new];
        customView.backgroundColor = [UIColor cyanColor];
        
        // Have the custom view request the space it needs.
        // A little tricky because we need to let it size to fit if there's not enough space.
        customView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[c(>=160)]"
                                                                               options:(NSLayoutFormatOptions)0
                                                                               metrics:nil
                                                                                 views:@{@"c":customView}];
        for (NSLayoutConstraint *constraint in verticalConstraints)
        {
            constraint.priority = UILayoutPriorityFittingSizeLevel;
        }
        [NSLayoutConstraint activateConstraints:verticalConstraints];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[c(>=280)]"
                                                                                        options:(NSLayoutFormatOptions)0
                                                                                        metrics:nil
                                                                                          views:@{@"c":customView}]];
        
        [(ORKActiveStepViewController *)stepViewController setCustomView:customView];
        
        // Set custom button on navigation bar
        stepViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Custom button"
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:nil
                                                                                              action:nil];
    } else if ([stepViewController.step.identifier hasPrefix:@"question_"]
               && ![stepViewController.step.identifier hasSuffix:@"6"]) {
        /*
         Tests customizing continue button ("some of the time").
         */
        stepViewController.continueButtonTitle = @"Next Question";
    } else if ([stepViewController.step.identifier isEqualToString:@"mini_form_001"]) {
        /*
         Tests customizing continue and learn more buttons.
         */
        stepViewController.continueButtonTitle = @"Try Mini Form";
        stepViewController.learnMoreButtonTitle = @"Learn more about this survey";
    } else if ([stepViewController.step.identifier isEqualToString: @"qid_001"]) {
        /*
         Example of customizing the back and cancel buttons in a way that's
         visibly obvious.
         */
        stepViewController.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back1"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:stepViewController.backButtonItem.target
                                                                            action:stepViewController.backButtonItem.action];
        stepViewController.cancelButtonItem.title = @"Cancel1";
    } else if ([stepViewController.step.identifier isEqualToString:@"customNavigationItemTask.step1"]) {
        stepViewController.navigationItem.title = @"Custom title";
    } else if ([stepViewController.step.identifier isEqualToString:@"customNavigationItemTask.step2"]) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        [items addObject:@"Item1"];
        [items addObject:@"Item2"];
        [items addObject:@"Item3"];
        stepViewController.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:items];
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
            [self taskViewControllerDidComplete:taskViewController];
            break;
        case ORKTaskViewControllerFinishReasonFailed:
            NSLog(@"Error on step %@: %@", taskViewController.currentStepViewController.step, error);
            break;
        case ORKTaskViewControllerFinishReasonDiscarded:
            [self dismissTaskViewController:taskViewController];
            break;
        case ORKTaskViewControllerFinishReasonSaved:
        {
            /*
             Save the restoration data, dismiss the task VC, and do an early return
             so we don't clear the restoration data.
             */
            id<ORKTask> task = taskViewController.task;
            _savedViewControllers[task.identifier] = [taskViewController restorationData];
            /*
             Save only tasks of the ORKNavigableOrderedTask class, as it's useful to preserve its navigation stack
             */
            if ([task isKindOfClass:[ORKNavigableOrderedTask class]]) {
                _savedTasks[task.identifier] = [NSKeyedArchiver archivedDataWithRootObject:task];
            }
            [self dismissTaskViewController:taskViewController];
            return;
        }
            break;
            
        default:
            break;
    }
    
    [_savedViewControllers removeObjectForKey:taskViewController.task.identifier];
    [_savedTasks removeObjectForKey:taskViewController.task.identifier];
    _taskViewController = nil;
}

/*
 When a task completes, we pretty-print the result to the console.
 
 This is ok for testing, but if what you want to do is see the results of a task,
 the `ORKCatalog` Swift sample app might be a better choice, since it lets
 you navigate through the result structure.
 */
- (void)taskViewControllerDidComplete:(ORKTaskViewController *)taskViewController {
    
    NSLog(@"%@", taskViewController.result);
    for (ORKStepResult *sResult in taskViewController.result.results) {
        NSLog(@"--%@", sResult);
        for (ORKResult *result in sResult.results) {
            if ([result isKindOfClass:[ORKDateQuestionResult class]]) {
                ORKDateQuestionResult *dateQuestionResult = (ORKDateQuestionResult *)result;
                NSLog(@"    %@:   %@  %@  %@", result.identifier, dateQuestionResult.answer, dateQuestionResult.timeZone, dateQuestionResult.calendar);
            } else if ([result isKindOfClass:[ORKQuestionResult class]]) {
                ORKQuestionResult *qr = (ORKQuestionResult *)result;
                NSLog(@"    %@:   %@", result.identifier, qr.answer);
            } else if ([result isKindOfClass:[ORKTappingIntervalResult class]]) {
                ORKTappingIntervalResult *tir = (ORKTappingIntervalResult *)result;
                NSLog(@"    %@:     %@\n    %@ %@", tir.identifier, tir.samples, NSStringFromCGRect(tir.buttonRect1), NSStringFromCGRect(tir.buttonRect2));
            } else if ([result isKindOfClass:[ORKFileResult class]]) {
                ORKFileResult *fileResult = (ORKFileResult *)result;
                NSLog(@"    File: %@", fileResult.fileURL);
            } else if ([result isKindOfClass:[ORKToneAudiometryResult class]]) {
                ORKToneAudiometryResult *tor = (ORKToneAudiometryResult *)result;
                NSLog(@"    %@:     %@", tor.identifier, tor.samples);
            } else if ([result isKindOfClass:[ORKTimedWalkResult class]]) {
                ORKTimedWalkResult *twr = (ORKTimedWalkResult *)result;
                NSLog(@"%@ %@ %@ %@", twr.identifier, @(twr.distanceInMeters), @(twr.timeLimit), @(twr.duration));
            } else if ([result isKindOfClass:[ORKPSATResult class]]) {
                ORKPSATResult *pr = (ORKPSATResult *)result;
                NSLog(@"    %@:     %@\n    Total correct:     %@/%@", pr.identifier, pr.samples, @(pr.totalCorrect), @(pr.length));
            } else {
                NSLog(@"    %@:   userInfo: %@", result.identifier, result.userInfo);
            }
        }
    }
    
    if (_currentDocument)
    {
        /*
         This demonstrates how to take a signature result, apply it to a document,
         and then generate a PDF From the document that includes the signature.
         */
        
        ORKStep *lastStep = ((ORKOrderedTask *)taskViewController.task).steps.lastObject;
        ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[taskViewController.result stepResultForStepIdentifier:lastStep.identifier].firstResult;
        
        [signatureResult applyToDocument:_currentDocument];
        
        [_currentDocument makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
            NSLog(@"Created PDF of size %lu (error = %@)", (unsigned long)pdfData.length, error);
            
            if (! error) {
                NSURL *documents = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
                NSURL *outputUrl = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", taskViewController.taskRunUUID.UUIDString]];
                
                [pdfData writeToURL:outputUrl atomically:YES];
                NSLog(@"Wrote PDF to %@", [outputUrl path]);
            }
        }];
        
        _currentDocument = nil;
    }
    
    NSURL *dir = taskViewController.outputDirectory;
    [self dismissViewControllerAnimated:YES completion:^{
        if (dir)
        {
            NSError *err = nil;
            if (! [[NSFileManager defaultManager] removeItemAtURL:dir error:&err]) {
                NSLog(@"Error removing %@: %@", dir, err);
            }
        }
    }];
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
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    _taskViewController = [coder decodeObjectOfClass:[UIViewController class] forKey:@"taskVC"];
    _lastRouteResult = [coder decodeObjectForKey:@"lastRouteResult"];
    
    // Need to give the task VC back a copy of its task, so it can restore itself.
    
    // Could save and restore the task's identifier separately, but the VC's
    // restoration identifier defaults to the task's identifier.
    id<ORKTask> taskForTaskViewController = [self makeTaskWithIdentifier:_taskViewController.restorationIdentifier];
    
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
    UIViewController *chartListViewController = [chartStoryboard instantiateInitialViewController];
    [self presentViewController:chartListViewController animated:YES completion:nil];
}

@end
