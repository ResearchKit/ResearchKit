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

#import <ResearchKitUI/ORKFormStepViewController_Private.h>

NS_ASSUME_NONNULL_BEGIN

@class ORKTableCellItemIdentifier;

@interface ORKFormStepViewController (TestingSupport)

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *savedAnswers;
- (void)decodeRestorableStateWithCoder:(NSCoder *)coder;
- (void)removeInvalidSavedAnswers;


/**
returns a list of all the formItems
 */
- (nonnull NSArray<ORKFormItem*> *)allFormItems;

/**
returns a list of all the visible formItems
 */
- (nonnull NSArray<ORKFormItem*> *)visibleFormItems;

/**
returns a list of all the answerable formItems
 */
- (nonnull NSArray<ORKFormItem*> *)answerableFormItems;

/**
 returns delegate_ongoingTaskResult from the ORKTaskViewController Delegate
 */
- (nonnull ORKTaskResult *)_ongoingTaskResult;

- (void)buildDataSource:(UITableViewDiffableDataSource<NSString *, ORKTableCellItemIdentifier *> *)dataSource withCompletion:(void (^ _Nullable)(void))completion;

/**
 fetches the associated ORKFormItem from an indexPath which calls  _formItemForFormItemIdentifier (potential performance hit)
 */
- (nullable ORKFormItem *)_formItemForIndexPath:(NSIndexPath *)indexPath;

/**
 fetches the associated ORKFormItem from a formItemIdentifier (potential performance hit)
 */
- (nullable ORKFormItem *)_formItemForFormItemIdentifier:(NSString *)formItemIdentifier;

@end

NS_ASSUME_NONNULL_END
