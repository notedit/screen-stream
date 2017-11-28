//
//  CVPixelBufferResize.h
//  dot-engine-ios-static-test
//
//  Created by xiang on 24/10/2017.
//  Copyright © 2017 dotEngine. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreImage;

@interface CVPixelBufferResize : NSObject

-(CVPixelBufferRef)processCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;
@end
