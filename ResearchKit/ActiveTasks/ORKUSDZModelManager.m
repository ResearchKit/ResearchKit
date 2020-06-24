/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>
#import <SceneKit/SceneKit.h>
#import "ORKUSDZModelManager.h"
#import "ORKUSDZModelManagerResult.h"
#import "ORKUSDZModelManagerScene.h"
#import "ORKHelpers_Internal.h"

@implementation ORKUSDZModelManager {
    ORKUSDZModelManagerScene *_usdzModelManagerScene;
    
    UIActivityIndicatorView *_spinner;
    
    SCNView *_sceneView;
    SCNNode *_lastSelectedNode;
    
    UIView *_parentView;
    
    NSMutableArray<NSString *> *_selectedObjects;
}

- (instancetype)initWithUSDZFileName:(NSString *)fileName {
    self = [super init];
    
    if (self) {
        _fileName = fileName;
        _enableContinueAfterSelection = NO;
    }
    
    return self;
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ORKUSDZModelManager *step = [super copyWithZone:zone];
    step.fileName = [self.fileName copy];
    step.enableContinueAfterSelection = self.enableContinueAfterSelection;
    return step;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self ) {
        ORK_DECODE_OBJ_CLASS(aDecoder, fileName, NSString);
        ORK_DECODE_BOOL(aDecoder, enableContinueAfterSelection);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    ORK_ENCODE_OBJ(aCoder, fileName);
    ORK_ENCODE_BOOL(aCoder, enableContinueAfterSelection);
}

- (BOOL)isEqual:(id)object {
    BOOL isParentSame = [super isEqual:object];
    
    __typeof(self) castObject = object;
    return (isParentSame &&
            ORKEqualObjects(self.fileName, castObject.fileName) &&
            (self.enableContinueAfterSelection == castObject.enableContinueAfterSelection));
}

- (NSUInteger)hash
{
    return [super hash] ^ [_fileName hash] ^ (_enableContinueAfterSelection ? 0xf : 0x0);
}

- (void)setSpinnerConstraints {
    _spinner.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[_spinner.centerYAnchor constraintEqualToAnchor:_parentView.centerYAnchor] setActive:YES];
    [[_spinner.centerXAnchor constraintEqualToAnchor:_parentView.centerXAnchor] setActive:YES];
}

- (void)setupSceneViewConstraints {
    if (_spinner) {
        [_spinner stopAnimating];
        [_spinner removeFromSuperview];
        _spinner = nil;
    }
    
    [[_sceneView.topAnchor constraintEqualToAnchor:_parentView.topAnchor] setActive:YES];
    [[_sceneView.trailingAnchor constraintEqualToAnchor:_parentView.trailingAnchor] setActive:YES];
    [[_sceneView.leadingAnchor constraintEqualToAnchor:_parentView.leadingAnchor] setActive:YES];
    [[_sceneView.bottomAnchor constraintEqualToAnchor:_parentView.bottomAnchor] setActive:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint touchPoint = [gesture locationInView:_sceneView];
    NSArray<SCNHitTestResult *> *hitTestResults = [_sceneView hitTest:touchPoint options:nil];
    
    if (hitTestResults.count > 0) {
        SCNHitTestResult *hitTestResult = hitTestResults.firstObject;
        [_usdzModelManagerScene handleTapWithHitTestResult:hitTestResult];
        
        if (self.enableContinueAfterSelection) {
         [self setContinueEnabled:![_usdzModelManagerScene currentSelectedNode] ? NO : YES];
        }
    }
}

#pragma mark - ORK3DModelManagerProtocol

- (void)addContentToView:(UIView *)view {
    [self setContinueEnabled:!self.enableContinueAfterSelection];
    _parentView = view;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_parentView addSubview:_spinner];
    [self setSpinnerConstraints];
    [_spinner startAnimating];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:_fileName withExtension:@"usdz"];
    
    if (url) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MDLAsset *mdlAsset = [[MDLAsset alloc] initWithURL:url];
            [mdlAsset loadTextures];
            _usdzModelManagerScene = [[ORKUSDZModelManagerScene alloc] initWithMDLAsset:mdlAsset
                                                                        hightlightColor:self.highlightColor
                                                                               fileName:_fileName];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                _sceneView = [SCNView new];
                _sceneView.scene = _usdzModelManagerScene;
                [_sceneView setAllowsCameraControl:YES];
                [_sceneView setAutoenablesDefaultLighting:YES];
                [_sceneView setAntialiasingMode:SCNAntialiasingModeMultisampling4X];
                _sceneView.translatesAutoresizingMaskIntoConstraints = NO;
                
                if (@available(iOS 13.0, *)) {
                    _sceneView.backgroundColor = [UIColor secondarySystemBackgroundColor];
                }
                
                [_parentView addSubview:_sceneView];
                [self setupSceneViewConstraints];
                
                if (self.allowsSelection) {
                    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
                    [_sceneView addGestureRecognizer:tapRecognizer];
                }
                
                if (self.identifiersOfObjectsToHighlight) {
                    [_usdzModelManagerScene hightlightModelObjectsWithIdentifiers:self.identifiersOfObjectsToHighlight];
                }
                
            });
        });
        
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"The file named \"%@\" was not found.", _fileName]  userInfo:nil];
    }
}

- (void)stepWillEnd {
    if (_sceneView) {
        _sceneView.scene = nil;
    }
}

- (NSArray<ORKResult *> *)provideResults {
    SCNNode *currentSelectedNode = [_usdzModelManagerScene currentSelectedNode];
    
    ORKUSDZModelManagerResult *result = [ORKUSDZModelManagerResult new];
    result.identifierOfObjectSelectedAtClose = currentSelectedNode.name;
    result.identifiersOfSelectedObjects = [_usdzModelManagerScene selectedNodeIdentifierHistory];
    
    return @[result];
}

@end
