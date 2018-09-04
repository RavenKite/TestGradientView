//
//  PageContentViewController.h
//  GradientViewProj
//
//  Created by 李沛倬 on 2018/8/14.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (nonatomic, weak, readonly) UILabel *contentLabel;

@property (nonatomic, weak, readonly) UILabel *pageLabel;

@property (nonatomic, assign, readonly, getter=isVisible) BOOL visible;

@property (nonatomic, assign) NSUInteger index;


- (void)resetSubviewsContent;


@end
























