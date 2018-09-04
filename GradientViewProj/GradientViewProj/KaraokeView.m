//
//  KaraokeView.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/21.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "KaraokeView.h"

@interface KaraokeView()

@property (nonatomic, assign) uint32_t *rgbImageBuf;

@property (nonatomic, assign) CGColorSpaceRef colorSpace;

@property (nonatomic, assign) CGContextRef context;

@property (nonatomic, assign) CGDataProviderRef dataProvider;

@end



@implementation KaraokeView

- (instancetype)initWithOriginImage:(UIImage *)image {
    if (self = [super initWithImage:image]) {
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.originImage = image;
    }
    
    return self;
}



- (void)setOriginImage:(UIImage *)originImage {
    if (_originImage != originImage) {
        _originImage = originImage;
        
        // 清理空间
        CGDataProviderRelease(self.dataProvider);
        CGContextRelease(self.context);
        CGColorSpaceRelease(self.colorSpace);
        self.dataProvider = NULL;
        self.colorSpace = NULL;
        self.context = NULL;

        int imageWidth = originImage.size.width;
        int imageHeight = originImage.size.height;
        
        size_t bytesPerRow = imageWidth * 4;
        uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
        CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), originImage.CGImage);

        
        self.rgbImageBuf = rgbImageBuf;
        self.colorSpace = colorSpace;
        self.context = context;
    }
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
    CGRect canvas = CGRectMake(0, 0, self.originImage.size.width, self.originImage.size.height);
    if (!CGRectContainsRect(canvas, rect)) {
        if (CGRectIntersectsRect(canvas, rect)) {
            rect = CGRectIntersection(canvas, rect);    // 取交集
        } else {
            return self.originImage;
        }
    }
    
    UIImage *transImage = nil;
    
    int imageWidth = self.originImage.size.width;
    int imageHeight = self.originImage.size.height;
    size_t bytesPerRow = imageWidth * 4;
    
    // 遍历并修改像素
    uint32_t *pCurPtr = self.rgbImageBuf;
    pCurPtr += (long)(rect.origin.y*imageWidth);    // 将指针移动到初始行的起始位置
    
    // 遍历次数：rect.size.width * rect.size.height
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
        
        pCurPtr += (long)(imageWidth - CGRectGetMaxX(rect));    // 将指针移动到当前行的末尾列
    }
    
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, self.rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData1);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, self.colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    transImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    
    self.dataProvider = dataProvider;
    return transImage;
}


void ProviderReleaseData1 (void *info, const void *data, size_t size) {
    free((void*)data);
}




@end


























