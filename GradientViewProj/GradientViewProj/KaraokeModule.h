//
//  KaraokeModule.h
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/21.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KaraokeModel;

@interface KaraokeModule : NSObject

@property (nonatomic, strong) UIImage *originImage;

@property (nonatomic, assign) CGRect rect;

@property (nonatomic, strong) NSArray<KaraokeModel *> *dataSource;

/** 在调用configurationImage: inRect: dataSource: 方法之后，将会生成该对象，可将其addSubview到指定的view上 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, copy) void(^karaokeDidEnd)(void);

- (instancetype)init;

- (instancetype)initWithOriginImage:(UIImage *)image inRect:(CGRect)rect dataSource:(NSArray<KaraokeModel *> *)dataSource;

- (void)configurationImage:(UIImage *)image inRect:(CGRect)rect dataSource:(NSArray<KaraokeModel *> *)dataSource;

- (void)beginKaraokeAnimation;

@end





@interface KaraokeModel : NSObject

@property (nonatomic, copy) NSString *content;

@property (nonatomic, assign) CGFloat begin;

@property (nonatomic, assign) CGFloat end;

@property (nonatomic, assign) CGFloat x;

@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;


@end
