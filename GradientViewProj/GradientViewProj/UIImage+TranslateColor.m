//
//  UIImage+TranslateColor.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/8.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "UIImage+TranslateColor.h"

/**
 将传入的rect按照scale倍数进行缩放。
 注意：起点坐标也会跟随缩放
 
 @param rect 需要缩放的原始rect
 @param scale 缩放倍数，小于0时将返回CGRectZero
 @return 缩放后的rect
 */
CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat scale) {
    if (scale <= 0 ) { return CGRectZero; }
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}

// MARK: - UIColor+RGB

@implementation UIColor (RGB)

// MARK: - Public Method

- (UInt32)RGB {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    BOOL succ = [self getRed:&red green:&green blue:&blue alpha:nil];
    
    UInt32 r = round(red*255);
    UInt32 g = round(green*255);
    UInt32 b = round(blue*255);
    
    UInt32 result = (r << 16) + (g << 8) + b;
    return succ ? result : 0x000000;
}

- (UInt32)RGBA {
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    
    BOOL succ = [self getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UInt32 r = round(red*255);
    UInt32 g = round(green*255);
    UInt32 b = round(blue*255);
    UInt32 a = round(alpha*255);

    r = (r << 24);
    g = (g << 16);
    b = (b << 8);
    
    UInt32 rgba = r + g + b + a;
    return succ ? rgba : 0x00000000;
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

@end


// MARK: - UIImage+TranslateColor

@implementation UIImage (TranslateColor)

// MARK: - Public Method

+ (UIImage *)fullScreenshot {
    return [self imageWithView:[UIApplication sharedApplication].keyWindow];
}

+ (UIImage *)screenshotWithView:(UIView *)view {
    return [self imageWithView:view];
}

+ (UIImage *)screenshotWithView:(UIView *)view rect:(CGRect)rect {
    UIImage *image = [self imageWithView:view];
    
    CGRect scaleRect = CGRectScale(rect, [UIScreen mainScreen].scale);
    CGImageRef cgImage = CGImageCreateWithImageInRect(image.CGImage, scaleRect);
    
    UIImage *screenshotImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return screenshotImage;
}


- (UIImage *)translatePixelColorByTargetNearBlackColor:(UIColor *)nearBlackColor
                                        nearWhiteColor:(UIColor *)nearWhiteColor
                                            transColor:(UIColor *)transColor {
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    return [self translatePixelColorByTargetNearBlackColor:nearBlackColor nearWhiteColor:nearWhiteColor transColor:transColor inRect:rect];
}

- (UIImage *)translatePixelColorByTargetNearBlackColor:(UIColor *)nearBlackColor
                                        nearWhiteColor:(UIColor *)nearWhiteColor
                                            transColor:(UIColor *)transColor
                                                inRect:(CGRect)rect {
    // UIColor 转 RGBA
    UInt32 nearBlackRGBA = nearBlackColor.RGBA;
    UInt32 nearWhiteRGBA = nearWhiteColor.RGBA;
    UInt32 transRGBA = transColor.RGBA;

    return [self translatePixelColorByTargetNearBlackColorRGBA:nearBlackRGBA nearWhiteColorRGBA:nearWhiteRGBA transColorRGBA:transRGBA inRect:rect];
}


- (UIImage *)translatePixelColorByTargetNearBlackColorHex:(UInt32)nearBlackRGB
                                        nearWhiteColorHex:(UInt32)nearWhiteRGB
                                            transColorHex:(UInt32)transRGB {
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    return [self translatePixelColorByTargetNearBlackColorHex:nearBlackRGB nearWhiteColorHex:nearWhiteRGB transColorHex:transRGB inRect:rect];
}


- (UIImage *)translatePixelColorByTargetNearBlackColorHex:(UInt32)nearBlackRGB
                                        nearWhiteColorHex:(UInt32)nearWhiteRGB
                                            transColorHex:(UInt32)transRGB
                                                   inRect:(CGRect)rect {
    // RGB 转 RGBA
    UInt32 nearBlackRGBA = (nearBlackRGB << 8) + 0xFF;
    UInt32 nearWhiteRGBA = (nearWhiteRGB << 8) + 0xFF;
    UInt32 transRGBA = (transRGB << 8) + 0xFF;
    
    return [self translatePixelColorByTargetNearBlackColorRGBA:nearBlackRGBA nearWhiteColorRGBA:nearWhiteRGBA transColorRGBA:transRGBA inRect:rect];
}


- (UIImage *)translatePixelColorByTargetNearBlackColorRGBA:(UInt32)nearBlackRGBA
                                        nearWhiteColorRGBA:(UInt32)nearWhiteRGBA
                                            transColorRGBA:(UInt32)transRGBA
                                                   inRect:(CGRect)rect {
    CGRect canvas = CGRectMake(0, 0, self.size.width, self.size.height);
    if (!CGRectContainsRect(canvas, rect)) {
        if (CGRectIntersectsRect(canvas, rect)) {
            rect = CGRectIntersection(canvas, rect);    // 取交集
        } else {
            return self;
        }
    }
    
    UIImage *transImage = nil;
    
    int imageWidth = self.size.width;
    int imageHeight = self.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    
    // 遍历并修改像素
    uint32_t *pCurPtr = rgbImageBuf;
    pCurPtr += (long)(rect.origin.y*imageWidth);    // 将指针移动到初始行的起始位置
    
    // 空间复杂度：O(rect.size.width * rect.size.height)
    for (int i = rect.origin.y; i < CGRectGetMaxY(rect); i++) {                     // row
        pCurPtr += (long)rect.origin.x;             // 将指针移动到当前行的起始列
        
        for (int j = rect.origin.x; j < CGRectGetMaxX(rect); j++, pCurPtr++) {      // column
            if (*pCurPtr < nearBlackRGBA || *pCurPtr > nearWhiteRGBA) { continue; }
            
            // 将图片转成想要的颜色
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[3] = (transRGBA >> 24) & 0xFF;              // R
            ptr[2] = (transRGBA >> 16) & 0xFF;              // G
            ptr[1] = (transRGBA >> 8)  & 0xFF;              // B
        }
        
        pCurPtr += (long)(imageWidth - CGRectGetMaxX(rect));    // 将指针移动到下一行的起始列
    }
    
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, providerReleaseDataCallback);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    transImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return transImage ? : self;
}


- (UIColor *)pixelColorAtPoint:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.size.width, self.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.CGImage;
    NSUInteger width = self.size.width;
    NSUInteger height = self.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
//    NSLog(@"%f %f %f %f",(CGFloat)pixelData[0],(CGFloat)pixelData[1],(CGFloat)pixelData[2],(CGFloat)pixelData[3]);
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    return color;
}

// MARK: - Private Methods

void providerReleaseDataCallback (void *info, const void *data, size_t size) {
    free((void*)data);
}

+ (UIImage *)imageWithView:(UIView *)view {
    UIImage *image = [[UIImage alloc] init];
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size, true, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end





















