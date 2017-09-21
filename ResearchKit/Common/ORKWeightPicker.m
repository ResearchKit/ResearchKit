/*
 Copyright (c) 2017, Nino Guba.
 
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


#import "ORKWeightPicker.h"
#import "ORKResult_Private.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKAccessibilityFunctions.h"


@interface ORKWeightPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@end


@implementation ORKWeightPicker {
    UIPickerView *_pickerView;
    ORKWeightAnswerFormat *_answerFormat;
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
    NSArray *kilogramValues;
    NSArray *poundValues;
    NSArray *fractionValues;
    NSNumber *minValue;
    NSNumber *maxValue;
}

@synthesize pickerDelegate = _pickerDelegate;

- (instancetype)initWithAnswerFormat:(ORKWeightAnswerFormat *)answerFormat answer:(id)answer pickerDelegate:(id<ORKPickerDelegate>)delegate {
    self = [super init];
    if (self) {
        NSAssert([answerFormat isKindOfClass:[ORKWeightAnswerFormat class]], @"answerFormat should be ORKWeightAnswerFormat");
                
        // Take into account locale changes so unit string can be updated
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(currentLocaleDidChange:)
                                                     name:NSCurrentLocaleDidChangeNotification object:nil];
        
        _answerFormat = answerFormat;
        _pickerDelegate = delegate;
        self.answer = answer;
        
        if (_answerFormat.useMetricSystem) {
            kilogramValues = [self kilogramValues];
        } else {
            poundValues = [self poundValues];
        }
        
        if (_answerFormat.additionalPrecision) {
            fractionValues = [self fractionValues];
        }
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
        answer = [self defaultAnswerValue];
    }
    
    if (_answerFormat.useMetricSystem) {
        double whole, fraction;
        ORKKilogramsToWholeAndFractions(((NSNumber *)answer).doubleValue, &whole, &fraction);
        NSUInteger wholeIndex = [kilogramValues indexOfObject:@((NSInteger)whole)];
        NSUInteger fractionIndex = [fractionValues indexOfObject:@((NSInteger)fraction)];
        if (wholeIndex == NSNotFound || fractionIndex == NSNotFound) {
            [self setAnswer:[self defaultAnswerValue]];
            return;
        }
        if (_answerFormat.additionalPrecision || fraction == 0.0) {
            [_pickerView selectRow:wholeIndex inComponent:0 animated:NO];
        } else if (!_answerFormat.additionalPrecision && fraction == 50.0) {
            wholeIndex = [kilogramValues indexOfObject:@((NSInteger)whole + 0.5)];
            [_pickerView selectRow:wholeIndex inComponent:0 animated:NO];
        }
        if (_answerFormat.additionalPrecision) {
            [_pickerView selectRow:fractionIndex inComponent:1 animated:NO];
            [_pickerView selectRow:0 inComponent:2 animated:NO];
        }
    } else {
        double pounds, ounces;
        if (!_answerFormat.additionalPrecision) {
            ORKKilogramsToPounds(((NSNumber *)answer).doubleValue, &pounds);
            ounces = 0;
        } else {
            ORKKilogramsToPoundsAndOunces(((NSNumber *)answer).doubleValue, &pounds, &ounces);
        }
        NSUInteger poundsIndex = [poundValues indexOfObject:@((NSInteger)pounds)];
        NSUInteger ouncesIndex = [fractionValues indexOfObject:@((NSInteger)ounces)];
        if (poundsIndex == NSNotFound || ouncesIndex == NSNotFound) {
            [self setAnswer:[self defaultAnswerValue]];
            return;
        }
        [_pickerView selectRow:poundsIndex inComponent:0 animated:NO];
        if (_answerFormat.additionalPrecision) {
            [_pickerView selectRow:ouncesIndex inComponent:1 animated:NO];
        }
    }
}

- (id)answer {
    return _answer;
}

- (NSNumber *)defaultAnswerValue {
    NSNumber *defaultAnswerValue = nil;
    if (_answerFormat.defaultValue) {
        if (_answerFormat.useMetricSystem) {
            defaultAnswerValue = _answerFormat.defaultValue;
        } else if (!_answerFormat.additionalPrecision) {
            defaultAnswerValue = [NSNumber numberWithDouble:ORKPoundsToKilograms([_answerFormat.defaultValue doubleValue])]; // Convert to kg
        } else {
            defaultAnswerValue = [NSNumber numberWithDouble:ORKPoundsAndOuncesToKilograms([_answerFormat.defaultValue doubleValue], 0.0)]; // Convert to kg
        }
    } else if (_answerFormat.useMetricSystem) {
        defaultAnswerValue = @(60.00); // Default metric weight: 60 kg
    } else {
        defaultAnswerValue = @(60.33); // Default USC weight: 133 lbs
    }
    
    // Ensure default value is within bounds
    if (minValue && [defaultAnswerValue doubleValue] < [minValue doubleValue]) {
        defaultAnswerValue = minValue;
    } else if (maxValue && [defaultAnswerValue doubleValue] > [maxValue doubleValue]) {
        defaultAnswerValue = maxValue;
    }
    
    return defaultAnswerValue;
}

- (NSNumber *)selectedAnswerValue {
    NSNumber *answer = nil;
    if (_answerFormat.useMetricSystem) {
        NSInteger wholeRow = [_pickerView selectedRowInComponent:0];
        NSNumber *whole = kilogramValues[wholeRow];
        if (!_answerFormat.additionalPrecision) {
            answer = @( ORKWholeAndFractionsToKilograms(whole.doubleValue, 0.0) );
        } else {
            NSInteger fractionRow = [_pickerView selectedRowInComponent:1];
            NSNumber *fraction = fractionValues[fractionRow];
            answer = @( ORKWholeAndFractionsToKilograms(whole.doubleValue, fraction.doubleValue) );
        }
    } else {
        NSInteger poundsRow = [_pickerView selectedRowInComponent:0];
        NSNumber *pounds = poundValues[poundsRow];
        if (!_answerFormat.additionalPrecision) {
            answer = @( ORKPoundsToKilograms(pounds.doubleValue) );
        } else {
            NSInteger ouncesRow = [_pickerView selectedRowInComponent:1];
            NSNumber *ounces = fractionValues[ouncesRow];
            answer = @( ORKPoundsAndOuncesToKilograms(pounds.doubleValue, ounces.doubleValue) );
        }
    }
    
    return answer;
}

- (NSString *)selectedLabelText {
    if (_answer == nil || _answer == ORKNullAnswerValue()) {
        return nil;
    }
    
    NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
    NSString *selectedLabelText = nil;
    if (_answerFormat.useMetricSystem) {
        double whole, fraction;
        ORKKilogramsToWholeAndFractions(((NSNumber *)_answer).doubleValue, &whole, &fraction);
        NSString *wholeString = [formatter stringFromNumber:@(whole)];
        if (!_answerFormat.additionalPrecision && fraction == 0.0) {
            selectedLabelText = [NSString stringWithFormat:@"%@ %@", wholeString, ORKLocalizedString(@"MEASURING_UNIT_KG", nil)];
        } else if (!_answerFormat.additionalPrecision && fraction == 50.0) {
            wholeString = [formatter stringFromNumber:@(whole + 0.5)];
            selectedLabelText = [NSString stringWithFormat:@"%@ %@", wholeString, ORKLocalizedString(@"MEASURING_UNIT_KG", nil)];
        } else {
            formatter.minimumIntegerDigits = 2;
            formatter.maximumFractionDigits = 0;
            NSString *fractionString = [formatter stringFromNumber:@(fraction)];
            selectedLabelText = [NSString stringWithFormat:@"%@.%@ %@", wholeString, fractionString, ORKLocalizedString(@"MEASURING_UNIT_KG", nil)];
        }
    } else {
        double pounds, ounces;
        if (!_answerFormat.additionalPrecision) {
            ORKKilogramsToPounds(((NSNumber *)_answer).doubleValue, &pounds);
            NSString *poundsString = [formatter stringFromNumber:@(pounds)];
            selectedLabelText = [NSString stringWithFormat:@"%@ %@", poundsString, ORKLocalizedString(@"MEASURING_UNIT_LBS", nil)];
        } else {
            ORKKilogramsToPoundsAndOunces(((NSNumber *)_answer).doubleValue, &pounds, &ounces);
            NSString *poundsString = [formatter stringFromNumber:@(pounds)];
            NSString *ouncesString = [formatter stringFromNumber:@(ounces)];
            selectedLabelText = [NSString stringWithFormat:@"%@ %@, %@ %@",
                                 poundsString, ORKLocalizedString(@"MEASURING_UNIT_LBS", nil), ouncesString, ORKLocalizedString(@"MEASURING_UNIT_OZ", nil)];
        }
    }
    return selectedLabelText;
}

- (void)pickerWillAppear {
    // Report current value, since ORKWeightPicker always has a value
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
    return !_answerFormat.additionalPrecision ? 1 : (_answerFormat.useMetricSystem ? 3 : 2);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (component == 0) {
        if (_answerFormat.useMetricSystem) {
            numberOfRows = kilogramValues.count;
        } else {
            numberOfRows = poundValues.count;
        }
    } else if (component == 1) {
        numberOfRows = fractionValues.count;
    } else {
        numberOfRows = 1;
    }
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = nil;
    if (_answerFormat.useMetricSystem) {
        if (component == 0) {
            if (!_answerFormat.additionalPrecision) {
                title = [NSString stringWithFormat:@"%@ %@", kilogramValues[row], ORKLocalizedString(@"MEASURING_UNIT_KG", nil)];
            } else {
                title = [NSString stringWithFormat:@"%@", kilogramValues[row]];
            }
        } else if (component == 1) {
            NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
            formatter.minimumIntegerDigits = 2;
            formatter.maximumFractionDigits = 0;
            title = [NSString stringWithFormat:@".%@", [formatter stringFromNumber:fractionValues[row]]];
        } else {
            title = ORKLocalizedString(@"MEASURING_UNIT_KG", nil);
        }
    } else {
        if (component == 0) {
            title = [NSString stringWithFormat:@"%@ %@", poundValues[row], ORKLocalizedString(@"MEASURING_UNIT_LBS", nil)];
        } else {
            title = [NSString stringWithFormat:@"%@ %@", fractionValues[row], ORKLocalizedString(@"MEASURING_UNIT_OZ", nil)];
        }
    }    
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self valueDidChange:self];
}

- (NSArray *)kilogramValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];

    NSInteger min = 0;
    NSInteger max = 657;
    if (_answerFormat.minimumValue && [_answerFormat.minimumValue integerValue] <= max) {
        min = [_answerFormat.minimumValue integerValue];
    }
    if (_answerFormat.maximumValue && [_answerFormat.maximumValue integerValue] >= min) {
        max = [_answerFormat.maximumValue integerValue];
    }
    minValue = [NSNumber numberWithInteger:min];
    maxValue = [NSNumber numberWithInteger:max];
    
    for (NSInteger i = min; i <= max; i++) {
        [mutableWholeValues addObject:[NSNumber numberWithInteger:i]];
        if (!_answerFormat.additionalPrecision) {
            if (!_answerFormat.valueInterval || [_answerFormat.valueInterval integerValue] != 0) {
                [mutableWholeValues addObject:[NSNumber numberWithDouble:i + 0.5]];
            }
        }
    }
    wholeValues = [mutableWholeValues copy];
    return wholeValues;
}

- (NSArray *)poundValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];

    NSInteger min = 0;
    NSInteger max = 1450;
    if (_answerFormat.minimumValue && [_answerFormat.minimumValue integerValue] <= max) {
        min = [_answerFormat.minimumValue integerValue];
    }
    if (_answerFormat.maximumValue && [_answerFormat.maximumValue integerValue] >= min) {
        max = [_answerFormat.maximumValue integerValue];
    }
    minValue = [NSNumber numberWithDouble:ORKPoundsToKilograms([[NSNumber numberWithInteger:min] doubleValue])]; // Convert to kg
    maxValue = [NSNumber numberWithDouble:ORKPoundsToKilograms([[NSNumber numberWithInteger:max] doubleValue])]; // Convert to kg
    
    for (NSInteger i = min; i <= max; i++) {
        [mutableWholeValues addObject:[NSNumber numberWithInteger:i]];
    }
    wholeValues = [mutableWholeValues copy];
    return wholeValues;
}

- (NSArray *)fractionValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];
    
    NSInteger max = 99;
    if (!_answerFormat.useMetricSystem) {
        max = 15;
    }
    for (NSInteger i = 0; i <= max; i++) {
        [mutableWholeValues addObject:[NSNumber numberWithInteger:i]];
    }
    wholeValues = [mutableWholeValues copy];
    return wholeValues;
}

- (void)currentLocaleDidChange:(NSNotification *)notification {
    [_pickerView reloadAllComponents];
    [self setAnswer:[self defaultAnswerValue]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
