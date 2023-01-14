/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
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


#import "ORKDevice.h"
#import "ORKHelpers_Internal.h"

#import <UIKit/UIDevice.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <errno.h>
#import <string.h>

#if !TARGET_OS_SIMULATOR
#ifndef ORK_SYS_CTL_DEBUG
#define ORK_SYST_CTL_DEBUG(t,s) ORK_SYSCTL_DEBUG_STRING(t, s)
#endif
static NSString * ORK_SYSCTL_DEBUG_STRING(int tl, int sl);

static NSString * ORK_SYSCTL(int tl, int sl) {

    ORK_Log_Info("Fetching %@", ORK_SYST_CTL_DEBUG(tl, sl));
    
    int mib[] = { tl, sl };
    size_t size;

    sysctl(mib, 2, NULL, &size, NULL, 0);

    char *cStr = malloc(size);

    int kErr = sysctl(mib, 2, cStr, &size, NULL, 0);
    
    if (kErr != KERN_SUCCESS || cStr == NULL) {
        
        ORK_Log_Error("ORKDevice encountered an error fetching %@. %s", ORK_SYST_CTL_DEBUG(tl, sl), strerror(errno));
        
        free(cStr);
        
        return nil;
    }

    NSString *str = [NSString stringWithCString:cStr encoding:NSASCIIStringEncoding];

    free(cStr);

    return [str copy];
}

static NSString * ORK_SYSCTL_DEBUG_STRING(int tl, int sl) {
    
    struct ctlname ctl_name[] = CTL_NAMES;
    char *tlaC = ctl_name[tl].ctl_name;
    NSString *tla = [NSString stringWithCString:tlaC encoding:NSASCIIStringEncoding];
    NSString *sla;
    
    switch (tl) {
        case CTL_HW:
        {
            struct ctlname ctl_hw_name[] = CTL_HW_NAMES;
            char *slaC = ctl_hw_name[sl].ctl_name;
            sla = [NSString stringWithCString:slaC encoding:NSASCIIStringEncoding];
            break;
        }
            
        case CTL_KERN:
        {
            struct ctlname ctl_kern_name[] = CTL_KERN_NAMES;
            char *slaC = ctl_kern_name[sl].ctl_name;
            sla = [NSString stringWithCString:slaC encoding:NSASCIIStringEncoding];
            break;
        }
        default:
            // Not supported
            return nil;
    }
    
    return [NSString stringWithFormat:@"%@.%@", tla, sla];
}

#endif

@implementation ORKDevice

+ (instancetype)currentDevice {
    return [[ORKDevice alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self->_product = [self _product];
    self->_osBuild = [self _osBuild];
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    self->_platform = [[UIDevice currentDevice] systemName];
    self->_osVersion = [NSString stringWithFormat:@"%ld.%ld.%ld", (long)version.majorVersion, (long)version.minorVersion, (long)version.patchVersion];
}

- (instancetype)initWithProduct:(NSString *)product
                      osVersion:(NSString *)osVersion
                        osBuild:(NSString *)osBuild
                       platform:(NSString *)platform
{
    self = [super init];
    if (self) {
        self->_product = [product copy];
        self->_osVersion = [osVersion copy];
        self->_osBuild = [osBuild copy];
        self->_platform = [platform copy];
    }
    return self;
}

- (nullable NSString *)_product {
#if !TARGET_OS_SIMULATOR
    return ORK_SYSCTL(CTL_HW, HW_PRODUCT);
#else
    return nil;
#endif
}

- (nullable NSString *)_osBuild {
#if !TARGET_OS_SIMULATOR
    return ORK_SYSCTL(CTL_KERN, KERN_OSVERSION);
#else
    return nil;
#endif
}

#pragma mark - NSObjectProtocol

- (BOOL)isEqual:(id)object {
    __typeof(self) castObject = object;
    return (ORKEqualObjects(self.product, castObject.product) &&
            ORKEqualObjects(self.platform, castObject.platform) &&
            ORKEqualObjects(self.osBuild, castObject.osBuild) &&
            ORKEqualObjects(self.osVersion, castObject.osVersion));
}

- (NSUInteger)hash {
    return super.hash ^ self.product.hash ^ self.platform.hash ^ self.osBuild.hash ^ self.osVersion.hash;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    ORK_ENCODE_OBJ(coder, product);
    ORK_ENCODE_OBJ(coder, platform);
    ORK_ENCODE_OBJ(coder, osBuild);
    ORK_ENCODE_OBJ(coder, osVersion);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        ORK_DECODE_OBJ_CLASS(coder, product, NSString);
        ORK_DECODE_OBJ_CLASS(coder, platform, NSString);
        ORK_DECODE_OBJ_CLASS(coder, osBuild, NSString);
        ORK_DECODE_OBJ_CLASS(coder, osVersion, NSString);
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end
