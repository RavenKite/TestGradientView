//
//  UIImage+TranslateColor.h
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/8.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGB)

/** 获取颜色的RGB色值。形如: 0xFFAABB */
- (UInt32)RGB;

/** 获取颜色的RGBA色值。形如: 0xFFAABBFF */
- (UInt32)RGBA;

/** 用RGB色值（形如：0xFFAABB）创建一个UIColor实例 */
+ (UIColor *)colorWithRGBHex:(UInt32)hex;

@end


@interface UIImage (TranslateColor)

/**
 全屏截图
 
 @return 全屏截图
 */
+ (UIImage *)fullScreenshot;

/**
 截取指定视图
 
 @param view 截取视图
 @return return value description
 */
+ (UIImage *)screenshotWithView:(UIView *)view;

/**
 截取指定视图的指定范围
 
 @param view 截取视图
 @param rect 截取范围
 @return return value description
 */
+ (UIImage *)screenshotWithView:(UIView *)view rect:(CGRect)rect;


/** 获取图片上指定位置的颜色 */
- (UIColor *)pixelColorAtPoint:(CGPoint)point;



/**
 改变图片颜色。方法会将图片指定rect中【nearBlackColor <= pixelColor <= nearWhiteColor】的颜色替换为【transColor】的颜色

 @param nearBlackColor 靠近纯黑色的UIColor实例
 @param nearWhiteColor 靠近纯白色的UIColor实例
 @param transColor 改变后的颜色
 @param rect 需要被改变的区域。不包含此参数的方法默认为整张图片区域
 @return 改变颜色后的图片
 */
- (UIImage *)translatePixelColorByTargetNearBlackColor:(UIColor *)nearBlackColor
                                        nearWhiteColor:(UIColor *)nearWhiteColor
                                            transColor:(UIColor *)transColor
                                                inRect:(CGRect)rect;

- (UIImage *)translatePixelColorByTargetNearBlackColor:(UIColor *)nearBlackColor
                                        nearWhiteColor:(UIColor *)nearWhiteColor
                                            transColor:(UIColor *)transColor;

/**
 改变图片颜色。参数中的颜色均为RGB色值，形如：0xAAAAAA。方法会将图片指定rect中【nearBlackRGB <= pixelColor <= nearWhiteRGB】的颜色替换为【transRGB】的颜色

 @param nearBlackRGB 靠近黑色（0x000000）的色值
 @param nearWhiteRGB 靠近白色（0xFFFFFF）的色值
 @param transRGB 改变后的色值
 @param rect 需要被改变的区域。不包含此参数的方法默认为整张图片区域
 @return 改变颜色后的图片
 */
- (UIImage *)translatePixelColorByTargetNearBlackColorHex:(UInt32)nearBlackRGB
                                        nearWhiteColorHex:(UInt32)nearWhiteRGB
                                            transColorHex:(UInt32)transRGB
                                                   inRect:(CGRect)rect;

- (UIImage *)translatePixelColorByTargetNearBlackColorHex:(UInt32)nearBlackRGB
                                        nearWhiteColorHex:(UInt32)nearWhiteRGB
                                            transColorHex:(UInt32)transRGB;



@end
























