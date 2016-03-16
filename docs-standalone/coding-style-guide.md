## ResearchKit Coding Style Guide

Always follow the [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html) for naming variables, properties, methods, classes and functions. Do not use any abbreviations except the ones mentioned in [Acceptable Abbreviations and Acronyms](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/APIAbbreviations.html#//apple_ref/doc/uid/20001285-BCIHCGAE).


### 1. Visual Style

#### 1.1. Whitespace

##### Indent with Spaces

Use groups of 4 spaces (instead of tabs) to denote different indentation levels.

*Xcode* does this by default. Double-check your settings in: `Preferences -> Text Editing -> Indentation`.

![Xcode indentation settings](https://cloud.githubusercontent.com/assets/444313/7571539/25cced36-f810-11e4-8568-b824838a7070.png)

##### Spaces in Declarations

Single spaces should be used in the cases detailed in this section. Don't use double spaces and don't add spaces elsewhere.

---

In `@interface` declarations, there should be one space between: the subclass name; the colon symbol; the superclass name; the adopted protocols section; and any adopted protocols.

    // DO
    @interface ORKProtocolAdoptingClass : NSObject <ORKProtocolA, ORKProtocolB>

    // DON'T
    @interface ORKProtocolAdoptingClass:NSObject <ORKProtocolA, ORKProtocolB>
    @interface ORKProtocolAdoptingClass : NSObject<ORKProtocolA, ORKProtocolB>
    @interface ORKProtocolAdoptingClass : NSObject <ORKProtocolA,ORKProtocolB>

---

In `@property` declarations, there should be one space between: the `@property` keyword; the property attributes section; any property attribute; the property type; and the pointer asterisk.

    // DO
    @property (nonatomic, weak, nullable) id<ORKDelegateProtocol> delegate;

    // DON'T
    @property(nonatomic, weak, nullable) id <ORKDelegateProtocol> delegate;
    @property (nonatomic,weak,nullable) id <ORKDelegateProtocol> delegate;
    @property (nonatomic, weak, nullable) id<ORKDelegateProtocol>delegate;

---

In *method* declarations, there should be one space between: the `-` or `+` character and the `(returnType)`; and any argument type and its pointer asterisk.

    // DO
    - (void)doSomethingWithString:(NSString *)string number:(NSNumber *)number

    // DON'T
    -(void)doSomethingWithString:(NSString *)string number:(NSNumber *)number
    - (void)doSomethingWithString:(NSString*)string number:(NSNumber *)number
    - (void)doSomethingWithString:(NSString *)string  number:(NSNumber *)number

---

In *variable* declarations, add one space between the type and the pointer asterisk, and omit it between the asterisk and the variable name.

Similarly, omit the space between the asterisk and non-prefixed variable modifiers such as `const`. On the other hand, use one exactly one space before underscored annotations such as `_Nullable` or `_Nonnull`.

    // DO
    ORKTask *task = [ORKTask new];
    static NSString *const ActivityUnknown = @"unknown";
    CGFloat ORKWidthForSignatureView(UIWindow * _Nullable window);
    - (BOOL)recreateFileWithError:(NSError * _Nullable *)error;


##### Spaces between Operators

Use spaces if the operator has two or more arguments:

    // DO
    steps += 2
    calories = 5
    calories == caloryGoal
    goalAchieved && notReminded
    flightsClimbed > 4
    success ? YES : NO

Omit the space when the operator takes only one argument:

    // DO
    calories++
    &error
    !success


##### Spaces in array and dictionary literals

Add exactly one space before the first and after the last element in array and dictionary literals. Use exactly one space after each comma-separated element. Do not add any space between the key and the colon symbol on dictionary literals, but add exactly one space between the colon and the pointed object.

    // DO
    @[ @"Abdomen", @"Chest", @"Back" ];         // Array literal
    @{ @"red": redImage, @"blue": blueImage };  // Dictionary literal

    // DON'T
    @[ @"Abdomen",@"Chest",@"Back" ];
    @{ @"red" : redImage, @"blue":blueImage };


#### 1.2. Brackets

Opening brackets should be on the same line as the statement they refer to. Closing brackets should be on their own line, except when followed by `else`.

    // DO
    - (void)doSomethingWithString:(NSString *)string {
        if (condition) {
            ...
        } else {
            ...
        }
    }

    // DON'T
    - (void)doSomethingWithString:(NSString *)string
    {
        if (condition)
        {
            ...
        }
        else
        {
            ...
        }
    }

Always use brackets even when the conditional code is only one statement.

    // DO
    if (condition) {
        return;
    }

    // DON'T
    if (condition)
        return;


#### 1.3. Line Wrapping

Hard-wrap lines that exceed 140 characters. You can configure the column guide on *Xcode*: `Preferences -> Text Editing -> Page guide at column: 140`.

When hard-wrapping method calls, give each parameter its own line. Align each parameter using the colon before the parameter (*Xcode* does this for you by default).

    // DO
    - (void)doSomethingWithFoo:(Foo *)foo
                           bar:(Bar *)bar
                      interval:(NSTimeInterval)interval {
        ...

Method invocations should be formatted much like method declarations. Invocations should have all arguments on one line or have one argument per line, with colons aligned.

    // DO
    [myObject doSomethingWithFoo:foo bar:bar interval:interval];

    [myObject doSomethingWithFoo:foo
                             bar:bar
                        interval:interval];

    // DON'T
    [myObject doSomethingWithFoo:foo bar:bar
                        interval:interval];

    [myObject doSomethingWithFoo:foo
              bar:bar
              interval:interval];

#### 1.4. Appledoc Header Comments

*ResearchKit* uses [appledoc](http://appledoc.gentlebytes.com/appledoc/) to generate its documentation from specially marked comments in header files.

Follow these guidelines when writing *appledoc comments*:

- Multiline *appledoc comments* start with the `/**` character sequence.
- When documenting methods, use the `@param` and `@return` keywords to detail the parameters and return value.
- When you name classes or methods, enclose them in backticks so *appledoc* creates a reference (`` `ORKStep` is ...``).
- For multiline code examples, surround them with a triple backtick (```) for cross references within the code block not to be automatically generated.
- Don't use abbreviations such as *e.g.* or *i.e.* in the documentation.
- Hard-wrap comment lines at column 100.
- Read the latest *ResearchKit* documentation for inspiration and try to follow the same literary style.

#### 1.5. Newlines

Use exactly two empty lines to separate:

- The `/* Copyright header */` and the `#import` section.
- The `#import` section and the class `@interface` or `@implementation` line (or its associated *forward declarations* or *appledoc comment*).
- Different `@interface` or `@implementation` sections within the same file.

Do not use two or more empty lines in any other cases.

Use exactly one empty line to separate:

- The last *forward declaration* and the *`@interface` declaration*.
- The *`@interface` declaration* and the first *method* or *property declaration*.
- The last *method* or *property declaration* and the *`@end` keyword*.
- The *`@implementation` line* and the first *method definition*.
- The closing bracket of the last *method definition* and the *`@end` keyword*.
- The *`@param` section* and the *`@return` line* in an *appledoc comment*.

*Header* and *implementation* files must have one, and only one, trailing empty line.

Do not use empty lines to separate:

- *Forward declarations* from other contiguous *forward declarations*.
- An *appledoc comment* from its related *class* or *method*.
- Contiguous *`@param` lines* within the same *appledoc comment*.
- Last statement in a method definition and its closing bracket.

Note that *forward declarations* should appear before any *class appledoc comment*.

You can optionally use one (and only one) blank like to separate:

- Groups of related `#import` statements.
- Groups of related statements in a single method implementation.



### 2. Code Style

#### 2.1. Variable Declarations

Declare one variable per line even if they have the same type. In general it's a good idea to initialize primitive type variables with a reasonable value.

    // DO
    int floatVariable = -1;
    double doubleVariable = 0.0;
    int *cPointerVariable = NULL;
    CGContextRef context = NULL;

Strong, weak, and autoreleasing stack variables are [implicitly initialized with `nil`](https://developer.apple.com/library/ios/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html#//apple_ref/doc/uid/TP40011226-CH1-SW5) so you can either explicitly initialize them (with `nil` or any valid object) for visual homogeneity, or skip initializing them altogether.

    // DO
    id object = nil;
    NSString *string = nil;
    UIView *view = nil;
    // ALSO OK
    id object;
    NSString *string;
    UIView *view;

When declaring pointers, there should be a space between the asterisk and the variable type, but none between the asterisk and the variable.

    // DON'T
    int* variablePointer2;
    int* variablePointer, variable;
    UIView* view;


#### 2.2. Forward Declarations

Use one line for each forward declarations:

    // DO
    @protocol ORKProtocol;
    @protocol ORKAnotherProtocol;
    @class ORKClass;
    @class ORKAnotherClass;
    @class ORKYetAnotherClass;

    // DON'T
    @protocol ORKProtocol, ORKAnotherProtocol;
    @class ORKClass, ORKAnotherClass, ORKYetAnotherClass;


#### 2.3. Constant Declarations

If a constant is only used inside one method, declare it locally to that method. If a constant is used in several methods of a single class, declare it as a `static` constant in the class implementation file. If a constant is used from several files, declare it as an `extern` constant and prefix its name with a suitable `ORK*` prefix.

Static or global constant names should start in uppercase. Constants should never start with the `k` prefix (that naming convention is deprecated). These rules also apply to `enum` value names.

    // Method-local constant
    - (void)animateView {
        const CGFloat animationDuration = 0.2;
        ...
    }


    // Class-local constant
    static const CGFloat DefaultLineWidth = 10.0;
    - (void)init {
        if (self = [super init]) {
            _lineWidth = DefaultLineWidth
            ...
        }
        return self;
    }

    - (void)resetView {
        _lineWidth = DefaultLineWidth
        ...
    }


    // Global constant

    // ORKSkin.h
    ORK_EXTERN NSString *const ORKToolBarTintColorKey;
    ORK_EXTERN const CGFloat ORKScreenMetricMaxDimension;

    // ORKSkin.m
    NSString *const ORKBackgroundColorKey = @"ORKBackgroundColorKey";
    const CGFloat ORKScreenMetricMaxDimension = 10000.0;


    // Global enum
    typedef NS_ENUM(NSInteger, ORKQuestionType) {
        ORKQuestionTypeNone,
        ORKQuestionTypeScale,
        ...
    } ORK_ENUM_AVAILABLE;



#### 2.4. Dot Notation

Dot notation (`object.property`) is a syntax for using properties in a convenient and compact way. Accessing or setting a property through dot notation is completely equivalent to calling the property accessor methods:

    - (PropertyType *)property
    - (void)setProperty:(PropertyType *)property

    // DO
    NSString *oldName = user.name;              // Equivalent to 'NSString *oldName = [user name]'
    user.name = @"John Appleseed";              // Equivalent to '[user setName:@"John Appleseed"]'

Dot notation should be used when accessing proper properties, but should be avoided when invoking regular methods. Use the syntax corresponding to the official documentation or relevant header declaration.

    // DO
    CGRect viewFrame = view.frame;                                      // Declared as a property
    NSUInteger numberOfItems = array.count;                             // Declared as a property since iOS 8
    NSUInteger stringLength = string.length;                            // Declared as a property since iOS 8
    [autoreleasePool drain];                                            // A method
    NSArray<NSLayoutConstraint *> *constraints = [view constraints];    // A method

    // DON'T
    CGRect viewFrame = [view frame];                                    // 'frame' is not declared as a method
    NSUInteger numberOfItems = [array count];                           // 'count' is no longer declared as a method
    NSUInteger stringLength = [string length];                          // 'length' is no longer declared as a method
    autoreleasePool.drain;                                              // Not a property
    NSArray<NSLayoutConstraint *> *constraints = view.constraints;      // Not a property

#### 2.5. Nullability Annotations

Always include [*nullability annotations*](https://developer.apple.com/swift/blog/?id=25) in header files.

Generally, it's a good idea to make the entirety of headers as *audited for nullability*, which makes any simple pointer type to be assumed as `nonnull` by the compiler. You do this by wrapping the whole file with the `NS_ASSUME_NONNULL_BEGIN` and `NS_ASSUME_NONNULL_END` macros. You can then opt any property or argument declaration that can take `nil` values out by annotating it as `nullable`.

    // DO

    NS_ASSUME_NONNULL_BEGIN

    - (instancetype)initWithStep:(nullable ORKStep *)step;
    @property (nonatomic, copy, nullable) NSString *aNullableProperty;

    NS_ASSUME_NONNULL_END


When annotating function or blocks, use the `_Nullable` keyword (available since Xcode 7), instead of the legacy `__nullable`.

    // DO
    CGFloat ORKWidthForSignatureView(UIWindow * _Nullable window);

    // DON'T
    CGFloat ORKWidthForSignatureView(UIWindow * __nullable window);

Do not add *nullability annotations* to implementation files.

See **Section 3** for a nullability-annotated *Header File Example*.


#### 2.6. Lightweight Generics

Always use [*lightweight generic parametrization*](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithObjective-CAPIs.html#//apple_ref/doc/uid/TP40014216-CH4-ID173) when declaring `NSArray`, `NSSet` and `NSDictionary` types. This tells the compiler which kind of objects these *Foundation collection classes* will contain. It improves type-safety and interoperability with *Swift*.

Use the same whitespace rules as when declaring *protocol conformance*, but omit the space between the type and the opening bracket:

    // DO
    @property NSArray<ORKStep *> *steps;
    @property NSDictionary<NSString *, ORKStepNavigationRule *> *stepNavigationRules;
    @property NSSet<ORKTask *> *tasks;

    // DON'T
    @property NSArray <ORKStep *>*steps;
    @property NSDictionary<NSString *,ORKStepNavigationRule *> *stepNavigationRules;
    @property NSSet<ORKTask*> *tasks;


### 3. Header File Example

    /*
     Copyright (c) 2015, John Appleseed. All rights reserved.
     ...
     */


    #import <Foundation/Foundation.h>
    #import <ResearchKit/ORKDefines.h>


    NS_ASSUME_NONNULL_BEGIN

    @protocol ORKTask;
    @class ORKStep;

    /**
     appledoc class comment.
     */
    ORK_CLASS_AVAILABLE
    @interface ORKMyClass : NSObject <NSSecureCoding, NSCopying>

    /**
     appledoc method comment.

     @param parameterA   The first parameter.
     @param parameterB   The second parameter.

     @return A new MyClass.
     */
    - (instancetype)initWithParameterA:(NSString *)parameterA parameterB:(NSString *)parameterB NS_DESIGNATED_INITIALIZER;

    /**
     appledoc property comment.
     */
    @property (nonatomic, copy, readonly) NSString *aProperty;

    /**
     appledoc property comment.
     */
    @property (nonatomic, copy, nullable) NSString *aNullableProperty;

    @end


    /**
     appledoc class comment.
     */
    ORK_CLASS_AVAILABLE
    @interface ORKMyOtherClass : ORKMyClass

    @end

    NS_ASSUME_NONNULL_END
