/*
 Copyright (c) 2016, Sage Bionetworks
 
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


@import UIKit;
#import <ResearchKit/ORKStep.h>


NS_ASSUME_NONNULL_BEGIN

/**
 The `ORKTableStep` class is a concrete subclass of `ORKStep`, used for presenting a list of model 
 objects in a UITableView.
 
 To use `ORKTableStep`, instantiate the object, fill in its properties, and include it
 in a task. Next, create a task view controller for the task and present it.
 
 The base class implementation will instatiate a read-only `ORKTableStepViewController` to display 
 the list of items using `UITableViewCell` with the text set to the `-description` for each item in 
 the `items` array.
 
 Customization can be handled by overriding the base class implementations in either `ORKTableStep`
 or `ORKTableStepViewController`.
 */

ORK_CLASS_AVAILABLE
@interface ORKTableStep : ORKStep

/**
 The array of items in table. These items must conform to NSCopying and NSSecureCoding protocols.
 */
@property (nonatomic, copy, nullable) NSArray <id <NSObject, NSCopying, NSSecureCoding>> *items;

/**
 Returns the number of sections in the tableview used to display this step. Default = `1`.
 
 @return                The number of sections in the tableview.
 */
- (NSInteger)numberOfSections;

/**
 Returns the number of rows in the section. Default = `items.count`
 
 @param  section        The section of the table
 @return                The number of rows in the tableview section
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 Returns the model object for this section/row. Default = `items[indexPath.row]`
 
 @param  indexPath      The indexpath of the section/row for the cell
 @return                The model object for this section/row
 */
- (id <NSObject, NSCopying, NSSecureCoding>)objectForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the reuseIdentifier for the object at this index path. Default = `ORKBasicCellReuseIdentifier`
 
 @param  indexPath      The indexpath of the section/row for the cell
 @return                The model object for this section/row
 */
- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Optional override for registering UITableViewCell instances. The default registers for `ORKBasicCellReuseIdentifier`.
 */
- (void)registerCellsForTableView:(UITableView *)tableView;

/**
 Optional override for configuring a cell. The default will set the text label using the object description for
 the object at a given index path.
 */
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
