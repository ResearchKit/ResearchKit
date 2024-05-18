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

#import "ORKUSDZModelManagerScene.h"
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>



@implementation ORKUSDZModelManagerScene {
    SCNNode *_cameraAttachNode;
    SCNNode *_cameraNode;
    SCNNode *_lastTouchedNode;
    NSInteger _lastTouchedNodeGeoIndex;
    UIColor *_lastTouchedNodeInitialColor;
    
    UIColor *_highlightColor;
    
    NSMutableArray<NSString *> *_selectedNodeIdentifierHistory;
    NSMutableArray<NSString *> *_objectsToHighlight;
    
    NSString *_fileName;
}

- (instancetype)initWithMDLAsset:(MDLAsset *)mdlAsset hightlightColor:(UIColor *)hightlightColor fileName:(NSString *)fileName {
    self = [ORKUSDZModelManagerScene sceneWithMDLAsset:mdlAsset];
    
    if (self) {
        _cameraNode = [SCNNode new];
        _cameraAttachNode = [SCNNode new];
        _highlightColor = hightlightColor;
        _selectedNodeIdentifierHistory = [NSMutableArray new];
        _objectsToHighlight = [NSMutableArray new];
        _fileName = fileName;
        [self setupLightsAndCamera];
    }
    
    return self;
}

- (void)setupLightsAndCamera {
    SCNNode *mainNode = [self.rootNode childNodeWithName:_fileName recursively:YES];
    
    if (mainNode) {
        SCNVector3 v1 = SCNVector3Make(0, 0, 0);
        SCNVector3 v2 = SCNVector3Make(0, 0, 0);
        [mainNode getBoundingBoxMin:&v1 max:&v2];
        
        CGFloat height = v2.y + -v1.y;
        CGFloat depth = v2.z + -v1.z;
        
        [_cameraNode setCamera:[SCNCamera new]];
        [_cameraNode setPosition:SCNVector3Make(0, height / 2, depth + height)];
        
        [self.rootNode addChildNode:_cameraNode];
    } 
}

- (void)hightlightModelObjectsWithIdentifiers:(NSArray<NSString *> *)modelObjects {
    _objectsToHighlight = [modelObjects copy];
    
    for (NSString *objectId in modelObjects) {
        SCNNode *node = [self.rootNode childNodeWithName:objectId recursively:YES];
        
        if (node) {
            [node.geometry.materials.firstObject.emission setContents:_highlightColor];
            [node setOpacity:1.0];
        }
    }
}

- (void)handleTapWithHitTestResult:(SCNHitTestResult *)hitTestResult {
    SCNNode *touchedNode = hitTestResult.node;
    
    UIColor *nodeCurrentColor = (UIColor *)[touchedNode.geometry.materials objectAtIndex:hitTestResult.geometryIndex].emission.contents;
    
    if (nodeCurrentColor) {
        
        if (_lastTouchedNode && _lastTouchedNode.name == touchedNode.name && _lastTouchedNodeGeoIndex == hitTestResult.geometryIndex) {
            [self deselectPreviousNode];
            return;
        } else if (nodeCurrentColor != _highlightColor) {
            [self deselectPreviousNode];
            
            //hightlight selected node
            [[touchedNode.geometry.materials objectAtIndex:hitTestResult.geometryIndex].emission setContents:_highlightColor];
            _lastTouchedNode = touchedNode;
            _lastTouchedNodeGeoIndex = hitTestResult.geometryIndex;
            _lastTouchedNodeInitialColor = nodeCurrentColor;
        }
        
        if (touchedNode.name) {
            [_selectedNodeIdentifierHistory addObject:touchedNode.name];
        }
        
    }
}

- (void)deselectPreviousNode {
    if (_lastTouchedNode) {
        [[_lastTouchedNode.geometry.materials objectAtIndex:_lastTouchedNodeGeoIndex].emission setContents:_lastTouchedNodeInitialColor];
        _lastTouchedNode = nil;
    }
}

- (NSArray<NSString *> *)selectedNodeIdentifierHistory {
    return [_selectedNodeIdentifierHistory copy];
}
- (nullable SCNNode *)currentSelectedNode {
    return _lastTouchedNode;
}

@end
