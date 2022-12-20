/*
 Copyright (c) 2016, Ricardo Sánchez-Sáez.
 
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


#import "ORKHeightPicker.h"
#import "ORKResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAccessibilityFunctions.h"


@interface ORKHeightPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

static const CGFloat PickerSpacerHeight = 15.0;
static const CGFloat PickerMinimumHeight = 34.0;

@implementation ORKHeightPicker {
    UIPickerView *_pickerView;
    ORKHeightAnswerFormat *_answerFormat;
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
}

@synthesize pickerDelegate = _pickerDelegate;

- (instancetype)initWithAnswerFormat:(ORKHeightAnswerFormat *)answerFormat answer:(id)answer pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSAssert([answerFormat isKindOfClass:[ORKHeightAnswerFormat class]], @"answerFormat should be ORKHeightAnswerFormat");
        
        // Take into account locale changes so unit string can be updated
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(currentLocaleDidChange:)
                                                     name:NSCurrentLocaleDidChangeNotification object:nil];

        _answerFormat = answerFormat;
        _pickerDelegate = delegate;
        self.answer = answer;
    }
    return self;
}

- (UIView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self setAnswer:_answer];
    }
    return _pickerView;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    
    if (ORKIsAnswerEmpty(answer)) {
        if (![_pickerDelegate isOptional]) {
            return;
        }
        
        answer = [self defaultAnswerValue];
    }
    
    if (_answerFormat.useMetricSystem) {
        NSUInteger index = [[self centimeterValues] indexOfObject:answer];
        if (index == NSNotFound) {
            [self setAnswer:[self defaultAnswerValue]];
            return;
        }
        // need to add one if not optional
        if (![_pickerDelegate isOptional]) {
            index = index + 1;
        }
        [_pickerView selectRow:index inComponent:0 animated:NO];
    } else {
        double feet, inches;
        ORKCentimetersToFeetAndInches(((NSNumber *)answer).doubleValue, &feet, &inches);
        NSUInteger feetIndex = [[self feetValues] indexOfObject:@((NSInteger)feet)];
        NSUInteger inchesIndex = [[self inchesValues] indexOfObject:@((NSInteger)inches)];
        if (feetIndex == NSNotFound || inchesIndex == NSNotFound) {
            [self setAnswer:[self defaultAnswerValue]];
            return;
        }
        // need to add one if not optional
        if (![_pickerDelegate isOptional]) {
            feetIndex = feetIndex + 1;
            inchesIndex = inchesIndex + 1;
        }
        
        [_pickerView selectRow:feetIndex inComponent:0 animated:NO];
        [_pickerView selectRow:inchesIndex inComponent:1 animated:NO];
    }
}

- (id)answer {
    return _answer;
}

- (NSNumber *)defaultAnswerValue {
    NSNumber *defaultAnswerValue = nil;
    if (_answerFormat.useMetricSystem) {
        defaultAnswerValue = @(162); // Default metric height: 162 cm
    } else {
        defaultAnswerValue = @(162.56); // Default USC height: 5ft 4in (162.56 cm)
    }
    return defaultAnswerValue;
}

- (NSNumber *)selectedAnswerValue {
    NSNumber *answer = nil;
    if (_answerFormat.useMetricSystem) {
        NSInteger row = [self fetchSelectedRowInComponent:0];

        if (![_pickerDelegate isOptional] && row == -1) {
            return nil;
        }
        
        answer = [self centimeterValues][row];
    } else {
        NSInteger feetRow = [self fetchSelectedRowInComponent:0];
        NSInteger inchesRow = [self fetchSelectedRowInComponent:1];
        
        if (![_pickerDelegate isOptional] && (feetRow == -1 || inchesRow == -1)) {
            return nil;
        }
        
        NSNumber *feet = [self feetValues][feetRow];
        NSNumber *inches = [self inchesValues][inchesRow];
        answer = @( ORKFeetAndInchesToCentimeters(feet.doubleValue, inches.doubleValue) );
    }
    return answer;
}

- (NSInteger)fetchSelectedRowInComponent:(NSInteger)component {
    NSInteger row = [_pickerView selectedRowInComponent:component];
     
    //subtract row by 1 to account for empty value added if step is not optional
    return [_pickerDelegate isOptional] ? row : (row - 1);
}

- (NSString *)selectedLabelText {
    return [_answerFormat stringForAnswer:_answer];
}

- (void)pickerWillAppear {
    // Report current value, since ORKHeightPicker always has a value
    [self pickerView];
    [self valueDidChange:self];
    [self accessibilityFocusOnPickerElement];
}

- (void)valueDidChange:(id)sender {
    _answer = [self selectedAnswerValue];

    if ([self.pickerDelegate respondsToSelector:@selector(picker:answerDidChangeTo:)]) {
        [self.pickerDelegate picker:self answerDidChangeTo:_answer];
    }
}

#pragma mark - Accessibility

- (void)accessibilityFocusOnPickerElement {
    if (UIAccessibilityIsVoiceOverRunning()) {
        ORKAccessibilityPerformBlockAfterDelay(0.75, ^{
            NSArray *axElements = [self.pickerView accessibilityElements];
            if ([axElements count] > 0) {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [axElements objectAtIndex:0]);
            }
        });
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _answerFormat.useMetricSystem ? 1 : 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (_answerFormat.useMetricSystem) {
        numberOfRows = [self centimeterValues].count;
    } else {
        if (component == 0) {
            numberOfRows = [self feetValues].count;
        } else {
            numberOfRows = [self inchesValues].count;
        }
    }
    return ![_pickerDelegate isOptional] ? numberOfRows + 1 : numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSInteger currentRow = row;
    
    if (![self.pickerDelegate isOptional]) {
        
        if (row == 0) {
            return @"";
        } else {
            currentRow = row - 1;
        }
    }

    NSString *title = nil;
    if (_answerFormat.useMetricSystem) {
        title = [NSString stringWithFormat:@"%@ %@", [self centimeterValues][currentRow], ORKLocalizedString(@"MEASURING_UNIT_CM", nil)];
    } else {
        if (component == 0) {
            title = [NSString stringWithFormat:@"%@ %@", [self feetValues][currentRow], ORKLocalizedString(@"MEASURING_UNIT_FT", nil)];
        } else {
            title = [NSString stringWithFormat:@"%@ %@", [self inchesValues][currentRow], ORKLocalizedString(@"MEASURING_UNIT_IN", nil)];
        }
    }
    return title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* valueLabel = (UILabel*)view;
    if (!valueLabel)
    {
        valueLabel = [[UILabel alloc] init];
        [valueLabel setFont:[self defaultFont]];
        [valueLabel setTextAlignment:NSTextAlignmentCenter];
    }
    valueLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return valueLabel;
}

- (UIFont *)defaultFont {
    UIFontDescriptor *descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    return [UIFont systemFontOfSize:((NSNumber *)[descriptor objectForKey:UIFontDescriptorSizeAttribute]).doubleValue + 2.0];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    UIFont *font = [self defaultFont];
    CGFloat height =  font.pointSize + PickerSpacerHeight;
    return (height < PickerMinimumHeight ? PickerMinimumHeight : height);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self valueDidChange:self];
}

- (NSArray *)centimeterValues {
    static NSArray *centimeterValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableCentimeterValues = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i <= 299; i++) {
            [mutableCentimeterValues addObject:[NSNumber numberWithInteger:i]];
        }
        centimeterValues = [mutableCentimeterValues copy];
    });
    return centimeterValues;
}

- (NSArray *)feetValues {
    static NSArray *feetValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableFeetValues = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i <= 9; i++) {
            [mutableFeetValues addObject:[NSNumber numberWithInteger:i]];
        }
        feetValues = [mutableFeetValues copy];
    });
    return feetValues;
}

- (NSArray *)inchesValues {
    static NSArray *inchesValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableInchesValues = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i <= 11; i++) {
            [mutableInchesValues addObject:[NSNumber numberWithInteger:i]];
        }
        inchesValues = [mutableInchesValues copy];
    });
    return inchesValues;
}

- (void)currentLocaleDidChange:(NSNotification *)notification {
    [_pickerView reloadAllComponents];
    [self setAnswer:[self defaultAnswerValue]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
