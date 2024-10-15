/*
 Copyright (c) 2023, Apple Inc. All rights reserved.
 
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

#import "ORKAgePicker.h"

#import "ORKResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAccessibilityFunctions.h"


@interface ORKAgePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

static const CGFloat PickerSpacerHeight = 15.0;
static const CGFloat PickerMinimumHeight = 34.0;

@implementation ORKAgePicker {
    UIPickerView *_pickerView;
    ORKAgeAnswerFormat *_answerFormat;
    NSArray<NSNumber *> *_ageOptions;
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
}

@synthesize pickerDelegate = _pickerDelegate;

- (instancetype)initWithAnswerFormat:(ORKAgeAnswerFormat *)answerFormat answer:(id)answer pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSAssert([answerFormat isKindOfClass:[ORKAgeAnswerFormat class]], @"answerFormat should be ORKAgeAnswerFormat");
        
        _answerFormat = answerFormat;
        _pickerDelegate = delegate;
        _answer = answer;
        
        NSMutableArray<NSNumber *> *tempArray = [NSMutableArray new];
        for (int i = _answerFormat.minimumAge; i <= _answerFormat.maximumAge; i++) {
            [tempArray addObject:[[NSNumber alloc] initWithInt:i]];
        }
        
        _ageOptions = [tempArray copy];
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

    if (!ORKIsAnswerEmpty(_answer)) {
        NSNumber *value = (NSNumber *)_answer;
        NSUInteger indexOfAgeOption = 0;
        
        if ([self isAnswerAYear:value]) {
            // if year is passed in, its converted back to age so picker can be set correctly
            NSNumber *ageValueForYear = [[NSNumber alloc] initWithInt:_answerFormat.relativeYear - value.intValue];
            indexOfAgeOption = [self indexForAgeValue:ageValueForYear];
        } else if (value < 0) {
            // if a sentinel value is passed in, either the first or last index is passed back accordingly
            indexOfAgeOption = [value intValue] == [ORKAgeAnswerFormat minimumAgeSentinelValue] ? 0 : _ageOptions.count - 1;
        } else  {
            indexOfAgeOption = [self indexForAgeValue:value];
        }
        
        // offset the index by 1 to account for the empty value in first position of the picker
        [_pickerView selectRow:indexOfAgeOption + 1 inComponent:0 animated:YES];
       
        return;
    }
    
    if (_answerFormat.defaultValue >= _answerFormat.minimumAge && _answerFormat.defaultValue <= _answerFormat.maximumAge) {
        // use default to select a row
        NSNumber *defaultValue = [self defaultAnswerValue];
        NSUInteger indexOfAgeOption = [_ageOptions indexOfObject: defaultValue];
        
        [_pickerView selectRow:indexOfAgeOption + 1 inComponent:0 animated:YES];
    }
}

- (id)answer {
    return _answer;
}

- (BOOL)isAnswerAYear:(NSNumber *)answer {
    NSInteger relativeYear = _answerFormat.relativeYear;
    
    return answer.intValue <= relativeYear && answer.intValue >= (relativeYear - _answerFormat.maximumAge);
}

- (NSUInteger)indexForAgeValue:(NSNumber *)ageValue {
    if ([ageValue intValue] < _answerFormat.minimumAge) {
        return 0;
    } else if ([ageValue intValue] > _answerFormat.maximumAge) {
        return _ageOptions.count - 1;
    }
    
    return [_ageOptions indexOfObject:ageValue];
}

- (NSNumber *)ageToYear:(NSNumber *)age {
    return [[NSNumber alloc] initWithInt: _answerFormat.relativeYear - age.intValue];
}

- (NSNumber *)defaultAnswerValue {
    return [[NSNumber alloc] initWithInt:_answerFormat.defaultValue];
}

- (NSNumber *)selectedAnswerValue {
    NSNumber *answer = nil;
    NSInteger selectedRowIndex = [_pickerView selectedRowInComponent:0];
    
    // The first option in the picker is an empty string. We return nil if this is selected
    if (selectedRowIndex == 0) {
        return nil;
    } else if ((selectedRowIndex == 1 && _answerFormat.treatMinAgeAsRange) || (selectedRowIndex == _ageOptions.count && _answerFormat.treatMaxAgeAsRange)) {
        // if the min or max has been selected a sentinel value is passed back if it should be treated as a range.
        int sentinelValue = selectedRowIndex == 1 ? [ORKAgeAnswerFormat minimumAgeSentinelValue] : [ORKAgeAnswerFormat maximumAgeSentinelValue];
        answer = [NSNumber numberWithInt:sentinelValue];
        return answer;
    }
    
    answer = [self ageForIndex:selectedRowIndex];
    
    return _answerFormat.useYearForResult ? [self ageToYear:answer] : answer;
}

- (NSString *)selectedLabelText {
    return [_answerFormat stringForAnswer:_answer];
}
    
- (void)pickerWillAppear {
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

- (NSNumber *)ageForIndex:(NSInteger)index {
    // index will need to be offset to account for empty choice added to picker
    index = (index - 1 < 0) ? 0 : index - 1;
    return [_ageOptions objectAtIndex:index];
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
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _ageOptions.count + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (row == 0) {
        return @"";
    }
    
    NSString *title;
    int ageValue = [self ageForIndex:row].intValue;
    
    if (row == 1 && _answerFormat.minimumAgeCustomText) {
        title = _answerFormat.minimumAgeCustomText;
    } else if (row == _ageOptions.count && _answerFormat.maximumAgeCustomText) {
        title = _answerFormat.maximumAgeCustomText;
    } else if (_answerFormat.showYear) {
        title = [NSString stringWithFormat:@"%li (%i)", _answerFormat.relativeYear - ageValue, ageValue];
    } else {
        title = [NSString stringWithFormat:@"%i", ageValue];
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

@end
