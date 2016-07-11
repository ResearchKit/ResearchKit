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


#import "ORKEAGLMoviePlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVUtilities.h>
#import <mach/mach_time.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ORKHelpers.h"


// Uniform index.
enum {
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_ROTATION_ANGLE,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    UNIFORM_TINT_COLOR,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)

// BT.601, which is the standard for SDTV.
static const GLfloat ColorConversion601[] = {
    1.164,  1.164, 1.164,
      0.0, -0.392, 2.017,
    1.596, -0.813,   0.0,
};

// BT.709, which is the standard for HDTV.
static const GLfloat ColorConversion709[] = {
    1.164,  1.164, 1.164,
      0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

#if defined(DEBUG)
    void ORKCheckForGLError()
    {
        GLenum error = glGetError();
        if (error != GL_NO_ERROR)
        {
            ORK_Log_Error(@"glError: 0x%04X", error);
        }
    }
#else
    #define ORKCheckForGLError(...)
#endif

#define ORKEAGLLog(...)

@interface ORKEAGLMoviePlayerView () {
    // The pixel dimensions of the CAEAGLLayer.
    GLint _backingWidth;
    GLint _backingHeight;
    
    EAGLContext *_context;
    NSMutableArray *_contextStack;
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;

    GLuint _programHandle;
    GLuint _vertexArrayHandle;
    GLuint _vertexBufferHandle;
    GLuint _frameBufferHandle;
    GLuint _colorBufferHandle;
    
    BOOL _glIsSetup;
}

@property (nonatomic) const GLfloat *preferredConversion;

- (void)setupBuffers;
- (void)cleanUpTextures;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end


@implementation ORKEAGLMoviePlayerView

const GLfloat DefaultPreferredRotation = 0;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Use 2x scale factor on Retina displays.
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Get and configure the layer.
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @YES,
                                          kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
        
        // Set the context into which the frames will be drawn.
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!_context || ![self loadShaders]) {
            return nil;
        }
        
        _preferredConversion = NULL;
    }
    return self;
}

# pragma mark - OpenGL setup

- (void)setupGL {
    if (_glIsSetup) {
        return;
    }
    _glIsSetup = YES;

    [self saveGLContext];
    
    glDisable(GL_DEPTH_TEST);
    [self setupBuffers];
    
    glUseProgram(_programHandle);
    
    // 0 and 1 are the texture IDs of _lumaTexture and _chromaTexture respectively.
    glUniform1i(uniforms[UNIFORM_Y], 0);
    glUniform1i(uniforms[UNIFORM_UV], 1);
    [self updateTintColorUniform];
    glUniform1f(uniforms[UNIFORM_ROTATION_ANGLE], DefaultPreferredRotation);
    // Set the default conversion to BT.709, which is the standard for HDTV.
    _preferredConversion = ColorConversion709;
    [self updatePreferredConversionUniform];
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    
    // Create CVOpenGLESTextureCacheRef for optimal CVPixelBufferRef to GLES texture conversion.
    if (!_videoTextureCache) {
        CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
        if (error != noErr) {
            ORK_Log_Error(@"Error at CVOpenGLESTextureCacheCreate %d", error);
            return;
        }
    }
    
    glGenVertexArraysOES(1, &_vertexArrayHandle);
    glGenBuffers(1, &_vertexBufferHandle);

    [self restoreGLContext];
    ORKEAGLLog(@"");
}

#pragma mark - Utilities

- (void)setupBuffers {
    if (!_glIsSetup) {
        return;
    }
    
    [self saveGLContext];
    
    [self deleteBuffers];
    
    glGenFramebuffers(1, &_frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    glGenRenderbuffers(1, &_colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBufferHandle);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        ORK_Log_Error(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
    
    // Set the view port to the entire view.
    glViewport(0, 0, _backingWidth, _backingHeight);

    [self restoreGLContext];
    ORKEAGLLog(@"");
}

- (void)deleteBuffers {
    [self saveGLContext];
    
    if (_frameBufferHandle) {
        glDeleteFramebuffers(1, &_frameBufferHandle);
        _frameBufferHandle = 0;
    }
    if (_colorBufferHandle) {
        glDeleteRenderbuffers(1, &_colorBufferHandle);
        _colorBufferHandle = 0;
    }
    
    [self restoreGLContext];
}

- (void)cleanUpTextures {
    [self saveGLContext];
    
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    [self restoreGLContext];
}

- (BOOL)saveGLContext {
    BOOL success = YES;
    
    if (_contextStack == nil) {
        _contextStack = [NSMutableArray new];
    }
    
    EAGLContext *currentContext = [EAGLContext currentContext];
    
    // Switch context only when necessary
    if (_context != currentContext) {
        glFlush();
        success = [EAGLContext setCurrentContext:_context];
    }
    
    // Always push
    [_contextStack addObject:currentContext ? : [NSNull null]];

    return success;
}

- (BOOL)restoreGLContext {
    BOOL success = YES;
    
    id lastObject = [_contextStack lastObject];
    
    if (lastObject) {
        EAGLContext *contextToBeRestored = (lastObject != [NSNull null]) ? lastObject : nil;
        
        // Switch context only when necessary
        if (_context != contextToBeRestored) {
            glFlush();
            success = [EAGLContext setCurrentContext:contextToBeRestored];
        }
    }
    
    // Always pop
    [_contextStack removeLastObject];
    
    return success;
}

- (void)dealloc {
    ORKEAGLLog(@"");
    
    [self saveGLContext];
    
    [self cleanUpTextures];
    
    if (_videoTextureCache) {
        CFRelease(_videoTextureCache);
    }
    [self deleteBuffers];
    if (_programHandle) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    [self restoreGLContext];
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    [self updateVertexAndTextureData];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self updateTintColorUniform];
}

- (void)setPreferredConversion:(const GLfloat *)preferredConversion {
    if (_preferredConversion != preferredConversion) {
        _preferredConversion = preferredConversion;
        [self updatePreferredConversionUniform];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupBuffers];
    [self updateVertexAndTextureData];
}

#pragma mark - OpenGLES drawing

- (BOOL)consumePixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!_glIsSetup) {
        return NO;
    }

    CVReturn error;
    if (pixelBuffer != NULL) {
        ORKEAGLLog(@"Have buffer");

        if (!_videoTextureCache) {
            ORK_Log_Error(@"No video texture cache");
            return NO;
        }
        
        [self saveGLContext];
        
        [self cleanUpTextures];
        
        /*
         Use the color attachment of the pixel buffer to determine the appropriate color conversion matrix.
         */
        CFTypeRef colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
        
        if (colorAttachments == kCVImageBufferYCbCrMatrix_ITU_R_601_4) {
            self.preferredConversion = ColorConversion601;
        } else {
            self.preferredConversion = ColorConversion709;
        }
        
        /*
         CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture optimally from CVPixelBufferRef.
         */
        
        /*
         Create Y and UV textures from the pixel buffer. These textures will be drawn on the frame buffer Y-plane.
         */
        error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RED_EXT,
                                                           (GLint)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0),
                                                           (GLint)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0),
                                                           GL_RED_EXT,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &_lumaTexture);
        if (0 == error) {
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            // UV-plane.
            error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               _videoTextureCache,
                                                               pixelBuffer,
                                                               NULL,
                                                               GL_TEXTURE_2D,
                                                               GL_RG_EXT,
                                                               (GLint)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1),
                                                               (GLint)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1),
                                                               GL_RG_EXT,
                                                               GL_UNSIGNED_BYTE,
                                                               1,
                                                               &_chromaTexture);
            
             if (0 == error) {
                 glActiveTexture(GL_TEXTURE1);
                 glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
                 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                 glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                 glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
             }
        }
        
        [self restoreGLContext];
        
        if (error) {
            ORK_Log_Error(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", error);
            return NO;
        }
        
        return YES;
    }
    return NO;
}

- (void)updateVertexAndTextureData {
    if (!_glIsSetup) {
        return;
    }

    // Set up the quad vertices with respect to the orientation and aspect ratio of the video.
    CGRect vertexSamplingRect = AVMakeRectWithAspectRatioInsideRect(_presentationSize, self.layer.bounds);
    ORKEAGLLog(@"%@", NSStringFromCGRect(vertexSamplingRect));
    
    // Compute normalized quad coordinates to draw the frame into.
    CGSize normalizedSamplingSize = CGSizeMake(0.0, 0.0);
    CGSize cropScaleAmount = CGSizeMake(vertexSamplingRect.size.width/self.layer.bounds.size.width, vertexSamplingRect.size.height/self.layer.bounds.size.height);
    
    // Normalize the quad vertices.
    if (cropScaleAmount.width > cropScaleAmount.height) {
        normalizedSamplingSize.width = 1.0;
        normalizedSamplingSize.height = cropScaleAmount.height/cropScaleAmount.width;
    } else {
        normalizedSamplingSize.height = 1.0;
        normalizedSamplingSize.width = cropScaleAmount.width/cropScaleAmount.height;
    }
    
    /*
     The quad vertex data defines the region of 2D plane onto which we draw our pixel buffers.
     Vertex data formed using (-1,-1) and (1,1) as the bottom left and top right coordinates respectively, covers the entire screen.
     
     The texture vertices are set up such that we flip the texture vertically. This is so that our top left origin buffers match OpenGL's bottom left texture coordinate system.
     */
    CGRect textureSamplingRect = CGRectMake(0, 0, 1, 1);
    
    GLfloat quadVertexAndTextureData[] =  {
        // Vertex
        -1 * normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        normalizedSamplingSize.width, -1 * normalizedSamplingSize.height,
        -1 * normalizedSamplingSize.width, normalizedSamplingSize.height,
        normalizedSamplingSize.width, normalizedSamplingSize.height,
        // Texture
        CGRectGetMinX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMaxY(textureSamplingRect),
        CGRectGetMinX(textureSamplingRect), CGRectGetMinY(textureSamplingRect),
        CGRectGetMaxX(textureSamplingRect), CGRectGetMinY(textureSamplingRect)
    };
    
    [self saveGLContext];
    
    glBindVertexArrayOES(_vertexArrayHandle);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferHandle);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertexAndTextureData), quadVertexAndTextureData, GL_STATIC_DRAW);
    
    // Set the position
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glEnableVertexAttribArray(ATTRIB_TEXCOORD);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 0, (void *)(8 * sizeof(GLfloat)));
    
    [self restoreGLContext];
}

- (void)updateTintColorUniform {
    if (!_glIsSetup) {
        return;
    }

    [self saveGLContext];
    
    CGFloat tintColorCG[4];
    [self.tintColor getRed:&tintColorCG[0] green:&tintColorCG[1] blue:&tintColorCG[2] alpha:&tintColorCG[3]];
    glUniform3f(uniforms[UNIFORM_TINT_COLOR], tintColorCG[0], tintColorCG[1], tintColorCG[2]);
    
    [self restoreGLContext];
}

- (void)updatePreferredConversionUniform {
    if (!_glIsSetup) {
        return;
    }
    [self saveGLContext];
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, _preferredConversion);
    [self restoreGLContext];
}

- (void)render {
    if (!_glIsSetup) {
        return;
    }
    
    [self saveGLContext];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandle);
    
    // Use the shader program and bin the VAO.
    glUseProgram(_programHandle);
    glBindVertexArrayOES(_vertexArrayHandle);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferHandle);
    if (![_context presentRenderbuffer:GL_RENDERBUFFER]) {
        ORK_Log_Error(@"presentRenderBuffer failed");
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
    glBindVertexArrayOES(0);
    glUseProgram(0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    [self restoreGLContext];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders {
    
    [self saveGLContext];
    
    GLuint vertShader, fragShader;
    NSURL *vertShaderURL, *fragShaderURL;
    
    // Create the shader program.
    _programHandle = glCreateProgram();
    
    [self restoreGLContext];
    
    // Create and compile the vertex shader.
    vertShaderURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"MovieTintShader" withExtension:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER URL:vertShaderURL]) {
        ORK_Log_Error(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"MovieTintShader" withExtension:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER URL:fragShaderURL]) {
        ORK_Log_Error(@"Failed to compile fragment shader");
        return NO;
    }
    
    [self saveGLContext];
    
    // Attach vertex shader to program.
    glAttachShader(_programHandle, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_programHandle, fragShader);
    
    // Bind attribute locations. This needs to be done prior to linking.
    glBindAttribLocation(_programHandle, ATTRIB_VERTEX, "position");
    glBindAttribLocation(_programHandle, ATTRIB_TEXCOORD, "texCoord");
    
    // Link the program.
    if (![self linkProgram:_programHandle]) {
        ORK_Log_Error(@"Failed to link program: %d", _programHandle);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programHandle) {
            glDeleteProgram(_programHandle);
            _programHandle = 0;
        }
        [self restoreGLContext];
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_Y] = glGetUniformLocation(_programHandle, "SamplerY");
    uniforms[UNIFORM_UV] = glGetUniformLocation(_programHandle, "SamplerUV");
    uniforms[UNIFORM_ROTATION_ANGLE] = glGetUniformLocation(_programHandle, "preferredRotation");
    uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = glGetUniformLocation(_programHandle, "colorConversionMatrix");
    uniforms[UNIFORM_TINT_COLOR] = glGetUniformLocation(_programHandle, "tintColor");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_programHandle, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_programHandle, fragShader);
        glDeleteShader(fragShader);
    }
    
    [self restoreGLContext];
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type URL:(NSURL *)URL {
    NSError *error;
    NSString *sourceString = [[NSString alloc] initWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
    if (sourceString == nil) {
        ORK_Log_Error(@"Failed to load vertex shader: %@", [error localizedDescription]);
        return NO;
    }
    
    [self saveGLContext];
    
    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        ORK_Log_Debug(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        [self restoreGLContext];
        glDeleteShader(*shader);
        return NO;
    }
    
    [self restoreGLContext];
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog {
    [self saveGLContext];
    
    GLint status;
    glLinkProgram(prog);
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        ORK_Log_Debug(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    [self restoreGLContext];
    
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog {
    [self saveGLContext];
    
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        ORK_Log_Debug(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    
    [self restoreGLContext];
    
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
