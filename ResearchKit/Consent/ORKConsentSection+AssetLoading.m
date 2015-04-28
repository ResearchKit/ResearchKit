/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
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


#import "ORKConsentSection+AssetLoading.h"
#import "ORKHelpers.h"


static NSString *movieNameForType(ORKConsentSectionType type, CGFloat scale) {
    
    NSString *fullMovieName = [NSString stringWithFormat:@"consent_%02ld", (long)type+1];
    fullMovieName = [NSString stringWithFormat:@"%@@%dx", fullMovieName, (int)scale];
    return fullMovieName;
}

NSURL *ORKMovieURLForConsentSectionType(ORKConsentSectionType type) {
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    // For iPad, use the movie for the next scale up
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && scale < 3) {
        scale++;
    }
    
    NSURL *url = [ORKAssetsBundle() URLForResource:movieNameForType(type, scale) withExtension:@"m4v"];
    if (url == nil) {
        // This can fail on 3x devices when the display is set to zoomed. Try an asset at 2x instead.
        url = [ORKAssetsBundle() URLForResource:movieNameForType(type, 2.0) withExtension:@"m4v"];
    }
    return url;
}

UIImage *ORKImageForConsentSectionType(ORKConsentSectionType type) {
    NSString *imageName = [NSString stringWithFormat:@"consent_%02ld", (long)type];
    return [[UIImage imageNamed:imageName inBundle:ORKBundle() compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}
