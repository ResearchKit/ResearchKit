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
 The `ORKTableStepSource` is a protocol that can be used for presenting a list of model
 objects in a UITableView. Any `ORKStep` subclass that implements this protocol can be used with
 an `ORKTableStepViewController` to display the list of items.
 */
@protocol ORKTableStepSource <NSObject>
    
/**
 Returns the number of rows in the section.
 
 @param  section        The section of the table
 @return                The number of rows in the tableview section
 */
- (NSInteger)numberOfRowsInSection:(NSInteger)section;

/**
 Method for configuring a cell.
 
 @param cell            The `UITableViewCell` to configure.
 @param indexPath       The indexpath for the cell.
 @param tableView       The table view for this cell.
 */
- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

/**
 Returns the number of sections in the tableview used to display this step. Default = `1`.
 
 @return                The number of sections in the tableview.
 */
@optional
- (NSInteger)numberOfSections;

/**
 Returns the reuseIdentifier for the object at this index path. Default = `ORKBasicCellReuseIdentifier`
 
 @param  indexPath      The indexpath of the section/row for the cell
 @return                The model object for this section/row
 */
@optional
- (NSString *)reuseIdentifierForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Optional override for registering UITableViewCell instances. The default registers a `UITableViewCell` 
 for `ORKBasicCellReuseIdentifier`.
 
 @param tableView       The table view to register cells
 */
@optional
- (void)registerCellsForTableView:(UITableView *)tableView;

/**
 Optional override to return custom header title for section. The default returns `nil`.
 
 @param section         The section for this custom header title
 @param tableView       The table view for custom section header title
 
 @return                The custom header title for this section
 */
@optional
- (nullable NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;

/**
 Optional override to return custom header view for section. The default returns `nil`.
 
 @param section         The section for this custom header view
 @param tableView       The table view for custom section header view
 
 @return                The custom header view for this section
 */
@optional
- (nullable UIView *)viewForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;

@end

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
@interface ORKTableStep : ORKStep <ORKTableStepSource>

/**
 The array of items in table. These items must conform to NSCopying and NSSecureCoding protocols.
 */
@property (nonatomic, copy, nullable) NSArray <id <NSObject, NSCopying, NSSecureCoding>> *items;

/**
 Boolean flag representing if the table data should be displayed in a bulleted format.
 */
@property (nonatomic) BOOL isBulleted;

/**
 The array of icon names to display instead of bullets.
 
 Images are only visible if the isBulleted property is set to YES. Images names must reference
 images in you application project not the ResearchKit framework.
 */
@property (nonatomic, copy, nullable) NSArray <NSString *> *bulletIconNames;

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
