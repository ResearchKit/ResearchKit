/*
 Copyright (c) 2015, Rugen Heidbuchel All rights reserved.
 
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

#import "ORKShaderView.h"

@implementation ORKShaderView {
    
    CGSize _size;
    UIView *_overlayView;
    
    void *_cacheBitmap;
    CGContextRef _cacheContext, _savedCurrentContext;
    UIColor *_drawingColor;
    CGFloat _drawingLineWidth;
    BOOL _drawingEnabled;
    
    int _shadedPixels, _totalPixels;
}



#pragma mark - Init

- (instancetype)initWithSize:(CGSize)size overlayView:(UIView *)overlayView delegate:(id<ORKShaderViewDelegate>)delegate {
    
    self = [super initWithFrame:(CGRect){CGPointZero, size}];
    if (self) {
        
        _size = size;
        _overlayView = overlayView;
        
        self.delegate = delegate;
        
        _drawingEnabled = YES;
        _drawingLineWidth = 10.0;
        _drawingColor = [UIColor colorWithRed:55.0f/255.0f green:130.0f/255.0f blue:232.0f/255.0f alpha:1];
        
        if (![self initContext]) {
            //TODO: Handle error here
        }
        
        [self setupOverlayView];
    }
    return self;
}

- (void) setupOverlayView {
    
    if (_overlayView) {
        [self addSubview:_overlayView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(_overlayView);
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_overlayView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_overlayView]|" options:0 metrics:nil views:views]];
    }
}



#pragma mark - AutoLayout

- (CGSize)intrinsicContentSize {
    return _size;
}



#pragma mark - Drawing Code

- (BOOL) initContext{
    
    int bitmapByteCount, bitmapBytesPerRow;
    
    // Declare the number of bytes per row. Each pixel in the bitmap
    // is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (_size.width * 4);
    bitmapByteCount = (bitmapBytesPerRow * _size.height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    _cacheBitmap = malloc(bitmapByteCount);
    if (_cacheBitmap == NULL){
        return NO;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _cacheContext = CGBitmapContextCreate (_cacheBitmap, _size.width, _size.height, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetShouldAntialias(_cacheContext, NO);
    
    CGRect drawRect = (CGRect){CGPointZero, _size};
    
    CGContextSetRGBFillColor(_cacheContext, 200.0f/255.0f, 200.0f/255.0f, 200.0f/255.0f, 1);
    CGContextFillRect(_cacheContext, drawRect);
    
    return YES;
}

- (void) drawRect:(CGRect)rect {
    
//    [self setContentScaleFactor:1.0];
    
    _savedCurrentContext = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(_savedCurrentContext, self.bounds);
    
    CGImageRef cacheImage = CGBitmapContextCreateImage(_cacheContext);
    CGContextDrawImage(_savedCurrentContext, self.bounds, cacheImage);
    CGImageRelease(cacheImage);
}

- (void) drawToCache:(UITouch*)touch {
    
    CGContextSetStrokeColorWithColor(_cacheContext, [_drawingColor CGColor]);
    CGContextSetLineCap(_cacheContext, kCGLineCapRound);
    
    // Line Width
    CGContextSetLineWidth(_cacheContext, _drawingLineWidth);
    
    CGPoint lastPoint = [touch previousLocationInView:self];
    CGPoint newPoint = [touch locationInView:self];
    
    CGContextMoveToPoint(_cacheContext, lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(_cacheContext, newPoint.x, newPoint.y);
    CGContextStrokePath(_cacheContext);
    
    [self setNeedsDisplay];
}

- (void)calculateDrawingPercentage:(CGContextRef)ctx {
    
    CGImageRef workingImage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:workingImage];
    
//    [self.questionnaireController updateImage:[UIImage imageWithCGImage:workingImage]];
    
    NSUInteger width = CGImageGetWidth(workingImage);
    NSUInteger height = CGImageGetHeight(workingImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), workingImage);
    CGImageRelease(workingImage);
    
    UIImage *colorManImage = [UIImage imageNamed:@"ColorMan.png"];
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), colorManImage.CGImage);
    
    CGContextRelease(context);
    
    
    _shadedPixels = 0;
    _totalPixels = 0;
    
    int byteIndex = 0;
    for (int i = 0 ; i < width * height ; ++i)
    {
        if ((rawData[byteIndex] >= 52 && rawData[byteIndex] <= 58) && (rawData[byteIndex + 1] >= 127 && rawData[byteIndex + 1] <= 133) && (rawData[byteIndex + 2] >= 229 && rawData[byteIndex + 2] <= 235)) {
            
            _shadedPixels++;
            _totalPixels++;
            //NSLog(@"R:%i G:%i B:%i", rawData[byteIndex], rawData[byteIndex+1], rawData[byteIndex+2]);
        }
        
        if ((rawData[byteIndex] >= 197 && rawData[byteIndex] <= 203) && (rawData[byteIndex + 1] >= 197 && rawData[byteIndex + 1] <= 203) && (rawData[byteIndex + 2] >= 197 && rawData[byteIndex + 2] <= 203)) {
            
            _totalPixels++;
        }
        
        byteIndex += 4;
    }
    
    NSLog(@"%i / %i", _shadedPixels, _totalPixels);
    
    if ([self.delegate respondsToSelector:@selector(shaderView:drawingImageChangedTo:withNumberOfShadedPixels:onTotalNumberOnPixels:)]) {
        [self.delegate shaderView:self drawingImageChangedTo:image withNumberOfShadedPixels:_shadedPixels onTotalNumberOnPixels:_totalPixels];
    }
    
    free(rawData);
}



#pragma mark - Touches

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_drawingEnabled) {
        UITouch *touch = [touches anyObject];
        [self drawToCache:touch];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self calculateDrawingPercentage:_savedCurrentContext];
}

@end
