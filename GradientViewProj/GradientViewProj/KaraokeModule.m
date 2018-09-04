//
//  KaraokeModule.m
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/21.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import "KaraokeModule.h"
#import "KaraokeView.h"

@interface KaraokeModule()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) uint32_t *rgbImageBuf;

@property (nonatomic, assign) CGColorSpaceRef colorSpace;

@property (nonatomic, assign) CGContextRef context;

@property (nonatomic, assign) CGDataProviderRef dataProvider;


@end



@implementation KaraokeModule

// MARK: - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithOriginImage:(UIImage *)image inRect:(CGRect)rect dataSource:(NSArray<KaraokeModel *> *)dataSource {
    if (self = [super init]) {
        [self configurationImage:image inRect:rect dataSource:dataSource];
    }
    
    return self;
}



// MARK: - Public Method

- (void)configurationImage:(UIImage *)image inRect:(CGRect)rect dataSource:(NSArray<KaraokeModel *> *)dataSource {
    self.originImage = image;
    self.rect = rect;
    self.dataSource = dataSource;
    
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = image;
    
    [self initImageContext];
}


- (void)beginKaraokeAnimation {
    KaraokeModel *model = self.dataSource[self.currentIndex];
    
    [self beginTimerWithInvalidateDelay:model.end - model.begin];
}



// MARK: - Private Method

- (void)initImageContext {
    
    int imageWidth = self.originImage.size.width;       // 图片宽度（像素取整）
    int imageHeight = self.originImage.size.height;     // 图片高度（像素取整）
    
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();         // 创建色彩空间
    // 创建位图画布
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    // 将图片铺在画布上
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.originImage.CGImage);
    
    // 持有相关对象
    self.rgbImageBuf = rgbImageBuf;
    self.colorSpace = colorSpace;
    self.context = context;
}

- (void)releaseImageContext {
    self.currentIndex = 0;

    // 释放空间
    CGDataProviderRelease(self.dataProvider);
    CGContextRelease(self.context);
    CGColorSpaceRelease(self.colorSpace);
    
    self.dataProvider = NULL;
    self.colorSpace = NULL;
    self.context = NULL;
}


- (void)beginTimerWithInvalidateDelay:(NSTimeInterval)delay {   // GCD定时器
    __block NSTimeInterval cancel = delay;
    NSTimeInterval timeInterval = 0.1;
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, NSEC_PER_MSEC * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        cancel -= timeInterval;
        
        [self translateColorWithProgress:1-cancel/delay];
        
        if (cancel <= 0) {
            dispatch_source_cancel(timer);
        }
    });
    dispatch_resume(timer);
    
    self.timer = timer;
}

- (void)translateColorWithProgress:(CGFloat)progress {
    if (progress > 1) {
        self.currentIndex++;
        
        if (self.currentIndex >= self.dataSource.count) {
            [self releaseImageContext];
            
            if (self.karaokeDidEnd) { self.karaokeDidEnd(); }
            
        } else {
            [self beginKaraokeAnimation];
        }
        return;
    }
    
    UIImage *image = self.imageView.image;
    
    KaraokeModel *model = self.dataSource[self.currentIndex];
    CGRect targetRect = CGRectMake(image.size.width*model.x, image.size.height*model.y, image.size.width*model.width*progress, image.size.height*model.height);
    
    // 使用RGB色值
    image = [self translatePixelColorByTargetNearBlackColorHex:0x000000 nearWhiteColorHex:0x626262 transColorHex:0xFF0000 inRect:targetRect];
    
    self.imageView.image = image;
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
    CGRect canvas = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    if (!CGRectContainsRect(canvas, rect)) {
        if (CGRectIntersectsRect(canvas, rect)) {
            rect = CGRectIntersection(canvas, rect);    // 取交集
        } else {
            return self.imageView.image;
        }
    }
    
    UIImage *transImage = nil;
    
    int imageWidth = self.imageView.image.size.width;
    int imageHeight = self.imageView.image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    
    // 遍历并修改像素
    uint32_t *pCurPtr = self.rgbImageBuf;
    pCurPtr += (long)((long)rect.origin.y*imageWidth);    // 将指针移动到初始行的起始位置
    
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
        
        pCurPtr += (long)(imageWidth - CGRectGetMaxX(rect));    // 将指针移动到下一行的起始列
    }
    
    
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, self.rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData2);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, self.colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    transImage = [UIImage imageWithCGImage:imageRef];
    
    // 清理空间
    CGImageRelease(imageRef);
    
    self.dataProvider = dataProvider;
    return transImage;
}


void ProviderReleaseData2 (void *info, const void *data, size_t size) {
    free((void*)data);
}



@end







@implementation KaraokeModel


@end





















