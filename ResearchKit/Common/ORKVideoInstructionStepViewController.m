/*
 Copyright (c) 2016, Oliver Schaefer.
 
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


#import "ORKVideoInstructionStepViewController.h"
#import "ORKInstructionStepViewController_Internal.h"
#import "AVFoundation/AVFoundation.h"
#import "AVKit/AVKit.h"
#import "ORKHelpers.h"


@implementation ORKVideoInstructionStepViewController

- (ORKVideoInstructionStep *)videoInstructionStep {
    return (ORKVideoInstructionStep *)self.step;
}

- (void)stepDidChange {
    [self setThumbnailImageFromAsset];
    [super stepDidChange];
    if (self.step && [self isViewLoaded] && [self videoInstructionStep].image) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
        [tapRecognizer addTarget:self action:@selector(play)];
        [self.stepView.instructionImageView addGestureRecognizer:tapRecognizer];
        
        if (self.stepView.instructionImageView.image) {
            UIImageView *playImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play" inBundle:ORKBundle() compatibleWithTraitCollection:nil]];
            self.stepView.instructionImageView.userInteractionEnabled = YES;
            [self.stepView.instructionImageView addSubview:playImageView];
            
            playImageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint* xConstraint = [NSLayoutConstraint constraintWithItem:self.stepView.instructionImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:playImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            NSLayoutConstraint* yConstraint = [NSLayoutConstraint constraintWithItem:self.stepView.instructionImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:playImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
            
            [self.stepView.instructionImageView addConstraints:@[xConstraint, yConstraint]];
        }
    }
}

- (void)setThumbnailImageFromAsset {
    if ([self videoInstructionStep].image) {
        return;
    }
    if (![self videoInstructionStep].videoURL) {
        self.videoInstructionStep.image = nil;
        return;
    }
    AVAsset* asset = [AVAsset assetWithURL:[self videoInstructionStep].videoURL];
    CMTime duration = [asset duration];
    duration.value = MIN([self videoInstructionStep].thumbnailTime, duration.value / duration.timescale) * duration.timescale;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    CGImageRef thumbnailImageRef = [imageGenerator copyCGImageAtTime:duration actualTime:NULL error:NULL];
    UIImage *thumbnailImage = [UIImage imageWithCGImage:thumbnailImageRef];
    CGImageRelease(thumbnailImageRef);
    [self videoInstructionStep].image = thumbnailImage;
}

- (void)play {
    AVAsset* asset = [AVAsset assetWithURL:[self videoInstructionStep].videoURL];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer* player = [AVPlayer playerWithPlayerItem:playerItem];
    player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = player;
    
    [self presentViewController:playerViewController animated:true completion:^{
        if (playerViewController.player.status == AVPlayerStatusReadyToPlay) {
            [playerViewController.player play];
        }
    }];
}

@end
