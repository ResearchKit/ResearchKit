/*
 Copyright (c) 2017, Nino Guba.
 Copyright (c) 2026, Snehal Mehta.
 
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

static const CGFloat PickerSpacerHeight = 15.0;
static const CGFloat PickerMinimumHeight = 34.0;

@implementation ORKWeightPicker {
    UIPickerView *_pickerView;
    ORKWeightAnswerFormat *_answerFormat;
    id _answer;
    __weak id<ORKPickerDelegate> _pickerDelegate;
    NSArray *_majorValues;
    NSArray *_minorValues;
    double _canonicalMaximumValue;
    double _canonicalMinimumValue;
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
        
        _canonicalMaximumValue = ORKDoubleDefaultValue;
        _canonicalMinimumValue = ORKDoubleDefaultValue;

        if (_answerFormat.useMetricSystem) {
            _majorValues = [self kilogramValues];
        } else {
            _majorValues = [self poundValues];
        }
        
        if (_answerFormat.numericPrecision == ORKNumericPrecisionHigh) {
            _minorValues = [self _minorValues];
        }
        
        // Set the answer only after the picker rows exist: setAnswer: looks the
        // value up in _majorValues/_minorValues, and with nil rows every
        // non-empty answer used to fall back to the 60 kg default.
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

- (void)resetAnswerToDefault {
    _answer = [self defaultAnswerValue];
}

- (NSNumber *)nearestValueInValues:(NSArray<NSNumber *> *)values toValue:(double)value {
    if (values.count == 0) {
        return nil;
    }
    // Values are sorted ascending. Clamp out-of-range values to the ends,
    // otherwise take the nearest row (ties go to the lower row).
    if (value <= values.firstObject.doubleValue) {
        return values.firstObject;
    }
    if (value >= values.lastObject.doubleValue) {
        return values.lastObject;
    }
    NSNumber *nearest = values.firstObject;
    for (NSNumber *candidate in values) {
        if (fabs(candidate.doubleValue - value) < fabs(nearest.doubleValue - value)) {
            nearest = candidate;
        } else if (candidate.doubleValue > value) {
            break;
        }
    }
    return nearest;
}

- (void)setAnswer:(id)answer {
    _answer = answer;
    if (ORKIsAnswerEmpty(answer)) {
        if (![_pickerDelegate isOptional]) {
            return;
        }
        
        answer = [self defaultAnswerValue];
    }
    
    // A value that is not an exact picker row (e.g. a HealthKit default such
    // as 66.68 kg, when rows are 0.5 kg steps) used to fall back to the
    // 60 kg default via resetAnswerToDefault. Snap to the nearest row
    // instead, so the picker shows the closest value to the requested one.
    // _answer is set to the snapped value so the picker's answer matches
    // the row it displays.
    if (_answerFormat.useMetricSystem) {
        if (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) {
            NSNumber *snappedValue = [self nearestValueInValues:_majorValues toValue:((NSNumber *)answer).doubleValue];
            if (snappedValue == nil) {
                // Not calling setAnswer:defaultAnswerValue to avoid infinite recursion
                [self resetAnswerToDefault];
                return;
            }
            _answer = snappedValue;
            NSUInteger index = [_majorValues indexOfObject:snappedValue];
            if (![_pickerDelegate isOptional]) {
                index = index + 1;
            }
            [_pickerView selectRow:index inComponent:0 animated:NO];
        } else {
            double whole, fraction;
            ORKKilogramsToWholeAndFraction(((NSNumber *)answer).doubleValue, &whole, &fraction);
            NSNumber *snappedWhole = [self nearestValueInValues:_majorValues toValue:whole];
            NSNumber *snappedFraction = [self nearestValueInValues:_minorValues toValue:fraction];
            if (snappedWhole == nil || snappedFraction == nil) {
                // Not calling setAnswer:defaultAnswerValue to avoid infinite recursion
                [self resetAnswerToDefault];
                return;
            }
            _answer = @(ORKWholeAndFractionToKilograms(snappedWhole.doubleValue, snappedFraction.doubleValue));
            NSUInteger wholeIndex = [_majorValues indexOfObject:snappedWhole];
            NSUInteger fractionIndex = [_minorValues indexOfObject:snappedFraction];
            if (![_pickerDelegate isOptional]) {
                wholeIndex = wholeIndex + 1;
                fractionIndex = fractionIndex + 1;
            }
            [_pickerView selectRow:wholeIndex inComponent:0 animated:NO];
            [_pickerView selectRow:fractionIndex inComponent:1 animated:NO];
            [_pickerView selectRow:0 inComponent:2 animated:NO];
        }
    } else {
        if (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) {
            double pounds, ounces;
            ORKKilogramsToPoundsAndOunces(((NSNumber *)answer).doubleValue, &pounds, &ounces);
            // Round to the nearest pound: ounces >= 8 means the fractional
            // part is at least half a pound.
            if (ounces >= 8) {
                pounds += 1;
            }
            NSNumber *snappedPounds = [self nearestValueInValues:_majorValues toValue:pounds];
            if (snappedPounds == nil) {
                // Not calling setAnswer:defaultAnswerValue to avoid infinite recursion
                [self resetAnswerToDefault];
                return;
            }
            _answer = @(ORKPoundsToKilograms(snappedPounds.doubleValue));
            NSUInteger poundsIndex = [_majorValues indexOfObject:snappedPounds];
            // need to add one if not optional
            if (![_pickerDelegate isOptional]) {
                poundsIndex = poundsIndex + 1;
            }
            [_pickerView selectRow:poundsIndex inComponent:0 animated:NO];
        } else {
            double pounds, ounces;
            ORKKilogramsToPoundsAndOunces(((NSNumber *)answer).doubleValue, &pounds, &ounces);
            NSNumber *snappedPounds = [self nearestValueInValues:_majorValues toValue:pounds];
            NSNumber *snappedOunces = [self nearestValueInValues:_minorValues toValue:ounces];
            if (snappedPounds == nil || snappedOunces == nil) {
                // Not calling setAnswer:defaultAnswerValue to avoid infinite recursion
                [self resetAnswerToDefault];
                return;
            }
            _answer = @(ORKPoundsAndOuncesToKilograms(snappedPounds.doubleValue, snappedOunces.doubleValue));
            NSUInteger poundsIndex = [_majorValues indexOfObject:snappedPounds];
            NSUInteger ouncesIndex = [_minorValues indexOfObject:snappedOunces];
            if (![_pickerDelegate isOptional]) {
                poundsIndex = poundsIndex + 1;
                ouncesIndex = ouncesIndex + 1;
            }
            [_pickerView selectRow:poundsIndex inComponent:0 animated:NO];
            [_pickerView selectRow:ouncesIndex inComponent:1 animated:NO];
        }
    }
}

- (id)answer {
    return _answer;
}

- (NSNumber *)defaultAnswerValue {
    double defaultValue = ORKDoubleDefaultValue;
    if (_answerFormat.defaultValue == ORKDoubleDefaultValue) {
        if (_answerFormat.useMetricSystem) {
            defaultValue = 60.00; // Default metric weight: 60 kg
        } else {
            defaultValue = 60.33; // Default USC weight: 133 lbs
        }
    } else {
        if (_answerFormat.useMetricSystem) {
            defaultValue = _answerFormat.defaultValue;
        } else {
            defaultValue = ORKPoundsToKilograms(_answerFormat.defaultValue); // Convert to kg
        }
    }
    // Ensure default value is within bounds
    if ((_canonicalMinimumValue != ORKDoubleDefaultValue) && (defaultValue < _canonicalMinimumValue)) {
        defaultValue = _canonicalMinimumValue;
    } else if ((_canonicalMaximumValue  != ORKDoubleDefaultValue) && (defaultValue > _canonicalMaximumValue)) {
        defaultValue = _canonicalMaximumValue;
    }
    
    return @(defaultValue);
}

- (NSNumber *)selectedAnswerValue {
    NSNumber *answer = nil;
    if (_answerFormat.useMetricSystem) {
        NSInteger wholeRow = [self fetchSelectedRowInComponent:0];;
        
        if (![_pickerDelegate isOptional] && wholeRow == -1) {
            return nil;
        }
        
        NSNumber *whole = _majorValues[wholeRow];
        if (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) {
            answer = @( whole.doubleValue );
        } else {
            NSInteger fractionRow = [self fetchSelectedRowInComponent:1];
            
            if (![_pickerDelegate isOptional] && fractionRow == -1) {
                return nil;
            }
            
            NSNumber *fraction = _minorValues[fractionRow];
            answer = @( ORKWholeAndFractionToKilograms(whole.doubleValue, fraction.doubleValue) );
        }
    } else {
        NSInteger poundsRow = [self fetchSelectedRowInComponent:0];
        
        if (![_pickerDelegate isOptional] && poundsRow == -1) {
            return nil;
        }
        
        NSNumber *pounds = _majorValues[poundsRow];
        if (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) {
            answer = @( ORKPoundsToKilograms(pounds.doubleValue) );
        } else {
            NSInteger ouncesRow = [self fetchSelectedRowInComponent:1];
            
            if (![_pickerDelegate isOptional] && ouncesRow == -1) {
                return nil;
            }
            
            NSNumber *ounces = _minorValues[ouncesRow];
            answer = @( ORKPoundsAndOuncesToKilograms(pounds.doubleValue, ounces.doubleValue) );
        }
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
    // Report current value, since ORKWeightPicker always has a value
    [self pickerView];
    // only do the assignment that's done in `valueDidChange`
    _answer = [self selectedAnswerValue];
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
    return (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) ? 1 : (_answerFormat.useMetricSystem ? 3 : 2);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    if (component == 0) {
        numberOfRows = _majorValues.count;
    } else if (component == 1) {
        numberOfRows = _minorValues.count;
    } else {
        numberOfRows = 1;
    }
    return  ![_pickerDelegate isOptional] && (component < 2) ? numberOfRows + 1 : numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSInteger currentRow = row;
    
    if (![self.pickerDelegate isOptional] && component < 2) {
        
        if (row == 0) {
            return @"";
        } else {
            currentRow = row - 1;
        }
    }
    
    NSString *title = nil;
    if (_answerFormat.useMetricSystem) {
        if (component == 0) {
            if (_answerFormat.numericPrecision != ORKNumericPrecisionHigh) {
                title = [NSString stringWithFormat:@"%@ %@", _majorValues[currentRow], ORKLocalizedString(@"MEASURING_UNIT_KG", nil)];
            } else {
                title = [NSString stringWithFormat:@"%@", _majorValues[currentRow]];
            }
        } else if (component == 1) {
            NSNumberFormatter *formatter = ORKDecimalNumberFormatter();
            formatter.minimumIntegerDigits = 2;
            formatter.maximumFractionDigits = 0;
            title = [NSString stringWithFormat:@".%@", [formatter stringFromNumber:_minorValues[currentRow]]];
        } else if (component == 2) {
            title = ORKLocalizedString(@"MEASURING_UNIT_KG", nil);
        }
    } else {
        if (component == 0) {
            title = [NSString stringWithFormat:@"%@ %@", _majorValues[currentRow], ORKLocalizedString(@"MEASURING_UNIT_LB", nil)];
        } else {
            title = [NSString stringWithFormat:@"%@ %@", _minorValues[currentRow], ORKLocalizedString(@"MEASURING_UNIT_OZ", nil)];
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

- (NSArray *)kilogramValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];

    double minimumValue = 0;
    double maximumValue = 657;
    if ((_answerFormat.minimumValue != ORKDoubleDefaultValue) && (_answerFormat.minimumValue <= maximumValue)) {
        minimumValue = _answerFormat.minimumValue;
    }
    if ((_answerFormat.maximumValue != ORKDoubleDefaultValue) && (_answerFormat.maximumValue >= minimumValue)) {
        maximumValue = _answerFormat.maximumValue;
    }
    _canonicalMinimumValue = minimumValue;
    _canonicalMaximumValue = maximumValue;
    
    for (NSInteger i = minimumValue; i <= maximumValue; i++) {
        [mutableWholeValues addObject:@(i)];
        if (_answerFormat.numericPrecision == ORKNumericPrecisionDefault) {
            double preciseValue = i + 0.5;
            [mutableWholeValues addObject:@(preciseValue)];
        }
    }
    wholeValues = [mutableWholeValues copy];
    return wholeValues;
}

- (NSArray *)poundValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];

    double minimumValue = 0;
    double maximumValue = 1450;
    if ((_answerFormat.minimumValue != ORKDoubleDefaultValue) && (_answerFormat.minimumValue <= maximumValue)) {
        minimumValue = _answerFormat.minimumValue;
    }
    if ((_answerFormat.maximumValue != ORKDoubleDefaultValue) && (_answerFormat.maximumValue >= minimumValue)) {
        maximumValue = _answerFormat.maximumValue;
    }
    _canonicalMinimumValue = ORKPoundsToKilograms(minimumValue); // Convert to kg
    _canonicalMaximumValue = ORKPoundsToKilograms(maximumValue); // Convert to kg
    
    for (NSInteger i = minimumValue; i <= maximumValue; i++) {
        [mutableWholeValues addObject:[NSNumber numberWithInteger:i]];
    }
    wholeValues = [mutableWholeValues copy];
    return wholeValues;
}

- (NSArray *)_minorValues {
    NSArray *wholeValues = nil;
    NSMutableArray *mutableWholeValues = [[NSMutableArray alloc] init];
    
    NSInteger maximumValue = 99;
    if (!_answerFormat.useMetricSystem) {
        maximumValue = 15;
    }
    for (NSInteger i = 0; i <= maximumValue; i++) {
        [mutableWholeValues addObject:@(i)];
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
