## ResearchKit Coding Style Guide

Always follow [Coding Guidelines for Cocoa](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html) for naming variables, properties, methods, classes and functions. Do not use any abbreviations except the ones mentioned in [Acceptable Abbreviations and Acronyms](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CodingGuidelines/Articles/APIAbbreviations.html#//apple_ref/doc/uid/20001285-BCIHCGAE).


### 1. Visual Style

#### 1.1. Whitespace

##### Indent with Spaces

Use groups of 4 spaces (instead of tabs) to denote different indentation levels.

*Xcode* does this by default. Double-check your settings in: `Preferences -> Text Editing -> Indentation`.

![Xcode indentation settings](https://cloud.githubusercontent.com/assets/444313/7571539/25cced36-f810-11e4-8568-b824838a7070.png)

##### Spaces in Declarations

In `@interface` declarations, there should be one space between: the subclass name; the colon symbol; the superclass name; the adopted protocols section; any adopted protocols.

    // DO
    @interface ORKProtocolAdoptingClass : NSObject <ORKProtocolA, ORKProtocolB>

    // DON'T
    @interface ORKProtocolAdoptingClass:NSObject <ORKProtocolA, ORKProtocolB>
    @interface ORKProtocolAdoptingClass : NSObject<ORKProtocolA, ORKProtocolB>
    @interface ORKProtocolAdoptingClass : NSObject <ORKProtocolA,ORKProtocolB>

---

In `@property` declarations, there should be one space between: the `@property` keyword; the property attributes section; any property attributes; the property type; and the pointer asterisk.

    // DO
    @property (nonatomic, weak) UIView<DelegateProtocol> *delegate;

    // DON'T
    @property (nonatomic,weak) UIView <DelegateProtocol> *delegate;
    @property(nonatomic, weak) UIView <DelegateProtocol> *delegate;
    @property (nonatomic, weak) UIView<DelegateProtocol>*delegate;

---

In *method* declarations, there should be one space between: the `-` or `+` character and the `(returnType)`; an argument type and its pointer asterisk.

    // DO
    - (void)doSomethingWithString:(NSString *)string number:(NSNumber *)number

    // DON'T
    - (void)doSomethingWithString:(NSString*)string number:(NSNumber *)number
    -(void)doSomethingWithString:(NSString *)string number:(NSNumber *)number
    - (void)doSomethingWithString:(NSString *)string  number:(NSNumber *)number

##### Spaces between Operators

Use spaces if the operator has two or more arguments:

    // DO
    a += 2
    a = 5
    z == 3
    aFlag && aBoolean
    zOrder > 4
    success ? YES : NO

Omit the space when the operator takes only one argument:

    // DO
    a++
    &var
    !success


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

Hard wrap lines that exceed 140 characters. You can configure the column guide on *Xcode*: `Preferences -> Text Editing -> Page guide at column: 140`. 

When hard wrapping method calls, give each parameter its own line. Align each parameter using the colon before the parameter (*Xcode* does this for you by default).

    // DO
    - (void)doSomethingWith:(Foo *)foo
                       rect:(NSRect)rect
                   interval:(float)interval {
        ...

Method invocations should be formatted much like method declarations. Invocations should have all arguments on one line or have one argument per line, with colons aligned.

    // DO
    [myObject doFooWith:arg1 name:arg2 error:arg3];

    [myObject doFooWith:arg1
                   name:arg2
                  error:arg3];

    // DON'T
    [myObject doFooWith:arg1 name:arg2
                  error:arg3];

    [myObject doFooWith:arg1
              name:arg2
              error:arg3];

#### 1.4. Appledoc Header Comments

*ResearchKit* uses [appledoc](http://appledoc.gentlebytes.com/appledoc/) to generate its documentation from specially marked comments in header files.

Follow these guidelines when writing *appledoc comments*:

- Multiline *appledoc comments* start with the `/**` character sequence.
- When documenting methods, use the `@param` and `@return` keywords to detail the parameters and return value.
- When you name classes or methods, enclose them in backticks so *appledoc* creates a reference (`` `ORKStep` is ...``).
- For multiline code examples, surround them with a triple backtick (```) for cross references within the code block not to be automatically generated.
- Don't use abbreviations such as *e.g.* or *i.e.* in the documentation.
- Hard wrap comment lines at column 100.
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


#### 1.6. Header File Example

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

    @end


    /**
     appledoc class comment.
     */
    ORK_CLASS_AVAILABLE
    @interface ORKMyOtherClass : ORKMyClass

    @end 

    NS_ASSUME_NONNULL_END


### 2. Code Style

#### 2.1. Variable Declarations

Declare one variable per line even if they have the same type. In general it's a good idea to initialize primitive type variables with a reasonable value.

    // DO
    int floatVariable = -1;
    double doubleVariable = 0.0;
    int *cPointerVariable = NULL;

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


#### 2.2. Forward Declarations

Use one line for each forward declarations:

    // DO
    @protocol forwardProtocol;
    @class aClass;
    @class anotherClass;
    @class yetAnotherClass;

    // DON'T
    @protocol forwardProtocol, anotherProtocol;
    @class aClass, anotherClass, yetAnotherClass;


#### 2.3. Dot Notation

Dot notation is syntactic sugar added in Objective-C 2.0. Its usage is equivalent to using the auto-synthesized methods:

    - (PropertyType *)property
    - (void)setProperty:(PropertyType *)property

Dot notation may be used when accessing proper properties, but should not be used to invoke regular methods.

    // DO
    oldName = myObject.name;    // Equivalent to 'oldName = [myObject name]'
    myObject.name = @"Alice";   // Equivalent to '[myObject setName:@"Alice"]'

    // DON'T
    NSUInteger numberOfItems = array.count;     // Not a property
    NSUInteger stringLength = string.length;    // Not a property
    array.release;                              // Not a property
