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

#import <Foundation/Foundation.h>

#import <ResearchKit/ORKTypes.h>


@class ORKTaskResult;
@class ORKFormStep;

NS_ASSUME_NONNULL_BEGIN

/**
 An object to represent a relative type displayed
 during a family health history survey.
 
 Example relative groups could be parents, children, or siblings.
 */

ORK_CLASS_AVAILABLE
@interface ORKRelativeGroup : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

/**
 Creates a new relative group with the specified identifier.
 
 This method is the primary designated initializer.
 
 @param identifier   The unique identifier of the relative group.
 @param name   The name of the relative group. This should be the singular representation.
 @param title   The table section title for the relative group.
 @param detailText   The detail text displayed in the table section header for the relative group.
 @param identifierForCellTitle   The identifier of the result value to be used for the relative's cell title.
 @param maxAllowed   The maximum amount of relatives that are allowed to be added by the participant.
 @param formSteps   The form steps that will precede the health conditions step during the survey.
 @param detailTextIdentifiers   The identifiers of each result value that will be displayed in the relative's card view.
 */

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                      sectionTitle:(NSString *)title
                 sectionDetailText:(NSString *)detailText
            identifierForCellTitle:(NSString *)identifierForCellTitle
                        maxAllowed:(NSUInteger)maxAllowed
                         formSteps:(NSArray<ORKFormStep *> *)formSteps
             detailTextIdentifiers:(NSArray<NSString *> *)detailTextIdentifiers NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *sectionTitle;
@property (nonatomic, readonly, copy) NSString *sectionDetailText;
@property (nonatomic, readonly, copy) NSString *identifierForCellTitle;
@property (nonatomic, readonly) NSUInteger maxAllowed;
@property (nonatomic, readonly, copy) NSArray<ORKFormStep *> *formSteps;
@property (nonatomic, readonly, copy) NSArray<NSString *> *detailTextIdentifiers;

@end

NS_ASSUME_NONNULL_END
