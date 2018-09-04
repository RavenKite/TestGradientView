//
//  KaraokeView.h
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/21.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KaraokeView : UIImageView

- (instancetype)initWithOriginImage:(UIImage *)image;

@property (nonatomic, strong) UIImage *originImage;



- (UIImage *)translatePixelColorByTargetNearBlackColorHex:(UInt32)nearBlackRGB
                                        nearWhiteColorHex:(UInt32)nearWhiteRGB
                                            transColorHex:(UInt32)transRGB
                                                   inRect:(CGRect)rect;

@end













