//
//  PreventsCaptureImageView.m
//  MyApp
//
//  Created by Jinwoo Kim on 12/9/24.
//

#import "PreventsCaptureImageView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <Metal/Metal.h>

@interface PreventsCaptureImageView ()
@property (strong, nonatomic, readonly) CIContext *_ciContext;
@end

@implementation PreventsCaptureImageView

+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (BOOL)preventsCapture {
    return ((AVSampleBufferDisplayLayer *)self.layer).preventsCapture;
}

- (void)setPreventsCapture:(BOOL)preventsCapture {
    ((AVSampleBufferDisplayLayer *)self.layer).preventsCapture = preventsCapture;
}

- (UIImage *)image {
    CVPixelBufferRef pixelBuffer = [((AVSampleBufferDisplayLayer *)self.layer).sampleBufferRenderer copyDisplayedPixelBuffer];
    if (pixelBuffer == NULL) return nil;
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CVPixelBufferRelease(pixelBuffer);
    
    return [[UIImage alloc] initWithCIImage:ciImage];
}

- (void)setImage:(UIImage *)image {
    CIImage *ciImage = image.CIImage;
    if (ciImage == nil) {
        assert(image.CGImage != NULL);
        ciImage = [[CIImage alloc] initWithCGImage:image.CGImage];
    }
    assert(ciImage != nil);
    
    //
    
    NSDictionary *pixelBufferAttributes = @{
        (id)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES
    };
    CVPixelBufferRef pixelBuffer;
    assert(CVPixelBufferCreate(kCFAllocatorDefault, CGRectGetWidth(ciImage.extent), CGRectGetHeight(ciImage.extent), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelBufferAttributes, &pixelBuffer) == kCVReturnSuccess);
    
    //
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    [self._ciContext render:ciImage toCVPixelBuffer:pixelBuffer bounds:ciImage.extent colorSpace:ciImage.colorSpace];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CMVideoFormatDescriptionRef desc;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &desc);
    
    CMSampleTimingInfo timing = {
        .duration = kCMTimeZero,
        .presentationTimeStamp = kCMTimeZero,
        .decodeTimeStamp = kCMTimeInvalid
    };
    CMSampleBufferRef sampleBuffer;
    assert(CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, desc, &timing, &sampleBuffer) == kCVReturnSuccess);
    CVPixelBufferRelease(pixelBuffer);
    CFRelease(desc);
    
    [((AVSampleBufferDisplayLayer *)self.layer).sampleBufferRenderer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

- (void)_commonInit {
    __ciContext = [CIContext contextWithMTLDevice:MTLCreateSystemDefaultDevice()];
    ((AVSampleBufferDisplayLayer *)self.layer).preventsCapture = YES;
}

@end
